import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../shared/providers/firestore_providers.dart';
import '../../../shared/models/test_attempt_model.dart';

// Parse raw maps into strongly typed TestAttemptModel objects
final testAttemptsProvider = Provider<AsyncValue<List<TestAttemptModel>>>((ref) {
  final attemptsAsync = ref.watch(userTestAttemptsStreamProvider);
  return attemptsAsync.whenData((maps) {
    return maps.map((m) => TestAttemptModel.fromMap(m, m['id'])).toList();
  });
});

class AnalyticsStats {
  final int testsTaken;
  final double avgScore;
  final int bestScore;
  final int totalTimeStudied; // in seconds

  AnalyticsStats({
    required this.testsTaken,
    required this.avgScore,
    required this.bestScore,
    required this.totalTimeStudied,
  });
}

final analyticsStatsProvider = Provider<AsyncValue<AnalyticsStats>>((ref) {
  final attemptsAsync = ref.watch(testAttemptsProvider);
  return attemptsAsync.whenData((attempts) {
    if (attempts.isEmpty) {
      return AnalyticsStats(testsTaken: 0, avgScore: 0, bestScore: 0, totalTimeStudied: 0);
    }

    int best = 0;
    int totalScore = 0;
    int totalTime = 0;

    for (var attempt in attempts) {
      if (attempt.score > best) best = attempt.score;
      totalScore += attempt.score;
      totalTime += attempt.timeTakenSeconds;
    }

    return AnalyticsStats(
      testsTaken: attempts.length,
      avgScore: totalScore / attempts.length,
      bestScore: best,
      totalTimeStudied: totalTime,
    );
  });
});

final radarChartProvider = Provider<AsyncValue<Map<String, Map<String, double>>>>((ref) {
  final attemptsAsync = ref.watch(testAttemptsProvider);
  return attemptsAsync.whenData((attempts) {
    // Current Week (last 7 days)
    final now = DateTime.now();
    final currentWeekStart = now.subtract(const Duration(days: 7));
    final prevWeekStart = currentWeekStart.subtract(const Duration(days: 7));

    final currentWeekAttempts = attempts.where((a) => a.startedAt.isAfter(currentWeekStart)).toList();
    final prevWeekAttempts = attempts.where((a) => a.startedAt.isAfter(prevWeekStart) && a.startedAt.isBefore(currentWeekStart)).toList();

    Map<String, double> computeAverages(List<TestAttemptModel> list) {
      final subjectTotals = <String, int>{};
      final subjectCounts = <String, int>{};
      for (var a in list) {
        a.subjectScores.forEach((subject, score) {
          subjectTotals[subject] = (subjectTotals[subject] ?? 0) + score;
          subjectCounts[subject] = (subjectCounts[subject] ?? 0) + 1;
        });
      }
      final averages = <String, double>{};
      subjectTotals.forEach((subject, total) {
        averages[subject] = total / subjectCounts[subject]!;
      });
      return averages;
    }

    return {
      'current': computeAverages(currentWeekAttempts),
      'previous': computeAverages(prevWeekAttempts),
    };
  });
});

final trendLineProvider = Provider<AsyncValue<List<TestAttemptModel>>>((ref) {
  final attemptsAsync = ref.watch(testAttemptsProvider);
  return attemptsAsync.whenData((attempts) {
    final sorted = List<TestAttemptModel>.from(attempts)
      ..sort((a, b) => a.startedAt.compareTo(b.startedAt));
    // Return last 10
    if (sorted.length > 10) return sorted.sublist(sorted.length - 10);
    return sorted;
  });
});

final heatmapProvider = Provider<AsyncValue<Map<DateTime, int>>>((ref) {
  final attemptsAsync = ref.watch(testAttemptsProvider);
  return attemptsAsync.whenData((attempts) {
    final map = <DateTime, int>{};
    for (var a in attempts) {
      final date = DateTime(a.startedAt.year, a.startedAt.month, a.startedAt.day);
      map[date] = (map[date] ?? 0) + a.totalQuestions;
    }
    return map;
  });
});

class WeakTopic {
  final String topic;
  final double avgScore;
  WeakTopic(this.topic, this.avgScore);
}

final weakTopicsProvider = Provider<AsyncValue<List<WeakTopic>>>((ref) {
  final attemptsAsync = ref.watch(testAttemptsProvider);
  return attemptsAsync.whenData((attempts) {
    final subjectTotals = <String, int>{};
    final subjectCounts = <String, int>{};
    for (var a in attempts) {
      a.subjectScores.forEach((subject, score) {
        subjectTotals[subject] = (subjectTotals[subject] ?? 0) + score;
        subjectCounts[subject] = (subjectCounts[subject] ?? 0) + 1;
      });
    }

    final weakTopics = <WeakTopic>[];
    subjectTotals.forEach((subject, total) {
      weakTopics.add(WeakTopic(subject, total / subjectCounts[subject]!));
    });

    weakTopics.sort((a, b) => a.avgScore.compareTo(b.avgScore));
    return weakTopics.take(5).toList();
  });
});

final improvementTipsProvider = Provider<AsyncValue<List<String>>>((ref) {
  final radarAsync = ref.watch(radarChartProvider);
  return radarAsync.whenData((radarData) {
    final tips = <String>[];
    final current = radarData['current'] ?? {};
    final previous = radarData['previous'] ?? {};

    if (current.isEmpty && previous.isEmpty) {
      return ['Take a mock test to generate improvement tips!'];
    }

    current.forEach((subject, curScore) {
      if (curScore < 40) {
        tips.add('You scored ${curScore.toStringAsFixed(0)}% in $subject — review basic concepts and practice more.');
      } else if (previous.containsKey(subject)) {
        final prevScore = previous[subject]!;
        final diff = curScore - prevScore;
        if (diff > 10) {
          tips.add('Great job! Your accuracy improved by ${diff.toStringAsFixed(0)}% in $subject this week! 🎉');
        } else if (diff < -10) {
          tips.add('Your performance in $subject dropped this week. Try taking a topic-wise revision test.');
        }
      }
    });

    if (tips.isEmpty) {
      tips.add('You are maintaining a steady performance. Keep practicing consistently!');
    }

    return tips;
  });
});
