class UserModel {
  final String uid;
  final String email;
  final String fullName;
  final String role; // e.g., 'student'
  final DateTime createdAt;
  final Map<String, dynamic> dashboardPreferences;
  final int xp;
  final int level;
  final int streak;

  UserModel({
    required this.uid,
    required this.email,
    required this.fullName,
    required this.role,
    required this.createdAt,
    this.dashboardPreferences = const {},
    this.xp = 0,
    this.level = 1,
    this.streak = 0,
  });

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'fullName': fullName,
      'role': role,
      'createdAt': createdAt.toIso8601String(),
      'dashboardPreferences': dashboardPreferences,
      'xp': xp,
      'level': level,
      'streak': streak,
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid: map['uid'] ?? '',
      email: map['email'] ?? '',
      fullName: map['fullName'] ?? '',
      role: map['role'] ?? 'student',
      createdAt: DateTime.parse(map['createdAt']),
      dashboardPreferences: Map<String, dynamic>.from(map['dashboardPreferences'] ?? {}),
      xp: map['xp'] ?? 0,
      level: map['level'] ?? 1,
      streak: map['streak'] ?? 0,
    );
  }

  UserModel copyWith({
    String? fullName,
    String? role,
    Map<String, dynamic>? dashboardPreferences,
    int? xp,
    int? level,
    int? streak,
  }) {
    return UserModel(
      uid: uid,
      email: email,
      fullName: fullName ?? this.fullName,
      role: role ?? this.role,
      createdAt: createdAt,
      dashboardPreferences: dashboardPreferences ?? this.dashboardPreferences,
      xp: xp ?? this.xp,
      level: level ?? this.level,
      streak: streak ?? this.streak,
    );
  }
}
