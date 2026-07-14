// lib/screens/achievements/utils/achievement_sorter.dart

enum SortOption {
  completionAsc,
  completionDesc,
  alphabeticalAsc,
  alphabeticalDesc,
  platformAsc,
  platformDesc,
}

enum CompletionFilterStatus {
  all,
  completedOnly,
  hideCompleted,
}

class AchievementSorter {
  // Apply filters to the games list
  static List<dynamic> applyFilters(
    List<dynamic> games, {
    required CompletionFilterStatus completionStatus,
    required Set<String> selectedPlatforms,
  }) {
    List<dynamic> filtered = List.from(games);
    
    // Filter by completion status
    if (completionStatus != CompletionFilterStatus.all) {
      filtered = filtered.where((game) {
        final maxPossible = game.maxPossible;
        final numAwarded = game.numAwardedHardcore;
        final isCompleted = maxPossible > 0 && numAwarded == maxPossible;
        
        if (completionStatus == CompletionFilterStatus.completedOnly) {
          return isCompleted;
        } else {
          // hideCompleted
          return !isCompleted;
        }
      }).toList();
    }
    
    // Filter by selected platforms
    if (selectedPlatforms.isNotEmpty) {
      filtered = filtered.where((game) {
        final consoleName = game.consoleName;
        return selectedPlatforms.contains(consoleName);
      }).toList();
    }
    
    return filtered;
  }
  
  // Apply sorting to the games list
  static List<dynamic> applySorting(List<dynamic> games, SortOption sortOption) {
    List<dynamic> sorted = List.from(games);
    
    switch (sortOption) {
      case SortOption.completionAsc:
        sorted.sort((a, b) {
          final aMax = a.maxPossible;
          final aAwarded = a.numAwardedHardcore;
          final bMax = b.maxPossible;
          final bAwarded = b.numAwardedHardcore;
          
          final aPercentage = aMax > 0 ? (aAwarded / aMax) : 0;
          final bPercentage = bMax > 0 ? (bAwarded / bMax) : 0;
          
          return aPercentage.compareTo(bPercentage);
        });
        break;
      case SortOption.completionDesc:
        sorted.sort((a, b) {
          final aMax = a.maxPossible;
          final aAwarded = a.numAwardedHardcore;
          final bMax = b.maxPossible;
          final bAwarded = b.numAwardedHardcore;
          
          final aPercentage = aMax > 0 ? (aAwarded / aMax) : 0;
          final bPercentage = bMax > 0 ? (bAwarded / bMax) : 0;
          
          return bPercentage.compareTo(aPercentage);
        });
        break;
      case SortOption.alphabeticalAsc:
        sorted.sort((a, b) {
          final aTitle = a.title;
          final bTitle = b.title;
          return aTitle.compareTo(bTitle);
        });
        break;
      case SortOption.alphabeticalDesc:
        sorted.sort((a, b) {
          final aTitle = a.title;
          final bTitle = b.title;
          return bTitle.compareTo(aTitle);
        });
        break;
      case SortOption.platformAsc:
        sorted.sort((a, b) {
          final aConsole = a.consoleName;
          final bConsole = b.consoleName;
          if (aConsole == bConsole) {
            final aTitle = a.title;
            final bTitle = b.title;
            return aTitle.compareTo(bTitle);
          }
          return aConsole.compareTo(bConsole);
        });
        break;
      case SortOption.platformDesc:
        sorted.sort((a, b) {
          final aConsole = a.consoleName;
          final bConsole = b.consoleName;
          if (aConsole == bConsole) {
            final aTitle = a.title;
            final bTitle = b.title;
            return aTitle.compareTo(bTitle);
          }
          return bConsole.compareTo(aConsole);
        });
        break;
    }
    
    return sorted;
  }
}