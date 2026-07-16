// lib/screens/dashboard/utils/completion_color_helper.dart

import 'package:flutter/material.dart';
import 'package:retroachievements_library/constants/constants.dart';

class CompletionColorHelper {
  static Color getCompletionColor(double percentage) {
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
}
