// lib/providers/states/consoles/consoles_updating_state_provider.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';

/// A global provider to track if console data is currently being fetched or refreshed
/// in the background. This can be used to lock navigation or show loading indicators.
final consolesUpdatingStateProvider = StateProvider<bool>((ref) => false);
