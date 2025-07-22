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
    );
  }
}

class HomePage extends StatelessWidget {
  final String userId;
  final String userEmail;

  const HomePage({super.key, required this.userId, required this.userEmail});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.black, Color(0xFF1DB954)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Welcome, $userEmail',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 30),
              _sectionTitle('Featured Playlists'),
              const SizedBox(height: 12),
              _horizontalCards([
                'Top Hits',
                'Chill Vibes',
                'Workout',
                'Jazz Classics',
              ]),
              const SizedBox(height: 30),
              _sectionTitle('Recently Played'),
              _trackTile(
                context,
                'Song 1 - Artist A',
                'https://example.com/song1.mp3',
              ),
              _trackTile(
                context,
                'Song 2 - Artist B',
                'https://example.com/song2.mp3',
              ),
              _trackTile(
                context,
                'Song 3 - Artist C',
                'https://example.com/song3.mp3',
              ),
              const SizedBox(height: 30),
              _sectionTitle('Top Charts'),
              _trackTile(
                context,
                'Chart 1 - Artist X',
                'https://example.com/chart1.mp3',
              ),
              _trackTile(
                context,
                'Chart 2 - Artist Y',
                'https://example.com/chart2.mp3',
              ),
              _trackTile(
                context,
                'Chart 3 - Artist Z',
                'https://example.com/chart3.mp3',
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _sectionTitle(String text) {
    return Text(
      text,
      style: const TextStyle(
        color: Colors.white,
        fontSize: 20,
        fontWeight: FontWeight.w600,
      ),
    );
  }

  Widget _horizontalCards(List<String> titles) {
    return SizedBox(
      height: 140,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: titles.length,
        itemBuilder: (context, index) {
          return Container(
            width: 120,
            margin: const EdgeInsets.only(right: 12),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.purpleAccent, Colors.deepPurple],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Text(
                  titles[index],
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _trackTile(BuildContext context, String title, String audioUrl) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6),
      color: Colors.grey[900],
      child: ListTile(
        leading: const Icon(Icons.music_note, color: Colors.white70),
        title: Text(title, style: const TextStyle(color: Colors.white)),
        trailing: const Icon(Icons.play_arrow, color: Colors.amber),
        onTap: () {
          Navigator.pushNamed(
            context,
            '/playlist',
            arguments: {'title': title, 'audioUrl': audioUrl},
          );
        },
      ),
    );
  }
}
