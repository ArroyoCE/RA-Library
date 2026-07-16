// lib/repositories/game_extended_repository.dart

import 'package:retroachievements_library/models/games/game_extended_model.dart';

abstract class GameExtendedRepository {
  /// Get extended game details in raw format
  /// Returns a Map with 'success' and 'data' or 'error' fields
  Future<Map<String, dynamic>> getGameExtendedRaw(
    String gameId,
    String apiKey, {
    bool useCache = true,
  });

  /// Get extended game details as a GameExtended model
  Future<GameExtended?> getGameExtended(
    String gameId,
    String apiKey, {
    bool useCache = true,
  });

  /// Cache game extended data
  Future<void> cacheGameExtended(String gameId, Map<String, dynamic> data);

  /// Get cached game extended data
  Future<Map<String, dynamic>?> getCachedGameExtended(String gameId);

  /// Save game images locally
  Future<Map<String, String?>> saveGameImages(
    String gameId,
    Map<String, dynamic> gameData,
  );
}
