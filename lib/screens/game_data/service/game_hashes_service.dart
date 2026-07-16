// lib/screens/game_data/service/game_hashes_service.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:retroachievements_library/providers/repositories/local_data_repository_provider.dart';
import 'package:retroachievements_library/providers/states/auth_state_provider.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:retroachievements_library/constants/api_constants.dart';

class GameHashesService {
  // Get local hashes for a console
  static Future<Map<String, String>> getLocalHashes(
    WidgetRef ref,
    int consoleId,
  ) async {
    try {
      // Use the local data repository to get hashes
      final repository = ref.read(localDataRepositoryProvider);
      final hashes = await repository.getLocalHashes(consoleId);
      return hashes;
    } catch (e, stackTrace) {
      debugPrint('Error loading local hashes: $e');
      debugPrint('Stack trace: $stackTrace');
      return {};
    }
  }

  // Get game hashes from API
  static Future<List<Map<String, dynamic>>> getGameHashes(
    WidgetRef ref,
    String gameId,
  ) async {
    try {
      // Get API key from auth provider
      final authState = ref.read(authStateProvider);
      final apiKey = authState.apiKey;

      if (apiKey == null) {
        throw Exception('No API key available');
      }

      // Build API URL
      final url =
          '${ApiConstants.baseUrl}/API_GetGameHashes.php?i=$gameId&y=$apiKey';

      // Make API request
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        // Check if we have results
        if (data != null && data is Map && data.containsKey('Results')) {
          return List<Map<String, dynamic>>.from(data['Results']);
        }

        return [];
      } else {
        throw Exception('Failed to load game hashes: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error getting game hashes: $e');
      return [];
    }
  }
}
