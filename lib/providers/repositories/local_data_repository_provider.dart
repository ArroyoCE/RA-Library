// lib/providers/repositories/local_data_repository_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:retroachievements_library/repositories/local_data_repository.dart';
import 'package:retroachievements_library/repositories/local_data_repository_impl.dart';
import 'package:retroachievements_library/services/storage_service.dart';

// Provider for the LocalDataRepository
final localDataRepositoryProvider = Provider<LocalDataRepository>((ref) {
  final storageService = ref.watch(storageServiceProvider);
  return LocalDataRepositoryImpl(storageService);
});
