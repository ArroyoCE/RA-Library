// lib/providers/states/game_extended_state_provider.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:retroachievements_library/models/games/game_extended_model.dart';
import 'package:retroachievements_library/providers/repositories/games/game_extended_repository_provider.dart';
import 'package:retroachievements_library/providers/states/auth_state_provider.dart';
import 'package:retroachievements_library/repositories/games/game_extended_repository.dart';

// Game extended state class
class GameExtendedState {
  final bool isLoading;
  final String? errorMessage;
  final GameExtended? data;
  final DateTime? lastUpdated;

  GameExtendedState({
    this.isLoading = false,
    this.errorMessage,
    this.data,
    this.lastUpdated,
  });

  GameExtendedState copyWith({
    bool? isLoading,
    String? errorMessage,
    GameExtended? data,
    DateTime? lastUpdated,
  }) {
    return GameExtendedState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
      data: data ?? this.data,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }
}

// Game extended notifier
class GameExtendedNotifier extends StateNotifier<GameExtendedState> {
  final String gameId;
  final String apiKey;
  final GameExtendedRepository repository;

  GameExtendedNotifier(this.repository, this.gameId, this.apiKey)
    : super(GameExtendedState()) {
    if (gameId.isNotEmpty && apiKey.isNotEmpty) {
      loadData();
    }
  }

  Future<void> loadData({bool forceRefresh = false}) async {
    if (gameId.isEmpty || apiKey.isEmpty) {
      state = state.copyWith(
        errorMessage: 'No game ID or API key available',
        isLoading: false,
      );
      return;
    }

    state = state.copyWith(isLoading: true);

    try {
      // Load extended game data
      final gameExtended = await repository.getGameExtended(
        gameId,
        apiKey,
        useCache: !forceRefresh,
      );

      if (!mounted) return;

      state = state.copyWith(
        data: gameExtended,
        isLoading: false,
        lastUpdated: DateTime.now(),
      );
    } catch (e) {
      if (!mounted) return;

      state = state.copyWith(
        errorMessage: 'Error loading extended game data: $e',
        isLoading: false,
      );
    }
  }
}

// Game extended provider (using family for different game IDs)
final gameExtendedProvider = StateNotifierProviderFamily<
  GameExtendedNotifier,
  GameExtendedState,
  String
>((ref, gameId) {
  final authState = ref.watch(authStateProvider);
  final repository = ref.watch(gameExtendedRepositoryProvider);

  return GameExtendedNotifier(repository, gameId, authState.apiKey ?? '');
});

// Provider for getting processed achievements list
final gameAchievementsListProvider = Provider.family<List<dynamic>, String>((
  ref,
  gameId,
) {
  final gameExtendedState = ref.watch(gameExtendedProvider(gameId));

  if (gameExtendedState.data != null) {
    return gameExtendedState.data!.getAchievementsList();
  }

  return <dynamic>[];
});
