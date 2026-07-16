// lib/repositories/all_games_hashes_repository_impl.dart

import 'package:retroachievements_library/api/consoles/all_games_hashes_api.dart';
import 'package:retroachievements_library/repositories/consoles/all_games_hashes_repository.dart';
import 'package:retroachievements_library/services/storage_service.dart';

class AllGamesHashesRepositoryImpl implements AllGamesHashesRepository {
  final AllGamesHashesApi _allGamesHashesApi;
  final StorageService _storageService;

  AllGamesHashesRepositoryImpl(this._allGamesHashesApi, this._storageService);

  @override
  Future<Map<String, dynamic>> getGameListRaw(
    String systemId,
    String apiKey, {
    bool useCache = true,
  }) async {
    if (useCache) {
      final cachedData = await getCachedGameList(systemId);
      if (cachedData != null) {
        return {'success': true, 'data': cachedData};
      }
    }

    final response = await _allGamesHashesApi.getGameList(systemId, apiKey);

    if (response['success'] && response['data'] != null) {
      await cacheGameList(systemId, response['data']);
    }

    return response;
  }

  @override
  Future<List<dynamic>?> getGameList(
    String systemId,
    String apiKey, {
    bool useCache = true,
  }) async {
    final response = await getGameListRaw(systemId, apiKey, useCache: useCache);

    if (response['success'] && response['data'] != null) {
      return response['data'];
    }

    return null;
  }

  @override
  Future<void> cacheGameList(String systemId, List<dynamic> data) async {
    await _storageService.saveJsonData({'games': data}, 'game_list', systemId);
  }

  @override
  Future<List<dynamic>?> getCachedGameList(String systemId) async {
    final cachedData = await _storageService.readJsonData(
      'game_list',
      systemId,
    );
    return cachedData != null ? cachedData['games'] as List<dynamic> : null;
  }
}
