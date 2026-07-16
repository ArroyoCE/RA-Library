// lib/api/all_games_hashes_api.dart

import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:retroachievements_library/constants/api_constants.dart';

class AllGamesHashesApi {
  Future<Map<String, dynamic>> getGameList(
    String systemId,
    String apiKey,
  ) async {
    try {
      final url = ApiConstants.getGameListUrl(systemId, apiKey);
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final decodedResponse = json.decode(response.body);
        return {'success': true, 'data': decodedResponse};
      } else {
        return {
          'success': false,
          'error': 'Failed to load game list: ${response.statusCode}',
        };
      }
    } catch (e) {
      debugPrint('Error getting game list: $e');
      return {'success': false, 'error': e.toString()};
    }
  }
}

/*
RESPONSE EXAMPLE:
[
  {
    "Title": "Advanced Busterhawk: Gley Lancer",
    "ID": 3684,
    "ConsoleID": 1,
    "ConsoleName": "Mega Drive",
    "ImageIcon": "/Images/020895.png",
    "NumAchievements": 44,
    "NumLeaderboards": 33,
    "Points": 595,
    "DateModified": "2022-11-20 03:44:12",
    "ForumTopicID": 1936,
    "Hashes": [
      "8bd4a97783cda077c342173df0a9b51e",
      "a13ab653a20fb383337fab1e52ddb0df"
    ]
  }
  // ...
]
*/
