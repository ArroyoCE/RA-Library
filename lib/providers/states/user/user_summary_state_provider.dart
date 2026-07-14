import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:retroachievements_organizer/models/user/user_summary_model.dart';
import 'package:retroachievements_organizer/providers/repositories/user/user_stats_repository_provider.dart';
import 'package:retroachievements_organizer/providers/states/auth_state_provider.dart';
import 'package:retroachievements_organizer/repositories/user/user_stats_repository.dart';

class UserSummaryState {
  final bool isLoading;
  final String? errorMessage;
  final UserSummary? data;
  final DateTime? lastUpdated;

  UserSummaryState({
    this.isLoading = false,
    this.errorMessage,
    this.data,
    this.lastUpdated,
  });

  UserSummaryState copyWith({
    bool? isLoading,
    String? errorMessage,
    UserSummary? data,
    DateTime? lastUpdated,
  }) {
    return UserSummaryState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
      data: data ?? this.data,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }
}

class UserSummaryNotifier extends StateNotifier<UserSummaryState> {
  final UserStatsRepository repository;
  final String username;
  final String apiKey;

  UserSummaryNotifier(this.repository, this.username, this.apiKey) 
      : super(UserSummaryState()) {
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
      final userSummary = await repository.getUserSummary(
        username, 
        apiKey, 
        useCache: !forceRefresh
      );

      if (userSummary != null) {
        state = state.copyWith(
          data: userSummary,
          isLoading: false,
          lastUpdated: DateTime.now(),
        );
      } else {
        state = state.copyWith(
          errorMessage: 'Failed to load user summary',
          isLoading: false,
        );
      }
    } catch (e) {
      state = state.copyWith(
        errorMessage: 'Error loading user summary: $e',
        isLoading: false,
      );
    }
  }
}

final userSummaryStateProvider = StateNotifierProvider<UserSummaryNotifier, UserSummaryState>((ref) {
  final authState = ref.watch(authStateProvider);
  final repository = ref.watch(userStatsRepositoryProvider);
  
  return UserSummaryNotifier(
    repository, 
    authState.username ?? '', 
    authState.apiKey ?? ''
  );
});
