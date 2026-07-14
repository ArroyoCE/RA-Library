// lib/models/user_profile.dart

class UserProfile {
  final String username;
  final String userPicUrl;
  final String memberSince;
  final String richPresenceMsg;
  final int lastGameId;
  final int contribCount;
  final int contribYield;
  final int totalPoints;
  final int totalSoftcorePoints;
  final int totalTruePoints;
  final int permissions;
  final int untracked;
  final int id;
  final bool userWallActive;
  final String motto;

  UserProfile({
    required this.username,
    required this.userPicUrl,
    required this.memberSince,
    required this.richPresenceMsg,
    required this.lastGameId,
    required this.contribCount,
    required this.contribYield,
    required this.totalPoints,
    required this.totalSoftcorePoints,
    required this.totalTruePoints,
    required this.permissions,
    required this.untracked,
    required this.id,
    required this.userWallActive,
    required this.motto,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      username: json['User'] ?? '',
      userPicUrl: json['UserPic'] ?? '',
      memberSince: json['MemberSince'] ?? '',
      richPresenceMsg: json['RichPresenceMsg'] ?? '',
      lastGameId: json['LastGameID'] ?? 0,
      contribCount: json['ContribCount'] ?? 0,
      contribYield: json['ContribYield'] ?? 0,
      totalPoints: json['TotalPoints'] ?? 0,
      totalSoftcorePoints: json['TotalSoftcorePoints'] ?? 0,
      totalTruePoints: json['TotalTruePoints'] ?? 0,
      permissions: json['Permissions'] ?? 0,
      untracked: json['Untracked'] ?? 0,
      id: json['ID'] ?? 0,
      userWallActive: json['UserWallActive'] == 1 || json['UserWallActive'] == true || json['UserWallActive'] == '1',
      motto: json['Motto'] ?? '',
    );
  }
  
  // Convert to JSON map
  Map<String, dynamic> toJson() {
    return {
      'User': username,
      'UserPic': userPicUrl,
      'MemberSince': memberSince,
      'RichPresenceMsg': richPresenceMsg,
      'LastGameID': lastGameId,
      'ContribCount': contribCount,
      'ContribYield': contribYield,
      'TotalPoints': totalPoints,
      'TotalSoftcorePoints': totalSoftcorePoints,
      'TotalTruePoints': totalTruePoints,
      'Permissions': permissions,
      'Untracked': untracked,
      'ID': id,
      'UserWallActive': userWallActive,
      'Motto': motto,
    };
  }
}