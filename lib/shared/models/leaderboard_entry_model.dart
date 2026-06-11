import 'package:cloud_firestore/cloud_firestore.dart';

class LeaderboardEntry {
  final String userId;
  final String userName;
  final String? photoUrl;
  final String district;
  final int totalScore;
  final int testsAttempted;
  final double avgScore;
  final int rank;
  final int weeklyScore;

  LeaderboardEntry({
    required this.userId,
    required this.userName,
    this.photoUrl,
    required this.district,
    required this.totalScore,
    required this.testsAttempted,
    required this.avgScore,
    required this.rank,
    required this.weeklyScore,
  });

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'userName': userName,
      'photoUrl': photoUrl,
      'district': district,
      'totalScore': totalScore,
      'testsAttempted': testsAttempted,
      'avgScore': avgScore,
      'rank': rank,
      'weeklyScore': weeklyScore,
    };
  }

  factory LeaderboardEntry.fromMap(Map<String, dynamic> map) {
    return LeaderboardEntry(
      userId: map['userId'] ?? '',
      userName: map['userName'] ?? 'Unknown User',
      photoUrl: map['photoUrl'],
      district: map['district'] ?? 'Unknown District',
      totalScore: (map['totalScore'] as num?)?.toInt() ?? 0,
      testsAttempted: (map['testsAttempted'] as num?)?.toInt() ?? 0,
      avgScore: (map['avgScore'] as num?)?.toDouble() ?? 0.0,
      rank: (map['rank'] as num?)?.toInt() ?? 0,
      weeklyScore: (map['weeklyScore'] as num?)?.toInt() ?? 0,
    );
  }

  factory LeaderboardEntry.fromFirestore(DocumentSnapshot snap) {
    final data = snap.data() as Map<String, dynamic>? ?? {};
    if (!data.containsKey('userId') || (data['userId'] as String).isEmpty) {
      data['userId'] = snap.id;
    }
    return LeaderboardEntry.fromMap(data);
  }
}
