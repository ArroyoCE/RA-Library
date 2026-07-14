// lib/models/games/user_game_progress_model.dart

class UserGameProgress {
  final int id;
  final String title;
  final int consoleId;
  final int forumTopicId;
  final String imageIcon;
  final String imageTitle;
  final String imageIngame;
  final String imageBoxArt;
  final String publisher;
  final String developer;
  final String genre;
  final String released;
  final String releasedAtGranularity;
  final bool isFinal;
  final String? richPresencePatch;
  final String? guideURL;
  final String consoleName;
  final int? parentGameID;
  final int numDistinctPlayers;
  final int numAchievements;
  final Map<String, dynamic> achievements;
  final int numAwardedToUser;
  final int numAwardedToUserHardcore;
  final int numDistinctPlayersCasual;
  final int numDistinctPlayersHardcore;
  final String userCompletion;
  final String userCompletionHardcore;
  final String highestAwardKind;
  final String highestAwardDate;

  UserGameProgress({
    required this.id,
    required this.title,
    required this.consoleId,
    required this.forumTopicId,
    required this.imageIcon,
    required this.imageTitle,
    required this.imageIngame,
    required this.imageBoxArt,
    required this.publisher,
    required this.developer,
    required this.genre,
    required this.released,
    required this.releasedAtGranularity,
    required this.isFinal,
    this.richPresencePatch,
    this.guideURL,
    required this.consoleName,
    this.parentGameID,
    required this.numDistinctPlayers,
    required this.numAchievements,
    required this.achievements,
    required this.numAwardedToUser,
    required this.numAwardedToUserHardcore,
    required this.numDistinctPlayersCasual,
    required this.numDistinctPlayersHardcore,
    required this.userCompletion,
    required this.userCompletionHardcore,
    required this.highestAwardKind,
    required this.highestAwardDate,
  });

  factory UserGameProgress.fromJson(Map<String, dynamic> json) {
    return UserGameProgress(
      id: json['ID'] is int ? json['ID'] : int.parse(json['ID'].toString()),
      title: json['Title'] ?? '',
      consoleId: json['ConsoleID'] is int ? json['ConsoleID'] : int.parse(json['ConsoleID'].toString()),
      forumTopicId: json['ForumTopicID'] is int ? json['ForumTopicID'] : int.parse(json['ForumTopicID'].toString()),
      imageIcon: json['ImageIcon'] ?? '',
      imageTitle: json['ImageTitle'] ?? '',
      imageIngame: json['ImageIngame'] ?? '',
      imageBoxArt: json['ImageBoxArt'] ?? '',
      publisher: json['Publisher'] ?? '',
      developer: json['Developer'] ?? '',
      genre: json['Genre'] ?? '',
      released: json['Released'] ?? '',
      releasedAtGranularity: json['ReleasedAtGranularity'] ?? '',
      isFinal: json['IsFinal'] == 1 || json['IsFinal'] == true || json['IsFinal'] == '1',
      richPresencePatch: json['RichPresencePatch'],
      guideURL: json['GuideURL'],
      consoleName: json['ConsoleName'] ?? '',
      parentGameID: json['ParentGameID'],
      numDistinctPlayers: json['NumDistinctPlayers'] is int ? json['NumDistinctPlayers'] : int.parse(json['NumDistinctPlayers'].toString()),
      numAchievements: json['NumAchievements'] is int ? json['NumAchievements'] : int.parse(json['NumAchievements'].toString()),
      achievements: json['Achievements'] as Map<String, dynamic>? ?? {},
      numAwardedToUser: json['NumAwardedToUser'] is int ? json['NumAwardedToUser'] : int.parse(json['NumAwardedToUser'].toString()),
      numAwardedToUserHardcore: json['NumAwardedToUserHardcore'] is int ? json['NumAwardedToUserHardcore'] : int.parse(json['NumAwardedToUserHardcore'].toString()),
      numDistinctPlayersCasual: json['NumDistinctPlayersCasual'] is int ? json['NumDistinctPlayersCasual'] : int.parse(json['NumDistinctPlayersCasual'].toString()),
      numDistinctPlayersHardcore: json['NumDistinctPlayersHardcore'] is int ? json['NumDistinctPlayersHardcore'] : int.parse(json['NumDistinctPlayersHardcore'].toString()),
      userCompletion: json['UserCompletion'] ?? '0.00%',
      userCompletionHardcore: json['UserCompletionHardcore'] ?? '0.00%',
      highestAwardKind: json['HighestAwardKind'] ?? '',
      highestAwardDate: json['HighestAwardDate'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'ID': id,
      'Title': title,
      'ConsoleID': consoleId,
      'ForumTopicID': forumTopicId,
      'ImageIcon': imageIcon,
      'ImageTitle': imageTitle,
      'ImageIngame': imageIngame,
      'ImageBoxArt': imageBoxArt,
      'Publisher': publisher,
      'Developer': developer,
      'Genre': genre,
      'Released': released,
      'ReleasedAtGranularity': releasedAtGranularity,
      'IsFinal': isFinal,
      'RichPresencePatch': richPresencePatch,
      'GuideURL': guideURL,
      'ConsoleName': consoleName,
      'ParentGameID': parentGameID,
      'NumDistinctPlayers': numDistinctPlayers,
      'NumAchievements': numAchievements,
      'Achievements': achievements,
      'NumAwardedToUser': numAwardedToUser,
      'NumAwardedToUserHardcore': numAwardedToUserHardcore,
      'NumDistinctPlayersCasual': numDistinctPlayersCasual,
      'NumDistinctPlayersHardcore': numDistinctPlayersHardcore,
      'UserCompletion': userCompletion,
      'UserCompletionHardcore': userCompletionHardcore,
      'HighestAwardKind': highestAwardKind,
      'HighestAwardDate': highestAwardDate,
    };
  }

  // Helper method to check if an achievement is unlocked
  bool isAchievementUnlocked(String achievementId) {
    if (!achievements.containsKey(achievementId)) {
      return false;
    }
    
    final achievement = achievements[achievementId];
    return achievement.containsKey('DateEarnedHardcore') && 
           achievement['DateEarnedHardcore'] != null;
  }
  
  // Get processed achievements list
  List<Map<String, dynamic>> getAchievementsList() {
    List<Map<String, dynamic>> achievementsList = [];
    
    achievements.forEach((key, value) {
      if (value is Map) {
        final Map<String, dynamic> achievementMap = Map<String, dynamic>.from(value);
        achievementMap['isUnlocked'] = isAchievementUnlocked(key);
        achievementsList.add(achievementMap);
      }
    });
    
    // Sort by display order
    achievementsList.sort((a, b) {
      final aOrder = a['DisplayOrder'] is int ? a['DisplayOrder'] : int.parse(a['DisplayOrder'].toString());
      final bOrder = b['DisplayOrder'] is int ? b['DisplayOrder'] : int.parse(b['DisplayOrder'].toString());
      return aOrder.compareTo(bOrder);
    });
    
    return achievementsList;
  }
}