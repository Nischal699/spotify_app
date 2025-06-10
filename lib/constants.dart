// App-wide Colors
import 'package:flutter/material.dart';

// constants.dart

// Base URL for your FastAPI deployed backend
const String baseUrl = 'https://spotify-api-pytj.onrender.com';

// API Endpoints (optional — makes your code cleaner & DRY)
class ApiEndpoints {
  static const String login = '/auth/login';
  static const String register = '/auth/register';
  static const String validateToken = '/validate_token';
  // Add more endpoints here as you build them
}

class AppColors {
  static const Color primaryColor = Color(0xffFCA148);
  static const Color secondaryColor = Color(0xfff7b858);
  static const Color backgroundColor = Colors.black;
  static const Color textColor = Colors.white;
}

// App-wide Strings (if needed)
class AppStrings {
  static const String appName = 'Spotify Clone';
  static const String loadingMessage = 'Loading Spotify Clone...';
}
