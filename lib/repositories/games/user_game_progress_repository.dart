// lib/repositories/games/user_game_progress_repository.dart

import 'package:retroachievements_library/models/games/user_game_progress_model.dart';

abstract class UserGameProgressRepository {
  Future<Map<String, dynamic>> getUserGameProgressRaw(
    String gameId,
    String username,
    String apiKey, {
    bool useCache = true,
  });
  Future<UserGameProgress?> getUserGameProgress(
    String gameId,
    String username,
    String apiKey, {
    bool useCache = true,
  });
  Future<void> cacheUserGameProgress(
    String gameId,
    String username,
    Map<String, dynamic> data,
  );
  Future<Map<String, dynamic>?> getCachedUserGameProgress(
    String gameId,
    String username,
  );
}
