import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:retroachievements_library/constants/constants.dart';
import 'package:retroachievements_library/providers/states/auth_state_provider.dart';
import 'package:retroachievements_library/providers/states/consoles/all_consoles_state_provider.dart';
import 'package:retroachievements_library/providers/states/user/user_summary_state_provider.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigateToNextScreen();
  }

  Future<void> _navigateToNextScreen() async {
    // Small delay to show splash screen
    await Future.delayed(const Duration(seconds: 1));

    if (mounted) {
      final userState = ref.read(authStateProvider);

      if (userState.isAuthenticated) {
        // Get notifiers
        final userSummaryNotifier = ref.read(userSummaryStateProvider.notifier);
        final consolesNotifier = ref.read(consolesStateProvider.notifier);

        // Trigger loads without awaiting or storing the futures
        // This starts the loading processes in the background
        userSummaryNotifier.loadData();
        consolesNotifier.loadData();

        // Navigate to dashboard immediately
        context.go('/dashboard');
      } else {
        context.go('/login');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkBackground,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Logo
            Image.asset('images/ra-icon.png', height: 150, width: 150),
            const SizedBox(height: 24),
            // App name
            const Text(
              AppStrings.appName,
              style: TextStyle(
                color: AppColors.primary,
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 48),
            // Loading indicator
            const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
            ),
          ],
        ),
      ),
    );
  }
}
