// lib/providers/repositories/user/user_stats_repository_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:retroachievements_library/api/user/all_completion_api.dart';
import 'package:retroachievements_library/api/user/completed_games_api.dart';
import 'package:retroachievements_library/api/user/recently_played_api.dart';
import 'package:retroachievements_library/api/user/user_awards_api.dart';
import 'package:retroachievements_library/api/user/user_summary_api.dart';
import 'package:retroachievements_library/services/storage_service.dart';
import 'package:retroachievements_library/repositories/user/user_stats_repository.dart';
import 'package:retroachievements_library/repositories/user/user_stats_repository_impl.dart';

final userStatsRepositoryProvider = Provider<UserStatsRepository>((ref) {
  final storageService = ref.watch(storageServiceProvider);

  return UserStatsRepositoryImpl(
    AllCompletionApi(),
    CompletedGamesApi(),
    RecentlyPlayedApi(),
    UserAwardsApi(),
    UserSummaryApi(),
    storageService,
  );
});
