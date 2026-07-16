// lib/screens/dashboard/components/user_profile_card.dart

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:retroachievements_library/constants/constants.dart';
import 'package:retroachievements_library/models/user_state.dart';
import 'package:retroachievements_library/models/user/user_summary_model.dart';
import 'package:retroachievements_library/models/user/user_awards_model.dart';
import 'package:retroachievements_library/screens/dashboard/utils/dashboard_formatter.dart';
import 'package:retroachievements_library/screens/dashboard/widgets/stat_item.dart';

class UserProfileCard extends StatelessWidget {
  final UserState userState;
  final UserSummary? userSummary;
  final UserAwards? userAwards;

  const UserProfileCard({
    super.key,
    required this.userState,
    required this.userSummary,
    required this.userAwards,
  });

  @override
  Widget build(BuildContext context) {
    final userProfile = userState.userProfile;

    if (userProfile == null) return const SizedBox.shrink();

    return Card(
      color: AppColors.cardBackground,
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // User pic
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppColors.darkBackground,
                border: Border.all(color: AppColors.primary, width: 2),
                borderRadius: BorderRadius.circular(8),
              ),
              child:
                  userState.userPicPath != null
                      ? ClipRRect(
                        borderRadius: BorderRadius.circular(6),
                        child: Image.file(
                          File(userState.userPicPath!),
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            debugPrint('Error loading user pic: $error');
                            return const Icon(
                              Icons.account_circle,
                              color: AppColors.primary,
                              size: 60,
                            );
                          },
                        ),
                      )
                      : const Icon(
                        Icons.account_circle,
                        color: AppColors.primary,
                        size: 60,
                      ),
            ),
            const SizedBox(width: 16),

            // User info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        userProfile.username,
                        style: const TextStyle(
                          color: AppColors.primary,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 8),
                    ],
                  ),
                  const SizedBox(height: 8),

                  // User stats
                  if (userSummary != null)
                    Wrap(
                      spacing: 16,
                      runSpacing: 8,
                      children: [
                        StatItem(
                          icon: Icons.emoji_events,
                          label: 'Total Points',
                          value: DashboardFormatter.formatNumber(
                            userSummary?.totalPoints,
                          ),
                        ),
                        StatItem(
                          icon: Icons.star,
                          label: 'True Points',
                          value: userProfile.totalTruePoints.toString(),
                        ),
                        StatItem(
                          icon: Icons.people,
                          label: 'Rank',
                          value: '#${userSummary?.rank}',
                        ),
                        if (userAwards != null) ...[
                          StatItem(
                            icon: Icons.military_tech,
                            label: 'Mastered',
                            value: DashboardFormatter.formatNumber(
                              userAwards!.masteryAwardsCount,
                            ),
                          ),
                          StatItem(
                            icon: Icons.gamepad,
                            label: 'Beaten',
                            value: DashboardFormatter.formatNumber(
                              userAwards!.beatenHardcoreAwardsCount,
                            ),
                          ),
                          StatItem(
                            icon: Icons.workspace_premium,
                            label: 'Total Awards',
                            value: DashboardFormatter.formatNumber(
                              userAwards!.totalAwardsCount,
                            ),
                          ),
                        ],
                      ],
                    ),
                  const SizedBox(height: 4),

                  // Motto
                  if (userProfile.motto.isNotEmpty)
                    Text(
                      '"${userProfile.motto}"',
                      style: const TextStyle(
                        color: AppColors.textLight,
                        fontSize: 12,
                        fontStyle: FontStyle.italic,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
