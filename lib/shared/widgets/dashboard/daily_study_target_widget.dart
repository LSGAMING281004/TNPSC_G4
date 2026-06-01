import 'package:flutter/material.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import '../../../../core/constants/app_colors.dart';

class DailyStudyTargetWidget extends StatelessWidget {
  const DailyStudyTargetWidget({super.key});

  @override
  Widget build(BuildContext context) {
    const questionsToday = 15;
    const questionsGoal = 30;
    const topicsDone = 2;
    const topicsGoal = 3;
    const streak = 7;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.flag_rounded, color: AppColors.accentSaffron),
              const SizedBox(width: 8),
              const Text('Daily Target', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.accentSaffron.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('🔥', style: TextStyle(fontSize: 16)),
                    const SizedBox(width: 4),
                    Text('$streak day streak', style: const TextStyle(color: AppColors.accentSaffron, fontSize: 12, fontWeight: FontWeight.bold)),
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
                  percent: questionsToday / questionsGoal,
                  center: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('$questionsToday', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                      Text('/$questionsGoal', style: TextStyle(fontSize: 12, color: Colors.grey.shade500)),
                    ],
                  ),
                  progressColor: AppColors.accentSaffron,
                  backgroundColor: AppColors.accentSaffron.withValues(alpha: 0.15),
                  circularStrokeCap: CircularStrokeCap.round,
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _TargetRow(label: 'Questions', done: questionsToday, total: questionsGoal, color: AppColors.accentSaffron),
                    const SizedBox(height: 12),
                    _TargetRow(label: 'Topics', done: topicsDone, total: topicsGoal, color: AppColors.info),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _TargetRow extends StatelessWidget {
  final String label;
  final int done;
  final int total;
  final Color color;

  const _TargetRow({required this.label, required this.done, required this.total, required this.color});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(label, style: TextStyle(fontSize: 13, color: Colors.grey.shade600)),
            const Spacer(),
            Text('$done/$total', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: color)),
          ],
        ),
        const SizedBox(height: 6),
        LinearProgressIndicator(
          value: done / total,
          backgroundColor: color.withValues(alpha: 0.15),
          valueColor: AlwaysStoppedAnimation<Color>(color),
          borderRadius: BorderRadius.circular(4),
          minHeight: 6,
        ),
      ],
    );
  }
}
