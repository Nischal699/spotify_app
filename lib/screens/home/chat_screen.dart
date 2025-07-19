import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:web_socket_channel/io.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class ChatScreen extends StatefulWidget {
  final String userId; // Your user ID (as string)
  final String receiverId; // Chat partner ID (as string)

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

    channel = IOWebSocketChannel.connect(
      Uri.parse('wss://spotify-api-pytj.onrender.com/chat/ws/${widget.userId}'),
    );

    channel.stream.listen((data) {
      print("📩 Received raw data: $data");
      try {
        final decoded = jsonDecode(data);

        print("Decoded data: $decoded");

        if (decoded is Map<String, dynamic> &&
            decoded.containsKey('sender_id') &&
            decoded.containsKey('receiver_id') &&
            decoded.containsKey('message')) {
          String sender = decoded['sender_id'].toString();
          String receiver = decoded['receiver_id'].toString();

          // Only add messages between this user and receiver
          if ((sender == widget.userId && receiver == widget.receiverId) ||
              (sender == widget.receiverId && receiver == widget.userId)) {
            setState(() {
              _messages.add({
                'sender_id': sender,
                'message': decoded['message']?.toString() ?? '',
              });
            });

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
            print(
              "Message ignored (not for this chat). Sender: $sender, Receiver: $receiver",
            );
          }
        }
      } catch (e) {
        print("JSON decode error: $e");
      }
    });
  }

  void _sendMessage() {
    final text = _controller.text.trim();
    if (text.isNotEmpty) {
      final payload = {
        'receiver_id': int.parse(widget.receiverId),
        'message': text,
      };
      print("📤 Sending: $payload");
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
    print(
      "Building message from ${msg['sender_id']} (isMe: $isMe): ${msg['message']}",
    );
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
    return Column(
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
                  decoration: const InputDecoration(hintText: 'Enter message'),
                  onSubmitted: (_) => _sendMessage(),
                ),
              ),
              IconButton(icon: const Icon(Icons.send), onPressed: _sendMessage),
            ],
          ),
        ),
      ],
    );
  }
}
