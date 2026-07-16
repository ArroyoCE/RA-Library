// lib/screens/games/components/games_grid.dart

import 'package:flutter/material.dart';
import 'package:retroachievements_library/models/consoles/all_game_hash.dart';
import 'package:retroachievements_library/models/local/hash_match_model.dart';
import 'package:retroachievements_library/screens/games/widgets/game_grid_item.dart';
import 'package:retroachievements_library/widgets/generic_grid_display.dart';

class GamesGrid extends StatelessWidget {
  final List<GameHash> games;
  final Function(GameHash) onGameSelected;
  final Map<int, MatchStatus>? matchStatuses;
  final bool isHashingInProgress;

  const GamesGrid({
    super.key,
    required this.games,
    required this.onGameSelected,
    this.matchStatuses,
    this.isHashingInProgress = false,
  });

  @override
  Widget build(BuildContext context) {
    return GenericGridDisplay<GameHash>(
      items: games,
      crossAxisCount: 10,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      childAspectRatio: 0.7,
      itemBuilder: (context, game, index) {
        final matchStatus =
            matchStatuses != null ? matchStatuses![game.id] : null;
        return GameGridItem(
          game: game,
          onTap: () => onGameSelected(game),
          matchStatus: matchStatus,
          isHashingInProgress: isHashingInProgress,
        );
      },
    );
  }
}
