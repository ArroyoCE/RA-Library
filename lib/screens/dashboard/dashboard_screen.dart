// lib/screens/dashboard/dashboard_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:retroachievements_organizer/constants/constants.dart';
import 'package:retroachievements_organizer/providers/states/auth_state_provider.dart';
import 'package:retroachievements_organizer/providers/states/user/completed_games_state_provider.dart';
import 'package:retroachievements_organizer/providers/states/user/recently_played_state_provider.dart';
import 'package:retroachievements_organizer/providers/states/user/user_awards_state_provider.dart';
import 'package:retroachievements_organizer/providers/states/user/user_summary_state_provider.dart';
import 'package:retroachievements_organizer/screens/dashboard/components/awards_carousel.dart';
import 'package:retroachievements_organizer/screens/dashboard/components/completion_progress.dart';
import 'package:retroachievements_organizer/screens/dashboard/components/dashboard_header.dart';
import 'package:retroachievements_organizer/screens/dashboard/components/recently_played_games.dart';
import 'package:retroachievements_organizer/screens/dashboard/components/user_profile_card.dart';
import 'package:shared_preferences/shared_preferences.dart';

export 'package:retroachievements_organizer/screens/dashboard/dashboard_screen.dart';


class DashboardScreen extends ConsumerStatefulWidget {
  final Widget child;

  const DashboardScreen({super.key, required this.child});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> with AutomaticKeepAliveClientMixin {
  @override
  Widget build(BuildContext context) {
    super.build(context);
    return widget.child;
  }

  @override
  bool get wantKeepAlive => true;
}

// This is the actual dashboard content
class DashboardContent extends ConsumerStatefulWidget {
  const DashboardContent({super.key});

  @override
  ConsumerState<DashboardContent> createState() => _DashboardContentState();
}

class _DashboardContentState extends ConsumerState<DashboardContent> with AutomaticKeepAliveClientMixin {
  @override
  Widget build(BuildContext context) {
    super.build(context);
    
    // Watch all necessary state providers
    final userState = ref.watch(authStateProvider);
    final userSummaryState = ref.watch(userSummaryStateProvider);
    final userAwardsState = ref.watch(userAwardsStateProvider);
    final completedGamesState = ref.watch(completedGamesStateProvider);
    final recentlyPlayedState = ref.watch(recentlyPlayedStateProvider);


    // Determine if loading
    final isLoading = userSummaryState.isLoading || 
                    userAwardsState.isLoading || 
                    completedGamesState.isLoading || 
                    recentlyPlayedState.isLoading;
    
    // Get last updated timestamp (use the latest from all providers)
    final lastUpdated = [
      userSummaryState.lastUpdated,
      userAwardsState.lastUpdated,
      completedGamesState.lastUpdated,
      recentlyPlayedState.lastUpdated,
    ].reduce((value, element) => 
      (value == null || (element != null && element.isAfter(value))) ? element : value);
    
        return isLoading
      ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
      : RefreshIndicator(
          onRefresh: () => _refreshAllData(ref),
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Dashboard header with title and last updated
                  DashboardHeader(
                    lastUpdated: lastUpdated, 
                    onRefresh: () => _refreshAllData(ref),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // User Profile Card
                  if (userState.userProfile != null)
                    UserProfileCard(
                      userState: userState, 
                      userSummary: userSummaryState.data,
                      userAwards: userAwardsState.data,
                    ),
                  
                  const SizedBox(height: 24),
                  
                  // Recent Awards
                  if (userAwardsState.data != null && 
                      userAwardsState.data!.visibleUserAwards.isNotEmpty)
                    AwardsCarousel(awards: userAwardsState.data!.visibleUserAwards),
                    
                  const SizedBox(height: 24),
                  
                  // Recently Played Games
                  if (recentlyPlayedState.data != null && recentlyPlayedState.data!.isNotEmpty)
                    RecentlyPlayedGames(
                      userSummary: userSummaryState.data,
                      recentlyPlayed: recentlyPlayedState.data!,
                    ),
                  
                  const SizedBox(height: 24),
                  
                  // Game Completion Progress
                  if (completedGamesState.data != null)
                    CompletionProgressList(
                      completedGames: completedGamesState.data!,
                    ),
                ],
              ),
            ),
          ),
        );
  }



  


  Future<void> _refreshAllData(WidgetRef ref) async {
    // Check for authentication
    final authState = ref.read(authStateProvider);
    if (!authState.isAuthenticated || authState.username == null || authState.apiKey == null) {
      return;
    }
    
    // Reload all data with force refresh = true
    await Future.wait([
      ref.read(userSummaryStateProvider.notifier).loadData(forceRefresh: true),
      ref.read(userAwardsStateProvider.notifier).loadData(forceRefresh: true),
      ref.read(completedGamesStateProvider.notifier).loadData(forceRefresh: true),
      ref.read(recentlyPlayedStateProvider.notifier).loadData(forceRefresh: true),
    ]);
    
    // You can still save last refresh time if needed using SharedPreferences
    try {
      final prefs = await SharedPreferences.getInstance();
      final now = DateTime.now();
      await prefs.setString('dashboard_last_updated', now.toIso8601String());
    } catch (e) {
      // Ignore errors
    }
  }
  
    @override
  bool get wantKeepAlive => true;

}