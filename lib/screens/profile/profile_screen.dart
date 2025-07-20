import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:jwt_decode/jwt_decode.dart';

final FlutterSecureStorage _storage = const FlutterSecureStorage();

Future<Map<String, String?>> getUserIdAndEmailFromToken() async {
  String? token = await _storage.read(key: 'auth_token');

  if (token != null && token.isNotEmpty) {
    try {
      Map<String, dynamic> payload = Jwt.parseJwt(token);

      String? userId =
          payload['sub']?.toString() ?? payload['userId']?.toString();
      String? email = payload['email']?.toString();

      return {'userId': userId, 'email': email};
    } catch (e) {
      print('Error decoding JWT token: $e');
      return {'userId': null, 'email': null};
    }
  }

  return {'userId': null, 'email': null};
}

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String? userId;
  String? email;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadUserData();
  }

  Future<void> loadUserData() async {
    final data = await getUserIdAndEmailFromToken();
    setState(() {
      userId = data['userId'];
      email = data['email'];
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const CircleAvatar(
            radius: 50,
            backgroundColor: Colors.blueAccent,
            child: Icon(Icons.person, size: 50, color: Colors.white),
          ),
          const SizedBox(height: 16),
          Text(
            userId ?? 'Unknown User',
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(
            email ?? 'No Email Found',
            style: const TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 24),
          ListTile(
            leading: const Icon(Icons.settings),
            title: const Text('Settings'),
            onTap: () {
              // Navigate to settings screen (optional)
            },
          ),
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text('Logout'),
            onTap: () {
              // Add logout logic
            },
          ),
        ],
      ),
    );
  }
}
