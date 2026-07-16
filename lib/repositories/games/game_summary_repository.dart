// lib/repositories/game_summary_repository.dart

import 'package:retroachievements_library/models/games/game_summary_model.dart';

abstract class GameSummaryRepository {
  /// Get game summary
  /// Returns a Map with 'success' and 'data' or 'error' fields
  Future<Map<String, dynamic>> getGameSummaryRaw(
    String gameId,
    String apiKey, {
    bool useCache = true,
  });

  /// Get game summary as a GameSummary model
  Future<GameSummary?> getGameSummary(
    String gameId,
    String apiKey, {
    bool useCache = true,
  });

  /// Get extended game details
  /// Returns a Map with 'success' and 'data' or 'error' fields
  Future<Map<String, dynamic>> getGameExtended(
    String gameId,
    String apiKey, {
    bool useCache = true,
  });

  /// Cache game summary data
  Future<void> cacheGameSummary(String gameId, Map<String, dynamic> data);

  /// Cache game extended data
  Future<void> cacheGameExtended(String gameId, Map<String, dynamic> data);

  /// Get cached game summary data
  Future<Map<String, dynamic>?> getCachedGameSummary(String gameId);

  /// Get cached game extended data
  Future<Map<String, dynamic>?> getCachedGameExtended(String gameId);

  /// Save game images locally
  Future<Map<String, String?>> saveGameImages(
    String gameId,
    Map<String, dynamic> gameData,
  );
}
