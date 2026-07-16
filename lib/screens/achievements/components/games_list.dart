// lib/screens/achievements/components/games_list.dart

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:retroachievements_library/constants/constants.dart';
import 'package:retroachievements_library/models/user/all_completion_model.dart';
import 'package:retroachievements_library/screens/dashboard/utils/completion_color_helper.dart';
import 'package:retroachievements_library/screens/dashboard/utils/dashboard_formatter.dart';
import 'package:retroachievements_library/services/storage_service.dart';

class GamesList extends ConsumerStatefulWidget {
  final List<dynamic> games;
  final Function(GameProgress) onGameSelected;

  const GamesList({
    super.key,
    required this.games,
    required this.onGameSelected,
  });

  @override
  ConsumerState<GamesList> createState() => _GamesListState();
}

class _GamesListState extends ConsumerState<GamesList> {
  final Map<int, String?> _gameIconPaths = {};

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: widget.games.length,
      itemBuilder: (context, index) {
        final game = widget.games[index];
        return _buildDenseGameTile(game);
      },
    );
  }

  Widget _buildDenseGameTile(GameProgress game) {
    final gameId = game.gameId;
    final title = game.title;
    final iconPath = game.imageIcon;
    final consoleName = game.consoleName;
    final maxPossible = game.maxPossible;
    final numAwarded = game.numAwardedHardcore;
    final percentage = game.getCompletionPercentage();
    final highestAward = game.highestAwardKind;
    final mostRecentDate =
        game.mostRecentAwardedDate.isNotEmpty
            ? DateTime.parse(game.mostRecentAwardedDate)
            : null;

    final progressColor = CompletionColorHelper.getCompletionColor(percentage);

    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => widget.onGameSelected(game),
          borderRadius: BorderRadius.circular(12),
          hoverColor: Colors.white.withValues(alpha: 0.02),
          splashColor: AppColors.primary.withValues(alpha: 0.1),
          highlightColor: Colors.white.withValues(alpha: 0.01),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.white.withValues(alpha: 0.03)),
              borderRadius: BorderRadius.circular(12),
              color: Colors.white.withValues(alpha: 0.015),
            ),
            child: Row(
              children: [
                // 1. Box Art (Smaller, rounded)
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.2),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child:
                        _gameIconPaths.containsKey(gameId) &&
                                _gameIconPaths[gameId] != null
                            ? Image.file(
                              File(_gameIconPaths[gameId]!),
                              fit: BoxFit.cover,
                              errorBuilder:
                                  (context, error, stackTrace) =>
                                      _buildPlaceholder(),
                            )
                            : FutureBuilder<String?>(
                              future: _getGameIcon(gameId, iconPath),
                              builder: (context, snapshot) {
                                if (snapshot.connectionState ==
                                        ConnectionState.done &&
                                    snapshot.hasData &&
                                    snapshot.data != null) {
                                  return Image.file(
                                    File(snapshot.data!),
                                    fit: BoxFit.cover,
                                    errorBuilder:
                                        (context, error, stackTrace) =>
                                            _buildPlaceholder(),
                                  );
                                } else {
                                  return _buildPlaceholder();
                                }
                              },
                            ),
                  ),
                ),

                const SizedBox(width: 16),

                // 2. Title & Console Info
                Expanded(
                  flex: 3,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              consoleName,
                              style: TextStyle(
                                color: AppColors.primary.withValues(alpha: 0.9),
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          if (mostRecentDate != null) ...[
                            const SizedBox(width: 8),
                            Text(
                              'Last played: ${_formatDate(mostRecentDate)}',
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.4),
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 16),

                // 3. Progress Section (Inline)
                Expanded(
                  flex: 2,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '$numAwarded / $maxPossible',
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.6),
                              fontSize: 12,
                            ),
                          ),
                          Text(
                            '${percentage.toStringAsFixed(0)}%',
                            style: TextStyle(
                              color: progressColor,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Container(
                        height: 6,
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.3),
                          borderRadius: BorderRadius.circular(3),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(3),
                          child: LinearProgressIndicator(
                            value: percentage / 100,
                            backgroundColor: Colors.transparent,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              progressColor,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 16),

                // 4. Award Badge
                SizedBox(
                  width: 32,
                  child:
                      highestAward.isNotEmpty
                          ? _buildAwardBadge(highestAward)
                          : const SizedBox.shrink(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      color: AppColors.darkBackground,
      child: const Icon(
        Icons.videogame_asset,
        color: AppColors.primary,
        size: 24,
      ),
    );
  }

  // Create a more visually distinct award badge
  Widget _buildAwardBadge(String awardKind) {
    IconData icon;
    Color color;
    String tooltip;

    if (awardKind == 'mastery') {
      icon = Icons.workspace_premium;
      color = Colors.amber;
      tooltip = 'Mastered';
    } else if (awardKind == 'beaten-hardcore') {
      icon = Icons.military_tech;
      color = AppColors.success;
      tooltip = 'Beaten Hardcore';
    } else {
      icon = Icons.emoji_events_outlined;
      color = AppColors.info;
      tooltip = 'Completed';
    }

    return Tooltip(
      message: tooltip,
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: color, size: 20),
      ),
    );
  }

  Future<String?> _getGameIcon(int gameId, String iconPath) async {
    // Check cache first
    if (_gameIconPaths.containsKey(gameId)) {
      return _gameIconPaths[gameId];
    }

    // Otherwise fetch and cache
    final storageService = ref.read(storageServiceProvider);

    // Make sure the icon path starts with '/' for API URL consistency
    final normalizedIconPath =
        iconPath.startsWith('/') ? iconPath : '/$iconPath';

    final localPath = await storageService.saveImageFromUrl(
      'https://retroachievements.org$normalizedIconPath',
      'game_images',
      'game_$gameId.png',
    );

    if (mounted) {
      setState(() {
        _gameIconPaths[gameId] = localPath;
      });
    }

    return localPath;
  }

  String _formatDate(DateTime date) {
    return DashboardFormatter.formatDate(date);
  }
}
