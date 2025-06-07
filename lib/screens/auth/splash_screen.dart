import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

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
    await Future.delayed(Duration(seconds: 5));

    String? token = await _storage.read(key: 'auth_token');

    if (!mounted) return; // <-- safeguard after await before using context

    if (token != null && token.isNotEmpty) {
      Navigator.pushReplacementNamed(context, '/home');
    } else {
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
