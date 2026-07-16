// lib/screens/achievements/components/achievement_header.dart

import 'package:flutter/material.dart';
import 'package:retroachievements_library/constants/constants.dart';

class AchievementHeader extends StatelessWidget {
  final VoidCallback onSort;
  final VoidCallback onFilter;
  final VoidCallback onRefresh;
  final bool isFilterExpanded;
  final int gamesPlayed;
  final int totalMastered;
  final int totalBeaten;

  const AchievementHeader({
    super.key,
    required this.onSort,
    required this.onFilter,
    required this.onRefresh,
    required this.isFilterExpanded,
    required this.gamesPlayed,
    required this.totalMastered,
    required this.totalBeaten,
  });

  @override
  Widget build(BuildContext context) {
    final unfinished = gamesPlayed - totalBeaten;

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF1E293B), // Deep Slate
            Color(0xFF0F172A), // Darker Slate
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.05),
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Row: Title and Actions
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'My Achievements',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.5,
                  ),
                ),
                Row(
                  children: [
                    _buildActionButton(
                      icon: Icons.sort_rounded,
                      label: 'Sort',
                      onPressed: onSort,
                      isActive: false,
                    ),
                    const SizedBox(width: 8),
                    _buildActionButton(
                      icon: Icons.filter_list_rounded,
                      label: 'Filter',
                      onPressed: onFilter,
                      isActive: isFilterExpanded,
                    ),
                    const SizedBox(width: 8),
                    _buildActionButton(
                      icon: Icons.refresh_rounded,
                      label: 'Refresh',
                      onPressed: onRefresh,
                      isActive: false,
                    ),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Stats Row
            Row(
              children: [
                Expanded(
                  child: _buildStatMiniCard(
                    'Played',
                    gamesPlayed.toString(),
                    Icons.videogame_asset,
                    Colors.amber,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildStatMiniCard(
                    'Unfinished',
                    unfinished.toString(),
                    Icons.hourglass_empty,
                    AppColors.info,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildStatMiniCard(
                    'Beaten',
                    totalBeaten.toString(),
                    Icons.military_tech,
                    AppColors.success,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildStatMiniCard(
                    'Mastered',
                    totalMastered.toString(),
                    Icons.workspace_premium,
                    AppColors.primary,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
    required bool isActive,
  }) {
    return Material(
      color:
          isActive
              ? AppColors.primary.withValues(alpha: 0.2)
              : Colors.white.withValues(alpha: 0.05),
      borderRadius: BorderRadius.circular(16),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onPressed,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 18,
                color:
                    isActive
                        ? AppColors.primary
                        : Colors.white.withValues(alpha: 0.9),
              ),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  color:
                      isActive
                          ? AppColors.primary
                          : Colors.white.withValues(alpha: 0.9),
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatMiniCard(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.03),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  height: 1.1,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                label,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.5),
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  textBaseline: TextBaseline.alphabetic,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
