import 'package:flutter/material.dart';
import 'package:spotify/screens/auth/login_screen.dart';
import 'package:spotify/screens/auth/register_screen.dart';
import 'package:spotify/screens/auth/splash_screen.dart';
import 'package:spotify/screens/home/home_screen.dart';
import 'package:spotify/screens/home/player_screen.dart';
import 'package:spotify/screens/home/search_screen.dart';
import 'package:spotify/screens/home/playlist_screen.dart';
import 'package:spotify/screens/home/liked_songs_screen.dart';
import 'package:spotify/screens/profile/profile_screen.dart';

class AppRoutes {
  static const String splash = '/splash';
  static const String login = '/login';
  static const String register = '/register';
  static const String home = '/home';
  static const String player = '/player';
  static const String search = '/search';
  static const String playlist = '/playlist';
  static const String likedSongs = '/liked_songs';
  static const String profile = '/profile';

  static Map<String, WidgetBuilder> routes = {
    splash: (context) => SplashScreen(),
    login: (context) => LoginScreen(),
    register: (context) => RegisterScreen(),
    home: (context) => Homescreen(),
    player: (context) => PlayerScreen(),
    search: (context) => SearchScreen(),
    playlist: (context) => PlaylistScreen(),
    likedSongs: (context) => LikedSongsScreen(),
    profile: (context) => ProfileScreen(),
  };
}
