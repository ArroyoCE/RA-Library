// lib/screens/games/utils/hash_matching_service.dart

import 'package:flutter/material.dart';
import 'package:retroachievements_library/models/consoles/all_game_hash.dart';
import 'package:retroachievements_library/models/local/hash_match_model.dart';

class HashMatchingService {
  /// Match game hashes with local hashes
  static List<HashMatchModel> matchGames(
    List<GameHash> games,
    Map<String, String> localHashes,
  ) {
    final List<HashMatchModel> matchResults = [];

    for (final game in games) {
      // Convert game hashes to strings
      final List<String> apiHashes =
          game.hashes.map((hash) => hash.toLowerCase()).toList();

      // Create match model
      final matchModel = HashMatchModel.fromGame(
        game.id,
        game.title,
        apiHashes,
        localHashes,
      );

      matchResults.add(matchModel);
    }

    return matchResults;
  }

  /// Get color based on match status
  static Color getMatchStatusColor(MatchStatus status) {
    switch (status) {
      case MatchStatus.fullMatch:
        return Colors.green;
      case MatchStatus.partialMatch:
        return Colors.blue;
      case MatchStatus.noMatch:
        return Colors.red;
    }
  }

  /// Get text based on match status
  static String getMatchStatusText(MatchStatus status) {
    switch (status) {
      case MatchStatus.fullMatch:
        return 'Full Match';
      case MatchStatus.partialMatch:
        return 'Partial Match';
      case MatchStatus.noMatch:
        return 'No Match';
    }
  }
}
