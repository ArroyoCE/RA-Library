// lib/screens/settings_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:retroachievements_organizer/constants/constants.dart';
import 'package:retroachievements_organizer/providers/states/auth_state_provider.dart';
import 'package:retroachievements_organizer/providers/states/settings_state_provider.dart';
import 'package:retroachievements_organizer/providers/repositories/local_data_repository_provider.dart';
import 'package:retroachievements_organizer/providers/repositories/consoles/all_games_hashes_repository_provider.dart';
import 'package:retroachievements_organizer/providers/states/local_data_state_provider.dart';
import 'package:retroachievements_organizer/models/consoles/all_game_hash.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  final Widget child;

  const SettingsScreen({super.key, required this.child});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> with AutomaticKeepAliveClientMixin {
  @override
  Widget build(BuildContext context) {
    super.build(context);
    return widget.child;
  }
  
  @override
  bool get wantKeepAlive => true;
}

class SettingsContent extends ConsumerStatefulWidget {
  const SettingsContent({super.key});

  @override
  ConsumerState<SettingsContent> createState() => _SettingsContentState();
}

class _SettingsContentState extends ConsumerState<SettingsContent> with AutomaticKeepAliveClientMixin {
  bool _autoLogin = true;
  
  @override
  void initState() {
    super.initState();
    // Initialize with user preferences
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final userState = ref.read(authStateProvider);
      setState(() {
        _autoLogin = userState.autoLogin;
      });
    });
  }
  
  Future<void> _applyChanges() async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator(color: AppColors.primary)),
    );
    
    try {
      final localDataRepo = ref.read(localDataRepositoryProvider);
      final supportedConsoles = localDataRepo.getSupportedConsoleIds();
      final allGamesRepo = ref.read(allGamesHashesRepositoryProvider);
      final apiKey = ref.read(authStateProvider).apiKey ?? '';
      final settings = ref.read(settingsProvider);
      
      for (final consoleId in supportedConsoles) {
        final gamesListRaw = await allGamesRepo.getGameList(consoleId.toString(), apiKey, useCache: true);
        if (gamesListRaw != null) {
          final gamesList = gamesListRaw
              .map((item) => GameHash.fromJson(item))
              .where((game) => !settings.shouldIgnoreGame(game.title))
              .toList();
              
          final totalGames = gamesList.length;
          final totalHashes = gamesList.fold<int>(0, (sum, game) => sum + game.hashes.length);
          
          await localDataRepo.saveConsoleTotals(consoleId, totalGames, totalHashes);
          
          final localHashes = await localDataRepo.getLocalHashes(consoleId);
          int matchedGames = 0;
          int matchedHashes = 0;
          
          if (localHashes.isNotEmpty) {
             final localHashSet = localHashes.values.toSet();
             final Set<String> uniqueMatchedHashes = <String>{};
             for (final game in gamesList) {
               bool isMatch = false;
               for (final h in game.hashes) {
                 final hashLower = h.toLowerCase();
                 if (localHashSet.contains(hashLower)) {
                   isMatch = true;
                   uniqueMatchedHashes.add(hashLower);
                 }
               }
               if (isMatch) {
                 matchedGames++;
               }
             }
             matchedHashes = uniqueMatchedHashes.length;
          }
          
          await localDataRepo.saveHashStats(consoleId, matchedGames, matchedHashes);
          
          final stats = {
            'matchedGames': matchedGames,
            'matchedHashes': matchedHashes,
            'totalGames': totalGames,
            'totalHashes': totalHashes,
            'lastUpdated': DateTime.now().toIso8601String(),
          };
          ref.read(consoleStatsNotifierProvider.notifier).updateConsoleStats(consoleId, stats);
        }
      }
    } catch (e) {
      debugPrint('Error applying changes: $e');
    } finally {
      if (mounted) {
        Navigator.of(context, rootNavigator: true).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Changes applied successfully!'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    
    return Card(
      color: AppColors.cardBackground,
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Settings title
            const Text(
              'Settings',
              style: TextStyle(
                color: AppColors.primary,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Divider(color: AppColors.primary),
            const SizedBox(height: 16),
            
            // Settings options
            SwitchListTile(
              dense: true,
              visualDensity: VisualDensity.compact,
              title: const Text(
                'Auto Login',
                style: TextStyle(
                  color: AppColors.textLight,
                  fontSize: 14,
                ),
              ),
              subtitle: const Text(
                'Remember login credentials',
                style: TextStyle(
                  color: AppColors.textLight,
                  fontSize: 11,
                ),
              ),
              value: _autoLogin,
              activeThumbColor: AppColors.primary,
              onChanged: (value) {
                setState(() {
                  _autoLogin = value;
                });
                ref.read(authStateProvider.notifier).setAutoLogin(value);
              },
            ),
            
            const Divider(color: Colors.grey),
            
            const SizedBox(height: 12),
            const Text(
              'Games to Ignore:',
              style: TextStyle(
                color: AppColors.primary,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            
            // Hack
            CheckboxListTile(
              dense: true,
              visualDensity: VisualDensity.compact,
              title: const Text('Hack (~Hack~)', style: TextStyle(color: AppColors.textLight, fontSize: 13)),
              value: ref.watch(settingsProvider).ignoreHack,
              activeColor: AppColors.primary,
              checkColor: AppColors.textDark,
              onChanged: (value) {
                if (value != null) ref.read(settingsProvider.notifier).setIgnoreHack(value);
              },
            ),
            // Homebrew
            CheckboxListTile(
              dense: true,
              visualDensity: VisualDensity.compact,
              title: const Text('Homebrew (~Homebrew~)', style: TextStyle(color: AppColors.textLight, fontSize: 13)),
              value: ref.watch(settingsProvider).ignoreHomebrew,
              activeColor: AppColors.primary,
              checkColor: AppColors.textDark,
              onChanged: (value) {
                if (value != null) ref.read(settingsProvider.notifier).setIgnoreHomebrew(value);
              },
            ),
            // Prototype
            CheckboxListTile(
              dense: true,
              visualDensity: VisualDensity.compact,
              title: const Text('Prototype (~Prototype~)', style: TextStyle(color: AppColors.textLight, fontSize: 13)),
              value: ref.watch(settingsProvider).ignorePrototype,
              activeColor: AppColors.primary,
              checkColor: AppColors.textDark,
              onChanged: (value) {
                if (value != null) ref.read(settingsProvider.notifier).setIgnorePrototype(value);
              },
            ),
            // Unlicensed
            CheckboxListTile(
              dense: true,
              visualDensity: VisualDensity.compact,
              title: const Text('Unlicensed (~Unlicensed~)', style: TextStyle(color: AppColors.textLight, fontSize: 13)),
              value: ref.watch(settingsProvider).ignoreUnlicensed,
              activeColor: AppColors.primary,
              checkColor: AppColors.textDark,
              onChanged: (value) {
                if (value != null) ref.read(settingsProvider.notifier).setIgnoreUnlicensed(value);
              },
            ),
            // Demo
            CheckboxListTile(
              dense: true,
              visualDensity: VisualDensity.compact,
              title: const Text('Demo (~Demo~)', style: TextStyle(color: AppColors.textLight, fontSize: 13)),
              value: ref.watch(settingsProvider).ignoreDemo,
              activeColor: AppColors.primary,
              checkColor: AppColors.textDark,
              onChanged: (value) {
                if (value != null) ref.read(settingsProvider.notifier).setIgnoreDemo(value);
              },
            ),
            
            const SizedBox(height: 16),
            Center(
              child: ElevatedButton.icon(
                onPressed: _applyChanges,
                icon: const Icon(Icons.check_circle_outline, size: 18),
                label: const Text('Apply Changes', style: TextStyle(fontSize: 14)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.textDark,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
              ),
            ),
            
            const Divider(color: Colors.grey),
            
            // Version info
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Text(
                'Version: 1.0.0 (Beta)',
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  @override
  bool get wantKeepAlive => true;
}