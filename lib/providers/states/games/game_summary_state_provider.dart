// lib/providers/states/game_summary_state_provider.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:retroachievements_library/models/games/game_summary_model.dart';
import 'package:retroachievements_library/providers/repositories/games/game_summary_repository_provider.dart';
import 'package:retroachievements_library/providers/states/auth_state_provider.dart';
import 'package:retroachievements_library/repositories/games/game_summary_repository.dart';

// Game summary state class
class GameSummaryState {
  final bool isLoading;
  final String? errorMessage;
  final GameSummary? data;
  final Map<String, dynamic>?
  extendedData; // For achievements and other extended info
  final DateTime? lastUpdated;

  GameSummaryState({
    this.isLoading = false,
    this.errorMessage,
    this.data,
    this.extendedData,
    this.lastUpdated,
  });

  GameSummaryState copyWith({
    bool? isLoading,
    String? errorMessage,
    GameSummary? data,
    Map<String, dynamic>? extendedData,
    DateTime? lastUpdated,
  }) {
    return GameSummaryState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
      data: data ?? this.data,
      extendedData: extendedData ?? this.extendedData,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }
}

// Game summary notifier
class GameSummaryNotifier extends StateNotifier<GameSummaryState> {
  final String gameId;
  final String apiKey;
  final GameSummaryRepository repository;

  GameSummaryNotifier(this.repository, this.gameId, this.apiKey)
    : super(GameSummaryState()) {
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
      // Load basic game summary
      final gameSummary = await repository.getGameSummary(
        gameId,
        apiKey,
        useCache: !forceRefresh,
      );

      // Load extended game data
      final extendedResponse = await repository.getGameExtended(
        gameId,
        apiKey,
        useCache: !forceRefresh,
      );

      Map<String, dynamic>? extendedData;
      if (extendedResponse['success'] && extendedResponse['data'] != null) {
        extendedData = extendedResponse['data'];
      }

      state = state.copyWith(
        data: gameSummary,
        extendedData: extendedData,
        isLoading: false,
        lastUpdated: DateTime.now(),
      );
    } catch (e) {
      state = state.copyWith(
        errorMessage: 'Error loading game data: $e',
        isLoading: false,
      );
    }
  }
}

// Game summary provider (using family for different game IDs)
final gameSummaryProvider =
    StateNotifierProviderFamily<GameSummaryNotifier, GameSummaryState, String>((
      ref,
      gameId,
    ) {
      final authState = ref.watch(authStateProvider);
      final repository = ref.watch(gameSummaryRepositoryProvider);

      return GameSummaryNotifier(repository, gameId, authState.apiKey ?? '');
    });

// Provider for getting processed achievements list
final gameAchievementsProvider = Provider.family<List<dynamic>, String>((
  ref,
  gameId,
) {
  final gameSummaryState = ref.watch(gameSummaryProvider(gameId));

  if (gameSummaryState.extendedData != null &&
      gameSummaryState.extendedData!.containsKey('Achievements')) {
    final achievementsMap =
        gameSummaryState.extendedData!['Achievements'] as Map<String, dynamic>;
    final achievementsList = achievementsMap.values.toList();

    // Sort achievements by display order
    achievementsList.sort((a, b) {
      final aOrder =
          a['DisplayOrder'] != null
              ? int.parse(a['DisplayOrder'].toString())
              : 999;
      final bOrder =
          b['DisplayOrder'] != null
              ? int.parse(b['DisplayOrder'].toString())
              : 999;
      return aOrder.compareTo(bOrder);
    });

    return achievementsList;
  }

  return <dynamic>[];
});
