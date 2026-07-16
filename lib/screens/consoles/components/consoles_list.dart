// lib/screens/consoles/components/consoles_list.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:retroachievements_library/constants/constants.dart';
import 'package:retroachievements_library/models/consoles/all_console_model.dart';
import 'package:retroachievements_library/screens/consoles/utils/consoles_helper.dart';
import 'package:retroachievements_library/screens/dashboard/widgets/progress_bar.dart';

class ConsolesList extends ConsumerWidget {
  final List<Console> consoles;
  final Map<int, Map<String, dynamic>> libraryStats;

  const ConsolesList({
    super.key,
    required this.consoles,
    required this.libraryStats,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListView.builder(
      padding: const EdgeInsets.all(8),
      itemCount: consoles.length,
      itemBuilder: (context, index) {
        final console = consoles[index];
        // Force all consoles to be supported
        const isSupported = true;

        return _buildConsoleListItem(
          context: context,
          console: console,
          isSupported: isSupported,
          libraryStats: libraryStats,
        );
      },
    );
  }

  Widget _buildConsoleListItem({
    required BuildContext context,
    required Console console,
    required bool isSupported,
    required Map<int, Map<String, dynamic>> libraryStats,
  }) {
    final hasLibraryStats = libraryStats.containsKey(console.id);
    final totalGames =
        hasLibraryStats ? libraryStats[console.id]!['totalGames'] ?? 0 : 0;
    final totalHashes =
        hasLibraryStats ? libraryStats[console.id]!['totalHashes'] ?? 0 : 0;
    final matchedGames =
        hasLibraryStats ? libraryStats[console.id]!['matchedGames'] ?? 0 : 0;
    final matchedHashes =
        hasLibraryStats ? libraryStats[console.id]!['matchedHashes'] ?? 0 : 0;

    final completionPercentage =
        totalGames > 0 ? (matchedGames / totalGames * 100) : 0.0;
    final progressColor = ConsolesHelper.getCompletionColor(
      completionPercentage,
    );

    return Card(
      color: AppColors.cardBackground,
      elevation: 4,
      margin: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        onTap:
            isSupported
                ? () => _navigateToConsoleGames(context, console)
                : null,
        borderRadius: BorderRadius.circular(4),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              // Console icon
              Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Image.network(
                      console.iconUrl,
                      height: 60,
                      width: 60,
                      fit: BoxFit.contain,
                      color:
                          isSupported
                              ? null
                              : Colors.grey.withValues(alpha: 0.5),
                      colorBlendMode: isSupported ? null : BlendMode.saturation,
                      errorBuilder: (context, error, stackTrace) {
                        return const Icon(
                          Icons.videogame_asset,
                          color: AppColors.primary,
                          size: 60,
                        );
                      },
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return const Center(
                          child: CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(
                              AppColors.primary,
                            ),
                            strokeWidth: 2,
                          ),
                        );
                      },
                    ),
                  ),
                  if (!isSupported)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.7),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Text(
                        'Coming Soon',
                        style: TextStyle(
                          color: AppColors.textLight,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(width: 16),

              // Console info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      console.name,
                      style: TextStyle(
                        color:
                            isSupported
                                ? AppColors.primary
                                : AppColors.textSubtle,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),

                    // Hash method info
                    if (isSupported)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              const Icon(
                                Icons.games,
                                color: AppColors.primary,
                                size: 14,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                'Games: $matchedGames/$totalGames (${completionPercentage.toStringAsFixed(1)}%)',
                                style: const TextStyle(
                                  color: AppColors.textLight,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 2),
                          Row(
                            children: [
                              const Icon(
                                Icons.tag,
                                color: AppColors.primary,
                                size: 14,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                'Hashes: $matchedHashes/$totalHashes (${(totalHashes > 0 ? matchedHashes / totalHashes * 100 : 0).toStringAsFixed(1)}%)',
                                style: const TextStyle(
                                  color: AppColors.textLight,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),

                          // Progress bar
                          const SizedBox(height: 8),
                          ProgressBar(
                            percentage: completionPercentage,
                            progressColor: progressColor,
                            height: 5.0,
                          ),
                        ],
                      ),
                  ],
                ),
              ),

              // Right chevron if supported
              if (isSupported)
                const Icon(
                  Icons.chevron_right,
                  color: AppColors.primary,
                  size: 24,
                ),
            ],
          ),
        ),
      ),
    );
  }

  void _navigateToConsoleGames(BuildContext context, Console console) {
    // Use go instead of pushNamed since we're working with nested navigation now
    context.go(
      '/games/${console.id}?name=${Uri.encodeComponent(console.name)}',
    );
  }
}
