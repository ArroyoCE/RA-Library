// lib/repositories/user/user_stats_repository.dart
import 'package:retroachievements_library/models/user/completed_game.dart';
import 'package:retroachievements_library/models/user/recently_played_model.dart';
import 'package:retroachievements_library/models/user/user_awards_model.dart';
import 'package:retroachievements_library/models/user/user_summary_model.dart';

abstract class UserStatsRepository {
  // Completion Progress
  Future<Map<String, dynamic>> getUserCompletionProgressRaw(
    String username,
    String apiKey, {
    bool useCache = true,
  });
  Future<Map<String, dynamic>?> getUserCompletionProgress(
    String username,
    String apiKey, {
    bool useCache = true,
  });
  Future<void> cacheCompletionProgress(
    String username,
    Map<String, dynamic> data,
  );
  Future<Map<String, dynamic>?> getCachedCompletionProgress(String username);

  // Completed Games
  Future<Map<String, dynamic>> getUserCompletedGamesRaw(
    String username,
    String apiKey, {
    bool useCache = true,
  });
  Future<List<CompletedGame>?> getUserCompletedGames(
    String username,
    String apiKey, {
    bool useCache = true,
  });
  Future<void> cacheCompletedGames(String username, List<dynamic> data);
  Future<List<dynamic>?> getCachedCompletedGames(String username);

  // Recently Played
  Future<Map<String, dynamic>> getUserRecentlyPlayedGamesRaw(
    String username,
    String apiKey, {
    int count = 10,
    bool useCache = true,
  });
  Future<List<RecentlyPlayedGame>?> getUserRecentlyPlayedGames(
    String username,
    String apiKey, {
    int count = 10,
    bool useCache = true,
  });
  Future<void> cacheRecentlyPlayedGames(String username, List<dynamic> data);
  Future<List<dynamic>?> getCachedRecentlyPlayedGames(String username);

  // User Awards
  Future<Map<String, dynamic>> getUserAwardsRaw(
    String username,
    String apiKey, {
    bool useCache = true,
  });
  Future<UserAwards?> getUserAwards(
    String username,
    String apiKey, {
    bool useCache = true,
  });
  Future<void> cacheUserAwards(String username, Map<String, dynamic> data);
  Future<Map<String, dynamic>?> getCachedUserAwards(String username);

  // User Summary
  Future<Map<String, dynamic>> getUserSummaryRaw(
    String username,
    String apiKey, {
    bool useCache = true,
  });
  Future<UserSummary?> getUserSummary(
    String username,
    String apiKey, {
    bool useCache = true,
  });
  Future<void> cacheUserSummary(String username, Map<String, dynamic> data);
  Future<Map<String, dynamic>?> getCachedUserSummary(String username);
}
