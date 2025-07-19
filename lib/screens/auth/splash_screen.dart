import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:jwt_decoder/jwt_decoder.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final _storage = FlutterSecureStorage();

  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  Future<void> _checkLoginStatus() async {
    print('🔍 [_checkLoginStatus] started');
    await Future.delayed(const Duration(seconds: 5));
    print('⏱ 5-second delay completed');

    String? token = await _storage.read(key: 'auth_token');
    print('📦 token read from storage: $token');

    if (!mounted) {
      print('⚠️ Widget unmounted, returning early');
      return;
    }

    if (token != null && token.isNotEmpty) {
      print('🔑 Token exists, validating with server…');
      try {
        final response = await http.get(
          Uri.parse(
            'https://spotify-api-pytj.onrender.com/auth/validate_token',
          ),
          headers: {'Authorization': 'Bearer $token'},
        );
        print('📨 HTTP GET done, statusCode=${response.statusCode}');

        if (!mounted) {
          print('⚠️ Widget unmounted after HTTP, returning early');
          return;
        }

        if (response.statusCode == 200) {
          // Decode the token to get user ID
          Map<String, dynamic> decodedToken = JwtDecoder.decode(token);
          String userId = decodedToken['sub']; // or adjust key if different
          print('✅ Decoded userId: $userId');

          // Save userId in secure storage for future use
          await _storage.write(key: 'user_id', value: userId);

          print('✅ Token valid — navigating to /home');
          Navigator.pushReplacementNamed(context, '/home');
        } else {
          print(
            '❌ Token invalid (${response.statusCode}) — deleting & sending to /login',
          );
          await _storage.delete(key: 'auth_token');
          await _storage.delete(key: 'user_id'); // Clear user_id as well
          Navigator.pushReplacementNamed(context, '/login');
        }
      } catch (e, st) {
        print('🚨 Token validation failed: $e\n$st');
        if (!mounted) {
          print('⚠️ Widget unmounted in catch, returning');
          return;
        }
        await _storage.delete(key: 'auth_token');
        await _storage.delete(key: 'user_id');
        Navigator.pushReplacementNamed(context, '/login');
      }
    } else {
      print('🔓 No token found — navigating to /login');
      Navigator.pushReplacementNamed(context, '/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // App logo with border radius and clean background
            Container(
              width: 300,
              height: 120,
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(30),
              ),
              clipBehavior: Clip
                  .hardEdge, // this ensures content doesn't overflow border radius
              child: Image.asset('assets/images/logo1.jpg', fit: BoxFit.cover),
            ),
            SizedBox(height: 30),
            SpinKitWave(color: Colors.greenAccent, size: 40.0),
            SizedBox(height: 20),
            Text(
              'Loading Spotify Clone...',
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}
