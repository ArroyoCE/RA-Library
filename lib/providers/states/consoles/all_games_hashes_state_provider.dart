// lib/providers/states/all_games_hashes_state_provider.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:retroachievements_library/models/consoles/all_game_hash.dart';
import 'package:retroachievements_library/providers/repositories/consoles/all_games_hashes_repository_provider.dart';
import 'package:retroachievements_library/providers/states/auth_state_provider.dart';
import 'package:retroachievements_library/repositories/consoles/all_games_hashes_repository.dart';

class GamesHashesState {
  final bool isLoading;
  final String? errorMessage;
  final List<GameHash>? data;
  final DateTime? lastUpdated;
  final String systemId;

  GamesHashesState({
    this.isLoading = false,
    this.errorMessage,
    this.data,
    this.lastUpdated,
    this.systemId = '',
  });

  GamesHashesState copyWith({
    bool? isLoading,
    String? errorMessage,
    List<GameHash>? data,
    DateTime? lastUpdated,
    String? systemId,
  }) {
    return GamesHashesState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
      data: data ?? this.data,
      lastUpdated: lastUpdated ?? this.lastUpdated,
      systemId: systemId ?? this.systemId,
    );
  }
}

class GamesHashesNotifier extends StateNotifier<GamesHashesState> {
  final AllGamesHashesRepository allGamesHashesRepository;
  final String apiKey;

  GamesHashesNotifier(this.allGamesHashesRepository, this.apiKey)
    : super(GamesHashesState());

  Future<void> loadGameList(
    String systemId, {
    bool forceRefresh = false,
  }) async {
    if (apiKey.isEmpty) {
      state = state.copyWith(
        errorMessage: 'No API key available',
        isLoading: false,
      );
      return;
    }

    state = state.copyWith(isLoading: true, systemId: systemId);

    try {
      final gamesList = await allGamesHashesRepository.getGameList(
        systemId,
        apiKey,
        useCache: !forceRefresh,
      );

      if (gamesList != null) {
        state = state.copyWith(
          data: gamesList.map((item) => GameHash.fromJson(item)).toList(),
          isLoading: false,
          lastUpdated: DateTime.now(),
        );
      } else {
        state = state.copyWith(
          errorMessage: 'Failed to load game list',
          isLoading: false,
        );
      }
    } catch (e) {
      state = state.copyWith(
        errorMessage: 'Error loading game list: $e',
        isLoading: false,
      );
    }
  }
}

final gamesHashesStateProvider =
    StateNotifierProvider<GamesHashesNotifier, GamesHashesState>((ref) {
      final authState = ref.watch(authStateProvider);
      final repository = ref.watch(allGamesHashesRepositoryProvider);

      return GamesHashesNotifier(repository, authState.apiKey ?? '');
    });
