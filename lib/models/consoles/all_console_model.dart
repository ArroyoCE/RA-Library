// lib/models/console.dart

class Console {
  final int id;
  final String name;
  final String iconUrl;
  final bool active;
  final bool isGameSystem;

  Console({
    required this.id,
    required this.name,
    required this.iconUrl,
    required this.active,
    required this.isGameSystem,
  });

  factory Console.fromJson(Map<String, dynamic> json) {
    return Console(
      id: json['ID'] ?? 0,
      name: json['Name'] ?? '',
      iconUrl: json['IconURL'] ?? '',
      active:
          json['Active'] == 1 ||
          json['Active'] == true ||
          json['Active'] == '1',
      isGameSystem:
          json['IsGameSystem'] == 1 ||
          json['IsGameSystem'] == true ||
          json['IsGameSystem'] == '1',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'ID': id,
      'Name': name,
      'IconURL': iconUrl,
      'Active': active,
      'IsGameSystem': isGameSystem,
    };
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
  
    return other is Console &&
      other.id == id &&
      other.name == name;
  }

  @override
  int get hashCode {
    return id.hashCode ^ name.hashCode;
  }
}
