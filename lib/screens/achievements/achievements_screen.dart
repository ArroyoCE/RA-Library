// lib/screens/achievements_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:retroachievements_organizer/constants/constants.dart';
import 'package:retroachievements_organizer/models/user/all_completion_model.dart';
import 'package:retroachievements_organizer/providers/states/user/all_completion_state_provider.dart';
import 'package:retroachievements_organizer/providers/states/user/user_awards_state_provider.dart';
import 'package:retroachievements_organizer/screens/achievements/components/achievement_filters.dart';
import 'package:retroachievements_organizer/screens/achievements/components/achievement_header.dart';
import 'package:retroachievements_organizer/screens/achievements/components/games_list.dart';
import 'package:retroachievements_organizer/screens/achievements/utils/achievement_sorter.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AchievementsScreen extends ConsumerStatefulWidget {
  final Widget child;

  const AchievementsScreen({super.key, required this.child});

  @override
  ConsumerState<AchievementsScreen> createState() => _AchievementsScreenState();
}

class _AchievementsScreenState extends ConsumerState<AchievementsScreen> with AutomaticKeepAliveClientMixin {
  @override
  Widget build(BuildContext context) {
    super.build(context);
    return widget.child;
  }
  
  @override
  bool get wantKeepAlive => true;
}

class AchievementsContent extends ConsumerStatefulWidget {
  const AchievementsContent({super.key});

  @override
  ConsumerState<AchievementsContent> createState() => _AchievementsContentState();
}

class _AchievementsContentState extends ConsumerState<AchievementsContent> with AutomaticKeepAliveClientMixin {
  SortOption _currentSortOption = SortOption.alphabeticalAsc;
  CompletionFilterStatus _completionStatus = CompletionFilterStatus.all;
  Set<String> _selectedPlatforms = {};
  bool _isFilterExpanded = false;
  List<dynamic> _filteredGames = [];
  bool _initialLoadComplete = false; // Add this flag

  @override
  void initState() {
    super.initState();
    _loadSavedPreferences();
    
    // Initial data load
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initialDataLoad();
    });
  }


  Future<void> _initialDataLoad() async {
    setState(() {
      _initialLoadComplete = false; // Ensure loading indicator shows
    });
    
    try {
      // Load both providers in parallel
      await Future.wait([
        ref.read(completionProgressStateProvider.notifier).loadData(),
        ref.read(userAwardsStateProvider.notifier).loadData(),
      ]);
      
      // Apply filters to loaded data
      _applyFiltersAndSort();
      
      if (mounted) {
        setState(() {
          _initialLoadComplete = true;
        });
      }
    } catch (e) {
      debugPrint('Error in initial data load: $e');
      if (mounted) {
        setState(() {
          _initialLoadComplete = true; // Still set to true to hide loading indicator
        });
      }
    }
  }

  // Load saved user preferences
  Future<void> _loadSavedPreferences() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Load sort option
      final savedSortOption = prefs.getInt('achievements_sort_option');
      if (savedSortOption != null && savedSortOption < SortOption.values.length) {
        setState(() {
          _currentSortOption = SortOption.values[savedSortOption];
        });
      }
      
      // Load completion status
      final savedCompletionStatus = prefs.getString('achievements_completion_status');
      if (savedCompletionStatus != null) {
        setState(() {
          _completionStatus = CompletionFilterStatus.values.firstWhere(
            (e) => e.toString() == savedCompletionStatus,
            orElse: () => CompletionFilterStatus.all,
          );
        });
      }
      
      // Load selected platforms
      final savedSelectedPlatforms = prefs.getStringList('achievements_selected_platforms');
      if (savedSelectedPlatforms != null) {
        setState(() {
          _selectedPlatforms = savedSelectedPlatforms.toSet();
        });
      }
      
      // Load filter expanded state
      final savedFilterExpanded = prefs.getBool('achievements_filter_expanded');
      if (savedFilterExpanded != null) {
        setState(() {
          _isFilterExpanded = savedFilterExpanded;
        });
      }
    } catch (e) {
      debugPrint('Error loading saved preferences: $e');
    }
  }

  // Save user preferences
  Future<void> _savePreferences() async {
  if (!mounted) return;
  
  try {
    final prefs = await SharedPreferences.getInstance();
    
    // Save sort option
    await prefs.setInt('achievements_sort_option', _currentSortOption.index);
    
    // Save completion status
    await prefs.setString('achievements_completion_status', _completionStatus.toString());
    
    // Save selected platforms
    await prefs.setStringList('achievements_selected_platforms', _selectedPlatforms.toList());
    
    // Save filter expanded state
    await prefs.setBool('achievements_filter_expanded', _isFilterExpanded);
  } catch (e) {
    debugPrint('Error saving preferences: $e');
  }
}


  // Refresh all data
  Future<void> _refreshData() async {
    setState(() {
      _initialLoadComplete = false; // Show loading during refresh
    });
    
    try {
      await Future.wait([
        ref.read(completionProgressStateProvider.notifier).loadData(forceRefresh: true),
        ref.read(userAwardsStateProvider.notifier).loadData(forceRefresh: true),
      ]);
      
      _applyFiltersAndSort();
      
      if (mounted) {
        setState(() {
          _initialLoadComplete = true;
        });
      }
    } catch (e) {
      debugPrint('Error refreshing data: $e');
      if (mounted) {
        setState(() {
          _initialLoadComplete = true;
        });
      }
    }
  }

  // Toggle filter panel
  void _toggleFilterPanel() {
    setState(() {
      _isFilterExpanded = !_isFilterExpanded;
    });
    _savePreferences();
  }

  // Update sort option

  // Update filter options
  void _updateFilterOptions({
    CompletionFilterStatus? completionStatus,
    Set<String>? selectedPlatforms,
  }) {
    setState(() {
      if (completionStatus != null) {
        _completionStatus = completionStatus;
      }
      
      if (selectedPlatforms != null) {
        _selectedPlatforms = selectedPlatforms;
      }
    });
    _applyFiltersAndSort();
  }

  // Clear all filters
  void _clearFilters() {
    setState(() {
      _completionStatus = CompletionFilterStatus.all;
      _selectedPlatforms = {};
    });
    _applyFiltersAndSort();
    _savePreferences();
  }

  // Apply filters and sorting
  void _applyFiltersAndSort() {
  if (!mounted) return;
  
  final completionState = ref.read(completionProgressStateProvider);
  
  if (completionState.data == null) {
    setState(() {
      _filteredGames = [];
    });
    return;
  }
  
  try {
    final results = List<dynamic>.from(completionState.data!.results);
    
    // Apply filters
    List<dynamic> filtered = AchievementSorter.applyFilters(
      results,
      completionStatus: _completionStatus,
      selectedPlatforms: _selectedPlatforms,
    );
    
    // Apply sorting
    filtered = AchievementSorter.applySorting(filtered, _currentSortOption);
    
    if (mounted) {
      setState(() {
        _filteredGames = filtered;
      });
      
      // Save preferences
      _savePreferences();
    }
  } catch (e) {
    
    if (mounted) {
      setState(() {
        _filteredGames = [];
      });
    }
  }
}

  // Navigate to game details
void _navigateToGameDetails(GameProgress game) {
  final gameId = game.gameId.toString();
  final encodedTitle = Uri.encodeComponent(game.title);
  final encodedIconPath = Uri.encodeComponent(game.imageIcon);
  final encodedConsoleName = Uri.encodeComponent(game.consoleName);
  
  // Use context.go to navigate to the nested route
  context.go('/achievements/game/$gameId?title=$encodedTitle&icon=$encodedIconPath&console=$encodedConsoleName');
}

   @override
  Widget build(BuildContext context) {
    super.build(context);
    
    final completionState = ref.watch(completionProgressStateProvider);
    final userAwardsState = ref.watch(userAwardsStateProvider);
    
    // Show loading indicator during initial load or when providers indicate loading
    final isLoading = !_initialLoadComplete || completionState.isLoading || userAwardsState.isLoading;
        
    return Card(
      color: AppColors.cardBackground,
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // We now combine the header and stats into a single stunning component
                AchievementHeader(
                  onSort: _showSortDialog,
                  onFilter: _toggleFilterPanel,
                  onRefresh: _refreshData,
                  isFilterExpanded: _isFilterExpanded,
                  gamesPlayed: completionState.data?.count ?? 0,
                  totalMastered: userAwardsState.data?.masteryAwardsCount ?? 0,
                  totalBeaten: userAwardsState.data?.beatenHardcoreAwardsCount ?? 0,
                ),
                
                // Filter panel
                if (_isFilterExpanded)
                  Padding(
                    padding: const EdgeInsets.only(top: 16.0),
                    child: AchievementFilters(
                      completionStatus: _completionStatus,
                      selectedPlatforms: _selectedPlatforms,
                      games: completionState.data?.results ?? [],
                      onFilterChanged: _updateFilterOptions,
                      onClearFilters: _clearFilters,
                    ),
                  ),
                
                const SizedBox(height: 24),
                
                // Game count
                Text(
                  'Viewing ${_filteredGames.length} games',
                  style: const TextStyle(
                    color: AppColors.textSubtle,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                
                const SizedBox(height: 8),
                
                // Games list
                Expanded(
                  child: _filteredGames.isNotEmpty
                    ? GamesList(
                        games: _filteredGames,
                        onGameSelected: _navigateToGameDetails,
                      )
                    : const Center(
                        child: Text(
                          'No games match your filters',
                          style: TextStyle(color: AppColors.textLight),
                        ),
                      ),
                ),
              ],
            ),
      ),
    );
  }
  
  void _showSortDialog() {
    if (!mounted) return;
    
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          backgroundColor: AppColors.cardBackground,
          title: const Text(
            'Sort Games By',
            style: TextStyle(color: AppColors.primary),
          ),
          content: StatefulBuilder(
            builder: (BuildContext context, StateSetter setDialogState) {
              return RadioGroup<SortOption>(
                groupValue: _currentSortOption,
                onChanged: (SortOption? value) {
                  if (value != null) {
                    setDialogState(() {
                      _currentSortOption = value;
                    });
                    
                    setState(() {
                      _currentSortOption = value;
                    });
                    
                    _applyFiltersAndSort();
                    Navigator.of(dialogContext).pop();
                  }
                },
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildSortOption(SortOption.completionAsc, 'Completion Rate (Low to High)'),
                    _buildSortOption(SortOption.completionDesc, 'Completion Rate (High to Low)'),
                    _buildSortOption(SortOption.alphabeticalAsc, 'Game Title (A to Z)'),
                    _buildSortOption(SortOption.alphabeticalDesc, 'Game Title (Z to A)'),
                    _buildSortOption(SortOption.platformAsc, 'Platform (A to Z)'),
                    _buildSortOption(SortOption.platformDesc, 'Platform (Z to A)'),
                  ],
                ),
              );
            },
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text(
                'Close',
                style: TextStyle(color: AppColors.primary),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildSortOption(SortOption option, String label) {
    return RadioListTile<SortOption>(
      title: Text(
        label,
        style: const TextStyle(color: AppColors.textLight),
      ),
      value: option,
      activeColor: AppColors.primary,
    );
  }

  @override
  bool get wantKeepAlive => true;
}