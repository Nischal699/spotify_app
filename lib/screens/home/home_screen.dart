import 'package:flutter/material.dart';
import 'package:spotify/screens/home/chat_screen.dart';

class Homescreen extends StatefulWidget {
  const Homescreen({super.key});

  @override
  HomescreenState createState() => HomescreenState();
}

class HomescreenState extends State<Homescreen> {
  int _selectedIndex = 0;
  final String userId = '1'; // Replace with your dynamic user ID

  static const TextStyle optionStyle = TextStyle(
    fontSize: 30,
    fontWeight: FontWeight.bold,
  );

  @override
  Widget build(BuildContext context) {
    final List<Widget> widgetOptions = <Widget>[
      Text('HOME PAGE', style: optionStyle),
      Text('PROFILE PAGE', style: optionStyle),
      ChatScreen(
        userId: userId,
        receiverId: '2',
      ), // Replaces Text with real ChatScreen
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Spotify Clone',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.black,
      ),
      body: Center(child: widgetOptions[_selectedIndex]),
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
