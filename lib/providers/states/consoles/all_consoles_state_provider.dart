// lib/providers/states/all_consoles_state_provider.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:retroachievements_library/models/consoles/all_console_model.dart';
import 'package:retroachievements_library/providers/repositories/consoles/all_consoles_repository_provider.dart';
import 'package:retroachievements_library/providers/states/auth_state_provider.dart';
import 'package:retroachievements_library/repositories/consoles/all_consoles_repository.dart';

class ConsolesState {
  final bool isLoading;
  final String? errorMessage;
  final List<Console>? data;
  final DateTime? lastUpdated;

  ConsolesState({
    this.isLoading = false,
    this.errorMessage,
    this.data,
    this.lastUpdated,
  });

  ConsolesState copyWith({
    bool? isLoading,
    String? errorMessage,
    List<Console>? data,
    DateTime? lastUpdated,
  }) {
    return ConsolesState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
      data: data ?? this.data,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }
}

class ConsolesNotifier extends StateNotifier<ConsolesState> {
  final AllConsolesRepository allConsolesRepository;
  final String apiKey;

  ConsolesNotifier(this.allConsolesRepository, this.apiKey)
    : super(ConsolesState()) {
    if (apiKey.isNotEmpty) {
      loadData();
    }
  }

  Future<void> loadData({bool forceRefresh = false}) async {
    if (apiKey.isEmpty) {
      state = state.copyWith(
        errorMessage: 'No API key available',
        isLoading: false,
      );
      return;
    }

    state = state.copyWith(isLoading: true);

    try {
      final consolesList = await allConsolesRepository.getConsoleIDs(
        apiKey,
        useCache: !forceRefresh,
      );

      if (consolesList != null) {
        state = state.copyWith(
          data: consolesList.map((item) => Console.fromJson(item)).toList(),
          isLoading: false,
          lastUpdated: DateTime.now(),
        );
      } else {
        state = state.copyWith(
          errorMessage: 'Failed to load console list',
          isLoading: false,
        );
      }
    } catch (e) {
      state = state.copyWith(
        errorMessage: 'Error loading console list: $e',
        isLoading: false,
      );
    }
  }
}

final consolesStateProvider =
    StateNotifierProvider<ConsolesNotifier, ConsolesState>((ref) {
      final authState = ref.watch(authStateProvider);
      final repository = ref.watch(allConsolesRepositoryProvider);

      return ConsolesNotifier(repository, authState.apiKey ?? '');
    });
