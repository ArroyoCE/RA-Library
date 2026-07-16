import 'package:retroachievements_library/models/user/user_profile_model.dart';

abstract class UserRepository {
  Future<UserProfile?> getUserProfile(String username, String apiKey);
  Future<String?> saveUserProfilePicture(String imageUrl, String username);
  Future<UserProfile?> getUserProfileFromCache(String username);
  Future<void> clearUserCache(String username);
}
