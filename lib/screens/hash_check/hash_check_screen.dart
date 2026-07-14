// lib/screens/hash_check/hash_check_screen.dart

import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:retroachievements_organizer/constants/constants.dart';
import 'package:retroachievements_organizer/models/consoles/all_console_model.dart';
import 'package:retroachievements_organizer/models/consoles/all_game_hash.dart';
import 'package:retroachievements_organizer/providers/states/consoles/all_consoles_state_provider.dart';
import 'package:retroachievements_organizer/providers/states/consoles/all_games_hashes_state_provider.dart';
import 'package:retroachievements_organizer/services/hashing/native/unified_hash_service.dart';

class HashCheckScreen extends ConsumerStatefulWidget {
  final Widget? child;
  const HashCheckScreen({super.key, this.child});

  @override
  ConsumerState<HashCheckScreen> createState() => _HashCheckScreenState();
}

class _HashCheckScreenState extends ConsumerState<HashCheckScreen> with AutomaticKeepAliveClientMixin {
  @override
  Widget build(BuildContext context) {
    super.build(context);
    return widget.child ?? const HashCheckContent();
  }

  @override
  bool get wantKeepAlive => true;
}

class HashCheckContent extends ConsumerStatefulWidget {
  const HashCheckContent({super.key});

  @override
  ConsumerState<HashCheckContent> createState() => _HashCheckContentState();
}

class _HashCheckContentState extends ConsumerState<HashCheckContent> {
  Console? _selectedConsole;
  File? _selectedFile;
  String _currentHash = '';
  bool _isHashing = false;
  bool _hasChecked = false;
  GameHash? _matchedGame;

  @override
  void initState() {
    super.initState();
    // Pre-load consoles if needed
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final consolesState = ref.read(consolesStateProvider);
      if (consolesState.data == null && !consolesState.isLoading) {
        ref.read(consolesStateProvider.notifier).loadData();
      }
    });
  }

  Future<void> _pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();
    if (result != null && result.files.single.path != null) {
      setState(() {
        _selectedFile = File(result.files.single.path!);
        _hasChecked = false;
        _currentHash = '';
        _matchedGame = null;
      });
    }
  }

  Future<void> _verifyHash() async {
    if (_selectedConsole == null || _selectedFile == null) return;

    setState(() {
      _isHashing = true;
      _hasChecked = false;
      _matchedGame = null;
      _currentHash = '';
    });

    try {
      // 1. Calculate the file's hash using UnifiedHashService
      final hashService = UnifiedHashService();
      final hashVal = await hashService.hashFile(_selectedFile!.path, _selectedConsole!.id);

      if (hashVal.isEmpty) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to calculate hash. Ensure the file is valid.')),
          );
        }
        setState(() {
          _isHashing = false;
        });
        return;
      }

      setState(() {
        _currentHash = hashVal;
      });

      // 2. Ensure games hashes are loaded for the console
      final hashesNotifier = ref.read(gamesHashesStateProvider.notifier);
      final hashesState = ref.read(gamesHashesStateProvider);
      
      if (hashesState.systemId != _selectedConsole!.id.toString() || hashesState.data == null) {
        await hashesNotifier.loadGameList(_selectedConsole!.id.toString());
      }
      
      // We must read the updated state after awaiting
      final updatedState = ref.read(gamesHashesStateProvider);
      if (updatedState.data != null) {
        // 3. Search for the hash
        for (final game in updatedState.data!) {
          if (game.hashes.contains(_currentHash)) {
            _matchedGame = game;
            break;
          }
        }
      }

    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isHashing = false;
          _hasChecked = true;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final consolesState = ref.watch(consolesStateProvider);
    final hashesState = ref.watch(gamesHashesStateProvider);
    
    // Create a safe, unique list of consoles for the dropdown
    List<Console> dropdownConsoles = [];
    if (consolesState.data != null) {
      final seenIds = <int>{};
      dropdownConsoles = consolesState.data!
          .where((c) => c.name.toLowerCase() != 'standalone' && seenIds.add(c.id))
          .toList();
    }
    
    // Ensure _selectedConsole is actually in the dropdown list to prevent assertion errors
    final safeSelectedConsole = dropdownConsoles.contains(_selectedConsole) ? _selectedConsole : null;

    return Scaffold(
      backgroundColor: AppColors.darkBackground,
      appBar: AppBar(
        backgroundColor: AppColors.appBarBackground,
        title: const Text('Hash Check Tool', style: TextStyle(color: AppColors.textLight)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Select a console and a file to verify its hash against RetroAchievements database.',
              style: TextStyle(color: AppColors.textLight, fontSize: 16),
            ),
            const SizedBox(height: 24),

            // Console Dropdown
            const Text('1. Select Console:', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            if (consolesState.isLoading)
              const CircularProgressIndicator()
            else if (consolesState.data != null)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: AppColors.cardBackground,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.textSubtle),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<Console>(
                    isExpanded: true,
                    dropdownColor: AppColors.cardBackground,
                    hint: const Text('Select a console', style: TextStyle(color: AppColors.textLight)),
                    value: safeSelectedConsole,
                    items: dropdownConsoles.map((console) {
                      return DropdownMenuItem<Console>(
                        value: console,
                        child: Text(console.name, style: const TextStyle(color: AppColors.textLight)),
                      );
                    }).toList(),
                    onChanged: (Console? newValue) {
                      setState(() {
                        _selectedConsole = newValue;
                        _hasChecked = false;
                        _matchedGame = null;
                      });
                    },
                  ),
                ),
              )
            else
              const Text('Failed to load consoles.', style: TextStyle(color: Colors.red)),

            const SizedBox(height: 24),

            // File Picker
            const Text('2. Select File:', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Row(
              children: [
                ElevatedButton.icon(
                  onPressed: _pickFile,
                  icon: const Icon(Icons.file_open),
                  label: const Text('Browse File...'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.cardBackground,
                    foregroundColor: AppColors.textLight,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    _selectedFile != null ? _selectedFile!.path.split(Platform.pathSeparator).last : 'No file selected',
                    style: const TextStyle(color: AppColors.textSubtle),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 32),

            // Verify Button
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: (_selectedConsole != null && _selectedFile != null && !_isHashing && !hashesState.isLoading)
                    ? _verifyHash
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.black,
                  disabledBackgroundColor: AppColors.cardBackground,
                ),
                child: _isHashing || hashesState.isLoading
                    ? const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black)),
                          SizedBox(width: 12),
                          Text('Verifying... (Downloading list can take a while)'),
                        ],
                      )
                    : const Text('Verify Hash', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ),

            const SizedBox(height: 32),

            // Results
            if (_hasChecked)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.cardBackground,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Result', style: TextStyle(color: AppColors.primary, fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 12),
                    Text('Calculated Hash: $_currentHash', style: const TextStyle(color: AppColors.textLight, fontFamily: 'monospace')),
                    const SizedBox(height: 16),
                    
                    if (_matchedGame != null) ...[
                      const Row(
                        children: [
                          Icon(Icons.check_circle, color: Colors.green),
                          SizedBox(width: 8),
                          Text('Match found!', style: TextStyle(color: Colors.green, fontSize: 16, fontWeight: FontWeight.bold)),
                        ],
                      ),
                      const SizedBox(height: 16),
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: _matchedGame!.imageIcon.isNotEmpty
                            ? Image.network(
                                'https://media.retroachievements.org${_matchedGame!.imageIcon}',
                                width: 50,
                                height: 50,
                                fit: BoxFit.cover,
                                errorBuilder: (c, e, s) => const Icon(Icons.videogame_asset, size: 50, color: AppColors.primary),
                              )
                            : const Icon(Icons.videogame_asset, size: 50, color: AppColors.primary),
                        title: Text(_matchedGame!.title, style: const TextStyle(color: AppColors.textLight, fontWeight: FontWeight.bold)),
                        subtitle: Text('${_matchedGame!.numAchievements} Achievements • ${_matchedGame!.points} Points', style: const TextStyle(color: AppColors.textSubtle)),
                        trailing: ElevatedButton(
                          onPressed: () {
                            // Navigate to game details
                            context.pushNamed(
                              'hash_check_game_details',
                              pathParameters: {'gameId': _matchedGame!.id.toString()},
                              queryParameters: {
                                'title': _matchedGame!.title,
                                'icon': _matchedGame!.imageIcon,
                                'console': _matchedGame!.consoleName,
                              },
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.black,
                          ),
                          child: const Text('View'),
                        ),
                      ),
                    ] else ...[
                      const Row(
                        children: [
                          Icon(Icons.cancel, color: Colors.red),
                          SizedBox(width: 8),
                          Text('No match found in RetroAchievements.', style: TextStyle(color: Colors.red, fontSize: 16, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
