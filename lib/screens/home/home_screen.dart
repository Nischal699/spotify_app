import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:jwt_decode/jwt_decode.dart';
import 'package:spotify/screens/home/chatlist_screen.dart';
import 'package:spotify/screens/profile/profile_screen.dart';

class Homescreen extends StatefulWidget {
  const Homescreen({super.key});

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

class HomePage extends StatelessWidget {
  final String userId;
  final String userEmail;

  const HomePage({super.key, required this.userId, required this.userEmail});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Welcome back, $userEmail!',
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 24),

          const Text(
            'Featured Playlists',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 12),

          SizedBox(
            height: 140,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                _playlistCard('Top Hits', Colors.redAccent),
                _playlistCard('Chill Vibes', Colors.blueAccent),
                _playlistCard('Workout', Colors.green),
                _playlistCard('Jazz Classics', Colors.deepPurple),
              ],
            ),
          ),

          const SizedBox(height: 24),

          const Text(
            'Recently Played',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 12),
          // Placeholder for recently played - replace with your data
          _placeholderListTile('Song 1 - Artist A'),
          _placeholderListTile('Song 2 - Artist B'),
          _placeholderListTile('Song 3 - Artist C'),

          const SizedBox(height: 24),

          const Text(
            'Top Charts',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 12),
          // Placeholder for top charts - replace with your data
          _placeholderListTile('Chart 1 - Artist X'),
          _placeholderListTile('Chart 2 - Artist Y'),
          _placeholderListTile('Chart 3 - Artist Z'),
        ],
      ),
    );
  }

  Widget _playlistCard(String title, Color color) {
    return Container(
      width: 120,
      margin: const EdgeInsets.only(right: 12),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Text(
            title,
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
  }

  Widget _placeholderListTile(String title) {
    return ListTile(
      title: Text(title),
      trailing: const Icon(Icons.play_arrow),
      onTap: () {
        // TODO: Play the song
      },
    );
  }
}
