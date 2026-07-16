// lib/screens/dashboard/components/completion_progress.dart

import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:retroachievements_library/constants/constants.dart';
import 'package:retroachievements_library/models/user/completed_game.dart';
import 'package:retroachievements_library/providers/states/games/game_extended_state_provider.dart';
import 'package:retroachievements_library/screens/dashboard/utils/completion_color_helper.dart';
import 'package:retroachievements_library/screens/dashboard/widgets/progress_bar.dart';

class CompletionProgressList extends ConsumerStatefulWidget {
  final List<CompletedGame> completedGames;

  const CompletionProgressList({super.key, required this.completedGames});

  @override
  ConsumerState<CompletionProgressList> createState() =>
      _CompletionProgressListState();
}

class _CompletionProgressListState
    extends ConsumerState<CompletionProgressList> {
  bool _isLoading = true;
  List<Map<String, dynamic>> _rankedGames = [];
  int _completedGamesCount = 0;

  @override
  void initState() {
    super.initState();
    // Use Future.microtask to delay the provider modification until after build
    Future.microtask(() => _calculateTopGames());
  }

  Future<void> _calculateTopGames() async {
    if (!mounted) return;

    setState(() {
      _isLoading = true;
    });

    try {
      // Filter for hardcore completed games where maxPossible = numAwarded
      final hardcoreGames =
          widget.completedGames
              .where(
                (game) =>
                    game.hardcoreMode && game.maxPossible == game.numAwarded,
              )
              .toList();

      _completedGamesCount = hardcoreGames.length;

      if (hardcoreGames.isEmpty) {
        if (mounted) {
          setState(() {
            _isLoading = false;
            _rankedGames = [];
          });
        }
        return;
      }

      // Process top games in parallel (limit to 10 for performance)
      final gamesToProcess = hardcoreGames.take(10).toList();
      final processedGames = <Map<String, dynamic>>[];

      for (final game in gamesToProcess) {
        try {
          // Check if widget is still mounted before each game processing
          if (!mounted) {
            debugPrint(
              'Stopping game processing as widget is no longer mounted',
            );
            return; // Exit early if widget is disposed
          }

          // Use read to safely access the provider
          final gameId = game.gameId.toString();

          // Load game data through the notifier
          await ref.read(gameExtendedProvider(gameId).notifier).loadData();

          // Check again if widget is still mounted after the await
          if (!mounted) return;

          // After loading, safely read the state
          final gameExtended = ref.read(gameExtendedProvider(gameId));

          if (gameExtended.data != null) {
            final achievements = gameExtended.data!.getAchievementsList();
            final numDistinctPlayers = gameExtended.data!.numDistinctPlayers;

            double totalTrueScore = 0;

            for (final achievement in achievements) {
              final int points = achievement['Points'] ?? 0;
              final int numAwardedHardcore =
                  achievement['NumAwardedHardcore'] ?? 1;

              // Calculate true score using the formula
              final double ratio =
                  numDistinctPlayers /
                  (numAwardedHardcore > 0 ? numAwardedHardcore : 1);
              final double trueScore = points * sqrt(ratio);

              totalTrueScore += trueScore;
            }

            processedGames.add({
              'game': game,
              'trueScore': totalTrueScore,
              'achievements': achievements.length,
            });
          }
        } catch (e) {
          debugPrint('Error processing game ${game.gameId}: $e');
          // Continue with next game
        }
      }

      // Final mounted check before updating state
      if (!mounted) return;

      // Sort by true score (highest first)
      processedGames.sort((a, b) => b['trueScore'].compareTo(a['trueScore']));

      setState(() {
        _isLoading = false;
        _rankedGames = processedGames.take(10).toList();
      });
    } catch (e) {
      debugPrint('Error calculating top games: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _navigateToGameDetails(CompletedGame game) {
    final gameId = game.gameId.toString();
    final encodedTitle = Uri.encodeComponent(game.title);
    final encodedIconPath = Uri.encodeComponent(game.imageIcon);
    final encodedConsoleName = Uri.encodeComponent(game.consoleName);

    // Use context.go to navigate to the game details screen
    context.go(
      '/dashboard/game/$gameId?title=$encodedTitle&icon=$encodedIconPath&console=$encodedConsoleName',
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Top Game Completions',
            style: TextStyle(
              color: AppColors.textLight,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(16),
            width: double.infinity,
            decoration: BoxDecoration(
              color: AppColors.cardBackground,
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            ),
          ),
        ],
      );
    }

    if (_rankedGames.isEmpty) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Top Game Completions',
            style: TextStyle(
              color: AppColors.textLight,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.cardBackground,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Center(
              child: Text(
                'No fully completed games yet!',
                style: TextStyle(color: AppColors.textSubtle, fontSize: 16),
              ),
            ),
          ),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Top Game Completions',
              style: TextStyle(
                color: AppColors.textLight,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              'Completed: $_completedGamesCount',
              style: const TextStyle(color: AppColors.success, fontSize: 14),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          width: double.infinity,
          decoration: BoxDecoration(
            color: AppColors.cardBackground,
            borderRadius: BorderRadius.circular(8),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: [
              for (int i = 0; i < _rankedGames.length; i++)
                _buildCompletionProgressItem(context, _rankedGames[i], i),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCompletionProgressItem(
    BuildContext context,
    Map<String, dynamic> gameData,
    int index,
  ) {
    final game = gameData['game'] as CompletedGame;
    final trueScore = gameData['trueScore'] as double;
    final percentage = game.getCompletionPercentage();

    Color progressColor = CompletionColorHelper.getCompletionColor(percentage);

    return Card(
      // Wrap in a Card for better visual separation
      margin: const EdgeInsets.only(bottom: 8), // Add margin between items
      color: AppColors.darkBackground,
      child: InkWell(
        onTap: () => _navigateToGameDetails(game),
        borderRadius: BorderRadius.circular(4),
        child: Padding(
          padding: const EdgeInsets.all(12), // Add padding inside the card
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 12,
                    backgroundColor: progressColor,
                    child: Text(
                      (index + 1).toString(),
                      style: TextStyle(
                        color:
                            percentage >= 100
                                ? AppColors.darkBackground
                                : AppColors.textLight,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          game.title,
                          style: const TextStyle(
                            color: AppColors.textLight,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Row(
                          children: [
                            Text(
                              game.consoleName,
                              style: const TextStyle(
                                color: AppColors.textSubtle,
                                fontSize: 12,
                              ),
                            ),
                            const Spacer(),
                            Text(
                              'True Score: ${trueScore.toStringAsFixed(0)}',
                              style: TextStyle(
                                color: progressColor,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              // Progress bar
              ProgressBar(percentage: percentage, progressColor: progressColor),
            ],
          ),
        ),
      ),
    );
  }
}
