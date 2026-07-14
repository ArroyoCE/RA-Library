// lib/constants/constants.dart

import 'package:flutter/material.dart';

// App colors
class AppColors {
  static const Color darkBackground = Color(0xFF262626);
  static const Color appBarBackground = Color(0xFF222222);
  static const Color cardBackground = Color(0xFF333333);
  static const Color primary = Color(0xFFFFD700);
  static const Color textLight = Colors.white;
  static const Color textDark = Color(0xFF262626);
  static const Color success = Colors.green;
  static const Color error = Colors.red;
  static const Color textSubtle = Color(0xFFAAAAAA);
  static const Color info = Color(0xFF3498DB);
  static const Color warning = Color(0xFFF39C12);
}

// App string constants
class AppStrings {
  // App info
  static const String appName = 'RetroAchievements Library';
  
  // Auth screens
  static const String login = 'Login';
  static const String register = 'Register';
  static const String username = 'Username';
  static const String apiKey = 'API Key';
  static const String forgotPassword = 'Forgot Password?';
  static const String rememberMe = 'Remember Me';
  static const String dontHaveAccount = 'Don\'t have an account?';
  static const String loginSuccessful = 'Login successful!';
  static const String apiKeyDisclaimer = 'Your API key can be found at RetroAchievements.org under your account settings. This app is not affiliated with RetroAchievements.org.';
  
  // Main app screens
  static const String dashboard = 'Dashboard';
  static const String myGames = 'Consoles';
  static const String myAchievements = 'My Achievements';
  static const String settings = 'Settings';
  static const String about = 'About';
  static const String hashCheck = 'Hash Check';
  static const String logout = 'Logout';

  static const String selectConsole = 'Select a console to view games';
  static const String comingSoon = 'Coming Soon';
}