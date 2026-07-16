// lib/api/all_completion_api.dart

import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:retroachievements_library/constants/api_constants.dart';

class AllCompletionApi {
  Future<Map<String, dynamic>> getUserCompletionProgress(
    String username,
    String apiKey,
  ) async {
    try {
      final url = ApiConstants.getUserCompletionProgressUrl(username, apiKey);
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final decodedResponse = json.decode(response.body);
        return {'success': true, 'data': decodedResponse};
      } else {
        return {
          'success': false,
          'error':
              'Failed to load user completion progress: ${response.statusCode}',
        };
      }
    } catch (e) {
      debugPrint('Error getting user completion progress: $e');
      return {'success': false, 'error': e.toString()};
    }
  }
}

/*
RESPONSE EXAMPLE:
{
  "Count": 100,
  "Total": 1287,
  "Results": [
    {
      "GameID": 20246,
      "Title": "~Hack~ Knuckles the Echidna in Sonic the Hedgehog",
      "ImageIcon": "/Images/074560.png",
      "ConsoleID": 1,
      "ConsoleName": "Mega Drive / Genesis",
      "MaxPossible": 0,
      "NumAwarded": 0,
      "NumAwardedHardcore": 0,
      "MostRecentAwardedDate": "2023-10-27T02:52:34+00:00",
      "HighestAwardKind": "beaten-hardcore",
      "HighestAwardDate": "2023-10-27T02:52:34+00:00"
    }
    // ...
  ]
}
*/
