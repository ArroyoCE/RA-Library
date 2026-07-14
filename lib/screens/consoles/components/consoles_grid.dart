// lib/screens/consoles/components/consoles_grid.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:retroachievements_organizer/constants/constants.dart';
import 'package:retroachievements_organizer/models/consoles/all_console_model.dart';
import 'package:retroachievements_organizer/widgets/generic_grid_display.dart';

class ConsolesGrid extends ConsumerWidget {
  final List<Console> consoles;
  final Map<int, Map<String, dynamic>> libraryStats;

  const ConsolesGrid({
    super.key,
    required this.consoles,
    required this.libraryStats,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GenericGridDisplay<Console>(
      items: consoles,
      crossAxisCount: 6,
      crossAxisSpacing: 5,
      mainAxisSpacing: 5,
      childAspectRatio: 1.8,
      itemBuilder: (context, console, index) {
        // Force all consoles to be supported
        const isSupported = true;
        
        return _buildConsoleCard(
          context: context,
          console: console,
          isSupported: isSupported,
          libraryStats: libraryStats,
        );
      },
    );
  }

  Widget _buildConsoleCard({
  required BuildContext context,
  required Console console,
  required bool isSupported,
  
  required Map<int, Map<String, dynamic>> libraryStats,
}) {
  final hasLibraryStats = libraryStats.containsKey(console.id);
  final totalGames = hasLibraryStats ? libraryStats[console.id]!['totalGames'] ?? 0 : 0;
  final totalHashes = hasLibraryStats ? libraryStats[console.id]!['totalHashes'] ?? 0 : 0;
  final matchedGames = hasLibraryStats ? libraryStats[console.id]!['matchedGames'] ?? 0 : 0;
  final matchedHashes = hasLibraryStats ? libraryStats[console.id]!['matchedHashes'] ?? 0 : 0;
  
  return Card(
    color: AppColors.cardBackground,
    elevation: 4,
    child: InkWell(
      onTap: isSupported ? () => _navigateToConsoleGames(context, console) : null,
      borderRadius: BorderRadius.circular(4),
      child: Padding(
        padding: const EdgeInsets.all(8), // Reduced from 16 to 8
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Console icon
                  Image.network(
                    console.iconUrl,
                    fit: BoxFit.contain,
                    color: isSupported ? null : Colors.grey.withValues(alpha: 0.5),
                    colorBlendMode: isSupported ? null : BlendMode.saturation,
                    errorBuilder: (context, error, stackTrace) {
                      return const Icon(
                        Icons.videogame_asset,
                        color: AppColors.primary,
                        size: 40,
                      );
                    },
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return const Center(
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                          strokeWidth: 2,
                        ),
                      );
                    },
                  ),
                  if (!isSupported)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.7),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Text(
                        'Soon',
                        style: TextStyle(
                          color: AppColors.textLight,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 4), // Reduced spacing
            
            Text(
              console.name,
              style: TextStyle(
                color: isSupported ? AppColors.primary : AppColors.textSubtle,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            
            // Library statistics if available
            if (isSupported)
  Column(
    children: [
      const SizedBox(height: 2), // Reduced spacing
      Text(
        'Games: $matchedGames/$totalGames',
        style: const TextStyle(
          color: AppColors.textLight,
          fontSize: 10,
        ),
        textAlign: TextAlign.center,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      Text(
        'Hashes: $matchedHashes/$totalHashes',
        style: const TextStyle(
          color: AppColors.textLight,
          fontSize: 10,
        ),
        textAlign: TextAlign.center,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
    ],
  ),
          ],
        ),
      ),
    ),
  );
}

void _navigateToConsoleGames(BuildContext context, Console console) {
  // Use go instead of pushNamed since we're working with nested navigation now
  context.go('/games/${console.id}?name=${Uri.encodeComponent(console.name)}');
}
}