import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../shared/providers/app_providers.dart';
import '../../../../shared/providers/firestore_providers.dart';
import '../../../auth/providers/auth_providers.dart';

// --- Models ---
class DashboardStats {
  final int todayTargetTotal;
  final int todayTargetCompleted;
  final int streakDays;
  final double readinessPercentage;
  final Map<String, double> subjectScores;

  DashboardStats({
    required this.todayTargetTotal,
    required this.todayTargetCompleted,
    required this.streakDays,
    required this.readinessPercentage,
    required this.subjectScores,
  });
}

class CurrentAffairPreview {
  final String id;
  final String title;
  final DateTime date;
  final String category;

  CurrentAffairPreview({required this.id, required this.title, required this.date, required this.category});
}

class LeaderboardPreview {
  final int userRank;
  final List<LeaderboardUser> topUsers;

  LeaderboardPreview({required this.userRank, required this.topUsers});
}

class LeaderboardUser {
  final String id;
  final String name;
  final String? avatarUrl;
  final int score;

  LeaderboardUser({required this.id, required this.name, this.avatarUrl, required this.score});
}

// --- Providers ---

final dashboardStatsProvider = StreamProvider<DashboardStats>((ref) {
  final userAsync = ref.watch(userModelProvider);
  final uid = ref.watch(authUidProvider);

  if (uid == null) {
    return Stream.value(DashboardStats(
      todayTargetTotal: 50,
      todayTargetCompleted: 0,
      streakDays: 0,
      readinessPercentage: 0.0,
      subjectScores: {},
    ));
  }

  final todayStart = DateTime.now().copyWith(
      hour: 0, minute: 0, second: 0, millisecond: 0, microsecond: 0);

  final attemptsStream = FirebaseFirestore.instance
      .collection(AppConstants.testAttemptsCollection)
      .where('userId', isEqualTo: uid)
      .where('attemptedAt', isGreaterThanOrEqualTo: Timestamp.fromDate(todayStart))
      .snapshots();

  return userAsync.when(
    data: (user) {
      if (user == null) {
        return Stream.value(DashboardStats(
          todayTargetTotal: 50,
          todayTargetCompleted: 0,
          streakDays: 0,
          readinessPercentage: 0.0,
          subjectScores: {},
        ));
      }

      return attemptsStream.map((snap) {
        int completedQuestions = 0;
        for (var doc in snap.docs) {
          completedQuestions += (doc.data()['totalQuestions'] as num?)?.toInt() ?? 0;
        }

        // Calculate readiness percentage matching profile screen logic
        double accuracy = user.accuracy;
        double readiness = (accuracy / 100) * 0.7; // Max 70% from accuracy
        double volume = (user.questionsAttempted / 5000).clamp(0.0, 1.0) * 0.3; // Max 30% from volume
        double readinessPercentage = double.parse(((readiness + volume) * 100).toStringAsFixed(1));

        // Use user's subjectScores
        final rawSubjectScores = user.subjectScores;
        final subjectScores = <String, double>{
          'Gen. Tamil': rawSubjectScores['General Tamil'] ?? rawSubjectScores['general_tamil'] ?? 0.0,
          'Gen. Knowledge': rawSubjectScores['General Studies'] ?? rawSubjectScores['general_knowledge'] ?? rawSubjectScores['general_studies'] ?? 0.0,
          'Aptitude': rawSubjectScores['Aptitude'] ?? rawSubjectScores['aptitude'] ?? rawSubjectScores['Aptitude & Mental Ability'] ?? rawSubjectScores['mental_ability'] ?? 0.0,
        };

        return DashboardStats(
          todayTargetTotal: 50,
          todayTargetCompleted: completedQuestions,
          streakDays: user.currentStreak,
          readinessPercentage: readinessPercentage,
          subjectScores: subjectScores,
        );
      });
    },
    loading: () => Stream.value(DashboardStats(
      todayTargetTotal: 50,
      todayTargetCompleted: 0,
      streakDays: 0,
      readinessPercentage: 0.0,
      subjectScores: {},
    )),
    error: (err, stack) => Stream.value(DashboardStats(
      todayTargetTotal: 50,
      todayTargetCompleted: 0,
      streakDays: 0,
      readinessPercentage: 0.0,
      subjectScores: {},
    )),
  );
});

final currentAffairsPreviewProvider = Provider<AsyncValue<List<CurrentAffairPreview>>>((ref) {
  final listAsync = ref.watch(currentAffairsStreamProvider(3));
  return listAsync.whenData((list) {
    return list.map((map) {
      final id = map['id'] ?? '';
      final title = map['titleEnglish'] ?? map['titleTamil'] ?? map['title'] ?? '';
      
      DateTime date = DateTime.now();
      if (map['publishedAt'] != null) {
        if (map['publishedAt'] is Timestamp) {
          date = (map['publishedAt'] as Timestamp).toDate();
        } else {
          date = DateTime.tryParse(map['publishedAt'].toString()) ?? DateTime.now();
        }
      }
      
      final category = map['category'] ?? 'State News';
      return CurrentAffairPreview(id: id, title: title, date: date, category: category);
    }).toList();
  });
});

final leaderboardPreviewProvider = Provider<AsyncValue<LeaderboardPreview>>((ref) {
  final leaderboardAsync = ref.watch(leaderboardStreamProvider);
  final uid = ref.watch(authUidProvider);

  return leaderboardAsync.whenData((list) {
    int userRank = -1;
    for (int i = 0; i < list.length; i++) {
      if (list[i]['id'] == uid) {
        userRank = i + 1;
        break;
      }
    }

    final topUsers = list.take(3).map((map) {
      final id = map['id'] ?? '';
      final name = map['name'] ?? 'User';
      final avatarUrl = map['photoUrl'] as String?;
      final score = (map['totalPoints'] as num?)?.toInt() ?? 0;
      return LeaderboardUser(id: id, name: name, avatarUrl: avatarUrl, score: score);
    }).toList();

    return LeaderboardPreview(
      userRank: userRank > 0 ? userRank : 50,
      topUsers: topUsers,
    );
  });
});

final dailyQuoteProvider = Provider<Map<String, String>>((ref) {
  final quotes = [
    {
      'tamil': 'கற்க கசடறக் கற்பவை கற்றபின்\nநிற்க அதற்குத் தக.',
      'english': 'Let a man learn thoroughly whatever he may learn, and let his conduct be worthy of his learning.'
    },
    {
      'tamil': 'எண்ணிய எண்ணியாங்கு எய்துப எண்ணியார்\nதிண்ணியர் ஆகப் பெறின்.',
      'english': 'If those who think are steadfast in their thought, they will achieve what they thought exactly as they thought it.'
    },
    {
      'tamil': 'வெள்ளத் தனைய மலர்நீட்டம் மாந்தர்தம்\nஉள்ளத் தனையது உயர்வு.',
      'english': 'The length of the flower stem is the depth of the water; the greatness of men is proportional to their greatness of mind.'
    },
  ];
  
  final dayOfYear = DateTime.now().difference(DateTime(DateTime.now().year, 1, 1)).inDays;
  return quotes[dayOfYear % quotes.length];
});
