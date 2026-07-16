// lib/providers/states/auth_state_provider.dart

import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:retroachievements_library/models/user_state.dart';
import 'package:retroachievements_library/providers/repositories/user/user_repository_provider.dart';
import 'package:retroachievements_library/repositories/user/user_repository.dart';

// Auth state provider
final authStateProvider = StateNotifierProvider<AuthStateNotifier, UserState>((
  ref,
) {
  final repository = ref.watch(userRepositoryProvider);
  return AuthStateNotifier(repository);
});

// Authentication state notifier class
class AuthStateNotifier extends StateNotifier<UserState> {
  final UserRepository _repository;

  // Stream controller for notifying GoRouter of state changes
  final _controller = StreamController<UserState>.broadcast();
  @override
  Stream<UserState> get stream => _controller.stream;

  AuthStateNotifier(this._repository) : super(const UserState()) {
    _loadFromPrefs();
  }

  // Load user data from shared preferences
  Future<void> _loadFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final username = prefs.getString('username');
    final apiKey = prefs.getString('apiKey');
    final autoLogin = prefs.getBool('autoLogin') ?? false;
    final userPicPath = prefs.getString('userPicPath');

    if (username != null && apiKey != null && autoLogin) {
      state = UserState(
        isAuthenticated: true,
        username: username,
        apiKey: apiKey,
        autoLogin: autoLogin,
        userPicPath: userPicPath,
      );
      _controller.add(state);

      // Refresh user profile data
      login(username, apiKey, autoLogin);
    }
  }

  // Save user data to shared preferences
  Future<void> _saveToPrefs(
    String username,
    String apiKey,
    bool autoLogin, [
    String? userPicPath,
  ]) async {
    final prefs = await SharedPreferences.getInstance();
    if (autoLogin) {
      await prefs.setString('username', username);
      await prefs.setString('apiKey', apiKey);
      await prefs.setBool('autoLogin', autoLogin);

      if (userPicPath != null) {
        await prefs.setString('userPicPath', userPicPath);
      }
    } else {
      await prefs.remove('username');
      await prefs.remove('apiKey');
      await prefs.remove('userPicPath');
      await prefs.setBool('autoLogin', false);
    }
  }

  // Login method
  Future<void> login(String username, String apiKey, [bool? rememberMe]) async {
    // Update state to show loading
    state = state.copyWith(isLoading: true, errorMessage: null);
    _controller.add(state);

    try {
      // Call repository to get user profile
      final userProfile = await _repository.getUserProfile(username, apiKey);

      // Download and cache user profile picture if available
      String? userPicPath;
      if (userProfile != null && userProfile.userPicUrl.isNotEmpty) {
        userPicPath = await _repository.saveUserProfilePicture(
          userProfile.userPicUrl,
          username,
        );
      }

      // Update state with successful login
      final saveRememberMe = rememberMe ?? state.autoLogin;
      state = UserState(
        isAuthenticated: true,
        isLoading: false,
        username: username,
        apiKey: apiKey,
        autoLogin: saveRememberMe,
        userPicPath: userPicPath,
        userProfile: userProfile,
      );
      _controller.add(state);

      // Save to preferences if remember me is checked
      await _saveToPrefs(username, apiKey, saveRememberMe, userPicPath);
    } catch (e) {
      // Handle error
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Authentication failed: ${e.toString()}',
      );
      _controller.add(state);
    }
  }

  // Set auto login preference
  Future<void> setAutoLogin(bool value) async {
    state = state.copyWith(autoLogin: value);
    _controller.add(state);

    if (state.isAuthenticated &&
        state.username != null &&
        state.apiKey != null) {
      await _saveToPrefs(
        state.username!,
        state.apiKey!,
        value,
        state.userPicPath,
      );
    }
  }

  // Logout method
  Future<void> logout() async {
    // Clear stored credentials
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('username');
    await prefs.remove('apiKey');
    await prefs.remove('userPicPath');

    // Update state
    state = const UserState();
    _controller.add(state);
  }

  @override
  void dispose() {
    _controller.close();
    super.dispose();
  }
}
