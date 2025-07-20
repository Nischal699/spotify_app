// ... (your existing imports)
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

    // WebSocket setup
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
                'reactions': <String, int>{}, // initialize empty reactions map
              });
            });
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

        // Handle reaction updates (add/remove)
        if (decoded['type'] == 'reaction_update') {
          final messageId = decoded['message_id'];
          final emoji = decoded['emoji'];
          final action = decoded['action']; // "add" or "remove"

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
          // Use reactions map, convert to Map<String,int>
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
    }
  }

  void _showEmojiPicker(BuildContext context, int index) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Wrap(
          children: emojiOptions.map((emoji) {
            return ListTile(
              title: Text(emoji, style: const TextStyle(fontSize: 24)),
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

  void _sendReaction(int index, String emoji) {
    final message = _messages[index];
    final payload = {
      "type": "add_reaction",
      "message_id": message['id'],
      "emoji": emoji,
    };
    channel.sink.add(jsonEncode(payload));
    // Note: do not update UI here; wait for WS reaction_update message from server
  }

  String formatTimestamp(String isoString) {
    try {
      return DateFormat('hh:mm a').format(DateTime.parse(isoString));
    } catch (_) {
      return "";
    }
  }

  Widget _buildDateHeader(DateTime date) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Center(
        child: Text(
          DateFormat('EEEE, MMM d, yyyy').format(date),
          style: TextStyle(
            color: Colors.grey[600],
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
      ),
    );
  }

  Widget _buildMessageItem(Map<String, dynamic> msg, int index) {
    final isMe = msg['sender_id'].toString() == widget.userId;
    final seen = msg['seen'] == true;
    final timestamp = msg['timestamp'] ?? "";

    final reactions = (msg['reactions'] as Map<String, int>?) ?? {};

    return GestureDetector(
      onLongPress: () => _showEmojiPicker(context, index),
      child: Align(
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
                  fontSize: 12,
                  color: Colors.grey[700],
                ),
              ),
              const SizedBox(height: 4),
              Text.rich(
                TextSpan(
                  text: msg['message'] ?? '',
                  children: isMe
                      ? [
                          TextSpan(
                            text: seen ? '  👁️' : '  ✅',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                        ]
                      : [],
                ),
              ),
              if (reactions.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 4.0),
                  child: Wrap(
                    spacing: 6,
                    children: reactions.entries.map((entry) {
                      final emoji = entry.key;
                      final count = entry.value;
                      return Chip(
                        label: Text(
                          '$emoji $count',
                          style: TextStyle(fontSize: 16),
                        ),
                        backgroundColor: Colors.grey[200],
                      );
                    }).toList(),
                  ),
                ),
              const SizedBox(height: 6),
              Text(
                formatTimestamp(timestamp),
                style: TextStyle(fontSize: 10, color: Colors.grey[500]),
              ),
            ],
          ),
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
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: Row(
          children: [
            const CircleAvatar(
              backgroundColor: Colors.white,
              child: Icon(Icons.person, color: Colors.blue),
            ),
            const SizedBox(width: 10),
            Text(
              'Chat with User ${widget.receiverId}',
              style: const TextStyle(fontSize: 18),
            ),
          ],
        ),
        backgroundColor: Colors.blue,
        elevation: 1,
      ),
      body: SafeArea(
        child: Column(
          children: [
            if (_isLoadingMore && _messages.isNotEmpty)
              const Padding(
                padding: EdgeInsets.all(8.0),
                child: Center(child: CircularProgressIndicator()),
              ),
            Expanded(
              child: ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                itemCount: _messages.length,
                itemBuilder: (context, index) {
                  final msg = _messages[index];
                  final currentDate =
                      DateTime.tryParse(msg['timestamp'] ?? '') ??
                      DateTime.now();

                  bool showDateHeader = false;
                  if (index == 0) {
                    showDateHeader = true;
                  } else {
                    final prevMsg = _messages[index - 1];
                    final prevDate =
                        DateTime.tryParse(prevMsg['timestamp'] ?? '') ??
                        DateTime.now();

                    if (currentDate.year != prevDate.year ||
                        currentDate.month != prevDate.month ||
                        currentDate.day != prevDate.day) {
                      showDateHeader = true;
                    }
                  }

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (showDateHeader) _buildDateHeader(currentDate),
                      _buildMessageItem(msg, index),
                    ],
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 6, 12, 10),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextField(
                        controller: _controller,
                        decoration: const InputDecoration(
                          hintText: 'Type a message...',
                          border: InputBorder.none,
                        ),
                        onSubmitted: (_) => _sendMessage(),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.send_rounded, color: Colors.blue),
                      onPressed: _sendMessage,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
