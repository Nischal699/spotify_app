import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:jwt_decode/jwt_decode.dart';
import 'package:spotify/screens/home/home_screen.dart';

class HomeLoader extends StatefulWidget {
  const HomeLoader({super.key});

  @override
  State<HomeLoader> createState() => _HomeLoaderState();
}

class _HomeLoaderState extends State<HomeLoader> {
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  String? userId;
  String? userEmail;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    String? token = await _storage.read(key: 'auth_token');
    if (token != null) {
      try {
        final payload = Jwt.parseJwt(token);
        setState(() {
          userId = payload['sub']?.toString() ?? payload['userId']?.toString();
          userEmail = payload['email']?.toString();
        });
      } catch (e) {
        print('Error decoding JWT: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (userId == null || userEmail == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Homescreen(userId: userId!, userEmail: userEmail!);
  }
}
