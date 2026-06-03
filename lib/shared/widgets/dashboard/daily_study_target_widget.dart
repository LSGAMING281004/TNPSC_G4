import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../shared/providers/firestore_providers.dart';

class DailyStudyTargetWidget extends ConsumerWidget {
  const DailyStudyTargetWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(userProfileStreamProvider);
    final todayCountAsync = ref.watch(todayAttemptsCountProvider);

    return userAsync.when(
      loading: () => _buildShimmer(),
      error: (_, __) => const SizedBox.shrink(),
      data: (user) {
        final questionsToday = todayCountAsync.valueOrNull ?? 0;
        const questionsGoal = 30;
        final streak = user?.studyStreak ?? 0;
        final percent = questionsGoal > 0
            ? (questionsToday / questionsGoal).clamp(0.0, 1.0)
            : 0.0;

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
              Row(
                children: [
                  const Icon(Icons.flag_rounded, color: AppColors.accentSaffron),
                  const SizedBox(width: 8),
                  const Text('Daily Target',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                  const Spacer(),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.accentSaffron.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text('🔥', style: TextStyle(fontSize: 16)),
                        const SizedBox(width: 4),
                        Text('$streak day streak',
                            style: const TextStyle(
                                color: AppColors.accentSaffron,
                                fontSize: 12,
                                fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: CircularPercentIndicator(
                      radius: 50,
                      lineWidth: 8,
                      percent: percent,
                      center: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text('$questionsToday',
                              style: const TextStyle(
                                  fontSize: 22, fontWeight: FontWeight.bold)),
                          Text('/$questionsGoal',
                              style: TextStyle(
                                  fontSize: 12, color: Colors.grey.shade500)),
                        ],
                      ),
                      progressColor: AppColors.accentSaffron,
                      backgroundColor:
                          AppColors.accentSaffron.withValues(alpha: 0.15),
                      circularStrokeCap: CircularStrokeCap.round,
                    ),
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _TargetRow(
                            label: 'Questions',
                            done: questionsToday,
                            total: questionsGoal,
                            color: AppColors.accentSaffron),
                        const SizedBox(height: 12),
                        _TargetRow(
                            label: 'Accuracy',
                            done: (user?.accuracy ?? 0).round(),
                            total: 100,
                            color: AppColors.info),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildShimmer() {
    return Container(
      height: 160,
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(20),
      ),
      child: const Center(
          child: CircularProgressIndicator(
              strokeWidth: 2, color: AppColors.accentSaffron)),
    );
  }
}

class _TargetRow extends StatelessWidget {
  final String label;
  final int done;
  final int total;
  final Color color;

  const _TargetRow(
      {required this.label,
      required this.done,
      required this.total,
      required this.color});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(label,
                style: TextStyle(fontSize: 13, color: Colors.grey.shade600)),
            const Spacer(),
            Text('$done/$total',
                style: TextStyle(
                    fontSize: 13, fontWeight: FontWeight.bold, color: color)),
          ],
        ),
        const SizedBox(height: 6),
        LinearProgressIndicator(
          value: total > 0 ? (done / total).clamp(0.0, 1.0) : 0,
          backgroundColor: color.withValues(alpha: 0.15),
          valueColor: AlwaysStoppedAnimation<Color>(color),
          borderRadius: BorderRadius.circular(4),
          minHeight: 6,
        ),
      ],
    );
  }
}
