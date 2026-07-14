// lib/screens/dashboard/widgets/progress_bar.dart

import 'package:flutter/material.dart';
import 'package:retroachievements_organizer/constants/constants.dart';

class ProgressBar extends StatelessWidget {
  final double percentage;
  final Color progressColor;
  final double height;

  const ProgressBar({
    super.key,
    required this.percentage,
    required this.progressColor,
    this.height = 8.0,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.darkBackground,
        borderRadius: BorderRadius.circular(4),
      ),
      child: FractionallySizedBox(
        alignment: Alignment.centerLeft,
        widthFactor: percentage / 100,
        child: Container(
          decoration: BoxDecoration(
            color: progressColor,
            borderRadius: BorderRadius.circular(4),
            boxShadow: [
              BoxShadow(
                color: progressColor.withValues(alpha: 0.5),
                blurRadius: 4,
                offset: const Offset(0, 0),
              ),
            ],
          ),
        ),
      ),
    );
  }
}