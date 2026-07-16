// lib/repositories/game_extended_repository_impl.dart

import 'package:retroachievements_library/api/games/game_extended_api.dart';
import 'package:retroachievements_library/models/games/game_extended_model.dart';
import 'package:retroachievements_library/repositories/games/game_extended_repository.dart';
import 'package:retroachievements_library/services/storage_service.dart';

class GameExtendedRepositoryImpl implements GameExtendedRepository {
  final GameExtendedApi _gameExtendedApi;
  final StorageService _storageService;

  GameExtendedRepositoryImpl(this._gameExtendedApi, this._storageService);

  @override
  Future<Map<String, dynamic>> getGameExtendedRaw(
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
      await saveGameImages(gameId, response['data']);
    }

    return response;
  }

  @override
  Future<GameExtended?> getGameExtended(
    String gameId,
    String apiKey, {
    bool useCache = true,
  }) async {
    final response = await getGameExtendedRaw(
      gameId,
      apiKey,
      useCache: useCache,
    );

    if (response['success'] && response['data'] != null) {
      return GameExtended.fromJson(response['data']);
    }

    return null;
  }

  @override
  Future<void> cacheGameExtended(
    String gameId,
    Map<String, dynamic> data,
  ) async {
    await _storageService.saveJsonData(data, 'game_extended', gameId);
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
