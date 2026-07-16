// lib/repositories/game_summary_repository_impl.dart

import 'package:retroachievements_library/api/games/game_summary_api.dart';
import 'package:retroachievements_library/api/games/game_extended_api.dart';
import 'package:retroachievements_library/models/games/game_summary_model.dart';
import 'package:retroachievements_library/repositories/games/game_summary_repository.dart';
import 'package:retroachievements_library/services/storage_service.dart';

class GameSummaryRepositoryImpl implements GameSummaryRepository {
  final GameSummaryApi _gameSummaryApi;
  final GameExtendedApi _gameExtendedApi;
  final StorageService _storageService;

  GameSummaryRepositoryImpl(
    this._gameSummaryApi,
    this._gameExtendedApi,
    this._storageService,
  );

  @override
  Future<Map<String, dynamic>> getGameSummaryRaw(
    String gameId,
    String apiKey, {
    bool useCache = true,
  }) async {
    if (useCache) {
      final cachedData = await getCachedGameSummary(gameId);
      if (cachedData != null) {
        return {'success': true, 'data': cachedData};
      }
    }

    final response = await _gameSummaryApi.getGameSummary(gameId, apiKey);

    if (response['success'] && response['data'] != null) {
      await cacheGameSummary(gameId, response['data']);

      // Save game images
      await saveGameImages(gameId, response['data']);
    }

    return response;
  }

  @override
  Future<GameSummary?> getGameSummary(
    String gameId,
    String apiKey, {
    bool useCache = true,
  }) async {
    final response = await getGameSummaryRaw(
      gameId,
      apiKey,
      useCache: useCache,
    );

    if (response['success'] && response['data'] != null) {
      return GameSummary.fromJson(response['data']);
    }

    return null;
  }

  @override
  Future<Map<String, dynamic>> getGameExtended(
    String gameId,
    String apiKey, {
    bool useCache = true,
  }) async {
    if (useCache) {
      final cachedData = await getCachedGameExtended(gameId);
      if (cachedData != null) {
        return {'success': true, 'data': cachedData};
      }
    }

    final response = await _gameExtendedApi.getGameExtended(gameId, apiKey);

    if (response['success'] && response['data'] != null) {
      await cacheGameExtended(gameId, response['data']);

      // Save game images
      await saveGameImages(gameId, response['data']);
    }

    return response;
  }

  @override
  Future<void> cacheGameSummary(
    String gameId,
    Map<String, dynamic> data,
  ) async {
    await _storageService.saveJsonData(data, 'game_summary', gameId);
  }

  @override
  Future<void> cacheGameExtended(
    String gameId,
    Map<String, dynamic> data,
  ) async {
    await _storageService.saveJsonData(data, 'game_extended', gameId);
  }

  @override
  Future<Map<String, dynamic>?> getCachedGameSummary(String gameId) async {
    return await _storageService.readJsonData('game_summary', gameId);
  }

  @override
  Future<Map<String, dynamic>?> getCachedGameExtended(String gameId) async {
    return await _storageService.readJsonData('game_extended', gameId);
  }

  @override
  Future<Map<String, String?>> saveGameImages(
    String gameId,
    Map<String, dynamic> gameData,
  ) async {
    final results = <String, String?>{};

    // Save icon image
    if (gameData.containsKey('ImageIcon') && gameData['ImageIcon'] != null) {
      results['iconPath'] = await _storageService.saveGameImage(
        gameData['ImageIcon'],
        int.parse(gameId),
      );
    }

    // Save box art image
    if (gameData.containsKey('ImageBoxArt') &&
        gameData['ImageBoxArt'] != null) {
      results['boxArtPath'] = await _storageService.saveImageFromUrl(
        gameData['ImageBoxArt'],
        'game_images',
        'game_${gameId}_boxart.png',
      );
    }

    // Save title image
    if (gameData.containsKey('ImageTitle') && gameData['ImageTitle'] != null) {
      results['titlePath'] = await _storageService.saveImageFromUrl(
        gameData['ImageTitle'],
        'game_images',
        'game_${gameId}_title.png',
      );
    }

    // Save in-game image
    if (gameData.containsKey('ImageIngame') &&
        gameData['ImageIngame'] != null) {
      results['ingamePath'] = await _storageService.saveImageFromUrl(
        gameData['ImageIngame'],
        'game_images',
        'game_${gameId}_ingame.png',
      );
    }

    return results;
  }
}
