// lib/screens/about_screen.dart

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:retroachievements_library/constants/constants.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkBackground,
      appBar: AppBar(
        backgroundColor: AppColors.appBarBackground,
        title: const Text(
          'About',
          style: TextStyle(
            color: AppColors.textLight,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => context.go('/home'),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // App logo
            Center(
              child: Image.asset('images/ra-icon.png', height: 120, width: 120),
            ),
            const SizedBox(height: 24),

            // App name
            const Center(
              child: Text(
                AppStrings.appName,
                style: TextStyle(
                  color: AppColors.primary,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 8),

            // Version
            const Center(
              child: Text(
                'Version 1.0.0 (Beta)',
                style: TextStyle(color: Colors.grey, fontSize: 14),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 32),

            // About content
            const Text(
              'About the App',
              style: TextStyle(
                color: AppColors.primary,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'RetroAchievements library is an unofficial companion app for RetroAchievements.org, allowing you to track your gaming progress and achievements across retro games.',
              style: TextStyle(color: AppColors.textLight, fontSize: 16),
            ),
            const SizedBox(height: 24),

            // Disclaimer
            const Text(
              'Disclaimer',
              style: TextStyle(
                color: AppColors.primary,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'This app is not affiliated with or endorsed by RetroAchievements.org. All game data and achievements are the property of their respective owners.',
              style: TextStyle(color: AppColors.textLight, fontSize: 16),
            ),
            const SizedBox(height: 24),

            // Contact
            const Text(
              'Contact & Support',
              style: TextStyle(
                color: AppColors.primary,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'For support or feature requests, please contact us at support@retroachievementslibrary.com',
              style: TextStyle(color: AppColors.textLight, fontSize: 16),
            ),
            const SizedBox(height: 40),

            // Return button
            Center(
              child: ElevatedButton(
                onPressed: () => context.go('/home'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.textDark,
                  minimumSize: const Size(200, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  'Return to Dashboard',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
