// lib/providers/states/local_data_state_provider.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:retroachievements_organizer/providers/repositories/local_data_repository_provider.dart';
import 'package:retroachievements_organizer/repositories/local_data_repository.dart';

// Provide a list of local consoles folders
final consoleFoldersProvider = FutureProvider<Map<int, List<String>>>((ref) async {
  final repository = ref.watch(localDataRepositoryProvider);
  return await repository.getConsoleFolders();
});

// Provider for checking if a console is supported
final isConsoleSupportedProvider = Provider.family<bool, int>((ref, consoleId) {
  final repository = ref.watch(localDataRepositoryProvider);
  return repository.isConsoleSupported(consoleId);
});

// Provider for getting all supported console IDs
final supportedConsoleIdsProvider = Provider<List<int>>((ref) {
  final repository = ref.watch(localDataRepositoryProvider);
  return repository.getSupportedConsoleIds();
});

// A StateNotifier to manage console stats
class ConsoleStatsNotifier extends StateNotifier<Map<int, Map<String, dynamic>>> {
  final LocalDataRepository _repository;
  
  ConsoleStatsNotifier(this._repository) : super({}) {
    _loadInitialStats();
  }
  
  Future<void> _loadInitialStats() async {
  final supportedIds = _repository.getSupportedConsoleIds();
  Map<int, Map<String, dynamic>> initialStats = {};
  
  for (final id in supportedIds) {
    try {
      final stats = await _repository.getHashStats(id);
      if (stats != null) {
        // Make sure totalGames and totalHashes are present
        if (!stats.containsKey('totalGames') || !stats.containsKey('totalHashes') || 
            stats['totalGames'] == 0 || stats['totalHashes'] == 0) {
          // Try to get totals from somewhere else - use a placeholder
          // These will be populated properly when games are loaded
          stats['totalGames'] = stats['totalGames'] ?? 0;
          stats['totalHashes'] = stats['totalHashes'] ?? 0;
        }
        initialStats[id] = stats;
      }
    } catch (e) {
      debugPrint('Error loading initial stats for console $id: $e');
    }
  }
  
  // Set the state once with all loaded stats
  if (initialStats.isNotEmpty) {
    state = Map.from(initialStats);
  }
}
  
  Future<void> loadConsoleStats(int consoleId) async {
    final stats = await _repository.getHashStats(consoleId);
    if (stats != null) {
      // Create a new map to ensure state change is detected
      final newState = Map<int, Map<String, dynamic>>.from(state);
      newState[consoleId] = Map<String, dynamic>.from(stats);
      state = newState;
    }
  }
  
  void updateConsoleStats(int consoleId, Map<String, dynamic> stats) {
    // Create a new map to ensure state change is detected
    final newState = Map<int, Map<String, dynamic>>.from(state);
    newState[consoleId] = Map<String, dynamic>.from(stats);
    state = newState;
  }
  
  Future<void> refreshAllStats() async {
  final supportedIds = _repository.getSupportedConsoleIds();
  Map<int, Map<String, dynamic>> newStats = {};
  
  for (final id in supportedIds) {
    // Get current cached stats first
    final stats = await _repository.getHashStats(id);
    
    if (stats != null) {
      // Make sure we preserve totalGames and totalHashes
      // if they exist in the current state
      if (state.containsKey(id)) {
        // Create new stats object with existing totals
        final updatedStats = Map<String, dynamic>.from(stats);
        updatedStats['totalGames'] = state[id]?['totalGames'] ?? 0;
        updatedStats['totalHashes'] = state[id]?['totalHashes'] ?? 0;
        newStats[id] = updatedStats;
      } else {
        newStats[id] = stats;
      }
    }
  }
  
  if (newStats.isNotEmpty) {
    state = newStats;
  }
}
}

// The StateNotifierProvider for console stats
final consoleStatsNotifierProvider = StateNotifierProvider<ConsoleStatsNotifier, Map<int, Map<String, dynamic>>>((ref) {
  final repository = ref.watch(localDataRepositoryProvider);
  return ConsoleStatsNotifier(repository);
});

// For backward compatibility, provide a regular provider that returns the same data
final consoleStatsProvider = Provider<Map<int, Map<String, dynamic>>>((ref) {
  return ref.watch(consoleStatsNotifierProvider);
});