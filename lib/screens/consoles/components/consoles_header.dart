// lib/screens/consoles/components/consoles_header.dart

import 'package:flutter/material.dart';
import 'package:retroachievements_library/constants/constants.dart';

class ConsolesHeader extends StatelessWidget {
  final VoidCallback onViewToggle;
  final VoidCallback onRefresh;
  final bool isGridView;
  final bool isUpdating;

  const ConsolesHeader({
    super.key,
    required this.onViewToggle,
    required this.onRefresh,
    required this.isGridView,
    this.isUpdating = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          AppStrings.myGames,
          style: TextStyle(
            color: AppColors.textLight,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        Row(
          children: [
            // View toggle button
            IconButton(
              icon: Icon(
                isGridView ? Icons.view_list : Icons.grid_view,
                color:
                    isUpdating
                        ? AppColors.textLight.withValues(alpha: 0.3)
                        : AppColors.primary,
              ),
              onPressed: isUpdating ? null : onViewToggle,
              tooltip:
                  isGridView ? 'Switch to list view' : 'Switch to grid view',
            ),
            // Refresh button
            IconButton(
              icon: Icon(
                Icons.refresh,
                color:
                    isUpdating
                        ? AppColors.textLight.withValues(alpha: 0.3)
                        : AppColors.primary,
              ),
              onPressed: isUpdating ? null : onRefresh,
              tooltip: 'Refresh consoles',
            ),
          ],
        ),
      ],
    );
  }
}
