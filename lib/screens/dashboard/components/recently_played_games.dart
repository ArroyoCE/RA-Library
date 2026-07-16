// lib/screens/dashboard/components/recently_played_games.dart

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:retroachievements_library/constants/constants.dart';
import 'package:retroachievements_library/models/user/recently_played_model.dart';
import 'package:retroachievements_library/models/user/user_summary_model.dart';
import 'package:retroachievements_library/screens/dashboard/widgets/game_card.dart';

class RecentlyPlayedGames extends StatefulWidget {
  final UserSummary? userSummary;
  final List<RecentlyPlayedGame> recentlyPlayed;

  const RecentlyPlayedGames({
    super.key,
    required this.userSummary,
    required this.recentlyPlayed,
  });

  @override
  State<RecentlyPlayedGames> createState() => _RecentlyPlayedGamesState();
}

class _RecentlyPlayedGamesState extends State<RecentlyPlayedGames> {
  final ScrollController _recentGamesScrollController = ScrollController();

  @override
  void dispose() {
    _recentGamesScrollController.dispose();
    super.dispose();
  }

  void _navigateToGameDetails(RecentlyPlayedGame game) {
    final gameId = game.gameId.toString();
    final encodedTitle = Uri.encodeComponent(game.title);
    final encodedIconPath = Uri.encodeComponent(game.imageIcon);
    final encodedConsoleName = Uri.encodeComponent(game.consoleName);

    // Use context.go to navigate to the game details screen
    context.go(
      '/dashboard/game/$gameId?title=$encodedTitle&icon=$encodedIconPath&console=$encodedConsoleName',
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Recently Played Games',
              style: TextStyle(
                color: AppColors.textLight,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            // Add navigation buttons for mouse users
            Row(
              children: [
                IconButton(
                  icon: const Icon(
                    Icons.arrow_back_ios,
                    size: 14,
                    color: AppColors.primary,
                  ),
                  onPressed: () {
                    _recentGamesScrollController.animateTo(
                      _recentGamesScrollController.offset - 150,
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                    );
                  },
                ),
                IconButton(
                  icon: const Icon(
                    Icons.arrow_forward_ios,
                    size: 14,
                    color: AppColors.primary,
                  ),
                  onPressed: () {
                    _recentGamesScrollController.animateTo(
                      _recentGamesScrollController.offset + 150,
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                    );
                  },
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 12),

        // Height increased to avoid overflow
        SizedBox(
          height: 190,
          child: ListView.builder(
            controller: _recentGamesScrollController,
            scrollDirection: Axis.horizontal,
            itemCount: widget.recentlyPlayed.length,
            itemBuilder: (context, index) {
              final game = widget.recentlyPlayed[index];
              return GameCard(
                game: game,
                onTap: () => _navigateToGameDetails(game),
              );
            },
          ),
        ),
      ],
    );
  }
}
