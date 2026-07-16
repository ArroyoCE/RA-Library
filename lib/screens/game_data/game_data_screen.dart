// lib/screens/game_data/game_data_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:retroachievements_library/constants/constants.dart';
import 'package:retroachievements_library/models/games/game_extended_model.dart';
import 'package:retroachievements_library/models/games/game_summary_model.dart';
import 'package:retroachievements_library/providers/states/games/game_extended_state_provider.dart';
import 'package:retroachievements_library/providers/states/games/game_summary_state_provider.dart';
import 'package:retroachievements_library/providers/states/games/user_game_progress_state_provider.dart';
import 'package:retroachievements_library/screens/game_data/components/game_details_tab.dart';
import 'package:retroachievements_library/screens/game_data/components/game_hashes_tab.dart';
import 'package:retroachievements_library/screens/game_data/components/game_header.dart';

class GameDataScreen extends ConsumerStatefulWidget {
  final String gameId;
  final String? title;
  final String? iconPath;
  final String? consoleName;
  final String navigationSource;

  const GameDataScreen({
    super.key,
    required this.gameId,
    this.title,
    this.iconPath,
    this.consoleName,
    this.navigationSource = 'games',
  });

  @override
  ConsumerState<GameDataScreen> createState() => _GameDataScreenState();
}

class _GameDataScreenState extends ConsumerState<GameDataScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);

    // Load game data
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadGameData();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // Load data using existing providers
  Future<void> _loadGameData() async {
    final gameSummaryNotifier = ref.read(
      gameSummaryProvider(widget.gameId).notifier,
    );
    final gameExtendedNotifier = ref.read(
      gameExtendedProvider(widget.gameId).notifier,
    );
    final userGameProgressNotifier = ref.read(
      userGameProgressProvider(widget.gameId).notifier,
    );

    await Future.wait([
      gameSummaryNotifier.loadData(),
      gameExtendedNotifier.loadData(),
      userGameProgressNotifier.loadData(),
    ]);
  }

  void _handleBack() {
    switch (widget.navigationSource) {
      case 'achievements':
        context.go('/achievements');
        break;
      case 'games':
        // For games, we're in a nested route, so we just pop back to the parent games screen
        context.pop();
        break;
      case 'dashboard':
        context.go('/dashboard');
        break;
      default:
        context.pop();
        break;
    }
  }

  // Helper method to get console ID from name

  @override
  Widget build(BuildContext context) {
    // Watch providers to react to state changes
    final gameSummaryState = ref.watch(gameSummaryProvider(widget.gameId));
    final gameExtendedState = ref.watch(gameExtendedProvider(widget.gameId));

    // Determine if loading
    final isLoading = gameSummaryState.isLoading || gameExtendedState.isLoading;

    // Check for errors
    final errorMessage =
        gameSummaryState.errorMessage ?? gameExtendedState.errorMessage;

    // Get data
    final GameSummary? gameSummary = gameSummaryState.data;
    final GameExtended? gameExtended = gameExtendedState.data;

    return Scaffold(
      backgroundColor: AppColors.darkBackground,
      appBar: AppBar(
        backgroundColor: AppColors.appBarBackground,
        title: Text(
          gameSummary?.title ?? widget.title ?? 'Game Details',
          style: const TextStyle(color: AppColors.textLight),
          overflow: TextOverflow.ellipsis,
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textLight),
          onPressed: _handleBack,
        ),
        actions: [
          // Refresh button
          IconButton(
            icon: const Icon(Icons.refresh, color: AppColors.textLight),
            onPressed: _loadGameData,
          ),
        ],
      ),
      body:
          isLoading
              ? const Center(
                child: CircularProgressIndicator(color: AppColors.primary),
              )
              : errorMessage != null
              ? _buildErrorView(errorMessage)
              : _buildGameContent(gameSummary, gameExtended),
    );
  }

  Widget _buildErrorView(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, color: AppColors.error, size: 64),
          const SizedBox(height: 16),
          const Text(
            'Error loading game data',
            style: TextStyle(
              color: AppColors.textLight,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            message,
            style: const TextStyle(color: AppColors.textLight, fontSize: 16),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _loadGameData,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: AppColors.textDark,
            ),
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildGameContent(
    GameSummary? gameSummary,
    GameExtended? gameExtended,
  ) {
    if (gameSummary == null) {
      return const Center(
        child: Text(
          'No game data available',
          style: TextStyle(color: AppColors.textLight),
        ),
      );
    }

    return Column(
      children: [
        // Game header with basic information
        GameHeader(
          gameSummary: gameSummary,
          gameExtended: gameExtended,
          gameId: widget.gameId, // Pass the gameId here
        ),

        // Tab bar
        PreferredSize(
          preferredSize: const Size.fromHeight(18.0), // Reduced height
          child: TabBar(
            controller: _tabController,
            indicatorColor: AppColors.primary,
            labelColor: AppColors.primary,
            unselectedLabelColor: AppColors.textLight,
            labelPadding: const EdgeInsets.symmetric(vertical: 4.0),
            indicatorSize: TabBarIndicatorSize.label,
            tabs: const [
              Tab(
                height: 18.0,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.emoji_events, size: 16),
                    SizedBox(width: 4),
                    Text('Achievements', style: TextStyle(fontSize: 12)),
                  ],
                ),
              ),
              Tab(
                height: 18.0,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.tag, size: 16),
                    SizedBox(width: 4),
                    Text('Game Hashes', style: TextStyle(fontSize: 12)),
                  ],
                ),
              ),
            ],
          ),
        ),

        // Tab content
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              // Achievements tab - pass the gameId
              GameDetailsTab(
                gameExtended: gameExtended,
                gameId: widget.gameId, // Add this parameter
              ),

              // Hashes tab
              GameHashesTab(
                gameId: widget.gameId,
                consoleName: gameSummary.consoleName,
                consoleId: gameSummary.consoleId,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
