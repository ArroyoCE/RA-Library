// lib/screens/achievements/components/achievement_filters.dart

import 'package:flutter/material.dart';
import 'package:retroachievements_organizer/constants/constants.dart';
import 'package:retroachievements_organizer/screens/achievements/utils/achievement_sorter.dart';

class AchievementFilters extends StatefulWidget {
  final CompletionFilterStatus completionStatus;
  final Set<String> selectedPlatforms;
  final List<dynamic> games;
  final Function({CompletionFilterStatus? completionStatus, Set<String>? selectedPlatforms}) onFilterChanged;
  final VoidCallback onClearFilters;

  const AchievementFilters({
    super.key,
    required this.completionStatus,
    required this.selectedPlatforms,
    required this.games,
    required this.onFilterChanged,
    required this.onClearFilters,
  });

  @override
  State<AchievementFilters> createState() => _AchievementFiltersState();
}

class _AchievementFiltersState extends State<AchievementFilters> {
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Get unique console names from results
    Set<String> consoleNames = {};
    for (var game in widget.games) {
      final consoleName = game.consoleName;
      if (consoleName.isNotEmpty) {
        consoleNames.add(consoleName);
      }
    }
    final platforms = consoleNames.toList()..sort();
    
    // Determine if any filters are active
    final bool hasActiveFilters = widget.completionStatus != CompletionFilterStatus.all || widget.selectedPlatforms.isNotEmpty;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxHeight: 180),
        child: RawScrollbar(
          controller: _scrollController,
          thumbColor: AppColors.primary.withValues(alpha: 0.5),
          radius: const Radius.circular(4),
          thickness: 6,
          thumbVisibility: true,
          child: SingleChildScrollView(
            controller: _scrollController,
            padding: const EdgeInsets.only(right: 12),
            child: Wrap(
              spacing: 6,
              runSpacing: 6,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                // 1. Clear Filters Button (Always to the left if active)
                if (hasActiveFilters)
                  ActionChip(
                    visualDensity: VisualDensity.compact,
                    backgroundColor: AppColors.error.withValues(alpha: 0.1),
                    side: BorderSide(color: AppColors.error.withValues(alpha: 0.3)),
                    label: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.clear, size: 14, color: AppColors.error),
                        SizedBox(width: 4),
                        Text('Clear', style: TextStyle(color: AppColors.error, fontWeight: FontWeight.bold, fontSize: 12)),
                      ],
                    ),
                    onPressed: widget.onClearFilters,
                  ),
                
                // 2. Completion Status Chips
                _buildCompletionChip('Show All', CompletionFilterStatus.all, Icons.list),
                _buildCompletionChip('Completed', CompletionFilterStatus.completedOnly, Icons.emoji_events),
                _buildCompletionChip('Unfinished', CompletionFilterStatus.hideCompleted, Icons.hourglass_empty),

                if (platforms.isNotEmpty)
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    height: 24,
                    child: VerticalDivider(color: Colors.white.withValues(alpha: 0.1), width: 1),
                  ),
                
                // 3. Platform Chips
                ...platforms.map((platform) {
                  final isSelected = widget.selectedPlatforms.contains(platform);
                  return FilterChip(
                    visualDensity: VisualDensity.compact,
                    label: Text(platform),
                    selected: isSelected,
                    selectedColor: AppColors.primary.withValues(alpha: 0.2),
                    checkmarkColor: AppColors.primary,
                    backgroundColor: AppColors.darkBackground,
                    side: BorderSide(
                      color: isSelected 
                          ? AppColors.primary.withValues(alpha: 0.5) 
                          : Colors.white.withValues(alpha: 0.1),
                    ),
                    labelStyle: TextStyle(
                      fontSize: 12, // Smaller font for platforms
                      color: isSelected ? AppColors.primary : AppColors.textLight,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                    onSelected: (selected) {
                      final newSelectedPlatforms = Set<String>.from(widget.selectedPlatforms);
                      if (selected) {
                        newSelectedPlatforms.add(platform);
                      } else {
                        newSelectedPlatforms.remove(platform);
                      }
                      widget.onFilterChanged(selectedPlatforms: newSelectedPlatforms);
                    },
                  );
                }),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCompletionChip(String label, CompletionFilterStatus status, IconData icon) {
    final isSelected = widget.completionStatus == status;
    return FilterChip(
      visualDensity: VisualDensity.compact,
      showCheckmark: false,
      selected: isSelected,
      selectedColor: AppColors.info.withValues(alpha: 0.2),
      backgroundColor: AppColors.darkBackground,
      side: BorderSide(
        color: isSelected 
            ? AppColors.info.withValues(alpha: 0.5) 
            : Colors.white.withValues(alpha: 0.1),
      ),
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 14,
            color: isSelected ? AppColors.info : AppColors.textLight,
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: isSelected ? AppColors.info : AppColors.textLight,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
      onSelected: (_) => widget.onFilterChanged(completionStatus: status),
    );
  }
}