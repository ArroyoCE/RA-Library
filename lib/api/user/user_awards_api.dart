// lib/api/user_awards_api.dart

import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:retroachievements_library/constants/api_constants.dart';

class UserAwardsApi {
  Future<Map<String, dynamic>> getUserAwards(
    String username,
    String apiKey,
  ) async {
    try {
      final url = ApiConstants.getUserAwardsUrl(username, apiKey);
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final decodedResponse = json.decode(response.body);
        return {'success': true, 'data': decodedResponse};
      } else {
        return {
          'success': false,
          'error': 'Failed to load user awards: ${response.statusCode}',
        };
      }
    } catch (e) {
      debugPrint('Error getting user awards: $e');
      return {'success': false, 'error': e.toString()};
    }
  }
}

/*
HTML RESPONSE EXAMPLE
{
  "TotalAwardsCount": 1613,
  "HiddenAwardsCount": 0,
  "MasteryAwardsCount": 805,
  "CompletionAwardsCount": 0,
  "BeatenHardcoreAwardsCount": 807,
  "BeatenSoftcoreAwardsCount": 0,
  "EventAwardsCount": 2,
  "SiteAwardsCount": 0,
  "VisibleUserAwards": [
    {
      "AwardedAt": "2016-01-02T05:53:52+00:00",
      "AwardType": "Game Beaten",
      "AwardData": 1448,
      "AwardDataExtra": 1, // 1 for hardcore mode, 0 for softcore mode
      "DisplayOrder": 0,
      "Title": "Mega Man",
      "ConsoleID": 7,
      "ConsoleName": "NES",
      "Flags": 0,
      "ImageIcon": "/Images/024519.png"
    }
  ]
}
*/
