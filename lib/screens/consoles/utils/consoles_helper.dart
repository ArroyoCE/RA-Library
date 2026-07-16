// lib/screens/consoles/utils/consoles_helper.dart

import 'package:flutter/material.dart';
import 'package:retroachievements_library/constants/constants.dart';

class ConsolesHelper {
  // Get appropriate color based on completion percentage
  static Color getCompletionColor(double percentage) {
    if (percentage >= 90) {
      return Colors.amber; // Gold for near completion
    } else if (percentage >= 70) {
      return AppColors.primary; // Primary for high completion
    } else if (percentage >= 40) {
      return AppColors.success; // Green for medium completion
    } else if (percentage >= 20) {
      return AppColors.warning; // Yellow for low completion
    } else {
      return AppColors.error; // Red for very low completion
    }
  }

  // Convert hash method to descriptive string
  static String hashMethodToString(String hashMethod) {
    switch (hashMethod.toLowerCase()) {
      case 'md5':
        return 'MD5';
      case 'sha1':
        return 'SHA-1';
      case 'crc32':
        return 'CRC32';
      default:
        return hashMethod;
    }
  }
}
