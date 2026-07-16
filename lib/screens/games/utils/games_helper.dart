// lib/screens/games_screen/utils/games_helper.dart

import 'package:flutter/material.dart';
import 'package:retroachievements_library/constants/constants.dart';
import 'package:intl/intl.dart';

class GamesHelper {
  // Format points with K suffix for large values
  static String formatPoints(int points) {
    if (points >= 1000) {
      return '${(points / 1000).toStringAsFixed(1)}K';
    }
    return points.toString();
  }

  // Format date in a user-friendly way
  static String formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      final now = DateTime.now();
      final difference = now.difference(date);

      if (difference.inDays < 1) {
        if (difference.inHours < 1) {
          return '${difference.inMinutes} min ago';
        }
        return '${difference.inHours} hours ago';
      } else if (difference.inDays == 1) {
        return 'Yesterday';
      } else if (difference.inDays < 7) {
        return '${difference.inDays} days ago';
      } else if (difference.inDays < 30) {
        return '${(difference.inDays / 7).floor()} weeks ago';
      } else {
        return DateFormat('yyyy-MM-dd').format(date);
      }
    } catch (e) {
      // Return the original string if it can't be parsed
      return dateString.split(' ')[0]; // Just return the date part
    }
  }

  // Get color based on the match status
  static Color getMatchStatusColor(bool isMatched) {
    return isMatched ? AppColors.success : AppColors.error;
  }

  // Get a user-friendly description of the hash type
  static String getHashDescription(String hash) {
    if (hash.isEmpty) {
      return 'Unknown';
    }

    if (hash.length == 32) {
      return 'MD5';
    } else if (hash.length == 40) {
      return 'SHA-1';
    } else if (hash.length == 8) {
      return 'CRC32';
    } else {
      return 'Custom (${hash.length} chars)';
    }
  }
}
