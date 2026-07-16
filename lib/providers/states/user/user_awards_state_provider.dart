import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:retroachievements_library/models/user/user_awards_model.dart';
import 'package:retroachievements_library/providers/repositories/user/user_stats_repository_provider.dart';
import 'package:retroachievements_library/providers/states/auth_state_provider.dart';
import 'package:retroachievements_library/repositories/user/user_stats_repository.dart';

class UserAwardsState {
  final bool isLoading;
  final String? errorMessage;
  final UserAwards? data;
  final DateTime? lastUpdated;

  UserAwardsState({
    this.isLoading = false,
    this.errorMessage,
    this.data,
    this.lastUpdated,
  });

  UserAwardsState copyWith({
    bool? isLoading,
    String? errorMessage,
    UserAwards? data,
    DateTime? lastUpdated,
  }) {
    return UserAwardsState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
      data: data ?? this.data,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }
}

class UserAwardsNotifier extends StateNotifier<UserAwardsState> {
  final UserStatsRepository repository;
  final String username;
  final String apiKey;

  UserAwardsNotifier(this.repository, this.username, this.apiKey)
    : super(UserAwardsState()) {
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
      final userAwards = await repository.getUserAwards(
        username,
        apiKey,
        useCache: !forceRefresh,
      );

      if (userAwards != null) {
        state = state.copyWith(
          data: userAwards,
          isLoading: false,
          lastUpdated: DateTime.now(),
        );
      } else {
        state = state.copyWith(
          errorMessage: 'Failed to load user awards',
          isLoading: false,
        );
      }
    } catch (e) {
      state = state.copyWith(
        errorMessage: 'Error loading user awards: $e',
        isLoading: false,
      );
    }
  }
}

final userAwardsStateProvider =
    StateNotifierProvider<UserAwardsNotifier, UserAwardsState>((ref) {
      final authState = ref.watch(authStateProvider);
      final repository = ref.watch(userStatsRepositoryProvider);

      return UserAwardsNotifier(
        repository,
        authState.username ?? '',
        authState.apiKey ?? '',
      );
    });
