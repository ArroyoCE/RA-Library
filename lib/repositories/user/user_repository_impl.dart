// lib/repositories/user/user_repository_impl.dart

import 'package:retroachievements_library/api/user/user_profile_api.dart';
import 'package:retroachievements_library/models/user/user_profile_model.dart';
import 'package:retroachievements_library/repositories/user/user_repository.dart';
import 'package:retroachievements_library/services/storage_service.dart';

class UserRepositoryImpl implements UserRepository {
  final UserApiService _apiService;
  final StorageService _storageService;

  UserRepositoryImpl(this._apiService, this._storageService);

  @override
  Future<UserProfile?> getUserProfile(String username, String apiKey) async {
    return await _apiService.getUserProfile(username, apiKey);
  }

  @override
  Future<String?> saveUserProfilePicture(
    String imageUrl,
    String username,
  ) async {
    return await _storageService.saveUserProfilePicture(imageUrl, username);
  }

  @override
  Future<UserProfile?> getUserProfileFromCache(String username) async {
    return await _apiService.getUserProfileFromCache(username);
  }

  @override
  Future<void> clearUserCache(String username) async {
    await _apiService.clearUserCache(username);
  }
}
