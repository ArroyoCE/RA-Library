// lib/providers/states/settings_state_provider.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum HashDisplayPreference {
  onlyCountGames,
  onlyCountGamesShowHashes,
  accountForEveryHash,
}

class SettingsState {
  final bool ignoreHack;
  final bool ignoreHomebrew;
  final bool ignorePrototype;
  final bool ignoreUnlicensed;
  final bool ignoreDemo;
  final bool ignoreSubset;
  final HashDisplayPreference hashDisplayPreference;

  SettingsState({
    this.ignoreHack = false,
    this.ignoreHomebrew = false,
    this.ignorePrototype = false,
    this.ignoreUnlicensed = false,
    this.ignoreDemo = false,
    this.ignoreSubset = false,
    this.hashDisplayPreference = HashDisplayPreference.accountForEveryHash,
  });

  SettingsState copyWith({
    bool? ignoreHack,
    bool? ignoreHomebrew,
    bool? ignorePrototype,
    bool? ignoreUnlicensed,
    bool? ignoreDemo,
    bool? ignoreSubset,
    HashDisplayPreference? hashDisplayPreference,
  }) {
    return SettingsState(
      ignoreHack: ignoreHack ?? this.ignoreHack,
      ignoreHomebrew: ignoreHomebrew ?? this.ignoreHomebrew,
      ignorePrototype: ignorePrototype ?? this.ignorePrototype,
      ignoreUnlicensed: ignoreUnlicensed ?? this.ignoreUnlicensed,
      ignoreDemo: ignoreDemo ?? this.ignoreDemo,
      ignoreSubset: ignoreSubset ?? this.ignoreSubset,
      hashDisplayPreference: hashDisplayPreference ?? this.hashDisplayPreference,
    );
  }
  
  bool shouldIgnoreGame(String title) {
    if (ignoreHack && title.contains('~Hack~')) return true;
    if (ignoreHomebrew && title.contains('~Homebrew~')) return true;
    if (ignorePrototype && title.contains('~Prototype~')) return true;
    if (ignoreUnlicensed && title.contains('~Unlicensed~')) return true;
    if (ignoreDemo && title.contains('~Demo~')) return true;
    if (ignoreSubset && title.contains('Subset')) return true;
    return false;
  }
}

class SettingsNotifier extends StateNotifier<SettingsState> {
  SettingsNotifier() : super(SettingsState()) {
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    state = SettingsState(
      ignoreHack: prefs.getBool('ignore_hack') ?? false,
      ignoreHomebrew: prefs.getBool('ignore_homebrew') ?? false,
      ignorePrototype: prefs.getBool('ignore_prototype') ?? false,
      ignoreUnlicensed: prefs.getBool('ignore_unlicensed') ?? false,
      ignoreDemo: prefs.getBool('ignore_demo') ?? false,
      ignoreSubset: prefs.getBool('ignore_subset') ?? false,
      hashDisplayPreference: HashDisplayPreference.values[
          prefs.getInt('hash_display_preference') ?? 2],
    );
  }

  Future<void> setIgnoreHack(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('ignore_hack', value);
    state = state.copyWith(ignoreHack: value);
  }

  Future<void> setIgnoreHomebrew(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('ignore_homebrew', value);
    state = state.copyWith(ignoreHomebrew: value);
  }

  Future<void> setIgnorePrototype(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('ignore_prototype', value);
    state = state.copyWith(ignorePrototype: value);
  }

  Future<void> setIgnoreUnlicensed(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('ignore_unlicensed', value);
    state = state.copyWith(ignoreUnlicensed: value);
  }

  Future<void> setIgnoreDemo(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('ignore_demo', value);
    state = state.copyWith(ignoreDemo: value);
  }

  Future<void> setIgnoreSubset(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('ignore_subset', value);
    state = state.copyWith(ignoreSubset: value);
  }

  Future<void> setHashDisplayPreference(HashDisplayPreference value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('hash_display_preference', value.index);
    state = state.copyWith(hashDisplayPreference: value);
  }
}

final settingsProvider = StateNotifierProvider<SettingsNotifier, SettingsState>((ref) {
  return SettingsNotifier();
});
