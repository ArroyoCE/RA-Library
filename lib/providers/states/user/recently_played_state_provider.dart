import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:retroachievements_library/models/user/recently_played_model.dart';
import 'package:retroachievements_library/providers/repositories/user/user_stats_repository_provider.dart';
import 'package:retroachievements_library/providers/states/auth_state_provider.dart';
import 'package:retroachievements_library/repositories/user/user_stats_repository.dart';

class RecentlyPlayedState {
  final bool isLoading;
  final String? errorMessage;
  final List<RecentlyPlayedGame>? data;
  final DateTime? lastUpdated;

  RecentlyPlayedState({
    this.isLoading = false,
    this.errorMessage,
    this.data,
    this.lastUpdated,
  });

  RecentlyPlayedState copyWith({
    bool? isLoading,
    String? errorMessage,
    List<RecentlyPlayedGame>? data,
    DateTime? lastUpdated,
  }) {
    return RecentlyPlayedState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
      data: data ?? this.data,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }
}

class RecentlyPlayedNotifier extends StateNotifier<RecentlyPlayedState> {
  final UserStatsRepository repository;
  final String username;
  final String apiKey;
  final int count;

  RecentlyPlayedNotifier(
    this.repository,
    this.username,
    this.apiKey, {
    this.count = 10,
  }) : super(RecentlyPlayedState()) {
    if (username.isNotEmpty && apiKey.isNotEmpty) {
      loadData();
    }
  }

  Future<void> loadData({bool forceRefresh = false}) async {
    if (username.isEmpty || apiKey.isEmpty) {
      state = state.copyWith(
        errorMessage: 'No user credentials available',
        isLoading: false,
      );
      return;
    }

    state = state.copyWith(isLoading: true);

    try {
      final recentlyPlayed = await repository.getUserRecentlyPlayedGames(
        username,
        apiKey,
        count: count,
        useCache: !forceRefresh,
      );

      if (recentlyPlayed != null) {
        state = state.copyWith(
          data: recentlyPlayed,
          isLoading: false,
          lastUpdated: DateTime.now(),
        );
      } else {
        state = state.copyWith(
          errorMessage: 'Failed to load recently played games',
          isLoading: false,
        );
      }
    } catch (e) {
      state = state.copyWith(
        errorMessage: 'Error loading recently played games: $e',
        isLoading: false,
      );
    }
  }
}

final recentlyPlayedStateProvider =
    StateNotifierProvider<RecentlyPlayedNotifier, RecentlyPlayedState>((ref) {
      final authState = ref.watch(authStateProvider);
      final repository = ref.watch(userStatsRepositoryProvider);

      return RecentlyPlayedNotifier(
        repository,
        authState.username ?? '',
        authState.apiKey ?? '',
        count: 10,
      );
    });
