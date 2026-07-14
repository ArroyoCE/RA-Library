// lib/screens/dashboard/widgets/game_card.dart

import 'package:flutter/material.dart';
import 'package:retroachievements_organizer/constants/constants.dart';
import 'package:retroachievements_organizer/models/user/recently_played_model.dart';
import 'package:retroachievements_organizer/screens/dashboard/utils/completion_color_helper.dart';
import 'package:retroachievements_organizer/screens/dashboard/utils/dashboard_formatter.dart';

class GameCard extends StatelessWidget {
  final RecentlyPlayedGame game;
  final VoidCallback? onTap; 

  const GameCard({
    super.key,
    required this.game,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    double completionPercentage = game.getCompletionPercentage();
    Color progressColor = CompletionColorHelper.getCompletionColor(completionPercentage);
    String completionText = '';

    if (completionPercentage > 0) {
      completionText = '${completionPercentage.toStringAsFixed(1)}% Complete';
    }

    return InkWell(  
    onTap: onTap,
    borderRadius: BorderRadius.circular(8),
    child: Container(
      width: 140,
      margin: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: AppColors.darkBackground,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 3,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Game image
          ClipRRect(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(8),
              topRight: Radius.circular(8),
            ),
            child: Stack(
              children: [
                Image.network(
                  'https://retroachievements.org${game.imageIcon}',
                  height: 80,
                  width: 140,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      height: 80,
                      width: 140,
                      color: AppColors.darkBackground,
                      child: const Icon(
                        Icons.videogame_asset,
                        color: AppColors.primary,
                        size: 40,
                      ),
                    );
                  },
                ),
                // Completion indicator
                if (completionPercentage > 0)
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      height: 4,
                      decoration: const BoxDecoration(
                        color: AppColors.darkBackground,
                      ),
                      child: FractionallySizedBox(
                        widthFactor: completionPercentage / 100,
                        child: Container(
                          color: progressColor,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          
          // Game info
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  game.title,
                  style: const TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(
                      Icons.gamepad,
                      color: AppColors.textSubtle,
                      size: 10,
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        game.consoleName,
                        style: const TextStyle(
                          color: AppColors.textSubtle,
                          fontSize: 10,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                if (completionText.isNotEmpty)
                  Text(
                    completionText,
                    style: TextStyle(
                      color: progressColor,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    const Icon(
                      Icons.calendar_today,
                      color: AppColors.primary,
                      size: 10,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      DashboardFormatter.formatShortDate(game.lastPlayed),
                      style: const TextStyle(
                        color: AppColors.textSubtle,
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    )
    );
  }
}