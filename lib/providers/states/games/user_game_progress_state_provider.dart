// lib/providers/states/games/user_game_progress_state_provider.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:retroachievements_library/models/games/user_game_progress_model.dart';
import 'package:retroachievements_library/providers/repositories/games/user_game_progress_repository_provider.dart';
import 'package:retroachievements_library/providers/states/auth_state_provider.dart';
import 'package:retroachievements_library/repositories/games/user_game_progress_repository.dart';

class UserGameProgressState {
  final bool isLoading;
  final String? errorMessage;
  final UserGameProgress? data;
  final DateTime? lastUpdated;

  UserGameProgressState({
    this.isLoading = false,
    this.errorMessage,
    this.data,
    this.lastUpdated,
  });

  UserGameProgressState copyWith({
    bool? isLoading,
    String? errorMessage,
    UserGameProgress? data,
    DateTime? lastUpdated,
  }) {
    return UserGameProgressState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
      data: data ?? this.data,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }
}

class UserGameProgressNotifier extends StateNotifier<UserGameProgressState> {
  final UserGameProgressRepository repository;
  final String gameId;
  final String username;
  final String apiKey;

  UserGameProgressNotifier(
    this.repository,
    this.gameId,
    this.username,
    this.apiKey,
  ) : super(UserGameProgressState()) {
    if (gameId.isNotEmpty && username.isNotEmpty && apiKey.isNotEmpty) {
      loadData();
    }
  }

  Future<void> loadData({bool forceRefresh = false}) async {
    if (gameId.isEmpty || username.isEmpty || apiKey.isEmpty) {
      state = state.copyWith(
        errorMessage: 'Missing required parameters',
        isLoading: false,
      );
      return;
    }

    state = state.copyWith(isLoading: true);

    try {
      final userGameProgress = await repository.getUserGameProgress(
        gameId,
        username,
        apiKey,
        useCache: !forceRefresh,
      );

      state = state.copyWith(
        data: userGameProgress,
        isLoading: false,
        lastUpdated: DateTime.now(),
      );
    } catch (e) {
      state = state.copyWith(
        errorMessage: 'Error loading user game progress: $e',
        isLoading: false,
      );
    }
  }
}

final userGameProgressProvider = StateNotifierProviderFamily<
  UserGameProgressNotifier,
  UserGameProgressState,
  String
>((ref, gameId) {
  final authState = ref.watch(authStateProvider);
  final repository = ref.watch(userGameProgressRepositoryProvider);

  return UserGameProgressNotifier(
    repository,
    gameId,
    authState.username ?? '',
    authState.apiKey ?? '',
  );
});

// Provider for getting achievement list with unlock status
final userGameAchievementsProvider =
    Provider.family<List<Map<String, dynamic>>, String>((ref, gameId) {
      final userGameProgressState = ref.watch(userGameProgressProvider(gameId));

      if (userGameProgressState.data != null) {
        return userGameProgressState.data!.getAchievementsList();
      }

      return [];
    });
