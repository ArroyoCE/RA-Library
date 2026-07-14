// lib/models/games/game_extended_model.dart

class GameExtended {
  final int id;
  final String title;
  final int consoleId;
  final int forumTopicId;
  final int? flags;
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
  final String updated;
  final String consoleName;
  final int? parentGameID;
  final int numDistinctPlayers;
  final int numAchievements;
  final Map<String, dynamic>? achievements;
  final List<dynamic>? claims;
  final int numDistinctPlayersCasual;
  final int numDistinctPlayersHardcore;

  GameExtended({
    required this.id,
    required this.title,
    required this.consoleId,
    required this.forumTopicId,
    this.flags,
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
    required this.updated,
    required this.consoleName,
    this.parentGameID,
    required this.numDistinctPlayers,
    required this.numAchievements,
    this.achievements,
    this.claims,
    required this.numDistinctPlayersCasual,
    required this.numDistinctPlayersHardcore,
  });

  factory GameExtended.fromJson(Map<String, dynamic> json) {
    return GameExtended(
      id: json['ID'] is int ? json['ID'] : int.tryParse(json['ID'].toString()) ?? 0,
      title: json['Title'] ?? '',
      consoleId: json['ConsoleID'] is int ? json['ConsoleID'] : int.tryParse(json['ConsoleID'].toString()) ?? 0,
      forumTopicId: json['ForumTopicID'] is int ? json['ForumTopicID'] : int.tryParse(json['ForumTopicID'].toString()) ?? 0,
      flags: json['Flags'],
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
      updated: json['Updated'] ?? '',
      consoleName: json['ConsoleName'] ?? '',
      parentGameID: json['ParentGameID'],
      numDistinctPlayers: json['NumDistinctPlayers'] is int ? json['NumDistinctPlayers'] : int.tryParse(json['NumDistinctPlayers'].toString()) ?? 0,
      numAchievements: json['NumAchievements'] is int ? json['NumAchievements'] : int.tryParse(json['NumAchievements'].toString()) ?? 0,
      achievements: json['Achievements'] as Map<String, dynamic>?,
      claims: json['Claims'] as List<dynamic>?,
      numDistinctPlayersCasual: json['NumDistinctPlayersCasual'] is int ? json['NumDistinctPlayersCasual'] : int.tryParse(json['NumDistinctPlayersCasual'].toString()) ?? 0,
      numDistinctPlayersHardcore: json['NumDistinctPlayersHardcore'] is int ? json['NumDistinctPlayersHardcore'] : int.tryParse(json['NumDistinctPlayersHardcore'].toString()) ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'ID': id,
      'Title': title,
      'ConsoleID': consoleId,
      'ForumTopicID': forumTopicId,
      'Flags': flags,
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
      'Updated': updated,
      'ConsoleName': consoleName,
      'ParentGameID': parentGameID,
      'NumDistinctPlayers': numDistinctPlayers,
      'NumAchievements': numAchievements,
      'Achievements': achievements,
      'Claims': claims,
      'NumDistinctPlayersCasual': numDistinctPlayersCasual,
      'NumDistinctPlayersHardcore': numDistinctPlayersHardcore,
    };
  }
  
  // Helper method to get processed achievements list
  List<dynamic> getAchievementsList() {
    if (achievements == null) return [];
    
    final achievementsList = achievements!.values.toList();
    
    // Sort by display order
    achievementsList.sort((a, b) {
      final aOrder = a['DisplayOrder'] != null ? int.tryParse(a['DisplayOrder'].toString()) ?? 999 : 999;
      final bOrder = b['DisplayOrder'] != null ? int.tryParse(b['DisplayOrder'].toString()) ?? 999 : 999;
      return aOrder.compareTo(bOrder);
    });
    
    return achievementsList;
  }
}