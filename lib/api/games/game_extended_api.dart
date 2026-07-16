// lib/api/game_extended_api.dart

import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:retroachievements_library/constants/api_constants.dart';

class GameExtendedApi {
  Future<Map<String, dynamic>> getGameExtended(
    String gameId,
    String apiKey,
  ) async {
    try {
      final url = ApiConstants.getGameExtendedUrl(gameId, apiKey);
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final decodedResponse = json.decode(response.body);
        return {'success': true, 'data': decodedResponse};
      } else {
        return {
          'success': false,
          'error':
              'Failed to load extended game details: ${response.statusCode}',
        };
      }
    } catch (e) {
      debugPrint('Error getting extended game details: $e');
      return {'success': false, 'error': e.toString()};
    }
  }
}

/*
{
  "ID": 1,
  "Title": "Sonic the Hedgehog",
  "ConsoleID": 1,
  "ForumTopicID": 112,
  "Flags": null,
  "ImageIcon": "/Images/067895.png",
  "ImageTitle": "/Images/054993.png",
  "ImageIngame": "/Images/000010.png",
  "ImageBoxArt": "/Images/051872.png",
  "Publisher": "",
  "Developer": "",
  "Genre": "",
  "Released": "1992-06-02",
  "ReleasedAtGranularity": "day",
  "IsFinal": false, // this field is deprecated, and will always return false
  "RichPresencePatch": "cce60593880d25c97797446ed33eaffb",
  "GuideURL": null,
  "Updated": "2023-12-27T13:51:14.000000Z",
  "ConsoleName": "Mega Drive",
  "ParentGameID": null,
  "NumDistinctPlayers": 27080,
  "NumAchievements": 23,
  "Achievements": {
    "9": {
      "ID": 9,
      "NumAwarded": 24273,
      "NumAwardedHardcore": 10831,
      "Title": "That Was Easy",
      "Description": "Complete the first act in Green Hill Zone",
      "Points": 3,
      "TrueRatio": 3,
      "Author": "Scott",
      "AuthorULID": "00003EMFWR7XB8SDPEHB3K56ZQ",
      "DateModified": "2023-08-08 00:36:59",
      "DateCreated": "2012-11-02 00:03:12",
      "BadgeName": "250336",
      "DisplayOrder": 1,
      "MemAddr": "22c9d5e2cd7571df18a1a1b43dfe1fea",
      "type": "progression"
    }
    // ...
  },
  "Claims": [],
  "NumDistinctPlayersCasual": 27080,
  "NumDistinctPlayersHardcore": 27080
}
*/
