import 'package:cloud_firestore/cloud_firestore.dart';

/// User model for TNPSC Group 4 Master 2026
class UserModel {
  final String uid;
  final String name;
  final String email;
  final String? photoURL;
  final String district;
  final int targetScore;
  final int studyStreak;
  final int totalPoints;
  final int questionsAttempted;
  final double accuracy;
  final DateTime createdAt;
  final DateTime lastLoginAt;
  final bool isPremium;
  final String language; // 'en', 'ta', 'both'
  final bool isDarkMode;
  final Map<String, dynamic>? fcmTokens;

  const UserModel({
    required this.uid,
    required this.name,
    required this.email,
    this.photoURL,
    this.district = '',
    this.targetScore = 150,
    this.studyStreak = 0,
    this.totalPoints = 0,
    this.questionsAttempted = 0,
    this.accuracy = 0.0,
    required this.createdAt,
    required this.lastLoginAt,
    this.isPremium = false,
    this.language = 'both',
    this.isDarkMode = false,
    this.fcmTokens,
  });

  /// Create from Firestore document
  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return UserModel(
      uid: doc.id,
      name: data['name'] ?? '',
      email: data['email'] ?? '',
      photoURL: data['photoURL'],
      district: data['district'] ?? '',
      targetScore: data['targetScore'] ?? 150,
      studyStreak: data['studyStreak'] ?? 0,
      totalPoints: data['totalPoints'] ?? 0,
      questionsAttempted: data['questionsAttempted'] ?? 0,
      accuracy: (data['accuracy'] ?? 0.0).toDouble(),
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      lastLoginAt: (data['lastLoginAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      isPremium: data['isPremium'] ?? false,
      language: data['language'] ?? 'both',
      isDarkMode: data['isDarkMode'] ?? false,
      fcmTokens: data['fcmTokens'] as Map<String, dynamic>?,
    );
  }

  /// Create from Map (for Hive local cache)
  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid: map['uid'] ?? '',
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      photoURL: map['photoURL'],
      district: map['district'] ?? '',
      targetScore: map['targetScore'] ?? 150,
      studyStreak: map['studyStreak'] ?? 0,
      totalPoints: map['totalPoints'] ?? 0,
      questionsAttempted: map['questionsAttempted'] ?? 0,
      accuracy: (map['accuracy'] ?? 0.0).toDouble(),
      createdAt: map['createdAt'] is Timestamp
          ? (map['createdAt'] as Timestamp).toDate()
          : DateTime.tryParse(map['createdAt']?.toString() ?? '') ?? DateTime.now(),
      lastLoginAt: map['lastLoginAt'] is Timestamp
          ? (map['lastLoginAt'] as Timestamp).toDate()
          : DateTime.tryParse(map['lastLoginAt']?.toString() ?? '') ?? DateTime.now(),
      isPremium: map['isPremium'] ?? false,
      language: map['language'] ?? 'both',
      isDarkMode: map['isDarkMode'] ?? false,
      fcmTokens: map['fcmTokens'] as Map<String, dynamic>?,
    );
  }

  /// Convert to Firestore document
  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'email': email,
      'photoURL': photoURL,
      'district': district,
      'targetScore': targetScore,
      'studyStreak': studyStreak,
      'totalPoints': totalPoints,
      'questionsAttempted': questionsAttempted,
      'accuracy': accuracy,
      'createdAt': Timestamp.fromDate(createdAt),
      'lastLoginAt': Timestamp.fromDate(lastLoginAt),
      'isPremium': isPremium,
      'language': language,
      'isDarkMode': isDarkMode,
      'fcmTokens': fcmTokens,
    };
  }

  /// Convert to Map (for Hive local cache)
  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'name': name,
      'email': email,
      'photoURL': photoURL,
      'district': district,
      'targetScore': targetScore,
      'studyStreak': studyStreak,
      'totalPoints': totalPoints,
      'questionsAttempted': questionsAttempted,
      'accuracy': accuracy,
      'createdAt': createdAt.toIso8601String(),
      'lastLoginAt': lastLoginAt.toIso8601String(),
      'isPremium': isPremium,
      'language': language,
      'isDarkMode': isDarkMode,
      'fcmTokens': fcmTokens,
    };
  }

  /// Create a copy with updated fields
  UserModel copyWith({
    String? uid,
    String? name,
    String? email,
    String? photoURL,
    String? district,
    int? targetScore,
    int? studyStreak,
    int? totalPoints,
    int? questionsAttempted,
    double? accuracy,
    DateTime? createdAt,
    DateTime? lastLoginAt,
    bool? isPremium,
    String? language,
    bool? isDarkMode,
    Map<String, dynamic>? fcmTokens,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      name: name ?? this.name,
      email: email ?? this.email,
      photoURL: photoURL ?? this.photoURL,
      district: district ?? this.district,
      targetScore: targetScore ?? this.targetScore,
      studyStreak: studyStreak ?? this.studyStreak,
      totalPoints: totalPoints ?? this.totalPoints,
      questionsAttempted: questionsAttempted ?? this.questionsAttempted,
      accuracy: accuracy ?? this.accuracy,
      createdAt: createdAt ?? this.createdAt,
      lastLoginAt: lastLoginAt ?? this.lastLoginAt,
      isPremium: isPremium ?? this.isPremium,
      language: language ?? this.language,
      isDarkMode: isDarkMode ?? this.isDarkMode,
      fcmTokens: fcmTokens ?? this.fcmTokens,
    );
  }

  /// Empty user for initial state
  static UserModel empty = UserModel(
    uid: '',
    name: '',
    email: '',
    createdAt: DateTime.now(),
    lastLoginAt: DateTime.now(),
  );

  bool get isEmpty => uid.isEmpty;
  bool get isNotEmpty => uid.isNotEmpty;

  @override
  String toString() => 'UserModel(uid: $uid, name: $name, email: $email)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserModel && runtimeType == other.runtimeType && uid == other.uid;

  @override
  int get hashCode => uid.hashCode;
}
