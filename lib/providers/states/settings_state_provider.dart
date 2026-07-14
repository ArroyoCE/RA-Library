// lib/providers/states/settings_state_provider.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsState {
  final bool ignoreHack;
  final bool ignoreHomebrew;
  final bool ignorePrototype;
  final bool ignoreUnlicensed;
  final bool ignoreDemo;

  SettingsState({
    this.ignoreHack = false,
    this.ignoreHomebrew = false,
    this.ignorePrototype = false,
    this.ignoreUnlicensed = false,
    this.ignoreDemo = false,
  });

  SettingsState copyWith({
    bool? ignoreHack,
    bool? ignoreHomebrew,
    bool? ignorePrototype,
    bool? ignoreUnlicensed,
    bool? ignoreDemo,
  }) {
    return SettingsState(
      ignoreHack: ignoreHack ?? this.ignoreHack,
      ignoreHomebrew: ignoreHomebrew ?? this.ignoreHomebrew,
      ignorePrototype: ignorePrototype ?? this.ignorePrototype,
      ignoreUnlicensed: ignoreUnlicensed ?? this.ignoreUnlicensed,
      ignoreDemo: ignoreDemo ?? this.ignoreDemo,
    );
  }
  
  bool shouldIgnoreGame(String title) {
    if (ignoreHack && title.contains('~Hack~')) return true;
    if (ignoreHomebrew && title.contains('~Homebrew~')) return true;
    if (ignorePrototype && title.contains('~Prototype~')) return true;
    if (ignoreUnlicensed && title.contains('~Unlicensed~')) return true;
    if (ignoreDemo && title.contains('~Demo~')) return true;
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
}

final settingsProvider = StateNotifierProvider<SettingsNotifier, SettingsState>((ref) {
  return SettingsNotifier();
});
