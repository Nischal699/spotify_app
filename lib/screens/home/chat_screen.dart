import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:web_socket_channel/io.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:intl/intl.dart';

class ChatScreen extends StatefulWidget {
  final String userId;
  final String receiverId;

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

  bool _isLoadingMore = false;
  bool _hasMore = true;
  int _offset = 0;
  final int _limit = 20;

  final List<String> emojiOptions = ['👍', '❤️', '😂', '😮', '😢', '👏'];

  @override
  void initState() {
    super.initState();

    _scrollController.addListener(() {
      if (_scrollController.offset <= 50 &&
          !_isLoadingMore &&
          _hasMore &&
          _messages.isNotEmpty) {
        fetchMessageHistory(append: true);
      }
    });

    // Scroll to bottom when user types
    _controller.addListener(() {
      if (_controller.text.isNotEmpty) {
        _scrollToBottom();
      }
    });

    channel = IOWebSocketChannel.connect(
      Uri.parse('wss://spotify-api-pytj.onrender.com/chat/ws/${widget.userId}'),
    );

    fetchMessageHistory().then((historyMessages) {
      setState(() {
        _messages.addAll(historyMessages);
      });

      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_scrollController.hasClients) {
          _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
        }
      });

      channel.sink.add(
        jsonEncode({
          "type": "mark_seen",
          "sender_id": int.parse(widget.receiverId),
        }),
      );
    });

    channel.stream.listen((data) {
      try {
        final decoded = jsonDecode(data);

        if (decoded['type'] == null || decoded['type'] == 'chat_message') {
          final sender = decoded['sender_id'].toString();
          final receiver = decoded['receiver_id'].toString();

          if ((sender == widget.userId && receiver == widget.receiverId) ||
              (sender == widget.receiverId && receiver == widget.userId)) {
            setState(() {
              _messages.add({
                'id': decoded['id'],
                'sender_id': sender,
                'message': decoded['message'],
                'seen': false,
                'timestamp': DateTime.now().toIso8601String(),
                'reactions': <String, int>{},
              });
            });
            _scrollToBottom();
          }
        }

        if (decoded['type'] == 'seen_ack') {
          final receiverId = decoded['receiver_id'].toString();
          setState(() {
            for (var msg in _messages) {
              if (msg['sender_id'] == widget.userId &&
                  widget.receiverId == receiverId) {
                msg['seen'] = true;
              }
            }
          });
        }

        if (decoded['type'] == 'reaction_update') {
          final messageId = decoded['message_id'];
          final emoji = decoded['emoji'];
          final action = decoded['action'];

          setState(() {
            for (var msg in _messages) {
              if (msg['id'] == messageId) {
                msg['reactions'] ??= <String, int>{};

                if (action == "add") {
                  msg['reactions'][emoji] = (msg['reactions'][emoji] ?? 0) + 1;
                } else if (action == "remove") {
                  if (msg['reactions'][emoji] != null) {
                    msg['reactions'][emoji] = msg['reactions'][emoji]! - 1;
                    if (msg['reactions'][emoji]! <= 0) {
                      msg['reactions'].remove(emoji);
                    }
                  }
                }
                break;
              }
            }
          });
        }
      } catch (e) {
        print("❌ WebSocket decode error: $e");
      }
    });
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  Future<List<Map<String, dynamic>>> fetchMessageHistory({
    bool append = false,
  }) async {
    if (_isLoadingMore || !_hasMore) return [];

    setState(() => _isLoadingMore = true);

    final url =
        'https://spotify-api-pytj.onrender.com/chat/history?user_id=${widget.userId}&other_user_id=${widget.receiverId}&offset=$_offset&limit=$_limit';

    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      final fetched = data.map<Map<String, dynamic>>((msg) {
        return {
          'id': msg['id'],
          'sender_id': msg['sender_id'].toString(),
          'message': msg['content'],
          'seen': msg['is_seen'],
          'timestamp': msg['timestamp'],
          'reactions': Map<String, int>.from(msg['reactions'] ?? {}),
        };
      }).toList();

      setState(() {
        if (append) {
          _messages.insertAll(0, fetched);
        } else {
          _messages.addAll(fetched);
        }
        _offset += fetched.length;
        _hasMore = fetched.length == _limit;
        _isLoadingMore = false;
      });

      return fetched;
    } else {
      setState(() => _isLoadingMore = false);
      return [];
    }
  }

  void _sendMessage() {
    final text = _controller.text.trim();
    if (text.isNotEmpty) {
      final payload = {
        "type": "chat_message",
        'receiver_id': int.parse(widget.receiverId),
        'message': text,
      };
      channel.sink.add(jsonEncode(payload));
      _controller.clear();
      _scrollToBottom();
    }
  }

  void _sendReaction(int index, String emoji) {
    final message = _messages[index];
    final payload = {
      "type": "add_reaction",
      "message_id": message['id'],
      "emoji": emoji,
    };
    channel.sink.add(jsonEncode(payload));
  }

  void _showEmojiPicker(BuildContext context, int index) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.grey[900],
      builder: (_) {
        return Wrap(
          children: emojiOptions.map((emoji) {
            return ListTile(
              title: Center(
                child: Text(emoji, style: const TextStyle(fontSize: 28)),
              ),
              onTap: () {
                Navigator.pop(context);
                _sendReaction(index, emoji);
              },
            );
          }).toList(),
        );
      },
    );
  }

  String formatTimestamp(String isoString) {
    try {
      return DateFormat('hh:mm a').format(DateTime.parse(isoString));
    } catch (_) {
      return "";
    }
  }

  Widget _buildMessage(Map<String, dynamic> msg, int index) {
    final isMe = msg['sender_id'].toString() == widget.userId;
    final reactions = msg['reactions'] as Map<String, int>? ?? {};

    return GestureDetector(
      onLongPress: () => _showEmojiPicker(context, index),
      child: Container(
        alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        child: Column(
          crossAxisAlignment: isMe
              ? CrossAxisAlignment.end
              : CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              constraints: const BoxConstraints(maxWidth: 300),
              decoration: BoxDecoration(
                color: isMe ? Colors.greenAccent[400] : Colors.grey[800],
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                msg['message'] ?? '',
                style: const TextStyle(color: Colors.white, fontSize: 16),
              ),
            ),
            if (reactions.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Wrap(
                  spacing: 6,
                  children: reactions.entries.map((entry) {
                    return Chip(
                      label: Text('${entry.key} ${entry.value}'),
                      backgroundColor: Colors.black54,
                      labelStyle: const TextStyle(color: Colors.white),
                    );
                  }).toList(),
                ),
              ),
            const SizedBox(height: 2),
            Text(
              formatTimestamp(msg['timestamp'] ?? ''),
              style: TextStyle(color: Colors.grey[500], fontSize: 10),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    channel.sink.close();
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1E1E1E),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1C1C1C),
        elevation: 0.5,
        iconTheme: const IconThemeData(
          color: Colors.white, // bright back arrow
        ),
        title: Row(
          children: [
            const CircleAvatar(
              backgroundColor: Colors.green,
              child: Icon(Icons.person, color: Colors.white),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Row(
                children: [
                  Text(
                    'User ${widget.receiverId}',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  const Icon(Icons.arrow_drop_down, color: Colors.white),
                ],
              ),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          if (_isLoadingMore)
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: CircularProgressIndicator(color: Colors.greenAccent),
            ),
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              reverse: false,
              padding: const EdgeInsets.symmetric(vertical: 12),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                return _buildMessage(_messages[index], index);
              },
            ),
          ),
          Container(
            margin: const EdgeInsets.fromLTRB(12, 8, 12, 16),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.grey[900],
              borderRadius: BorderRadius.circular(30),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    style: const TextStyle(color: Colors.white),
                    decoration: const InputDecoration(
                      hintText: 'Type a message...',
                      hintStyle: TextStyle(color: Colors.white54),
                      border: InputBorder.none,
                    ),
                    onSubmitted: (_) => _sendMessage(),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send, color: Colors.greenAccent),
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
