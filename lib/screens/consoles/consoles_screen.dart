// lib/screens/consoles/consoles_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:retroachievements_organizer/constants/constants.dart';
import 'package:retroachievements_organizer/models/consoles/all_console_model.dart';
import 'package:retroachievements_organizer/providers/repositories/local_data_repository_provider.dart';
import 'package:retroachievements_organizer/providers/repositories/consoles/all_games_hashes_repository_provider.dart';
import 'package:retroachievements_organizer/providers/states/auth_state_provider.dart';
import 'package:retroachievements_organizer/providers/states/consoles/all_consoles_state_provider.dart';
import 'package:retroachievements_organizer/providers/states/consoles/consoles_updating_state_provider.dart';
import 'package:retroachievements_organizer/providers/states/local_data_state_provider.dart';
import 'package:retroachievements_organizer/providers/states/settings_state_provider.dart';
import 'package:retroachievements_organizer/models/consoles/all_game_hash.dart';
import 'package:retroachievements_organizer/screens/consoles/components/consoles_filters.dart';
import 'package:retroachievements_organizer/screens/consoles/components/consoles_grid.dart';
import 'package:retroachievements_organizer/screens/consoles/components/consoles_header.dart';
import 'package:retroachievements_organizer/screens/consoles/components/consoles_list.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ConsolesScreen extends StatefulWidget {
  final Widget child;

  const ConsolesScreen({super.key, required this.child});

  @override
  State<ConsolesScreen> createState() => _ConsolesScreenState();
}

class _ConsolesScreenState extends State<ConsolesScreen> with AutomaticKeepAliveClientMixin {
  @override
  Widget build(BuildContext context) {
    super.build(context);
    return widget.child;
  }
  
  @override
  bool get wantKeepAlive => true;
}

class GamesContent extends ConsumerStatefulWidget {
  const GamesContent({super.key});

  @override
  ConsumerState<GamesContent> createState() => _GamesContentState();
}

class _GamesContentState extends ConsumerState<GamesContent> with AutomaticKeepAliveClientMixin {
  bool _isGridView = true;
  final Map<int, Map<String, dynamic>> _libraryStats = {};
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  @override
void initState() {
  super.initState();
  _loadSavedPreferences();
  
  // Load consoles and game data
  WidgetsBinding.instance.addPostFrameCallback((_) async {
    await ref.read(consolesStateProvider.notifier).loadData();
    
    // Add this line to load the totals for all consoles
    await _loadConsoleStats();
    
    // Then preload game data
    _preloadGameData();
  });
}

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadSavedPreferences() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Load view preference
      final savedIsGridView = prefs.getBool('consoles_grid_view');
      if (savedIsGridView != null) {
        setState(() {
          _isGridView = savedIsGridView;
        });
      }
    } catch (e) {
      debugPrint('Error loading saved preferences: $e');
    }
  }

  Future<void> _loadConsoleStats() async {
  try {
    // Get supported console IDs
    final supportedConsoleIds = ref.read(supportedConsoleIdsProvider);
    
    // Get local data repository
    final localDataRepository = ref.read(localDataRepositoryProvider);
    
    // Load totals for each console from JSON storage
    for (final consoleId in supportedConsoleIds) {
      // Get cached console totals
      final cachedTotals = await localDataRepository.getConsoleTotals(consoleId);
      
      if (cachedTotals != null) {
        // Get hash stats
        final hashStats = await localDataRepository.getHashStats(consoleId);
        
        // Create updated stats with loaded totals
        final stats = {
          'matchedGames': hashStats?['matchedGames'] ?? 0,
          'matchedHashes': hashStats?['matchedHashes'] ?? 0,
          'totalGames': cachedTotals['totalGames'] ?? 0,
          'totalHashes': cachedTotals['totalHashes'] ?? 0,
          'lastUpdated': DateTime.now().toIso8601String(),
        };
        
        // Update the stats provider
        ref.read(consoleStatsNotifierProvider.notifier).updateConsoleStats(consoleId, stats);
        
        // Update local state
        if (mounted) {
          setState(() {
            _libraryStats[consoleId] = Map.from(stats);
          });
        }
      }
    }
  } catch (e) {
    debugPrint('Error loading console stats: $e');
  }
}


  Future<void> _saveViewPreference() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('consoles_grid_view', _isGridView);
    } catch (e) {
      debugPrint('Error saving view preference: $e');
    }
  }

  void _toggleView() {
    setState(() {
      _isGridView = !_isGridView;
    });
    _saveViewPreference();
  }

  // Preload game data for all consoles
 Future<void> _preloadGameData() async {
  if (!mounted) return;
  
  final consoleState = ref.read(consolesStateProvider);
  if (consoleState.data == null) {
    debugPrint('Consoles not loaded yet, skipping preload');
    return;
  }
  
  // Lock UI and navigation
  Future.microtask(() {
    if (mounted) ref.read(consolesUpdatingStateProvider.notifier).state = true;
  });
  
  try {
  
  // Get supported console IDs
  final supportedConsoleIds = ref.read(supportedConsoleIdsProvider);
  
  // Process each console
  const batchSize = 5;
  for (int i = 0; i < supportedConsoleIds.length; i += batchSize) {
    final end = (i + batchSize < supportedConsoleIds.length) ? i + batchSize : supportedConsoleIds.length;
    final batch = supportedConsoleIds.sublist(i, end);
    
    // Process batch in parallel
    await Future.wait(
      batch.map((consoleId) async {
        try {
          // Get local data repository
          final localDataRepository = ref.read(localDataRepositoryProvider);
          
          // Check if we have cached totals
          final cachedTotals = await localDataRepository.getConsoleTotals(consoleId);
          int totalGames = 0;
          int totalHashes = 0;
          
          // If we don't have cached totals, or they're outdated, fetch from API
          if (cachedTotals == null) {
            // Load game list directly from repository to avoid race condition
            final repository = ref.read(allGamesHashesRepositoryProvider);
            final apiKey = ref.read(authStateProvider).apiKey ?? '';
            final gamesListRaw = await repository.getGameList(consoleId.toString(), apiKey, useCache: true);
            
            if (gamesListRaw != null) {
              final settings = ref.read(settingsProvider);
              final gamesList = gamesListRaw
                  .map((item) => GameHash.fromJson(item))
                  .where((game) => !settings.shouldIgnoreGame(game.title))
                  .toList();
              totalGames = gamesList.length;
              totalHashes = gamesList.fold<int>(
                0, (sum, game) => sum + game.hashes.length
              );
              
              // Save the totals for future use
              await localDataRepository.saveConsoleTotals(consoleId, totalGames, totalHashes);
            }
          } else {
            // Use cached totals
            totalGames = cachedTotals['totalGames'] ?? 0;
            totalHashes = cachedTotals['totalHashes'] ?? 0;
          }
          
          // Get hash stats
          final hashStats = await localDataRepository.getHashStats(consoleId);
          
          // Create stats with proper totals
          final stats = {
            'matchedGames': hashStats?['matchedGames'] ?? 0,
            'matchedHashes': hashStats?['matchedHashes'] ?? 0,
            'totalGames': totalGames,
            'totalHashes': totalHashes,
            'lastUpdated': DateTime.now().toIso8601String(),
          };
          
          // Update the stats
          ref.read(consoleStatsNotifierProvider.notifier).updateConsoleStats(consoleId, stats);
          
          // Update local state
          if (mounted) {
            setState(() {
              _libraryStats[consoleId] = Map.from(stats);
            });
          }
        } catch (e) {
          debugPrint('Error loading stats for console $consoleId: $e');
        }
      })
    );
    
    // Small delay between batches
    if (end < supportedConsoleIds.length) {
      await Future.delayed(const Duration(milliseconds: 200));
    }
  }
  } finally {
    if (mounted) {
      ref.read(consolesUpdatingStateProvider.notifier).state = false;
    }
  }
}



void _refreshData() async {
  // Lock UI and navigation
  Future.microtask(() {
    if (mounted) ref.read(consolesUpdatingStateProvider.notifier).state = true;
  });

  try {
    // First refresh console data from API
    await ref.read(consolesStateProvider.notifier).loadData(forceRefresh: true);
    
    // Get supported console IDs
    final supportedConsoleIds = ref.read(supportedConsoleIdsProvider);
  
  // Process each console to refresh totals
  for (final consoleId in supportedConsoleIds) {
    try {
      // Get local data repository
      final localDataRepository = ref.read(localDataRepositoryProvider);
      
      // Load game list directly from repository to avoid race condition
      final repository = ref.read(allGamesHashesRepositoryProvider);
      final apiKey = ref.read(authStateProvider).apiKey ?? '';
      final gamesListRaw = await repository.getGameList(consoleId.toString(), apiKey, useCache: false);
      
      if (gamesListRaw != null) {
        final settings = ref.read(settingsProvider);
        final gamesList = gamesListRaw
            .map((item) => GameHash.fromJson(item))
            .where((game) => !settings.shouldIgnoreGame(game.title))
            .toList();
        final totalGames = gamesList.length;
        final totalHashes = gamesList.fold<int>(
          0, (sum, game) => sum + game.hashes.length
        );
        
        // Save the updated totals
        await localDataRepository.saveConsoleTotals(consoleId, totalGames, totalHashes);
        
        // Get hash stats
        final hashStats = await localDataRepository.getHashStats(consoleId);
        
        // Create updated stats with proper totals
        final stats = {
          'matchedGames': hashStats?['matchedGames'] ?? 0,
          'matchedHashes': hashStats?['matchedHashes'] ?? 0,
          'totalGames': totalGames,
          'totalHashes': totalHashes,
          'lastUpdated': DateTime.now().toIso8601String(),
        };
        
        // Update the stats
        ref.read(consoleStatsNotifierProvider.notifier).updateConsoleStats(consoleId, stats);
        
        // Update local state
        if (mounted) {
          setState(() {
            _libraryStats[consoleId] = Map.from(stats);
          });
        }
      }
    } catch (e) {
      debugPrint('Error refreshing stats for console $consoleId: $e');
    }
  }
  
  // Refresh all stats from storage
  await ref.read(consoleStatsNotifierProvider.notifier).refreshAllStats();
  } finally {
    if (mounted) {
      ref.read(consolesUpdatingStateProvider.notifier).state = false;
    }
  }
}

  // Filter consoles based on search and availability
  List<Console> _getFilteredConsoles() {
    final consoleState = ref.read(consolesStateProvider);
    if (consoleState.data == null) return [];
    
    // First filter out "Standalone"
    List<Console> filteredList = consoleState.data!.where((console) => 
        console.name.toLowerCase() != 'standalone').toList();
    
    // Then filter by search query
    if (_searchQuery.isNotEmpty) {
      final query = _searchQuery.toLowerCase();
      filteredList = filteredList.where((console) => 
        console.name.toLowerCase().contains(query)).toList();
    }
    
    return filteredList;
  }

@override
Widget build(BuildContext context) {
  super.build(context);

  // Explicitly watch the stats provider to get updates
  final statsCache = ref.watch(consoleStatsProvider);
  
  // If there are updated stats, copy them to our local state
  if (statsCache.isNotEmpty && mounted) {
    for (final entry in statsCache.entries) {
      if (!_libraryStats.containsKey(entry.key) || 
          _libraryStats[entry.key]!['lastUpdated'] != entry.value['lastUpdated']) {
        _libraryStats[entry.key] = Map.from(entry.value);
      }
    }
  }
  
  final consoleState = ref.watch(consolesStateProvider);
  final filteredConsoles = _getFilteredConsoles();
  final isUpdating = ref.watch(consolesUpdatingStateProvider);

  return Padding(
    padding: const EdgeInsets.all(16),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header with title and actions
        ConsolesHeader(
          onViewToggle: _toggleView,
          onRefresh: _refreshData,
          isGridView: _isGridView,
          isUpdating: isUpdating,
        ),
        
        const SizedBox(height: 16),
        
        // Search and filters
        ConsolesFilters(
          searchController: _searchController,
          onSearchChanged: (value) {
            setState(() {
              _searchQuery = value;
            });
          },
        ),
        
        const SizedBox(height: 16),
        
        // Console count and updating progress
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Showing ${filteredConsoles.length} consoles',
              style: const TextStyle(
                color: AppColors.info,
                fontSize: 14,
              ),
            ),
            if (isUpdating)
              const Row(
                children: [
                  SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                    ),
                  ),
                  SizedBox(width: 12),
                  Text(
                    'Syncing games and hashes...',
                    style: TextStyle(
                      color: AppColors.primary, 
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
          ],
        ),
        
        const SizedBox(height: 12),
        
        // Loading indicator or consoles grid/list
        Expanded(
          child: AbsorbPointer(
            absorbing: isUpdating,
            child: consoleState.isLoading
                ? const Center(
                    child: CircularProgressIndicator(color: AppColors.primary),
                  )
                : consoleState.data == null || consoleState.data!.isEmpty
                    ? const Center(
                        child: Text(
                          'No consoles found',
                          style: TextStyle(
                            color: AppColors.textLight,
                            fontSize: 18,
                          ),
                        ),
                      )
                    : _isGridView
                        ? ConsolesGrid(
                            consoles: filteredConsoles,
                            libraryStats: _libraryStats,
                          )
                        : ConsolesList(
                            consoles: filteredConsoles,
                            libraryStats: _libraryStats,
                          ),
          ),
        ),
      ],
    ),
  );
}

@override
bool get wantKeepAlive => true;
}