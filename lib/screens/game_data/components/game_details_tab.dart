// Updated lib/screens/game_data/components/game_details_tab.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:retroachievements_library/constants/constants.dart';
import 'package:retroachievements_library/models/games/game_extended_model.dart';
import 'package:retroachievements_library/providers/states/games/user_game_progress_state_provider.dart';
import 'package:retroachievements_library/screens/game_data/widgets/achievement_item.dart';

class GameDetailsTab extends ConsumerStatefulWidget {
  final GameExtended? gameExtended;
  final String gameId;

  const GameDetailsTab({
    super.key,
    required this.gameExtended,
    required this.gameId,
  });

  @override
  ConsumerState<GameDetailsTab> createState() => _GameDetailsTabState();
}

class _GameDetailsTabState extends ConsumerState<GameDetailsTab> {
  bool _hideUnlocked = false;
  bool _showOnlyMissable = false;

  @override
  Widget build(BuildContext context) {
    final userGameProgressState = ref.watch(
      userGameProgressProvider(widget.gameId),
    );

    if (userGameProgressState.isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.primary),
      );
    }

    if (userGameProgressState.errorMessage != null) {
      return Center(
        child: Text(
          'Error loading achievements: ${userGameProgressState.errorMessage}',
          style: const TextStyle(color: AppColors.textLight, fontSize: 16),
        ),
      );
    }

    final userGameProgress = userGameProgressState.data;

    if (userGameProgress == null) {
      if (widget.gameExtended == null) {
        return const Center(
          child: Text(
            'No detailed information available for this game.',
            style: TextStyle(color: AppColors.textLight, fontSize: 16),
          ),
        );
      }

      // Fall back to game extended data if user progress isn't available
      final achievements = widget.gameExtended!.getAchievementsList();

      if (achievements.isEmpty) {
        return const Center(
          child: Text(
            'No achievements available for this game.',
            style: TextStyle(color: AppColors.textLight, fontSize: 16),
          ),
        );
      }

      // Just show the achievements without user progress
      return Column(
        children: [
          // Filter options
          _buildFilterOptions(hasUserProgress: false),
          // Achievements list
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: achievements.length,
              itemBuilder: (context, index) {
                final achievement = achievements[index];

                // Check if we should show this achievement based on filter
                final typeValue =
                    achievement['Type'] ?? achievement['type'] ?? '';
                if (_showOnlyMissable &&
                    typeValue.toString().toLowerCase() != 'missable' &&
                    typeValue.toString() != '3') {
                  return const SizedBox.shrink();
                }

                return AchievementItem(
                  achievement: achievement,
                  isUnlocked: false,
                  numDistinctPlayers:
                      widget.gameExtended?.numDistinctPlayers ?? 0,
                );
              },
            ),
          ),
        ],
      );
    }

    // Use user game progress data
    final achievements = userGameProgress.getAchievementsList();

    if (achievements.isEmpty) {
      return const Center(
        child: Text(
          'No achievements available for this game.',
          style: TextStyle(color: AppColors.textLight, fontSize: 16),
        ),
      );
    }

    // Show achievements with user progress
    return Column(
      children: [
        // Filter options
        _buildFilterOptions(hasUserProgress: true),
        // Achievements list
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: achievements.length,
            itemBuilder: (context, index) {
              final achievement = achievements[index];
              final isUnlocked = achievement['isUnlocked'] ?? false;

              // Apply filters
              if (_hideUnlocked && isUnlocked) {
                return const SizedBox.shrink();
              }

              final typeValue =
                  achievement['Type'] ?? achievement['type'] ?? '';
              if (_showOnlyMissable &&
                  typeValue.toString().toLowerCase() != 'missable' &&
                  typeValue.toString() != '3') {
                return const SizedBox.shrink();
              }

              return AchievementItem(
                achievement: achievement,
                isUnlocked: isUnlocked,
                numDistinctPlayers: userGameProgress.numDistinctPlayers,
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildFilterOptions({required bool hasUserProgress}) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(10, 5, 10, 5),
      child: Row(
        children: [
          const Text(
            'Filters:',
            style: TextStyle(color: AppColors.textLight, fontSize: 12),
          ),
          const SizedBox(width: 8),

          // "Show only missable" filter (always visible)
          _buildFilterChip(
            label: 'Show Only Missable',
            selected: _showOnlyMissable,
            onSelected: (value) {
              setState(() {
                _showOnlyMissable = value;
              });
            },
          ),

          const SizedBox(width: 8),

          // "Hide unlocked" filter (only visible if user has progress)
          if (hasUserProgress)
            _buildFilterChip(
              label: 'Hide Unlocked',
              selected: _hideUnlocked,
              onSelected: (value) {
                setState(() {
                  _hideUnlocked = value;
                });
              },
            ),
        ],
      ),
    );
  }

  Widget _buildFilterChip({
    required String label,
    required bool selected,
    required Function(bool) onSelected,
  }) {
    return FilterChip(
      label: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          color: selected ? AppColors.textDark : AppColors.textLight,
        ),
      ),
      selected: selected,
      onSelected: onSelected,
      selectedColor: AppColors.primary,
      backgroundColor: AppColors.darkBackground,
      checkmarkColor: AppColors.textDark,
      visualDensity: VisualDensity.compact,
      padding: EdgeInsets.zero,
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
    );
  }
}
