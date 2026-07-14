// lib/repositories/user/user_stats_repository_impl.dart
import 'package:retroachievements_organizer/api/user/all_completion_api.dart';
import 'package:retroachievements_organizer/api/user/completed_games_api.dart';
import 'package:retroachievements_organizer/api/user/recently_played_api.dart';
import 'package:retroachievements_organizer/api/user/user_awards_api.dart';
import 'package:retroachievements_organizer/api/user/user_summary_api.dart';
import 'package:retroachievements_organizer/models/user/completed_game.dart';
import 'package:retroachievements_organizer/models/user/recently_played_model.dart';
import 'package:retroachievements_organizer/models/user/user_awards_model.dart';
import 'package:retroachievements_organizer/models/user/user_summary_model.dart';
import 'package:retroachievements_organizer/repositories/user/user_stats_repository.dart';
import 'package:retroachievements_organizer/services/storage_service.dart';

class UserStatsRepositoryImpl implements UserStatsRepository {
  final AllCompletionApi _allCompletionApi;
  final CompletedGamesApi _completedGamesApi;
  final RecentlyPlayedApi _recentlyPlayedApi;
  final UserAwardsApi _userAwardsApi;
  final UserSummaryApi _userSummaryApi;
  final StorageService _storageService;

  UserStatsRepositoryImpl(
    this._allCompletionApi,
    this._completedGamesApi,
    this._recentlyPlayedApi,
    this._userAwardsApi,
    this._userSummaryApi,
    this._storageService,
  );

  // --- Completion Progress ---
  @override
  Future<Map<String, dynamic>> getUserCompletionProgressRaw(String username, String apiKey, {bool useCache = true}) async {
    if (useCache) {
      final cachedData = await getCachedCompletionProgress(username);
      if (cachedData != null) return {'success': true, 'data': cachedData};
    }
    final response = await _allCompletionApi.getUserCompletionProgress(username, apiKey);
    if (response['success'] && response['data'] != null) {
      await cacheCompletionProgress(username, response['data']);
    }
    return response;
  }

  @override
  Future<Map<String, dynamic>?> getUserCompletionProgress(String username, String apiKey, {bool useCache = true}) async {
    final response = await getUserCompletionProgressRaw(username, apiKey, useCache: useCache);
    if (response['success'] && response['data'] != null) {
      return response['data'];
    }
    return null;
  }

  @override
  Future<void> cacheCompletionProgress(String username, Map<String, dynamic> data) async {
    await _storageService.saveJsonData(data, 'completion_progress', username);
  }

  @override
  Future<Map<String, dynamic>?> getCachedCompletionProgress(String username) async {
    return await _storageService.readJsonData('completion_progress', username);
  }

  // --- Completed Games ---
  @override
  Future<Map<String, dynamic>> getUserCompletedGamesRaw(String username, String apiKey, {bool useCache = true}) async {
    if (useCache) {
      final cachedData = await getCachedCompletedGames(username);
      if (cachedData != null) return {'success': true, 'data': cachedData};
    }
    final response = await _completedGamesApi.getUserCompletedGames(username, apiKey);
    if (response['success'] && response['data'] != null) {
      await cacheCompletedGames(username, response['data']);
    }
    return response;
  }

  @override
  Future<List<CompletedGame>?> getUserCompletedGames(String username, String apiKey, {bool useCache = true}) async {
    final response = await getUserCompletedGamesRaw(username, apiKey, useCache: useCache);
    if (response['success'] && response['data'] != null) {
      final List<dynamic> gamesJson = response['data'];
      return gamesJson.map((json) => CompletedGame.fromJson(json)).toList();
    }
    return null;
  }

  @override
  Future<void> cacheCompletedGames(String username, List<dynamic> data) async {
    await _storageService.saveJsonData({'games': data}, 'completed_games', username);
  }

  @override
  Future<List<dynamic>?> getCachedCompletedGames(String username) async {
    final data = await _storageService.readJsonData('completed_games', username);
    return data?['games'];
  }

  // --- Recently Played ---
  @override
  Future<Map<String, dynamic>> getUserRecentlyPlayedGamesRaw(String username, String apiKey, {int count = 10, bool useCache = true}) async {
    if (useCache) {
      final cachedData = await getCachedRecentlyPlayedGames(username);
      if (cachedData != null) return {'success': true, 'data': cachedData};
    }
    final response = await _recentlyPlayedApi.getUserRecentlyPlayedGames(username, apiKey, count: count);
    if (response['success'] && response['data'] != null) {
      await cacheRecentlyPlayedGames(username, response['data']);
    }
    return response;
  }

  @override
  Future<List<RecentlyPlayedGame>?> getUserRecentlyPlayedGames(String username, String apiKey, {int count = 10, bool useCache = true}) async {
    final response = await getUserRecentlyPlayedGamesRaw(username, apiKey, count: count, useCache: useCache);
    if (response['success'] && response['data'] != null) {
      final List<dynamic> gamesJson = response['data'];
      return gamesJson.map((json) => RecentlyPlayedGame.fromJson(json)).toList();
    }
    return null;
  }

  @override
  Future<void> cacheRecentlyPlayedGames(String username, List<dynamic> data) async {
    await _storageService.saveJsonData({'games': data}, 'recently_played', username);
  }

  @override
  Future<List<dynamic>?> getCachedRecentlyPlayedGames(String username) async {
    final data = await _storageService.readJsonData('recently_played', username);
    return data?['games'];
  }

  // --- User Awards ---
  @override
  Future<Map<String, dynamic>> getUserAwardsRaw(String username, String apiKey, {bool useCache = true}) async {
    if (useCache) {
      final cachedData = await getCachedUserAwards(username);
      if (cachedData != null) return {'success': true, 'data': cachedData};
    }
    final response = await _userAwardsApi.getUserAwards(username, apiKey);
    if (response['success'] && response['data'] != null) {
      await cacheUserAwards(username, response['data']);
    }
    return response;
  }

  @override
  Future<UserAwards?> getUserAwards(String username, String apiKey, {bool useCache = true}) async {
    final response = await getUserAwardsRaw(username, apiKey, useCache: useCache);
    if (response['success'] && response['data'] != null) {
      return UserAwards.fromJson(response['data']);
    }
    return null;
  }

  @override
  Future<void> cacheUserAwards(String username, Map<String, dynamic> data) async {
    await _storageService.saveJsonData(data, 'user_awards', username);
  }

  @override
  Future<Map<String, dynamic>?> getCachedUserAwards(String username) async {
    return await _storageService.readJsonData('user_awards', username);
  }

  // --- User Summary ---
  @override
  Future<Map<String, dynamic>> getUserSummaryRaw(String username, String apiKey, {bool useCache = true}) async {
    if (useCache) {
      final cachedData = await getCachedUserSummary(username);
      if (cachedData != null) return {'success': true, 'data': cachedData};
    }
    final response = await _userSummaryApi.getUserSummary(username, apiKey);
    if (response['success'] && response['data'] != null) {
      await cacheUserSummary(username, response['data']);
    }
    return response;
  }

  @override
  Future<UserSummary?> getUserSummary(String username, String apiKey, {bool useCache = true}) async {
    final response = await getUserSummaryRaw(username, apiKey, useCache: useCache);
    if (response['success'] && response['data'] != null) {
      return UserSummary.fromJson(response['data']);
    }
    return null;
  }

  @override
  Future<void> cacheUserSummary(String username, Map<String, dynamic> data) async {
    await _storageService.saveJsonData(data, 'user_summary', username);
  }

  @override
  Future<Map<String, dynamic>?> getCachedUserSummary(String username) async {
    return await _storageService.readJsonData('user_summary', username);
  }
}
