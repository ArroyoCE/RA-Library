// lib/constants/api_constants.dart

class ApiConstants {
  static const String baseUrl = 'https://retroachievements.org/API';

  // API Endpoints
  static const String getUserProfile = '$baseUrl/API_GetUserProfile.php';
  static const String getUserSummary = '$baseUrl/API_GetUserSummary.php';
  static const String getUserRecentlyPlayedGames =
      '$baseUrl/API_GetUserRecentlyPlayedGames.php';
  static const String getUserCompletionProgress =
      '$baseUrl/API_GetUserCompletionProgress.php';
  static const String getGameInfo =
      '$baseUrl/API_GetGameInfoAndUserProgress.php';
  static const String getAchievementInfo =
      '$baseUrl/API_GetAchievementInfo.php';
  static const String getUserCompletedGames =
      '$baseUrl/API_GetUserCompletedGames.php';
  static const String getUserAwards = '$baseUrl/API_GetUserAwards.php';

  // Create full URLs with parameters
  static String getUserProfileUrl(String username, String apiKey) {
    return '$getUserProfile?u=$username&y=$apiKey';
  }

  static String getUserGameProgressUrl(
    String gameId,
    String username,
    String apiKey,
  ) {
    return '$baseUrl/API_GetGameInfoAndUserProgress.php?g=$gameId&u=$username&y=$apiKey';
  }

  static String getGameExtendedUrl(String gameId, String apiKey) {
    return '$baseUrl/API_GetGameExtended.php?i=$gameId&y=$apiKey';
  }

  static String getGameUrl(String gameId, String apiKey) {
    return '$baseUrl/API_GetGame.php?i=$gameId&y=$apiKey';
  }

  static String getUserSummaryUrl(
    String username,
    String apiKey, {
    int gameCount = 10,
    int achievementCount = 10,
  }) {
    return '$getUserSummary?u=$username&y=$apiKey&g=$gameCount&a=$achievementCount';
  }

  static String getUserCompletedGamesUrl(String username, String apiKey) {
    return '$getUserCompletedGames?u=$username&y=$apiKey';
  }

  static String getUserAwardsUrl(String username, String apiKey) {
    return '$getUserAwards?u=$username&y=$apiKey';
  }

  static String getUserRecentlyPlayedGamesUrl(
    String username,
    String apiKey, {
    int count = 10,
  }) {
    return '$getUserRecentlyPlayedGames?u=$username&y=$apiKey&c=$count';
  }

  static String getUserCompletionProgressUrl(String username, String apiKey) {
    return '$getUserCompletionProgress?c=500&u=$username&y=$apiKey';
  }

  static String getGameInfoUrl(String username, String apiKey, int gameId) {
    return '$getGameInfo?u=$username&y=$apiKey&g=$gameId';
  }

  static String getAchievementInfoUrl(
    String username,
    String apiKey,
    int achievementId,
  ) {
    return '$getAchievementInfo?u=$username&y=$apiKey&a=$achievementId';
  }

  static String getConsoleIDsUrl(String apiKey) {
    return '$baseUrl/API_GetConsoleIDs.php?a=1&g=1&y=$apiKey';
  }

  static String getGameListUrl(String systemId, String apiKey) {
    return '$baseUrl/API_GetGameList.php?i=$systemId&h=1&f=1&y=$apiKey';
  }
}
