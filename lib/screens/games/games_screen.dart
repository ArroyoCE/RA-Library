// lib/screens/games/games_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:retroachievements_library/constants/constants.dart';
import 'package:retroachievements_library/models/consoles/all_game_hash.dart';
import 'package:retroachievements_library/models/local/hash_match_model.dart';
import 'package:retroachievements_library/providers/repositories/local_data_repository_provider.dart';
import 'package:retroachievements_library/providers/states/consoles/all_games_hashes_state_provider.dart';
import 'package:retroachievements_library/providers/states/local_data_state_provider.dart';
import 'package:retroachievements_library/providers/states/settings_state_provider.dart';
import 'package:retroachievements_library/screens/games/components/games_filters.dart';
import 'package:retroachievements_library/screens/games/components/games_grid.dart';
import 'package:retroachievements_library/screens/games/components/games_header.dart';
import 'package:retroachievements_library/screens/games/components/games_list.dart';
import 'package:retroachievements_library/screens/games/dialogs/folder_management_dialog.dart';
import 'package:retroachievements_library/screens/games/widgets/folders_display.dart';
import 'package:shared_preferences/shared_preferences.dart';

class GamesScreen extends ConsumerStatefulWidget {
  final int consoleId;
  final String consoleName;

  const GamesScreen({
    super.key,
    required this.consoleId,
    required this.consoleName,
  });

  @override
  ConsumerState<GamesScreen> createState() => _GamesScreenState();
}

class _GamesScreenState extends ConsumerState<GamesScreen>
    with AutomaticKeepAliveClientMixin {
  bool _isGridView = true;
  String _searchQuery = '';
  double? _hashingProgress;
  final TextEditingController _searchController = TextEditingController();
  GameMatchFilter _currentMatchFilter = GameMatchFilter.all;
  bool _isLoading = true;
  bool _isHashingInProgress = false;
  List<String> _consoleFolders = [];
  Map<String, String> _localHashes = {};
  Map<int, MatchStatus> _matchStatuses = {};
  GameSortOption _currentSortOption = GameSortOption.nameAsc;

  @override
  void initState() {
    super.initState();
    _loadSavedPreferences();

    // Load games data
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _loadFolders();
      await _loadGamesData();
      await _loadLocalHashes();
    });
  }

  void _updateHashingProgress(int current, int total) {
    if (mounted) {
      setState(() {
        _hashingProgress = total > 0 ? current / total : null;
      });
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _handleSortChange(GameSortOption option) {
    setState(() {
      _currentSortOption = option;
    });
  }

  Future<void> _loadSavedPreferences() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Load view preference
      final savedIsGridView = prefs.getBool('games_grid_view');
      if (savedIsGridView != null) {
        setState(() {
          _isGridView = savedIsGridView;
        });
      }

      // Load filter preference (changed from bool to int)
      final savedMatchFilter = prefs.getInt('games_match_filter');
      if (savedMatchFilter != null) {
        setState(() {
          _currentMatchFilter = GameMatchFilter.values[savedMatchFilter];
        });
      }
    } catch (e) {
      debugPrint('Error loading saved preferences: $e');
    }
  }

  Future<void> _saveViewPreference() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('games_grid_view', _isGridView);
    } catch (e) {
      debugPrint('Error saving view preference: $e');
    }
  }

  Future<void> _saveFilterPreference() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('games_match_filter', _currentMatchFilter.index);
    } catch (e) {
      debugPrint('Error saving filter preference: $e');
    }
  }

  void _toggleView() {
    setState(() {
      _isGridView = !_isGridView;
    });
    _saveViewPreference();
  }

  void _handleMatchFilterChange(GameMatchFilter filter) {
    setState(() {
      _currentMatchFilter = filter;
    });
    _saveFilterPreference();
  }

  Future<void> _loadFolders() async {
    try {
      final localDataRepository = ref.read(localDataRepositoryProvider);
      final consoleFolders = await localDataRepository.getConsoleFolders();

      setState(() {
        _consoleFolders = consoleFolders[widget.consoleId] ?? [];
      });
    } catch (e) {
      debugPrint('Error loading console folders: $e');
    }
  }

  Future<void> _loadLocalHashes() async {
    try {
      final localDataRepository = ref.read(localDataRepositoryProvider);
      final hashes = await localDataRepository.getLocalHashes(widget.consoleId);

      if (mounted) {
        setState(() {
          _localHashes = hashes;
        });

        _matchGamesWithLocalHashes();
      }
    } catch (e) {
      debugPrint('Error loading local hashes: $e');
    }
  }

  void _matchGamesWithLocalHashes() {
    final gamesState = ref.read(gamesHashesStateProvider);
    final settings = ref.read(settingsProvider);

    if (gamesState.data == null || gamesState.data!.isEmpty) {
      return;
    }

    final Map<int, MatchStatus> statuses = {};

    // Track statistics for saving
    int matchedGamesCount = 0;
    int matchedHashesCount = 0;
    final Set<String> uniqueMatchedHashes = <String>{};

    // If there are no local hashes, set all games to "No Match"
    if (_localHashes.isEmpty) {
      for (final game in gamesState.data!) {
        statuses[game.id] = MatchStatus.noMatch;
      }

      if (mounted) {
        setState(() {
          _matchStatuses = statuses;
        });

        // Save stats with zeros
        _saveHashStats(0, 0);
      }
      return;
    }

    // Process each game and determine match status
    for (final game in gamesState.data!) {
      if (settings.shouldIgnoreGame(game.title)) {
        statuses[game.id] = MatchStatus.noMatch;
        continue;
      }

      if (game.hashes.isEmpty) {
        statuses[game.id] = MatchStatus.noMatch;
        continue;
      }

      final apiHashes = game.hashes.map((hash) => hash.toLowerCase()).toList();

      // Count matches
      int matchCount = 0;
      for (final apiHash in apiHashes) {
        if (_localHashes.values.contains(apiHash)) {
          matchCount++;
          uniqueMatchedHashes.add(apiHash);
        }
      }

      // Determine status
      if (matchCount == 0) {
        statuses[game.id] = MatchStatus.noMatch;
      } else if (settings.hashDisplayPreference != HashDisplayPreference.accountForEveryHash) {
        statuses[game.id] = MatchStatus.fullMatch;
        matchedGamesCount++;
      } else if (matchCount == apiHashes.length) {
        statuses[game.id] = MatchStatus.fullMatch;
        matchedGamesCount++;
      } else {
        statuses[game.id] = MatchStatus.partialMatch;
        matchedGamesCount++; // Count partial matches too
      }
    }

    if (mounted) {
      setState(() {
        _matchStatuses = statuses;
      });

      // Save hash stats
      matchedHashesCount = uniqueMatchedHashes.length;
      _saveHashStats(matchedGamesCount, matchedHashesCount);
    }
  }

  Future<void> _saveHashStats(int matchedGames, int matchedHashes) async {
    try {
      final localDataRepository = ref.read(localDataRepositoryProvider);
      await localDataRepository.saveHashStats(
        widget.consoleId,
        matchedGames,
        matchedHashes,
      );

      final consoleTotals = await localDataRepository.getConsoleTotals(
        widget.consoleId,
      );

      // Create updated stats map
      final updatedStats = {
        'totalGames': consoleTotals?['totalGames'] ?? 0,
        'totalHashes': consoleTotals?['totalHashes'] ?? 0,
        'matchedGames': matchedGames,
        'matchedHashes': matchedHashes,
        'lastUpdated': DateTime.now().toIso8601String(),
      };

      // Update the stats directly through the notifier
      ref
          .read(consoleStatsNotifierProvider.notifier)
          .updateConsoleStats(widget.consoleId, updatedStats);

      // Force refresh on the notifier to ensure all listeners are updated
      ref.invalidate(consoleStatsProvider);
    } catch (e) {
      debugPrint('Error saving hash stats: $e');
    }
  }

  Future<void> _loadGamesData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      await ref
          .read(gamesHashesStateProvider.notifier)
          .loadGameList(widget.consoleId.toString(), forceRefresh: false);
    } catch (e) {
      debugPrint('Error loading games data: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _refreshData() async {
    // If no folders are added, just refresh game data
    if (_consoleFolders.isEmpty) {
      setState(() {
        _isLoading = true;
      });

      try {
        await ref
            .read(gamesHashesStateProvider.notifier)
            .loadGameList(widget.consoleId.toString(), forceRefresh: true);

        // Update match statuses
        _matchGamesWithLocalHashes();
      } catch (e) {
        debugPrint('Error refreshing games data: $e');
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    } else {
      // If folders are added, ask user if they want to rehash
      final shouldRehash =
          await showDialog<bool>(
            context: context,
            builder:
                (context) => AlertDialog(
                  backgroundColor: AppColors.cardBackground,
                  title: const Text(
                    'Refresh Game Data',
                    style: TextStyle(color: AppColors.primary),
                  ),
                  content: const Text(
                    'Do you want to rehash all files in your folders? This may take some time.',
                    style: TextStyle(color: AppColors.textLight),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(false),
                      child: const Text(
                        'Cancel',
                        style: TextStyle(color: AppColors.textLight),
                      ),
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: AppColors.textDark,
                      ),
                      onPressed: () => Navigator.of(context).pop(true),
                      child: const Text('Yes, Rehash'),
                    ),
                  ],
                ),
          ) ??
          false;

      if (shouldRehash) {
        setState(() {
          _isLoading = true;
          _isHashingInProgress = true;
          _hashingProgress = null;
        });

        try {
          // First refresh games data
          await ref
              .read(gamesHashesStateProvider.notifier)
              .loadGameList(widget.consoleId.toString(), forceRefresh: true);

          // Show hashing in progress notification

          // Get local data repository
          final localDataRepository = ref.read(localDataRepositoryProvider);

          // Rehash all files in folders
          final hashes = await localDataRepository.hashFilesInFolders(
            widget.consoleId,
            _consoleFolders,
            skipExisting: false,
            progressCallback: _updateHashingProgress,
          );

          if (mounted) {
            setState(() {
              _localHashes = hashes;
              _isHashingInProgress = false;
              _isLoading = false;
              _hashingProgress = null;
            });

            // Match newly hashed files with games
            _matchGamesWithLocalHashes();

            // Show success notification
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('${hashes.length} files hashed successfully'),
                  backgroundColor: AppColors.success,
                ),
              );
            }
          }
        } catch (e) {
          debugPrint('Error during refresh and rehash: $e');
          if (mounted) {
            setState(() {
              _isHashingInProgress = false;
              _isLoading = false;
              _hashingProgress = null;
            });
          }
        }
      }
    }
  }

  void _onAddFolder() async {
    try {
      final localDataRepository = ref.read(localDataRepositoryProvider);

      // Get existing folders for this console
      final consoleFolders = await localDataRepository.getConsoleFolders();
      final existingFolders = consoleFolders[widget.consoleId] ?? [];

      if (mounted) {
        showDialog(
          context: context,
          builder:
              (context) => FolderManagementDialog(
                consoleId: widget.consoleId,
                consoleName: widget.consoleName,
                initialFolders: existingFolders,
                onSave: (updatedFolders) async {
                  setState(() {
                    _isHashingInProgress = true;
                    _hashingProgress = null;
                    _consoleFolders = updatedFolders;
                    // Clear match statuses when folder list changes
                    _matchStatuses = {};
                  });

                  // Show hashing in progress notification

                  // Save updated folders - this will also clean up hashes for removed folders
                  await localDataRepository.saveConsoleFolders(
                    widget.consoleId,
                    updatedFolders,
                  );

                  // If folders were removed, we need to update the local hashes
                  if (existingFolders.length > updatedFolders.length) {
                    // Reload local hashes which were updated by cleanHashesForRemovedFolders
                    final updatedLocalHashes = await localDataRepository
                        .getLocalHashes(widget.consoleId);
                    setState(() {
                      _localHashes = updatedLocalHashes;
                    });

                    // Get the updated hash stats
                    final hashStats = await localDataRepository.getHashStats(
                      widget.consoleId,
                    );
                    if (hashStats != null) {
                      final consoleTotals = await localDataRepository
                          .getConsoleTotals(widget.consoleId);

                      // Create updated stats map
                      final updatedStats = {
                        'totalGames': consoleTotals?['totalGames'] ?? 0,
                        'totalHashes': consoleTotals?['totalHashes'] ?? 0,
                        'matchedGames': hashStats['matchedGames'] ?? 0,
                        'matchedHashes': hashStats['matchedHashes'] ?? 0,
                        'lastUpdated': DateTime.now().toIso8601String(),
                      };

                      // Update the stats provider
                      ref
                          .read(consoleStatsNotifierProvider.notifier)
                          .updateConsoleStats(widget.consoleId, updatedStats);

                      // Force refresh provider
                      ref.invalidate(consoleStatsProvider);

                      // Re-match games with updated hashes
                      _matchGamesWithLocalHashes();
                    }
                  }

                  // Hash files in folders if there are any
                  if (updatedFolders.isNotEmpty) {
                    try {
                      final hashes = await localDataRepository
                          .hashFilesInFolders(
                            widget.consoleId,
                            updatedFolders,
                            skipExisting: true,
                            progressCallback: _updateHashingProgress,
                          );

                      if (mounted) {
                        setState(() {
                          _localHashes = hashes;
                          _isHashingInProgress = false;
                          _hashingProgress = null;
                        });

                        // Match newly hashed files with games
                        _matchGamesWithLocalHashes();

                        // No success notification here, just progress UI
                      }
                    } catch (e) {
                      if (mounted) {
                        setState(() {
                          _isHashingInProgress = false;
                          _hashingProgress = null;
                        });
                      }
                    }
                  } else {
                    // If no folders, clear all hashes
                    await localDataRepository.saveLocalHashes(
                      widget.consoleId,
                      {},
                    );

                    if (mounted) {
                      // Explicitly update match statuses for ALL games to NoMatch
                      final gamesState = ref.read(gamesHashesStateProvider);
                      Map<int, MatchStatus> updatedStatuses = {};

                      if (gamesState.data != null) {
                        for (final game in gamesState.data!) {
                          updatedStatuses[game.id] = MatchStatus.noMatch;
                        }
                      }

                      setState(() {
                        _localHashes = {};
                        _isHashingInProgress = false;
                        _hashingProgress = null;
                        _matchStatuses =
                            updatedStatuses; // Direct assignment of new map
                      });

                      // Update hash stats to zero
                      final updatedStats = {
                        'totalGames': gamesState.data?.length ?? 0,
                        'totalHashes':
                            gamesState.data != null
                                ? gamesState.data!.fold<int>(
                                  0,
                                  (sum, game) => sum + game.hashes.length,
                                )
                                : 0,
                        'matchedGames': 0,
                        'matchedHashes': 0,
                        'lastUpdated': DateTime.now().toIso8601String(),
                      };

                      // Update the stats provider
                      ref
                          .read(consoleStatsNotifierProvider.notifier)
                          .updateConsoleStats(widget.consoleId, updatedStats);

                      // Force refresh provider
                      ref.invalidate(consoleStatsProvider);

                      // Show info notification
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              'All folders removed. Local hashes cleared.',
                            ),
                            duration: Duration(seconds: 3),
                          ),
                        );
                      }
                    }
                  }
                },
              ),
        );
      }
    } catch (e) {
      debugPrint('Error opening folder management dialog: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error opening folder management dialog: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  void _sortGames(List<GameHash> games) {
    switch (_currentSortOption) {
      case GameSortOption.nameAsc:
        games.sort((a, b) {
          // Special handling for games starting with ~
          bool aStartsWithTilde = a.title.startsWith('~');
          bool bStartsWithTilde = b.title.startsWith('~');

          // If one starts with ~ and the other doesn't, the ~ one goes last
          if (aStartsWithTilde && !bStartsWithTilde) return 1;
          if (!aStartsWithTilde && bStartsWithTilde) return -1;

          // Otherwise, normal alphabetical comparison
          return a.title.compareTo(b.title);
        });
        break;
      case GameSortOption.nameDesc:
        games.sort((a, b) {
          // Special handling for games starting with ~
          bool aStartsWithTilde = a.title.startsWith('~');
          bool bStartsWithTilde = b.title.startsWith('~');

          // If one starts with ~ and the other doesn't, the ~ one goes first for Z-A
          if (aStartsWithTilde && !bStartsWithTilde) return -1;
          if (!aStartsWithTilde && bStartsWithTilde) return 1;

          // Otherwise, reverse alphabetical comparison
          return b.title.compareTo(a.title);
        });
        break;
    }
  }

  // Filter games based on search and matched filter
  List<GameHash> _getFilteredGames() {
    final gamesState = ref.watch(gamesHashesStateProvider);
    final settings = ref.watch(settingsProvider);

    if (gamesState.data == null) return [];

    // Filter by matched games if needed
    List<GameHash> filteredList = List.from(gamesState.data!);

    // Remove ignored games
    filteredList.removeWhere((game) => settings.shouldIgnoreGame(game.title));

    // Apply match filter
    if (_currentMatchFilter != GameMatchFilter.all) {
      filteredList =
          filteredList.where((game) {
            final status = _matchStatuses[game.id];

            if (_currentMatchFilter == GameMatchFilter.matched) {
              // Show games that are in the library (full or partial match)
              return status == MatchStatus.fullMatch ||
                  status == MatchStatus.partialMatch;
            } else {
              // GameMatchFilter.unmatched
              // Show games not in the library
              return status == MatchStatus.noMatch;
            }
          }).toList();
    }

    // Filter by search query
    if (_searchQuery.isNotEmpty) {
      final query = _searchQuery.toLowerCase();
      filteredList =
          filteredList
              .where((game) => game.title.toLowerCase().contains(query))
              .toList();
    }

    // Apply sorting
    _sortGames(filteredList);

    return filteredList;
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    ref.listen<SettingsState>(settingsProvider, (previous, next) {
      if (previous?.hashDisplayPreference != next.hashDisplayPreference ||
          previous?.ignoreHack != next.ignoreHack ||
          previous?.ignoreHomebrew != next.ignoreHomebrew ||
          previous?.ignorePrototype != next.ignorePrototype ||
          previous?.ignoreUnlicensed != next.ignoreUnlicensed ||
          previous?.ignoreDemo != next.ignoreDemo ||
          previous?.ignoreSubset != next.ignoreSubset) {
        _matchGamesWithLocalHashes();
      }
    });

    final settings = ref.watch(settingsProvider);
    final filteredGames = _getFilteredGames();
    final gamesState = ref.watch(gamesHashesStateProvider);

    return Card(
      color: AppColors.cardBackground,
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with title and actions
            GamesHeader(
              consoleName: widget.consoleName,
              onViewToggle: _toggleView,
              onRefresh: _refreshData,
              isGridView: _isGridView,
              isHashingInProgress: _isHashingInProgress,
            ),

            const SizedBox(height: 12),

            // Folders display (now more compact)
            FoldersDisplayWidget(
              folders: _consoleFolders,
              onAddFolder: _onAddFolder,
              isHashingInProgress: _isHashingInProgress,
            ),

            const SizedBox(height: 12),

            // Search and filters in a single row
            GamesFilters(
              searchController: _searchController,
              onSearchChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
              currentMatchFilter: _currentMatchFilter,
              onMatchFilterChanged: _handleMatchFilterChange,
              currentSortOption: _currentSortOption,
              onSortChanged: _handleSortChange,
            ),

            const SizedBox(height: 12),

            // Game count and hashing progress
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Showing ${filteredGames.length} games',
                  style: const TextStyle(color: AppColors.info, fontSize: 14),
                ),
                if (_isHashingInProgress)
                  Row(
                    children: [
                      SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          value: _hashingProgress,
                          valueColor: const AlwaysStoppedAnimation<Color>(
                            AppColors.primary,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        _hashingProgress != null
                            ? 'Hashing Progress: ${(_hashingProgress! * 100).toInt()}%'
                            : 'Hashing in progress...',
                        style: const TextStyle(
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

            // Loading indicator or games grid/list
            _isLoading || gamesState.isLoading
                ? const Expanded(
                  child: Center(
                    child: CircularProgressIndicator(color: AppColors.primary),
                  ),
                )
                : gamesState.data == null || gamesState.data!.isEmpty
                ? const Expanded(
                  child: Center(
                    child: Text(
                      'No games found',
                      style: TextStyle(
                        color: AppColors.textLight,
                        fontSize: 18,
                      ),
                    ),
                  ),
                )
                : Expanded(
                  child:
                      _isGridView
                          ? GamesGrid(
                            games: filteredGames,
                            onGameSelected: _navigateToGameDetails,
                            matchStatuses: _matchStatuses,
                            isHashingInProgress: _isHashingInProgress,
                            hashDisplayPreference: settings.hashDisplayPreference,
                          )
                          : GamesList(
                            games: filteredGames,
                            onGameSelected: _navigateToGameDetails,
                            matchStatuses: _matchStatuses,
                            isHashingInProgress: _isHashingInProgress,
                            hashDisplayPreference: settings.hashDisplayPreference,
                          ),
                ),
          ],
        ),
      ),
    );
  }

  void _navigateToGameDetails(GameHash game) {
    // Navigate to game details screen using GoRouter with nested route
    // This maintains the navigation stack with games/:consoleId as the parent
    context.go(
      '/games/${widget.consoleId}/game/${game.id}?title=${Uri.encodeComponent(game.title)}&icon=${Uri.encodeComponent(game.imageIcon)}&console=${Uri.encodeComponent(widget.consoleName)}',
    );
  }

  @override
  bool get wantKeepAlive => true;
}
