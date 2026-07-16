import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:retroachievements_library/constants/api_constants.dart';
import 'package:retroachievements_library/models/user/user_profile_model.dart';
import 'package:retroachievements_library/services/storage_service.dart';

// Provide a UserApiService with caching capabilities
final userApiServiceProvider = Provider<UserApiService>((ref) {
  final storageService = ref.watch(storageServiceProvider);
  return UserApiService(storageService);
});

class UserApiService {
  final StorageService _storageService;

  UserApiService(this._storageService);

  // Verify user credentials and get user profile
  Future<UserProfile?> getUserProfile(
    String username,
    String apiKey, {
    bool useCache = true,
  }) async {
    try {
      // Try to load from cache first if useCache is true
      if (useCache) {
        final cachedData = await _storageService.readJsonData(
          'user_data',
          username,
        );
        if (cachedData != null) {
          debugPrint('Loaded user profile from cache');
          return UserProfile.fromJson(cachedData);
        }
      }

      // If not in cache or cache not requested, fetch from API
      final url = ApiConstants.getUserProfileUrl(username, apiKey);
      final response = await http.get(Uri.parse(url));

      // Check response status
      if (response.statusCode == 200) {
        // Check if response is empty array (invalid username)
        if (response.body == '[]') {
          throw Exception('Invalid username');
        }

        // Check if response contains error message (invalid API key)
        final decodedResponse = json.decode(response.body);
        if (decodedResponse is Map && decodedResponse.containsKey('errors')) {
          throw Exception('Invalid API key');
        }

        // Valid response, parse user profile
        final userProfile = UserProfile.fromJson(decodedResponse);

        // Save to cache
        await _storageService.saveUserProfileCache(username, decodedResponse);

        return userProfile;
      } else {
        throw Exception('Failed to load user profile: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error getting user profile: $e');
      rethrow;
    }
  }

  // Get user profile from cache only (useful when offline)
  Future<UserProfile?> getUserProfileFromCache(String username) async {
    try {
      final cachedData = await _storageService.readJsonData(
        'user_data',
        username,
      );
      if (cachedData != null) {
        return UserProfile.fromJson(cachedData);
      }
    } catch (e) {
      debugPrint('Error reading user profile from cache: $e');
    }
    return null;
  }

  // Clear cached user data
  Future<void> clearUserCache(String username) async {
    try {
      final filePath =
          '${(await _storageService.getOrCreateSubdirectory('user_data')).path}/$username.json';
      await _storageService.deleteFile(filePath);
    } catch (e) {
      debugPrint('Error clearing user cache: $e');
    }
  }
}

/*
HTML RESPONSE EXAMPLE
{
  "User": "MaxMilyin",
  "ULID": "00003EMFWR7XB8SDPEHB3K56ZQ",
  "UserPic": "/UserPic/MaxMilyin.png",
  "MemberSince": "2016-01-02 00:43:04",
  "RichPresenceMsg": "Playing ~Hack~ 11th Annual Vanilla Level Design Contest, The",
  "LastGameID": 19504,
  "ContribCount": 0,
  "ContribYield": 0,
  "TotalPoints": 399597,
  "TotalSoftcorePoints": 0,
  "TotalTruePoints": 1599212,
  "Permissions": 1,
  "Untracked": 0,
  "ID": 16446,
  "UserWallActive": true,
  "Motto": "Join me on Twitch! GameSquadSquad for live RA"
}
*/
