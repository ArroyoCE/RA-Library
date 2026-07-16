import 'package:flutter/material.dart';
import 'package:retroachievements_library/constants/constants.dart';

enum GameSortOption { nameAsc, nameDesc }

enum GameMatchFilter { all, matched, unmatched }

class GamesFilters extends StatelessWidget {
  final TextEditingController searchController;
  final Function(String) onSearchChanged;
  final GameMatchFilter currentMatchFilter;
  final Function(GameMatchFilter) onMatchFilterChanged;
  final GameSortOption currentSortOption;
  final Function(GameSortOption) onSortChanged;

  const GamesFilters({
    super.key,
    required this.searchController,
    required this.onSearchChanged,
    required this.currentMatchFilter,
    required this.onMatchFilterChanged,
    required this.currentSortOption,
    required this.onSortChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Search bar (now takes less space)
        Expanded(
          flex: 3,
          child: TextField(
            controller: searchController,
            style: const TextStyle(color: AppColors.textLight),
            decoration: InputDecoration(
              hintText: 'Search games...',
              hintStyle: const TextStyle(color: AppColors.textSubtle),
              prefixIcon: const Icon(Icons.search, color: AppColors.primary),
              suffixIcon:
                  searchController.text.isNotEmpty
                      ? IconButton(
                        icon: const Icon(
                          Icons.clear,
                          color: AppColors.textSubtle,
                        ),
                        onPressed: () {
                          searchController.clear();
                          onSearchChanged('');
                        },
                      )
                      : null,
              filled: true,
              fillColor: AppColors.cardBackground,
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: AppColors.primary),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(
                  color: AppColors.primary,
                  width: 2,
                ),
              ),
              contentPadding: const EdgeInsets.symmetric(
                vertical: 8,
                horizontal: 8,
              ),
            ),
            onChanged: onSearchChanged,
          ),
        ),

        const SizedBox(width: 8),

        // Match filter dropdown
        Container(
          decoration: BoxDecoration(
            color: AppColors.cardBackground,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppColors.primary),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<GameMatchFilter>(
              value: currentMatchFilter,
              onChanged: (value) {
                if (value != null) {
                  onMatchFilterChanged(value);
                }
              },
              items: const [
                DropdownMenuItem(
                  value: GameMatchFilter.all,
                  child: Text(
                    'All Games',
                    style: TextStyle(color: AppColors.textLight),
                  ),
                ),
                DropdownMenuItem(
                  value: GameMatchFilter.matched,
                  child: Text(
                    'In Library',
                    style: TextStyle(color: AppColors.textLight),
                  ),
                ),
                DropdownMenuItem(
                  value: GameMatchFilter.unmatched,
                  child: Text(
                    'Not In Library',
                    style: TextStyle(color: AppColors.textLight),
                  ),
                ),
              ],
              dropdownColor: AppColors.darkBackground,
              icon: const Icon(Icons.filter_list, color: AppColors.primary),
            ),
          ),
        ),

        const SizedBox(width: 8),

        // Sorting dropdown
        Container(
          decoration: BoxDecoration(
            color: AppColors.cardBackground,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppColors.primary),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<GameSortOption>(
              value: currentSortOption,
              onChanged: (value) {
                if (value != null) {
                  onSortChanged(value);
                }
              },
              items: const [
                DropdownMenuItem(
                  value: GameSortOption.nameAsc,
                  child: Text(
                    'Name (A-Z)',
                    style: TextStyle(color: AppColors.textLight),
                  ),
                ),
                DropdownMenuItem(
                  value: GameSortOption.nameDesc,
                  child: Text(
                    'Name (Z-A)',
                    style: TextStyle(color: AppColors.textLight),
                  ),
                ),
              ],
              dropdownColor: AppColors.darkBackground,
              icon: const Icon(Icons.sort, color: AppColors.primary),
            ),
          ),
        ),
      ],
    );
  }
}
