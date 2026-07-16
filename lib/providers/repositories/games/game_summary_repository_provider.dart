// lib/providers/repositories/game_summary_repository_provider.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:retroachievements_library/api/games/game_summary_api.dart';
import 'package:retroachievements_library/api/games/game_extended_api.dart';
import 'package:retroachievements_library/repositories/games/game_summary_repository.dart';
import 'package:retroachievements_library/repositories/games/game_summary_repository_impl.dart';
import 'package:retroachievements_library/services/storage_service.dart';

// Provider for the GameSummaryAPI
final gameSummaryApiProvider = Provider<GameSummaryApi>((ref) {
  return GameSummaryApi();
});

// Provider for the GameExtendedAPI
final gameExtendedApiProvider = Provider<GameExtendedApi>((ref) {
  return GameExtendedApi();
});

// Provider for the GameSummaryRepository
final gameSummaryRepositoryProvider = Provider<GameSummaryRepository>((ref) {
  final gameSummaryApi = ref.watch(gameSummaryApiProvider);
  final gameExtendedApi = ref.watch(gameExtendedApiProvider);
  final storageService = ref.watch(storageServiceProvider);
  return GameSummaryRepositoryImpl(
    gameSummaryApi,
    gameExtendedApi,
    storageService,
  );
});
