// Updated lib/screens/game_data/components/game_hashes_tab.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:retroachievements_library/constants/constants.dart';
import 'package:retroachievements_library/screens/game_data/service/game_hashes_service.dart';
import 'package:retroachievements_library/screens/game_data/widgets/hash_item.dart';

class GameHashesTab extends ConsumerStatefulWidget {
  final String gameId;
  final String consoleName;
  final int consoleId;

  const GameHashesTab({
    super.key,
    required this.gameId,
    required this.consoleName,
    required this.consoleId,
  });

  @override
  ConsumerState<GameHashesTab> createState() => _GameHashesTabState();
}

class _GameHashesTabState extends ConsumerState<GameHashesTab> {
  bool _isLoading = true;
  String? _errorMessage;
  List<Map<String, dynamic>> _hashes = [];
  Map<String, String> _localHashes = {};

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Get local hashes for this console
      final localHashes = await GameHashesService.getLocalHashes(
        ref,
        widget.consoleId,
      );

      // Get game hashes from API
      final hashes = await GameHashesService.getGameHashes(ref, widget.gameId);

      if (mounted) {
        setState(() {
          _localHashes = localHashes;
          _hashes = hashes;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Error loading hash data: $e';
          _isLoading = false;
        });
      }
    }
  }

  // Check if a hash is available locally
  bool _isHashAvailable(String hash) {
    if (hash.isEmpty || _localHashes.isEmpty) return false;

    // Convert hash to lowercase for case-insensitive comparison
    final lowerHash = hash.toLowerCase();

    // Check if any hash in _localHashes matches (case-insensitive)
    return _localHashes.values.any(
      (storedHash) => storedHash.toLowerCase() == lowerHash,
    );
  }

  // Get ROM filename for a hash if available
  String? _getRomNameForHash(String hash) {
    if (hash.isEmpty) return null;

    final lowerHash = hash.toLowerCase();

    for (var entry in _localHashes.entries) {
      if (entry.value.toLowerCase() == lowerHash) {
        // Extract just the filename from the full path
        final pathParts = entry.key.split('/');
        return pathParts.isNotEmpty ? pathParts.last : entry.key;
      }
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.primary),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, color: AppColors.error, size: 48),
            const SizedBox(height: 16),
            Text(
              _errorMessage!,
              style: const TextStyle(color: AppColors.textLight, fontSize: 16),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadData,
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

    if (_hashes.isEmpty) {
      return const Center(
        child: Text(
          'No hash information available for this game.',
          style: TextStyle(color: AppColors.textLight, fontSize: 16),
        ),
      );
    }

    // Calculate hash availability statistics
    final availableHashes =
        _hashes.where((hash) => _isHashAvailable(hash['MD5'] ?? '')).length;

    return Column(
      children: [
        // Simplified header - just showing available hashes count
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            'Available ROMs: $availableHashes / ${_hashes.length}',
            style: TextStyle(
              color: availableHashes > 0 ? AppColors.success : AppColors.error,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),

        // List of hashes
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: _hashes.length,
            itemBuilder: (context, index) {
              final hash = _hashes[index];
              final md5Hash = hash['MD5'] ?? '';
              final isAvailable = _isHashAvailable(md5Hash);
              final localRomName =
                  isAvailable ? _getRomNameForHash(md5Hash) : null;

              return HashItem(
                hash: hash,
                isAvailable: isAvailable,
                localRomName: localRomName,
              );
            },
          ),
        ),
      ],
    );
  }
}
