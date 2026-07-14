// lib/screens/games/widgets/game_grid_item.dart

import 'package:flutter/material.dart';
import 'package:retroachievements_organizer/constants/constants.dart';
import 'package:retroachievements_organizer/models/consoles/all_game_hash.dart';
import 'package:retroachievements_organizer/models/local/hash_match_model.dart';
import 'package:retroachievements_organizer/screens/games/utils/games_helper.dart';
import 'package:retroachievements_organizer/screens/games/utils/hash_matching.dart';

class GameGridItem extends StatelessWidget {
  final GameHash game;
  final VoidCallback onTap;
  final MatchStatus? matchStatus;
  final bool isHashingInProgress;

  const GameGridItem({
    super.key,
    required this.game,
    required this.onTap,
    this.matchStatus,
    this.isHashingInProgress = false,
  });

  @override
  Widget build(BuildContext context) {
    // Determine match status color and text
    Color statusColor = AppColors.textSubtle;
    String statusText = 'Checking...';
    
    if (matchStatus != null) {
      statusColor = HashMatchingService.getMatchStatusColor(matchStatus!);
      statusText = HashMatchingService.getMatchStatusText(matchStatus!);
    }
    
    return Card(
      color: AppColors.cardBackground,
      elevation: 4,
      child: InkWell(
        onTap: isHashingInProgress ? null : onTap,
        borderRadius: BorderRadius.circular(4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Game image
            Expanded(
              flex: 4,
              child: Stack(
                children: [
                  // Game image
                  _buildGameImage(),
                  
                  // Match status indicator
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: statusColor.withValues(alpha: 0.8),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        statusText,
                        style: const TextStyle(
                          color: AppColors.textLight,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  
                  // Achievement count
                  Positioned(
                    bottom: 8,
                    left: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.darkBackground.withValues(alpha: 0.8),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.emoji_events,
                            color: AppColors.primary,
                            size: 12,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${game.numAchievements}',
                            style: const TextStyle(
                              color: AppColors.textLight,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            // Game title
            Expanded(
              flex: 4,
              child: Padding(
                padding: const EdgeInsets.all(4.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      game.title,
                      style: const TextStyle(
                        color: AppColors.textLight,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${GamesHelper.formatPoints(game.points)} pts',
                      style: const TextStyle(
                        color: AppColors.primary,
                        fontSize: 9,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (matchStatus != null)
                      const Spacer(),
                    if (matchStatus != null)
                      Row(
                        children: [
                          Container(
                            width: 6,
                            height: 6,
                            decoration: BoxDecoration(
                              color: statusColor,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              '${game.hashes.length} hashes',
                              style: TextStyle(
                                color: statusColor,
                                fontSize: 9,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGameImage() {
    // Try to load image from network
    final hasImageIcon = game.imageIcon.isNotEmpty;
    final imageUrl = hasImageIcon ? 'https://retroachievements.org${game.imageIcon}' : '';
    
    if (hasImageIcon) {
      return ClipRRect(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(4),
          topRight: Radius.circular(4),
        ),
        child: Image.network(
          imageUrl,
          fit: BoxFit.cover,
          width: double.infinity,
          height: double.infinity,
          errorBuilder: (context, error, stackTrace) {
            return _buildPlaceholderImage();
          },
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return Center(
              child: CircularProgressIndicator(
                value: loadingProgress.expectedTotalBytes != null
                    ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                    : null,
                valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
              ),
            );
          },
        ),
      );
    } else {
      return _buildPlaceholderImage();
    }
  }

  Widget _buildPlaceholderImage() {
    return Container(
      color: AppColors.darkBackground,
      child: const Center(
        child: Icon(
          Icons.videogame_asset,
          color: AppColors.primary,
          size: 48,
        ),
      ),
    );
  }
}