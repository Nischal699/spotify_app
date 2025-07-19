import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:web_socket_channel/io.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class ChatScreen extends StatefulWidget {
  final String userId; // Logged-in user ID
  final String receiverId; // Chat partner ID

  const ChatScreen({Key? key, required this.userId, required this.receiverId})
    : super(key: key);

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  late WebSocketChannel channel;
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<Map<String, dynamic>> _messages = [];

  @override
  void initState() {
    super.initState();

    // Step 1: Fetch message history from backend
    fetchMessageHistory().then((historyMessages) {
      setState(() {
        _messages.addAll(historyMessages);
      });

      // Scroll to bottom after loading
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_scrollController.hasClients) {
          _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
        }
      });
    });

    // Step 2: Set up WebSocket connection
    channel = IOWebSocketChannel.connect(
      Uri.parse('wss://spotify-api-pytj.onrender.com/chat/ws/${widget.userId}'),
    );

    // Step 3: Listen to WebSocket messages
    channel.stream.listen((data) {
      print("📩 Received raw data: $data");
      try {
        final decoded = jsonDecode(data);
        if (decoded is Map<String, dynamic> &&
            decoded.containsKey('sender_id') &&
            decoded.containsKey('receiver_id') &&
            decoded.containsKey('message')) {
          String sender = decoded['sender_id'].toString();
          String receiver = decoded['receiver_id'].toString();

          if ((sender == widget.userId && receiver == widget.receiverId) ||
              (sender == widget.receiverId && receiver == widget.userId)) {
            setState(() {
              _messages.add({
                'sender_id': sender,
                'message': decoded['message']?.toString() ?? '',
              });
            });

            // Auto-scroll to bottom
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (_scrollController.hasClients) {
                _scrollController.animateTo(
                  _scrollController.position.maxScrollExtent,
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeOut,
                );
              }
            });
          } else {
            print("Message ignored: not for this chat session");
          }
        }
      } catch (e) {
        print("❌ JSON decode error: $e");
      }
    });
  }

  // Fetch message history via REST API
  Future<List<Map<String, dynamic>>> fetchMessageHistory() async {
    final url =
        'https://spotify-api-pytj.onrender.com/chat/history?user_id=${widget.userId}&other_user_id=${widget.receiverId}';

    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      return data.map<Map<String, dynamic>>((msg) {
        return {
          'sender_id': msg['sender_id'].toString(),
          'message': msg['content'].toString(),
        };
      }).toList();
    } else {
      print("Failed to fetch message history: ${response.body}");
      return [];
    }
  }

  // Send message through WebSocket
  void _sendMessage() {
    final text = _controller.text.trim();
    if (text.isNotEmpty) {
      final payload = {
        'receiver_id': int.parse(widget.receiverId),
        'message': text,
      };
      print("📤 Sending message: $payload");
      channel.sink.add(jsonEncode(payload));
      _controller.clear();
    }
  }

  @override
  void dispose() {
    channel.sink.close();
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Widget _buildMessageItem(Map<String, dynamic> msg) {
    bool isMe = msg['sender_id'].toString() == widget.userId;
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
        padding: const EdgeInsets.all(10.0),
        decoration: BoxDecoration(
          color: isMe ? Colors.green[200] : Colors.grey[300],
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: isMe
              ? CrossAxisAlignment.end
              : CrossAxisAlignment.start,
          children: [
            Text(
              isMe ? 'You' : 'User ${msg['sender_id']}',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 4),
            Text(msg['message'] ?? ''),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              itemCount: _messages.length,
              itemBuilder: (context, index) =>
                  _buildMessageItem(_messages[index]),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 6),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: const InputDecoration(
                      hintText: 'Enter message',
                    ),
                    onSubmitted: (_) => _sendMessage(),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: _sendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
