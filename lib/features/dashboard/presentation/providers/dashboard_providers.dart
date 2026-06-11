import 'package:flutter_riverpod/flutter_riverpod.dart';

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

final dashboardStatsProvider = FutureProvider<DashboardStats>((ref) async {
  // Simulate network delay
  await Future.delayed(const Duration(seconds: 1));
  
  return DashboardStats(
    todayTargetTotal: 50,
    todayTargetCompleted: 35,
    streakDays: 7,
    readinessPercentage: 68.5,
    subjectScores: {
      'Gen. Tamil': 75.0,
      'Gen. English': 0.0, // Often mutually exclusive with Tamil
      'Gen. Knowledge': 60.5,
      'Aptitude': 82.0,
      'Mental Ability': 78.0,
    },
  );
});

final currentAffairsPreviewProvider = FutureProvider<List<CurrentAffairPreview>>((ref) async {
  await Future.delayed(const Duration(seconds: 1));
  
  return [
    CurrentAffairPreview(id: '1', title: 'TN Government launches new AI initiative for schools', date: DateTime.now().subtract(const Duration(hours: 2)), category: 'State News'),
    CurrentAffairPreview(id: '2', title: 'ISRO successfully launches new weather satellite', date: DateTime.now().subtract(const Duration(days: 1)), category: 'Science & Tech'),
    CurrentAffairPreview(id: '3', title: 'RBI announces new monetary policy rates', date: DateTime.now().subtract(const Duration(days: 2)), category: 'Economy'),
  ];
});

final leaderboardPreviewProvider = FutureProvider<LeaderboardPreview>((ref) async {
  await Future.delayed(const Duration(seconds: 1));
  
  return LeaderboardPreview(
    userRank: 47,
    topUsers: [
      LeaderboardUser(id: 'u1', name: 'Karthik N', score: 14500),
      LeaderboardUser(id: 'u2', name: 'Priya S', score: 14200),
      LeaderboardUser(id: 'u3', name: 'Arun K', score: 13950),
    ],
  );
});

final dailyQuoteProvider = Provider<Map<String, String>>((ref) {
  // Just returning a static daily quote for now based on day of year
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
