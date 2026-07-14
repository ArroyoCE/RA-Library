// lib/screens/dashboard/widgets/award_item.dart

import 'package:flutter/material.dart';
import 'package:retroachievements_organizer/constants/constants.dart';
import 'package:retroachievements_organizer/models/user/user_awards_model.dart';
import 'package:retroachievements_organizer/screens/dashboard/utils/dashboard_formatter.dart';

class AwardItem extends StatelessWidget {
  final UserAward award;

  const AwardItem({
    super.key, 
    required this.award,
  });

  @override
  Widget build(BuildContext context) {
    // Determine award icon and color
    IconData awardIcon;
    Color awardColor;

    switch (award.awardType) {
      case 'Game Beaten':
        awardIcon = Icons.military_tech;
        awardColor = AppColors.success;
        break;
      case 'Mastery':
        awardIcon = Icons.workspace_premium;
        awardColor = Colors.amber;
        break;
      case 'Event':
        awardIcon = Icons.celebration;
        awardColor = AppColors.info;
        break;
      default:
        awardIcon = Icons.emoji_events;
        awardColor = AppColors.primary;
    }

    return Container(
      width: 140,
      margin: const EdgeInsets.only(right: 12),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: AppColors.darkBackground,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: awardColor.withValues(alpha: 0.5)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Use network image for award badge if available
          if (award.imageIcon.isNotEmpty)
            Container(
              height: 60,
              width: 60,
              decoration: BoxDecoration(
                color: awardColor.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(30),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(30),
                child: Image.network(
                  'https://retroachievements.org${award.imageIcon}',
                  width: 60,
                  height: 60,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Icon(awardIcon, color: awardColor, size: 40);
                  },
                ),
              ),
            )
          else
            Icon(awardIcon, color: awardColor, size: 40),
          
          const SizedBox(height: 8),
          Text(
            award.title,
            style: TextStyle(
              color: awardColor,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
            maxLines: 2,
            textAlign: TextAlign.center,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Text(
            award.awardType,
            style: const TextStyle(
              color: AppColors.textSubtle,
              fontSize: 10,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          if (award.awardedAt.isNotEmpty)
            Text(
              DashboardFormatter.formatShortDate(award.awardedAt),
              style: const TextStyle(
                color: AppColors.textSubtle,
                fontSize: 10,
              ),
            ),
        ],
      ),
    );
  }
}