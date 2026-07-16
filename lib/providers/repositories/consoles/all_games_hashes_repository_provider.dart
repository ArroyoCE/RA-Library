// lib/providers/repositories/all_games_hashes_repository_provider.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:retroachievements_library/api/consoles/all_games_hashes_api.dart';
import 'package:retroachievements_library/repositories/consoles/all_games_hashes_repository.dart';
import 'package:retroachievements_library/repositories/consoles/all_games_hashes_repository_impl.dart';
import 'package:retroachievements_library/services/storage_service.dart';

// Provider for the AllGamesHashesAPI
final allGamesHashesApiProvider = Provider<AllGamesHashesApi>((ref) {
  return AllGamesHashesApi();
});

// Provider for the AllGamesHashesRepository
final allGamesHashesRepositoryProvider = Provider<AllGamesHashesRepository>((
  ref,
) {
  final allGamesHashesApi = ref.watch(allGamesHashesApiProvider);
  final storageService = ref.watch(storageServiceProvider);
  return AllGamesHashesRepositoryImpl(allGamesHashesApi, storageService);
});
