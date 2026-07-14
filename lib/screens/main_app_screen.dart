// lib/screens/main_app_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:retroachievements_organizer/constants/constants.dart';
import 'package:retroachievements_organizer/providers/states/auth_state_provider.dart';
import 'package:retroachievements_organizer/providers/states/consoles/consoles_updating_state_provider.dart';
import 'package:window_manager/window_manager.dart';

class MainAppScreen extends ConsumerWidget {
  final StatefulNavigationShell navigationShell;

  const MainAppScreen({
    super.key,
    required this.navigationShell,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(authStateProvider);
    final isUpdating = ref.watch(consolesUpdatingStateProvider);
    
    return Scaffold(
      backgroundColor: AppColors.darkBackground,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight),
        child: DragToMoveArea(
          child: AppBar(
            backgroundColor: AppColors.appBarBackground,
            title: Row(
              children: [
                Image.asset(
                  'images/ra-icon.png',
                  height: 24,
                  width: 24,
                ),
                const SizedBox(width: 8),
                const Text(
                  AppStrings.appName,
                  style: TextStyle(
                    color: AppColors.textLight,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.logout, color: Colors.white),
                onPressed: isUpdating ? null : () async {
                  await ref.read(authStateProvider.notifier).logout();
                  if (context.mounted) {
                    context.go('/login');
                  }
                },
              ),
              const SizedBox(
                width: 138,
                child: WindowCaption(
                  brightness: Brightness.dark,
                  backgroundColor: Colors.transparent,
                ),
              ),
            ],
          ),
        ),
      ),
      body: Row(
        children: [
          // Sidebar navigation
          AbsorbPointer(
            absorbing: isUpdating,
            child: Opacity(
              opacity: isUpdating ? 0.5 : 1.0,
              child: NavigationRail(
                backgroundColor: AppColors.cardBackground,
                selectedIndex: navigationShell.currentIndex,
                onDestinationSelected: (int index) {
                  // This is where we change the branch we're on
                  navigationShell.goBranch(index);
                },
                labelType: NavigationRailLabelType.all,
                destinations: const [
                  NavigationRailDestination(
                    icon: Icon(Icons.dashboard, color: AppColors.primary),
                    selectedIcon: Icon(Icons.dashboard, color: AppColors.primary),
                    label: Text(AppStrings.dashboard, style: TextStyle(color: AppColors.textLight)),
                  ),
                  NavigationRailDestination(
                    icon: Icon(Icons.videogame_asset, color: AppColors.primary),
                    selectedIcon: Icon(Icons.videogame_asset, color: AppColors.primary),
                    label: Text(AppStrings.myGames, style: TextStyle(color: AppColors.textLight)),
                  ),
                  NavigationRailDestination(
                    icon: Icon(Icons.emoji_events, color: AppColors.primary),
                    selectedIcon: Icon(Icons.emoji_events, color: AppColors.primary),
                    label: Text(AppStrings.myAchievements, style: TextStyle(color: AppColors.textLight)),
                  ),
                  NavigationRailDestination(
                    icon: Icon(Icons.tag, color: AppColors.primary),
                    selectedIcon: Icon(Icons.tag, color: AppColors.primary),
                    label: Text(AppStrings.hashCheck, style: TextStyle(color: AppColors.textLight)),
                  ),
                  NavigationRailDestination(
                    icon: Icon(Icons.settings, color: AppColors.primary),
                    selectedIcon: Icon(Icons.settings, color: AppColors.primary),
                    label: Text(AppStrings.settings, style: TextStyle(color: AppColors.textLight)),
                  ),
                ],
                selectedLabelTextStyle: const TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                ),
                unselectedLabelTextStyle: const TextStyle(
                  color: AppColors.textLight,
                ),
              ),
            ),
          ),
          
          // Main content - Use the navigationShell to display the current branch
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: navigationShell,
            ),
          ),
        ],
      ),
    );
  }
}