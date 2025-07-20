import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'chat_screen.dart';

class ChatListScreen extends StatefulWidget {
  final String currentUserId;
  const ChatListScreen({required this.currentUserId, Key? key})
    : super(key: key);

  @override
  State<ChatListScreen> createState() => _ChatListScreenState();
}

class _ChatListScreenState extends State<ChatListScreen> {
  List<Map<String, dynamic>> users = [];
  bool isLoading = true;

  Future<void> fetchUsers() async {
    final url = Uri.parse('https://spotify-api-pytj.onrender.com/users/');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final List<dynamic> jsonList = jsonDecode(response.body);

        print('🔍 Current User ID: ${widget.currentUserId}');
        print(
          '📦 Fetched Users: ${jsonList.map((u) => u['id'].toString()).toList()}',
        );

        setState(() {
          users = jsonList
              .map(
                (user) => {
                  'userId': user['id'].toString(),
                  'name': user['email'] ?? 'User ${user['id']}',
                },
              )
              .where(
                (user) =>
                    user['userId'].toString().trim() !=
                    widget.currentUserId.trim(),
              )
              .toList();
          isLoading = false;
        });
      } else {
        throw Exception('Failed to load users');
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      print('❌ Error fetching users: $e');
    }
  }

  @override
  void initState() {
    super.initState();
    fetchUsers();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chats'),
        backgroundColor: Colors.blue,
        elevation: 1,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : users.isEmpty
          ? const Center(child: Text('No users found.'))
          : ListView.separated(
              itemCount: users.length,
              separatorBuilder: (_, __) => Divider(height: 1),
              itemBuilder: (context, index) {
                final user = users[index];
                return ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.blue[100],
                    child: Text(
                      user['name'][0].toUpperCase(),
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  title: Text(
                    user['name'],
                    style: const TextStyle(fontSize: 16),
                  ),
                  trailing: const Icon(Icons.chat_bubble_outline),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ChatScreen(
                          userId: widget.currentUserId,
                          receiverId: user['userId'],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
    );
  }
}
