// lib/screens/games_screen/components/games_header.dart

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:retroachievements_library/constants/constants.dart';

class GamesHeader extends StatelessWidget {
  final String consoleName;
  final VoidCallback onViewToggle;
  final VoidCallback onRefresh;
  final bool isGridView;
  final bool isHashingInProgress; // Add this parameter

  const GamesHeader({
    super.key,
    required this.consoleName,
    required this.onViewToggle,
    required this.onRefresh,
    required this.isGridView,
    this.isHashingInProgress = false, // Default to false
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                // Back button - disabled when hashing is in progress
                IconButton(
                  icon: const Icon(Icons.arrow_back, color: AppColors.primary),
                  onPressed:
                      isHashingInProgress
                          ? null // Disable the button
                          : () => context.go('/games'),
                  tooltip:
                      isHashingInProgress
                          ? 'Please wait until hashing completes'
                          : 'Back to consoles',
                ),
                // Screen title
                const Text(
                  'Games Library',
                  style: TextStyle(
                    color: AppColors.textLight,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            Row(
              children: [
                // View toggle button - can be disabled during hashing too
                IconButton(
                  icon: Icon(
                    isGridView ? Icons.view_list : Icons.grid_view,
                    color: AppColors.primary,
                  ),
                  onPressed: isHashingInProgress ? null : onViewToggle,
                  tooltip:
                      isGridView
                          ? 'Switch to list view'
                          : 'Switch to grid view',
                ),
                // Refresh button - should be disabled during hashing
                IconButton(
                  icon: const Icon(Icons.refresh, color: AppColors.primary),
                  onPressed: isHashingInProgress ? null : onRefresh,
                  tooltip: 'Refresh games',
                ),
              ],
            ),
          ],
        ),
        Text(
          consoleName,
          style: const TextStyle(
            color: AppColors.primary,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
