// lib/repositories/all_consoles_repository_impl.dart

import 'package:retroachievements_library/api/consoles/all_consoles_api.dart';
import 'package:retroachievements_library/repositories/consoles/all_consoles_repository.dart';
import 'package:retroachievements_library/services/storage_service.dart';

class AllConsolesRepositoryImpl implements AllConsolesRepository {
  final AllConsolesApi _allConsolesApi;
  final StorageService _storageService;

  AllConsolesRepositoryImpl(this._allConsolesApi, this._storageService);

  @override
  Future<Map<String, dynamic>> getConsoleIDsRaw(
    String apiKey, {
    bool useCache = true,
  }) async {
    if (useCache) {
      final cachedData = await getCachedConsoleIDs();
      if (cachedData != null) {
        return {'success': true, 'data': cachedData};
      }
    }

    final response = await _allConsolesApi.getConsoleIDs(apiKey);

    if (response['success'] && response['data'] != null) {
      await cacheConsoleIDs(response['data']);
    }

    return response;
  }

  @override
  Future<List<dynamic>?> getConsoleIDs(
    String apiKey, {
    bool useCache = true,
  }) async {
    final response = await getConsoleIDsRaw(apiKey, useCache: useCache);

    if (response['success'] && response['data'] != null) {
      return response['data'];
    }

    return null;
  }

  @override
  Future<void> cacheConsoleIDs(List<dynamic> data) async {
    await _storageService.saveJsonData(
      {'consoles': data},
      'console_ids',
      'all',
    );
  }

  @override
  Future<List<dynamic>?> getCachedConsoleIDs() async {
    final cachedData = await _storageService.readJsonData('console_ids', 'all');
    return cachedData != null ? cachedData['consoles'] as List<dynamic> : null;
  }
}
