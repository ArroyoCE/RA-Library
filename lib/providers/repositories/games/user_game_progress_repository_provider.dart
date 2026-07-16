// lib/providers/repositories/games/user_game_progress_repository_provider.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:retroachievements_library/api/games/user_game_progress_api.dart';
import 'package:retroachievements_library/repositories/games/user_game_progress_repository.dart';
import 'package:retroachievements_library/repositories/games/user_game_progress_repository_impl.dart';
import 'package:retroachievements_library/services/storage_service.dart';

// Provider for the UserGameProgressApi
final userGameProgressApiProvider = Provider<UserGameProgressApi>((ref) {
  return UserGameProgressApi();
});

// Provider for the UserGameProgressRepository
final userGameProgressRepositoryProvider = Provider<UserGameProgressRepository>(
  (ref) {
    final userGameProgressApi = ref.watch(userGameProgressApiProvider);
    final storageService = ref.watch(storageServiceProvider);
    return UserGameProgressRepositoryImpl(userGameProgressApi, storageService);
  },
);
