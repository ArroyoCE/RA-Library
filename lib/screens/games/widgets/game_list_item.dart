// lib/screens/games/widgets/game_list_item.dart

import 'package:flutter/material.dart';
import 'package:retroachievements_organizer/constants/constants.dart';
import 'package:retroachievements_organizer/models/consoles/all_game_hash.dart';
import 'package:retroachievements_organizer/models/local/hash_match_model.dart';
import 'package:retroachievements_organizer/screens/games/utils/games_helper.dart';
import 'package:retroachievements_organizer/screens/games/utils/hash_matching.dart';

class GameListItem extends StatelessWidget {
  final GameHash game;
  final VoidCallback onTap;
  final MatchStatus? matchStatus;
  final bool isHashingInProgress;

  const GameListItem({
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
      margin: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        onTap:  isHashingInProgress ? null : onTap,
        borderRadius: BorderRadius.circular(4),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              // Game icon
              SizedBox(
                width: 70,
                height: 70,
                child: _buildGameImage(),
              ),
              const SizedBox(width: 16),
              
              // Game info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      game.title,
                      style: const TextStyle(
                        color: AppColors.textLight,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    
                    const SizedBox(height: 4),
                    
                    // Achievements count and points
                    Row(
                      children: [
                        const Icon(
                          Icons.emoji_events,
                          color: AppColors.primary,
                          size: 14,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${game.numAchievements} achievements (${GamesHelper.formatPoints(game.points)} points)',
                          style: const TextStyle(
                            color: AppColors.textLight,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 4),
                    
                    // Match status and date modified
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: statusColor.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(
                              color: statusColor,
                              width: 1,
                            ),
                          ),
                          child: Text(
                            statusText,
                            style: TextStyle(
                              color: statusColor,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        
                      ],
                    ),
                    
                    // Hash count
                    const SizedBox(height: 4),
                    Text(
                      'Hashes: ${game.hashes.length}',
                      style: const TextStyle(
                        color: AppColors.textSubtle,
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
              ),
              
              // Right chevron
              const Icon(
                Icons.chevron_right,
                color: AppColors.primary,
                size: 24,
              ),
            ],
          ),
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
        borderRadius: BorderRadius.circular(4),
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
      decoration: BoxDecoration(
        color: AppColors.darkBackground,
        borderRadius: BorderRadius.circular(4),
      ),
      child: const Center(
        child: Icon(
          Icons.videogame_asset,
          color: AppColors.primary,
          size: 32,
        ),
      ),
    );
  }
}