// lib/screens/game_data/components/game_header.dart

import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:retroachievements_library/constants/constants.dart';
import 'package:retroachievements_library/models/games/game_extended_model.dart';
import 'package:retroachievements_library/models/games/game_summary_model.dart';
import 'package:retroachievements_library/providers/states/games/user_game_progress_state_provider.dart';
import 'package:retroachievements_library/screens/game_data/utils/game_data_formatter.dart';

class GameHeader extends ConsumerWidget {
  final GameSummary gameSummary;
  final GameExtended? gameExtended;
  final String gameId;

  const GameHeader({
    super.key,
    required this.gameSummary,
    this.gameExtended,
    required this.gameId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch the user game progress provider to get user progress data
    final userGameProgressState = ref.watch(userGameProgressProvider(gameId));
    final userProgress = userGameProgressState.data;

    // Calculate completion percentage
    final completionPercentage =
        userProgress != null
            ? (userProgress.numAwardedToUserHardcore /
                    userProgress.numAchievements) *
                100
            : 0.0;

    // Get appropriate color based on completion percentage
    final progressColor = _getCompletionColor(completionPercentage);

    return Card(
      color: AppColors.cardBackground,
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Game info row with image and details
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Box art
                if (gameSummary.imageBoxArt.isNotEmpty)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: _buildBoxArt(),
                  ),

                const SizedBox(width: 16),

                // Game details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        gameSummary.title,
                        style: const TextStyle(
                          color: AppColors.primary,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),

                      // Console, developer and publisher
                      Row(
                        children: [
                          const Icon(
                            Icons.videogame_asset,
                            color: AppColors.primary,
                            size: 14,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            gameSummary.consoleName,
                            style: const TextStyle(
                              color: AppColors.textLight,
                              fontSize: 12,
                            ),
                          ),
                          if (gameSummary.developer.isNotEmpty) ...[
                            const SizedBox(width: 16),
                            const Icon(
                              Icons.code,
                              color: AppColors.primary,
                              size: 14,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              gameSummary.developer,
                              style: const TextStyle(
                                color: AppColors.textLight,
                                fontSize: 12,
                              ),
                            ),
                          ],
                          if (gameSummary.publisher.isNotEmpty) ...[
                            const SizedBox(width: 16),
                            const Icon(
                              Icons.business,
                              color: AppColors.primary,
                              size: 14,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              gameSummary.publisher,
                              style: const TextStyle(
                                color: AppColors.textLight,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ],
                      ),

                      // Other info (genre, release date, etc.)
                      if (gameSummary.genre.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.category,
                                color: AppColors.primary,
                                size: 16,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Genre: ${gameSummary.genre}',
                                style: const TextStyle(
                                  color: AppColors.textLight,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                      if (gameSummary.released.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.calendar_today,
                                color: AppColors.primary,
                                size: 16,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Released: ${GameDataFormatter.formatReleaseDate(gameSummary.released)}',
                                style: const TextStyle(
                                  color: AppColors.textLight,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                      if (gameExtended != null &&
                          gameExtended!.numDistinctPlayers > 0)
                        Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.auto_graph,
                                color: AppColors.primary,
                                size: 16,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'True Score: ${_calculateTotalTrueScore(gameExtended)}',
                                style: const TextStyle(
                                  color: AppColors.textLight,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                      if (gameExtended != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.people,
                                color: AppColors.primary,
                                size: 16,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Players: ${gameExtended!.numDistinctPlayers}',
                                style: const TextStyle(
                                  color: AppColors.textLight,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                      if (gameExtended != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.emoji_events,
                                color: AppColors.primary,
                                size: 16,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Achievements: ${gameExtended!.numAchievements}',
                                style: const TextStyle(
                                  color: AppColors.textLight,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.stars,
                              color: AppColors.primary,
                              size: 16,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Points: ${_calculatePoints(gameSummary, gameExtended)}',
                              style: const TextStyle(
                                color: AppColors.textLight,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            // User progress section (only show if data is available)
            if (userProgress?.numAwardedToUserHardcore != null &&
                userProgress!.numAwardedToUserHardcore > 0) ...[
              const SizedBox(height: 12),
              const Divider(color: AppColors.primary, height: 1),
              const SizedBox(height: 12),

              // Progress row with all stats side by side
              Row(
                children: [
                  // Title
                  const Text(
                    'User Progress:',
                    style: TextStyle(
                      color: AppColors.primary,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 12),

                  // Achievements
                  Row(
                    children: [
                      const Icon(
                        Icons.emoji_events,
                        color: AppColors.primary,
                        size: 14,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${userProgress.numAwardedToUserHardcore}/${userProgress.numAchievements}',
                        style: const TextStyle(
                          color: AppColors.textLight,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 12),

                  // Points
                  Row(
                    children: [
                      const Icon(
                        Icons.stars,
                        color: AppColors.primary,
                        size: 14,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        _getPointsFromProgress(userProgress),
                        style: const TextStyle(
                          color: AppColors.textLight,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 12),

                  // True Points
                  Row(
                    children: [
                      const Icon(
                        Icons.auto_graph,
                        color: AppColors.primary,
                        size: 14,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        _calculateUserTruePoints(userProgress, gameExtended),
                        style: const TextStyle(
                          color: AppColors.textLight,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              // If mastered or beaten, show a badge
              if (userProgress.highestAwardKind == 'mastered' ||
                  userProgress.highestAwardKind == 'beaten-hardcore') ...[
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(
                      userProgress.highestAwardKind == 'mastered'
                          ? Icons.workspace_premium
                          : Icons.military_tech,
                      color: progressColor,
                      size: 14,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      _formatAwardKind(userProgress.highestAwardKind),
                      style: TextStyle(
                        color: progressColor,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (userProgress.highestAwardDate.isNotEmpty) ...[
                      const SizedBox(width: 8),
                      Text(
                        'on ${_formatDate(userProgress.highestAwardDate)}',
                        style: const TextStyle(
                          color: AppColors.textSubtle,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ],
          ],
        ),
      ),
    );
  }

  // Helper to build a progress stat item

  // Format date in a user-friendly way
  String _formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
    } catch (e) {
      return dateString.split('T')[0]; // Fallback if parsing fails
    }
  }

  // Format award kind in a user-friendly way
  String _formatAwardKind(String awardKind) {
    switch (awardKind) {
      case 'mastered':
        return 'Mastered';
      case 'beaten-hardcore':
        return 'Beaten (Hardcore)';
      case 'beaten-softcore':
        return 'Beaten (Softcore)';
      default:
        return awardKind
            .split('-')
            .map(
              (word) => word.substring(0, 1).toUpperCase() + word.substring(1),
            )
            .join(' ');
    }
  }

  // Get appropriate color based on completion percentage
  Color _getCompletionColor(double percentage) {
    if (percentage >= 100) {
      return Colors.amber; // Gold for 100%
    } else if (percentage >= 80) {
      return AppColors.primary; // Primary for high completion
    } else if (percentage >= 50) {
      return AppColors.success; // Green for medium completion
    } else if (percentage >= 25) {
      return AppColors.warning; // Yellow for low completion
    } else {
      return AppColors.error; // Red for very low completion
    }
  }

  // Extract points earned from user progress
  String _getPointsFromProgress(dynamic userProgress) {
    int earnedPoints = 0;
    int totalPoints = 0;

    if (userProgress.achievements != null) {
      userProgress.achievements.forEach((id, achievement) {
        final points =
            int.tryParse(achievement['Points']?.toString() ?? '0') ?? 0;
        totalPoints += points;

        if (achievement['DateEarnedHardcore'] != null) {
          earnedPoints += points;
        }
      });
    }

    return '$earnedPoints/$totalPoints';
  }

  // Calculate user true points for their earned achievements
  String _calculateUserTruePoints(
    dynamic userProgress,
    GameExtended? gameExtended,
  ) {
    if (gameExtended == null ||
        gameExtended.numDistinctPlayers <= 0 ||
        userProgress == null) {
      return 'N/A';
    }

    double earnedTruePoints = 0;
    double totalTruePoints = 0;
    int numDistinctPlayers = gameExtended.numDistinctPlayers;

    if (userProgress.achievements != null) {
      userProgress.achievements.forEach((id, achievement) {
        if (achievement is Map) {
          final points =
              int.tryParse(achievement['Points']?.toString() ?? '0') ?? 0;
          final numAwardedHardcore =
              int.tryParse(
                achievement['NumAwardedHardcore']?.toString() ?? '0',
              ) ??
              1;

          // Calculate the ratio
          double ratio = numDistinctPlayers / numAwardedHardcore;
          // Calculate true score
          double trueScore = points * sqrt(ratio);

          totalTruePoints += trueScore;

          // Add to earned true points if achievement is earned
          if (achievement['DateEarnedHardcore'] != null) {
            earnedTruePoints += trueScore;
          }
        }
      });
    }

    return '${earnedTruePoints.toStringAsFixed(0)}/${totalTruePoints.toStringAsFixed(0)}';
  }

  String _calculatePoints(GameSummary gameSummary, GameExtended? gameExtended) {
    // First try to use points from gameSummary
    if (gameSummary.points > 0) {
      return gameSummary.points.toString();
    }

    // If game summary points are 0, calculate from achievements if available
    if (gameExtended != null &&
        gameExtended.achievements != null &&
        gameExtended.achievements!.isNotEmpty) {
      int totalPoints = 0;

      gameExtended.achievements!.forEach((id, achievement) {
        if (achievement is Map && achievement.containsKey('Points')) {
          final points = achievement['Points'];
          if (points != null) {
            totalPoints += int.tryParse(points.toString()) ?? 0;
          }
        }
      });

      return totalPoints.toString();
    }

    // If neither is available, return "Unknown"
    return "Unknown";
  }

  String _calculateTotalTrueScore(GameExtended? gameExtended) {
    if (gameExtended == null ||
        gameExtended.achievements == null ||
        gameExtended.achievements!.isEmpty) {
      return "Unknown";
    }

    double totalTrueScore = 0;
    int numDistinctPlayers = gameExtended.numDistinctPlayers;

    gameExtended.achievements!.forEach((id, achievement) {
      if (achievement is Map) {
        totalTrueScore += _calculateTrueScore(
          achievement.cast<String, dynamic>(),
          numDistinctPlayers,
        );
      }
    });

    // Round to 2 decimal places for display
    return totalTrueScore.toStringAsFixed(0);
  }

  double _calculateTrueScore(
    Map<String, dynamic> achievement,
    int numDistinctPlayers,
  ) {
    // Extract points and numAwardedHardcore from the achievement
    final points = int.tryParse(achievement['Points']?.toString() ?? '0') ?? 0;
    final numAwardedHardcore =
        int.tryParse(achievement['NumAwardedHardcore']?.toString() ?? '0') ??
        1; // Default to 1 to avoid division by zero

    // Calculate the ratio
    double ratio = numDistinctPlayers / numAwardedHardcore;

    // Calculate true score using the formula: points * sqrt(ratio)
    double trueScore = points * sqrt(ratio);

    return trueScore;
  }

  Widget _buildBoxArt() {
    return Image.network(
      'https://retroachievements.org${gameSummary.imageBoxArt}',
      width: 140,
      height: 180,
      fit: BoxFit.contain,
      errorBuilder: (context, error, stackTrace) {
        return _buildBoxArtPlaceholder();
      },
    );
  }

  Widget _buildBoxArtPlaceholder() {
    return Container(
      width: 100,
      height: 140,
      color: AppColors.darkBackground,
      child: const Icon(Icons.image, color: AppColors.primary, size: 50),
    );
  }
}
