import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../shared/providers/firestore_providers.dart';

class ProgressSummaryCard extends ConsumerWidget {
  const ProgressSummaryCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(userProfileStreamProvider);

    return userAsync.when(
      loading: () => Container(
        height: 160,
        decoration: BoxDecoration(
          color: Colors.grey.shade200,
          borderRadius: BorderRadius.circular(20),
        ),
        child: const Center(
            child: CircularProgressIndicator(
                strokeWidth: 2, color: AppColors.accentSaffron)),
      ),
      error: (_, __) => const SizedBox.shrink(),
      data: (user) {
        final accuracy = user?.accuracy ?? 0;
        final questionsAttempted = user?.questionsAttempted ?? 0;
        final milestone = questionsAttempted < 200
            ? 'Complete ${200 - questionsAttempted} more questions for "Century" badge!'
            : questionsAttempted < 500
                ? 'Complete ${500 - questionsAttempted} more for "Scholar" badge!'
                : 'Amazing progress! Keep pushing forward! 🚀';

        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05), blurRadius: 10)
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  Icon(Icons.trending_up_rounded, color: AppColors.success),
                  SizedBox(width: 8),
                  Text('Your Progress',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  _StatCard(
                      label: 'Accuracy',
                      value: '${accuracy.toStringAsFixed(0)}%',
                      icon: Icons.check_circle,
                      color: AppColors.success),
                  const SizedBox(width: 12),
                  _StatCard(
                      label: 'Questions',
                      value: _formatNumber(questionsAttempted),
                      icon: Icons.quiz,
                      color: AppColors.info),
                  const SizedBox(width: 12),
                  _StatCard(
                      label: 'Streak',
                      value: '${user?.studyStreak ?? 0}🔥',
                      icon: Icons.local_fire_department,
                      color: AppColors.tamilSubject),
                ],
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.success.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.emoji_events,
                        color: AppColors.warning, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        milestone,
                        style: const TextStyle(
                            fontSize: 12, fontWeight: FontWeight.w500),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  String _formatNumber(int n) {
    if (n >= 1000) return '${(n / 1000).toStringAsFixed(1)}K';
    return '$n';
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard(
      {required this.label,
      required this.value,
      required this.icon,
      required this.color});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 22),
            const SizedBox(height: 6),
            Text(value,
                style: TextStyle(
                    fontSize: 18, fontWeight: FontWeight.bold, color: color)),
            const SizedBox(height: 2),
            Text(label,
                style: TextStyle(fontSize: 11, color: Colors.grey.shade600)),
          ],
        ),
      ),
    );
  }
}
