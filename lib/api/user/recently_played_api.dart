// lib/api/recently_played_api.dart

import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:retroachievements_library/constants/api_constants.dart';

class RecentlyPlayedApi {
  Future<Map<String, dynamic>> getUserRecentlyPlayedGames(
    String username,
    String apiKey, {
    int count = 10,
  }) async {
    try {
      final url = ApiConstants.getUserRecentlyPlayedGamesUrl(
        username,
        apiKey,
        count: count,
      );
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final decodedResponse = json.decode(response.body);
        return {'success': true, 'data': decodedResponse};
      } else {
        return {
          'success': false,
          'error':
              'Failed to load recently played games: ${response.statusCode}',
        };
      }
    } catch (e) {
      debugPrint('Error getting recently played games: $e');
      return {'success': false, 'error': e.toString()};
    }
  }
}
/*
HTML RESPONSE EXAMPLE
[
  {
    "GameID": 11332,
    "ConsoleID": 12,
    "ConsoleName": "PlayStation",
    "Title": "Final Fantasy Origins",
    "ImageIcon": "/Images/060249.png",
    "ImageTitle": "/Images/026707.png",
    "ImageIngame": "/Images/026708.png",
    "ImageBoxArt": "/Images/046257.png",
    "LastPlayed": "2023-10-27 00:30:04",
    "AchievementsTotal": 119,
    "NumPossibleAchievements": 119,
    "PossibleScore": 945,
    "NumAchieved": 38,
    "ScoreAchieved": 382,
    "NumAchievedHardcore": 38,
    "ScoreAchievedHardcore": 382
  }
  // ...
]
*/