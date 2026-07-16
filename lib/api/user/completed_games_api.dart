// lib/api/completed_games_api.dart

import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:retroachievements_library/constants/api_constants.dart';

class CompletedGamesApi {
  Future<Map<String, dynamic>> getUserCompletedGames(
    String username,
    String apiKey,
  ) async {
    try {
      final url = ApiConstants.getUserCompletedGamesUrl(username, apiKey);
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final decodedResponse = json.decode(response.body);
        return {'success': true, 'data': decodedResponse};
      } else {
        return {
          'success': false,
          'error': 'Failed to load completed games: ${response.statusCode}',
        };
      }
    } catch (e) {
      debugPrint('Error getting completed games: $e');
      return {'success': false, 'error': e.toString()};
    }
  }
}

/*
HTML RESPONSE EXAMPLE
[
  {
    "GameID": 19921,
    "Title": "Mega Man: Powered Up [Subset - 468 Stages]",
    "ImageIcon": "/Images/073205.png",
    "ConsoleID": 41,
    "ConsoleName": "PlayStation Portable",
    "MaxPossible": 481,
    "NumAwarded": 481,
    "PctWon": "1.0000",
    "HardcoreMode": "0"
  },
  {
    "GameID": 19921,
    "Title": "Mega Man: Powered Up [Subset - 468 Stages]",
    "ImageIcon": "/Images/073205.png",
    "ConsoleID": 41,
    "ConsoleName": "PlayStation Portable",
    "MaxPossible": 481,
    "NumAwarded": 481,
    "PctWon": "1.0000",
    "HardcoreMode": "1"
  }
  // ...
]
*/
