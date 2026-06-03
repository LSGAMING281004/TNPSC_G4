import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../shared/providers/firestore_providers.dart';

class AnalyticsScreen extends ConsumerWidget {
  const AnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Analytics'),
          backgroundColor: AppColors.primaryNavy,
          bottom: const TabBar(
            isScrollable: true,
            indicatorColor: AppColors.accentSaffron,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white54,
            tabs: [
              Tab(text: 'Overview'),
              Tab(text: 'Test History'),
              Tab(text: 'Tips')
            ],
          ),
        ),
        body: const TabBarView(
          children: [_OverviewTab(), _TestHistoryTab(), _TipsTab()],
        ),
      ),
    );
  }
}

class _OverviewTab extends ConsumerWidget {
  const _OverviewTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(userProfileStreamProvider);
    final attemptsAsync = ref.watch(userTestAttemptsStreamProvider);

    return userAsync.when(
      loading: () => const Center(
          child: CircularProgressIndicator(
              strokeWidth: 2, color: AppColors.accentSaffron)),
      error: (_, __) =>
          const Center(child: Text('Error loading analytics')),
      data: (user) {
        final totalAttempts = attemptsAsync.valueOrNull?.length ?? 0;
        final streak = user?.studyStreak ?? 0;
        final accuracy = user?.accuracy ?? 0;
        final questionsAttempted = user?.questionsAttempted ?? 0;

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // Streak
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                    gradient: AppColors.saffronGradient,
                    borderRadius: BorderRadius.circular(20)),
                child: Row(
                  children: [
                    const Text('🔥', style: TextStyle(fontSize: 40)),
                    const SizedBox(width: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('$streak Day Streak!',
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 22,
                                fontWeight: FontWeight.bold)),
                        Text(
                            streak > 0
                                ? 'Keep it going!'
                                : 'Start your streak today!',
                            style: const TextStyle(color: Colors.white70)),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  _StatBox(
                      label: 'Questions',
                      value: _formatNum(questionsAttempted),
                      icon: Icons.quiz,
                      color: AppColors.info),
                  const SizedBox(width: 12),
                  _StatBox(
                      label: 'Accuracy',
                      value: '${accuracy.toStringAsFixed(0)}%',
                      icon: Icons.check_circle,
                      color: AppColors.success),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  _StatBox(
                      label: 'Points',
                      value: _formatNum(user?.totalPoints ?? 0),
                      icon: Icons.star,
                      color: AppColors.tamilSubject),
                  const SizedBox(width: 12),
                  _StatBox(
                      label: 'Tests Taken',
                      value: '$totalAttempts',
                      icon: Icons.assignment,
                      color: AppColors.warning),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  String _formatNum(int n) {
    if (n >= 1000) return '${(n / 1000).toStringAsFixed(1)}K';
    return '$n';
  }
}

class _StatBox extends StatelessWidget {
  final String label, value;
  final IconData icon;
  final Color color;
  const _StatBox(
      {required this.label,
      required this.value,
      required this.icon,
      required this.color});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Card(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, color: color, size: 24),
              const SizedBox(height: 10),
              Text(value,
                  style: const TextStyle(
                      fontSize: 22, fontWeight: FontWeight.bold)),
              Text(label,
                  style:
                      TextStyle(fontSize: 12, color: Colors.grey.shade600)),
            ],
          ),
        ),
      ),
    );
  }
}

class _TestHistoryTab extends ConsumerWidget {
  const _TestHistoryTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final attemptsAsync = ref.watch(userTestAttemptsStreamProvider);

    return attemptsAsync.when(
      loading: () => const Center(
          child: CircularProgressIndicator(
              strokeWidth: 2, color: AppColors.accentSaffron)),
      error: (_, __) =>
          const Center(child: Text('Error loading test history')),
      data: (attempts) {
        if (attempts.isEmpty) {
          return Center(
              child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.history, color: Colors.grey.shade300, size: 64),
              const SizedBox(height: 12),
              Text('No tests taken yet',
                  style:
                      TextStyle(color: Colors.grey.shade500, fontSize: 16)),
              const SizedBox(height: 4),
              Text('Your test history will appear here',
                  style:
                      TextStyle(color: Colors.grey.shade400, fontSize: 13)),
            ],
          ));
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: attempts.length,
          itemBuilder: (_, i) {
            final attempt = attempts[i];
            final score = attempt['score'] ?? 0;
            final total = attempt['totalQuestions'] ?? 100;
            final percent =
                total > 0 ? ((score / total) * 100).round() : 0;
            final title =
                (attempt['testTitle'] as String?) ?? 'Test ${i + 1}';
            final completedAt = attempt['completedAt'];
            String dateStr = '';
            if (completedAt is Timestamp) {
              final d = completedAt.toDate();
              dateStr =
                  '${_monthName(d.month)} ${d.day}, ${d.year} • $total questions';
            }
            final statusColor =
                percent >= 60 ? AppColors.success : AppColors.warning;

            return Card(
              margin: const EdgeInsets.only(bottom: 10),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14)),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: statusColor.withValues(alpha: 0.1),
                  child: Text('$percent%',
                      style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: statusColor)),
                ),
                title: Text(title,
                    style: const TextStyle(fontWeight: FontWeight.w500)),
                subtitle: Text(dateStr,
                    style: const TextStyle(fontSize: 12)),
                trailing: const Icon(Icons.chevron_right),
              ),
            );
          },
        );
      },
    );
  }

  String _monthName(int m) {
    const months = [
      '', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return months[m];
  }
}

class _TipsTab extends ConsumerWidget {
  const _TipsTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(userProfileStreamProvider);

    return userAsync.when(
      loading: () => const Center(
          child: CircularProgressIndicator(
              strokeWidth: 2, color: AppColors.accentSaffron)),
      error: (_, __) => const SizedBox.shrink(),
      data: (user) {
        final accuracy = user?.accuracy ?? 0;
        final questionsAttempted = user?.questionsAttempted ?? 0;
        final streak = user?.studyStreak ?? 0;

        final tips = <Map<String, dynamic>>[
          if (accuracy < 60)
            {
              'title': 'Improve Your Accuracy',
              'desc':
                  'Your accuracy is ${accuracy.toStringAsFixed(0)}%. Focus on understanding concepts before attempting more questions.',
              'icon': Icons.check_circle
            },
          if (streak < 3)
            {
              'title': 'Build a Study Streak',
              'desc':
                  'Your current streak is $streak days. Aim for at least 7 consecutive days.',
              'icon': Icons.local_fire_department
            },
          if (questionsAttempted < 100)
            {
              'title': 'Practice More Questions',
              'desc':
                  'You\'ve attempted $questionsAttempted questions. Try to reach 100 for better preparation.',
              'icon': Icons.quiz
            },
          {
            'title': 'Take Full Mock Tests',
            'desc':
                'Practice with full-length tests to build exam stamina and time management skills.',
            'icon': Icons.assignment
          },
          {
            'title': 'Review Mistakes',
            'desc':
                'Go through your wrong answers and understand the correct solutions thoroughly.',
            'icon': Icons.replay
          },
        ];

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: tips.length,
          itemBuilder: (_, i) => Card(
            margin: const EdgeInsets.only(bottom: 12),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14)),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                        color: AppColors.info.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12)),
                    child: Icon(tips[i]['icon'] as IconData,
                        color: AppColors.info),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                        Text(tips[i]['title'] as String,
                            style: const TextStyle(
                                fontWeight: FontWeight.w600)),
                        const SizedBox(height: 4),
                        Text(tips[i]['desc'] as String,
                            style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey.shade600)),
                      ])),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
