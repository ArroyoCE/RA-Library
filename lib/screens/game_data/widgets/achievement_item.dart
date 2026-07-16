// Updated lib/screens/game_data/widgets/achievement_item.dart

import 'dart:math';

import 'package:flutter/material.dart';
import 'package:retroachievements_library/constants/constants.dart';

class AchievementItem extends StatelessWidget {
  final Map<String, dynamic> achievement;
  final bool isUnlocked;
  final int numDistinctPlayers; // Add this parameter

  const AchievementItem({
    super.key,
    required this.achievement,
    required this.isUnlocked,
    this.numDistinctPlayers = 0, // Default to 0
  });

  @override
  Widget build(BuildContext context) {
    final int points = achievement['Points'] ?? 0;
    final String title = achievement['Title'] ?? 'Unknown Achievement';
    final String description = achievement['Description'] ?? '';
    final int numAwarded = achievement['NumAwarded'] ?? 0;
    final int numAwardedHardcore = achievement['NumAwardedHardcore'] ?? 0;
    final String badgeName = achievement['BadgeName'] ?? '';
    final String type =
        (achievement['Type'] ?? achievement['type'] ?? '').toString();

    return Card(
      color:
          isUnlocked
              ? AppColors.success.withValues(alpha: 0.2)
              : AppColors.cardBackground,
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Badge image or points badge
            _buildBadge(badgeName, points),

            const SizedBox(width: 12),

            // Achievement details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title and type icon
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          title,
                          style: TextStyle(
                            color:
                                isUnlocked
                                    ? AppColors.success
                                    : AppColors.primary,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Icon(
                        isUnlocked
                            ? Icons.check_circle
                            : (type == 'progression'
                                ? Icons.linear_scale
                                : Icons.emoji_events),
                        color:
                            isUnlocked ? AppColors.success : AppColors.primary,
                        size: 16,
                      ),
                    ],
                  ),

                  // Description
                  if (description.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        description,
                        style: const TextStyle(
                          color: AppColors.textLight,
                          fontSize: 14,
                        ),
                      ),
                    ),

                  // Points and unlock date if available
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Row(
                      children: [
                        Text(
                          '$points points',
                          style: TextStyle(
                            color:
                                isUnlocked
                                    ? AppColors.success
                                    : AppColors.primary,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'True Score: ${_calculateTrueScore().toStringAsFixed(2)}',
                          style: const TextStyle(
                            color: Colors.amber,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Spacer(),
                        if (isUnlocked &&
                            achievement['DateEarnedHardcore'] != null)
                          Text(
                            'Unlocked: ${_formatDate(achievement['DateEarnedHardcore'])}',
                            style: const TextStyle(
                              color: AppColors.success,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          )
                        else
                          Row(
                            children: [
                              const Icon(
                                Icons.people,
                                color: AppColors.textSubtle,
                                size: 12,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                'Unlocked by $numAwarded ($numAwardedHardcore HC)',
                                style: const TextStyle(
                                  color: AppColors.textSubtle,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  double _calculateTrueScore() {
    final int points = achievement['Points'] ?? 0;

    // Early return if no player data
    if (numDistinctPlayers <= 0) return points.toDouble();

    final int numAwardedHardcore = achievement['NumAwardedHardcore'] ?? 1;

    // Avoid division by zero
    if (numAwardedHardcore <= 0) return points.toDouble();

    // Calculate the ratio
    double ratio = numDistinctPlayers / numAwardedHardcore;

    // Calculate true score using the formula: points * sqrt(ratio)
    double trueScore = points * sqrt(ratio);

    return trueScore;
  }

  String _formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
    } catch (e) {
      return dateString;
    }
  }

  Widget _buildBadge(String badgeName, int points) {
    // Check if we have a valid badge name
    if (badgeName.isNotEmpty) {
      // In a real app, you'd load the badge image here
      return ClipRRect(
        borderRadius: BorderRadius.circular(4),
        child: Image.network(
          'https://retroachievements.org/Badge/$badgeName.png',
          width: 64,
          height: 64,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return _buildPointsBadge(points);
          },
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return const SizedBox(
              width: 64,
              height: 64,
              child: Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                  strokeWidth: 2,
                ),
              ),
            );
          },
        ),
      );
    }

    // If no badge name, use points badge
    return _buildPointsBadge(points);
  }

  Widget _buildPointsBadge(int points) {
    return Container(
      width: 64,
      height: 64,
      decoration: BoxDecoration(
        color: isUnlocked ? AppColors.success : AppColors.primary,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Center(
        child: Text(
          points.toString(),
          style: TextStyle(
            color: AppColors.textDark,
            fontSize: points > 99 ? 18 : 24,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
