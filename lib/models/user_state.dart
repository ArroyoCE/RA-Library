// lib/models/user_state.dart

import 'package:retroachievements_library/models/user/user_profile_model.dart';

class UserState {
  final bool isAuthenticated;
  final bool isLoading;
  final String? username;
  final String? apiKey;
  final String? errorMessage;
  final bool autoLogin;
  final UserProfile? userProfile;
  final String? userPicPath;

  const UserState({
    this.isAuthenticated = false,
    this.isLoading = false,
    this.username,
    this.apiKey,
    this.errorMessage,
    this.autoLogin = false,
    this.userProfile,
    this.userPicPath,
  });

  UserState copyWith({
    bool? isAuthenticated,
    bool? isLoading,
    String? username,
    String? apiKey,
    String? errorMessage,
    bool? autoLogin,
    UserProfile? userProfile,
    String? userPicPath,
  }) {
    return UserState(
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      isLoading: isLoading ?? this.isLoading,
      username: username ?? this.username,
      apiKey: apiKey ?? this.apiKey,
      errorMessage: errorMessage ?? this.errorMessage,
      autoLogin: autoLogin ?? this.autoLogin,
      userProfile: userProfile ?? this.userProfile,
      userPicPath: userPicPath ?? this.userPicPath,
    );
  }

  UserState clearError() {
    return UserState(
      isAuthenticated: isAuthenticated,
      isLoading: isLoading,
      username: username,
      apiKey: apiKey,
      errorMessage: null,
      autoLogin: autoLogin,
      userProfile: userProfile,
      userPicPath: userPicPath,
    );
  }
}
