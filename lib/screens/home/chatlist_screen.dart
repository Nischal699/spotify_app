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
    if (isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Chats')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }
    return Scaffold(
      appBar: AppBar(title: const Text('Chats')),
      body: ListView.builder(
        itemCount: users.length,
        itemBuilder: (context, index) {
          final user = users[index];
          return ListTile(
            title: Text(user['name']),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => Scaffold(
                    appBar: AppBar(title: Text('Chat with ${user['name']}')),
                    body: ChatScreen(
                      userId: widget.currentUserId,
                      receiverId: user['userId'],
                    ),
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
