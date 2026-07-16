// lib/providers/repositories/game_extended_repository_provider.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:retroachievements_library/api/games/game_extended_api.dart';
import 'package:retroachievements_library/repositories/games/game_extended_repository.dart';
import 'package:retroachievements_library/repositories/games/game_extended_repository_impl.dart';
import 'package:retroachievements_library/services/storage_service.dart';

// Provider for the GameExtendedAPI
final gameExtendedApiProvider = Provider<GameExtendedApi>((ref) {
  return GameExtendedApi();
});

// Provider for the GameExtendedRepository
final gameExtendedRepositoryProvider = Provider<GameExtendedRepository>((ref) {
  final gameExtendedApi = ref.watch(gameExtendedApiProvider);
  final storageService = ref.watch(storageServiceProvider);
  return GameExtendedRepositoryImpl(gameExtendedApi, storageService);
});
