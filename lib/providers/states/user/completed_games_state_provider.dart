import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:retroachievements_organizer/models/user/completed_game.dart';
import 'package:retroachievements_organizer/providers/repositories/user/user_stats_repository_provider.dart';
import 'package:retroachievements_organizer/providers/states/auth_state_provider.dart';
import 'package:retroachievements_organizer/repositories/user/user_stats_repository.dart';

class CompletedGamesState {
  final bool isLoading;
  final String? errorMessage;
  final List<CompletedGame>? data;
  final DateTime? lastUpdated;

  CompletedGamesState({
    this.isLoading = false,
    this.errorMessage,
    this.data,
    this.lastUpdated,
  });

  CompletedGamesState copyWith({
    bool? isLoading,
    String? errorMessage,
    List<CompletedGame>? data,
    DateTime? lastUpdated,
  }) {
    return CompletedGamesState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
      data: data ?? this.data,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }
  
  // Get hardcore completed games
  List<CompletedGame> get hardcoreCompletedGames {
    if (data == null) return [];
    return data!.where((game) => game.hardcoreMode).toList();
  }
  
  // Get softcore completed games
  List<CompletedGame> get softcoreCompletedGames {
    if (data == null) return [];
    return data!.where((game) => !game.hardcoreMode).toList();
  }
}

class CompletedGamesNotifier extends StateNotifier<CompletedGamesState> {
  final UserStatsRepository repository;
  final String username;
  final String apiKey;

  CompletedGamesNotifier(this.repository, this.username, this.apiKey) 
      : super(CompletedGamesState()) {
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
      final completedGames = await repository.getUserCompletedGames(
        username, 
        apiKey, 
        useCache: !forceRefresh
      );

      if (completedGames != null) {
        state = state.copyWith(
          data: completedGames,
          isLoading: false,
          lastUpdated: DateTime.now(),
        );
      } else {
        state = state.copyWith(
          errorMessage: 'Failed to load completed games',
          isLoading: false,
        );
      }
    } catch (e) {
      state = state.copyWith(
        errorMessage: 'Error loading completed games: $e',
        isLoading: false,
      );
    }
  }
}

final completedGamesStateProvider = StateNotifierProvider<CompletedGamesNotifier, CompletedGamesState>((ref) {
  final authState = ref.watch(authStateProvider);
  final repository = ref.watch(userStatsRepositoryProvider);
  
  return CompletedGamesNotifier(
    repository, 
    authState.username ?? '', 
    authState.apiKey ?? ''
  );
});
