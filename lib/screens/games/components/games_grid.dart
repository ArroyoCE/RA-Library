// lib/screens/games/components/games_grid.dart

import 'package:flutter/material.dart';
import 'package:retroachievements_library/models/consoles/all_game_hash.dart';
import 'package:retroachievements_library/models/local/hash_match_model.dart';
import 'package:retroachievements_library/providers/states/settings_state_provider.dart';
import 'package:retroachievements_library/screens/games/widgets/game_grid_item.dart';
import 'package:retroachievements_library/widgets/generic_grid_display.dart';

class GamesGrid extends StatelessWidget {
  final List<GameHash> games;
  final Function(GameHash) onGameSelected;
  final Map<int, MatchStatus>? matchStatuses;
  final bool isHashingInProgress;
  final HashDisplayPreference hashDisplayPreference;

  const GamesGrid({
    super.key,
    required this.games,
    required this.onGameSelected,
    this.matchStatuses,
    this.isHashingInProgress = false,
    this.hashDisplayPreference = HashDisplayPreference.accountForEveryHash,
  });

  @override
  Widget build(BuildContext context) {
    return GenericGridDisplay<GameHash>(
      items: games,
      crossAxisCount: 9,
      crossAxisSpacing: 5,
      mainAxisSpacing: 10,
      childAspectRatio: hashDisplayPreference == HashDisplayPreference.onlyCountGames ? 0.80 : 0.69,
      itemBuilder: (context, game, index) {
        final matchStatus =
            matchStatuses != null ? matchStatuses![game.id] : null;
        return GameGridItem(
          game: game,
          onTap: () => onGameSelected(game),
          matchStatus: matchStatus,
          isHashingInProgress: isHashingInProgress,
          hashDisplayPreference: hashDisplayPreference,
        );
      },
    );
  }
}
