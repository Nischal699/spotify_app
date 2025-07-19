import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:jwt_decode/jwt_decode.dart';
import 'package:spotify/screens/home/chatlist_screen.dart';

class Homescreen extends StatefulWidget {
  const Homescreen({super.key});

  @override
  HomescreenState createState() => HomescreenState();
}

class HomescreenState extends State<Homescreen> {
  int _selectedIndex = 0;
  String currentUserId = '';

  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  @override
  void initState() {
    super.initState();
    loadCurrentUserId();
  }

  Future<void> loadCurrentUserId() async {
    String? token = await _storage.read(key: 'auth_token');
    if (token != null && token.isNotEmpty) {
      try {
        Map<String, dynamic> payload = Jwt.parseJwt(token);
        setState(() {
          // Adjust the key depending on your token structure
          currentUserId =
              payload['sub']?.toString() ?? payload['userId']?.toString() ?? '';
        });
      } catch (e) {
        print('Error decoding JWT token: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (currentUserId.isEmpty) {
      // Show loading spinner while loading user ID
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final List<Widget> widgetOptions = <Widget>[
      const Center(
        child: Text(
          'HOME PAGE',
          style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
        ),
      ),
      const Center(
        child: Text(
          'PROFILE PAGE',
          style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
        ),
      ),
      ChatListScreen(currentUserId: currentUserId),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Spotify Clone',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.black,
      ),
      body: widgetOptions[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
          BottomNavigationBarItem(icon: Icon(Icons.message), label: 'Chat'),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.amber[800],
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
      ),
    );
  }
}
