// lib/repositories/games/user_game_progress_repository_impl.dart

import 'package:retroachievements_library/api/games/user_game_progress_api.dart';
import 'package:retroachievements_library/models/games/user_game_progress_model.dart';
import 'package:retroachievements_library/repositories/games/user_game_progress_repository.dart';
import 'package:retroachievements_library/services/storage_service.dart';

class UserGameProgressRepositoryImpl implements UserGameProgressRepository {
  final UserGameProgressApi _userGameProgressApi;
  final StorageService _storageService;

  UserGameProgressRepositoryImpl(
    this._userGameProgressApi,
    this._storageService,
  );

  @override
  Future<Map<String, dynamic>> getUserGameProgressRaw(
    String gameId,
    String username,
    String apiKey, {
    bool useCache = true,
  }) async {
    if (useCache) {
      final cachedData = await getCachedUserGameProgress(gameId, username);
      if (cachedData != null) {
        return {'success': true, 'data': cachedData};
      }
    }

    final response = await _userGameProgressApi.getUserGameProgress(
      gameId,
      username,
      apiKey,
    );

    if (response['success'] && response['data'] != null) {
      await cacheUserGameProgress(gameId, username, response['data']);
    }

    return response;
  }

  @override
  Future<UserGameProgress?> getUserGameProgress(
    String gameId,
    String username,
    String apiKey, {
    bool useCache = true,
  }) async {
    final response = await getUserGameProgressRaw(
      gameId,
      username,
      apiKey,
      useCache: useCache,
    );

    if (response['success'] && response['data'] != null) {
      return UserGameProgress.fromJson(response['data']);
    }

    return null;
  }

  @override
  Future<void> cacheUserGameProgress(
    String gameId,
    String username,
    Map<String, dynamic> data,
  ) async {
    await _storageService.saveJsonData(
      data,
      'user_game_progress',
      '${username}_$gameId',
    );
  }

  @override
  Future<Map<String, dynamic>?> getCachedUserGameProgress(
    String gameId,
    String username,
  ) async {
    return await _storageService.readJsonData(
      'user_game_progress',
      '${username}_$gameId',
    );
  }
}
