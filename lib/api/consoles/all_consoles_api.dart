// lib/api/all_consoles_api.dart

import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:retroachievements_library/constants/api_constants.dart';

class AllConsolesApi {
  Future<Map<String, dynamic>> getConsoleIDs(String apiKey) async {
    try {
      final url = ApiConstants.getConsoleIDsUrl(apiKey);
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final decodedResponse = json.decode(response.body);
        return {'success': true, 'data': decodedResponse};
      } else {
        return {
          'success': false,
          'error': 'Failed to load console IDs: ${response.statusCode}',
        };
      }
    } catch (e) {
      debugPrint('Error getting console IDs: $e');
      return {'success': false, 'error': e.toString()};
    }
  }
}

/*
RESPONSE EXAMPLE:
[
  {
    "ID": 1,
    "Name": "Mega Drive",
    "IconURL": "https://static.retroachievements.org/assets/images/system/md.png",
    "Active": true,
    "IsGameSystem": true
  }
  // ...
]
*/
