// lib/providers/repositories/user_repository_provider.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:retroachievements_library/api/user/user_profile_api.dart';
import 'package:retroachievements_library/repositories/user/user_repository.dart';
import 'package:retroachievements_library/repositories/user/user_repository_impl.dart';
import 'package:retroachievements_library/services/storage_service.dart';

// Provider for the UserRepository
final userRepositoryProvider = Provider<UserRepository>((ref) {
  final apiService = ref.watch(userApiServiceProvider);
  final storageService = ref.watch(storageServiceProvider);
  return UserRepositoryImpl(apiService, storageService);
});
