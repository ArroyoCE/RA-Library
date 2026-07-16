// lib/api/game_summary_api.dart

import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:retroachievements_library/constants/api_constants.dart';

class GameSummaryApi {
  Future<Map<String, dynamic>> getGameSummary(
    String gameId,
    String apiKey,
  ) async {
    try {
      final url = ApiConstants.getGameUrl(gameId, apiKey);
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final decodedResponse = json.decode(response.body);
        return {'success': true, 'data': decodedResponse};
      } else {
        return {
          'success': false,
          'error': 'Failed to load game summary: ${response.statusCode}',
        };
      }
    } catch (e) {
      debugPrint('Error getting game summary: $e');
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
  "RichPresencePatch": null,
}
*/
