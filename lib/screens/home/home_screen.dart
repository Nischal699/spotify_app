import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:jwt_decode/jwt_decode.dart';
import 'package:spotify/screens/home/chatlist_screen.dart';
import 'package:spotify/screens/profile/profile_screen.dart';

class Homescreen extends StatefulWidget {
  final String userId;
  final String userEmail;

  const Homescreen({super.key, required this.userId, required this.userEmail});

  @override
  HomescreenState createState() => HomescreenState();
}

class HomescreenState extends State<Homescreen> {
  int _selectedIndex = 0;
  String currentUserId = '';
  String currentUserEmail = '';

  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  @override
  void initState() {
    super.initState();
    loadCurrentUserData();
  }

  Future<void> loadCurrentUserData() async {
    String? token = await _storage.read(key: 'auth_token');
    if (token != null && token.isNotEmpty) {
      try {
        Map<String, dynamic> payload = Jwt.parseJwt(token);
        setState(() {
          currentUserId =
              payload['sub']?.toString() ?? payload['userId']?.toString() ?? '';
          currentUserEmail = payload['email']?.toString() ?? '';
        });
      } catch (e) {
        print('Error decoding JWT token: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (currentUserId.isEmpty) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final List<Widget> widgetOptions = <Widget>[
      HomePage(userId: currentUserId, userEmail: currentUserEmail),
      const ProfileScreen(),
      ChatListScreen(currentUserId: currentUserId),
    ];

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 4,
        centerTitle: true,
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.account_circle, color: Colors.amber, size: 36),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                'Welcome, $currentUserEmail',
                style: const TextStyle(
                  color: Colors.amberAccent,
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.5,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        shadowColor: Colors.amber.withOpacity(0.3),
      ),
      body: widgetOptions[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.black,
        selectedItemColor: Colors.amber[800],
        unselectedItemColor: Colors.white70,
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() => _selectedIndex = index);
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
          BottomNavigationBarItem(icon: Icon(Icons.message), label: 'Chat'),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: ElevatedButton.icon(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.amber,
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
          elevation: 8,
          minimumSize: const Size(200, 50), // fixed width & height
        ),
        icon: const Icon(Icons.music_note, size: 28, color: Colors.black87),
        label: const Text(
          'Open Playlist',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        onPressed: () {
          Navigator.pushNamed(context, '/playlist');
        },
      ),
    );
  }
}

class HomePage extends StatelessWidget {
  final String userId;
  final String userEmail;

  const HomePage({super.key, required this.userId, required this.userEmail});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.music_note, size: 100, color: Colors.amber),
          const SizedBox(height: 20),
          Text(
            'Welcome to Spotify',
            style: TextStyle(
              fontSize: 36,
              fontWeight: FontWeight.bold,
              color: Colors.amber,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'User ID: $userId',
            style: const TextStyle(fontSize: 16, color: Colors.white70),
          ),
          Text(
            'Email: $userEmail',
            style: const TextStyle(fontSize: 16, color: Colors.white70),
          ),
        ],
      ),
    );
  }
}
