import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String uid;
  final String name;
  final String email;
  final String? photoUrl;
  final String? phoneNumber;
  final String district;       // Tamil Nadu district
  final DateTime createdAt;
  final DateTime lastLoginAt;
  final int totalScore;
  final int testsAttempted;
  final int currentStreak;     // days
  final int longestStreak;
  final Map<String, double> subjectScores; // subject → avg %
  final List<String> achievements;
  final bool isAnonymous;
  final bool isPremium;
  final String? fcmToken;

  int get totalPoints => totalScore;
  double get accuracy {
    if (subjectScores.isEmpty) return 0.0;
    return subjectScores.values.reduce((a, b) => a + b) / subjectScores.length;
  }
  int get studyStreak => currentStreak;
  int get questionsAttempted => testsAttempted * 10;

  UserModel({
    required this.uid,
    required this.name,
    required this.email,
    this.photoUrl,
    this.phoneNumber,
    this.district = '',
    required this.createdAt,
    required this.lastLoginAt,
    this.totalScore = 0,
    this.testsAttempted = 0,
    this.currentStreak = 0,
    this.longestStreak = 0,
    this.subjectScores = const {},
    this.achievements = const [],
    this.isAnonymous = false,
    this.isPremium = false,
    this.fcmToken,
  });

  UserModel copyWith({
    String? uid,
    String? name,
    String? email,
    String? photoUrl,
    String? phoneNumber,
    String? district,
    DateTime? createdAt,
    DateTime? lastLoginAt,
    int? totalScore,
    int? testsAttempted,
    int? currentStreak,
    int? longestStreak,
    Map<String, double>? subjectScores,
    List<String>? achievements,
    bool? isAnonymous,
    bool? isPremium,
    String? fcmToken,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      name: name ?? this.name,
      email: email ?? this.email,
      photoUrl: photoUrl ?? this.photoUrl,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      district: district ?? this.district,
      createdAt: createdAt ?? this.createdAt,
      lastLoginAt: lastLoginAt ?? this.lastLoginAt,
      totalScore: totalScore ?? this.totalScore,
      testsAttempted: testsAttempted ?? this.testsAttempted,
      currentStreak: currentStreak ?? this.currentStreak,
      longestStreak: longestStreak ?? this.longestStreak,
      subjectScores: subjectScores ?? this.subjectScores,
      achievements: achievements ?? this.achievements,
      isAnonymous: isAnonymous ?? this.isAnonymous,
      isPremium: isPremium ?? this.isPremium,
      fcmToken: fcmToken ?? this.fcmToken,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'name': name,
      'email': email,
      'photoUrl': photoUrl,
      'phoneNumber': phoneNumber,
      'district': district,
      'createdAt': Timestamp.fromDate(createdAt),
      'lastLoginAt': Timestamp.fromDate(lastLoginAt),
      'totalScore': totalScore,
      'testsAttempted': testsAttempted,
      'currentStreak': currentStreak,
      'longestStreak': longestStreak,
      'subjectScores': subjectScores,
      'achievements': achievements,
      'isAnonymous': isAnonymous,
      'isPremium': isPremium,
      'fcmToken': fcmToken,
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map, String id) {
    return UserModel(
      uid: id,
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      photoUrl: map['photoUrl'],
      phoneNumber: map['phoneNumber'],
      district: map['district'] ?? '',
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      lastLoginAt: (map['lastLoginAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      totalScore: map['totalScore']?.toInt() ?? 0,
      testsAttempted: map['testsAttempted']?.toInt() ?? 0,
      currentStreak: map['currentStreak']?.toInt() ?? 0,
      longestStreak: map['longestStreak']?.toInt() ?? 0,
      subjectScores: Map<String, double>.from(map['subjectScores'] ?? {}),
      achievements: List<String>.from(map['achievements'] ?? []),
      isAnonymous: map['isAnonymous'] ?? false,
      isPremium: map['isPremium'] ?? false,
      fcmToken: map['fcmToken'],
    );
  }
}
