import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/router/app_router.dart';
import '../../../../shared/providers/firestore_providers.dart';
import '../../data/models/mock_test_models.dart';

class TestResultScreen extends ConsumerWidget {
  final String resultId;

  const TestResultScreen({super.key, required this.resultId});

  String _formatDuration(double seconds) {
    final intSecs = seconds.round();
    if (intSecs >= 3600) {
      final h = intSecs ~/ 3600;
      final m = (intSecs % 3600) ~/ 60;
      return '${h}h ${m}m';
    } else if (intSecs >= 60) {
      final m = intSecs ~/ 60;
      final s = intSecs % 60;
      return '${m}m ${s}s';
    } else {
      return '${intSecs}s';
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final resultAsync = ref.watch(singleTestResultProvider(resultId));

    return resultAsync.when(
      loading: () => Scaffold(
        appBar: AppBar(title: const Text('Test Result')),
        body: const Center(
          child: CircularProgressIndicator(color: AppColors.accentSaffron),
        ),
      ),
      error: (err, stack) => Scaffold(
        appBar: AppBar(title: const Text('Test Result')),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 48, color: AppColors.error),
                const SizedBox(height: 16),
                Text('Failed to load test result: $err', textAlign: TextAlign.center),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => ref.invalidate(singleTestResultProvider(resultId)),
                  child: const Text('Retry'),
                ),
              ],
            ),
          ),
        ),
      ),
      data: (result) {
        if (result == null) {
          return Scaffold(
            appBar: AppBar(title: const Text('Test Result')),
            body: const Center(
              child: Text('Result not found.'),
            ),
          );
        }

        final percentage = result.percentage;
        final isPass = percentage >= 40.0;

        String feedbackMessage;
        if (percentage >= 80.0) {
          feedbackMessage = "Excellent! 🌟";
        } else if (percentage >= 60.0) {
          feedbackMessage = "Good Job! 🎉";
        } else if (percentage >= 40.0) {
          feedbackMessage = "Keep Practicing 💪";
        } else {
          feedbackMessage = "Needs More Work 📚";
        }

        final attemptsCountAsync = ref.watch(testAttemptsCountProvider(result.testId));

        return Scaffold(
          appBar: AppBar(
            title: const Text('Test Result'),
            leading: IconButton(
              icon: const Icon(Icons.close),
              onPressed: () => context.go('/home/dashboard'),
            ),
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // 1. SCORE CIRCLE AND FEEDBACK
                Card(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 32.0, horizontal: 16.0),
                    child: Column(
                      children: [
                        Text(
                          feedbackMessage,
                          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        const SizedBox(height: 24),
                        Container(
                          width: 150,
                          height: 150,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: (isPass ? AppColors.success : AppColors.error).withValues(alpha: 0.2),
                              width: 8,
                            ),
                          ),
                          child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.baseline,
                                  textBaseline: TextBaseline.alphabetic,
                                  children: [
                                    Text(
                                      '${result.correctAnswers}',
                                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                            fontWeight: FontWeight.bold,
                                            color: isPass ? AppColors.success : AppColors.error,
                                          ),
                                    ),
                                    Text(
                                      '/${result.totalQuestions}',
                                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                                          ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  'Score: ${result.score.toStringAsFixed(2)}',
                                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                        fontWeight: FontWeight.bold,
                                        color: Theme.of(context).colorScheme.outline,
                                      ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          '${percentage.toStringAsFixed(1)}%',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: isPass ? AppColors.success : AppColors.error,
                              ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // 2. STATS ROW
                Card(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 20.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _ResultStat(
                          icon: Icons.check_circle,
                          label: 'Correct',
                          value: result.correctAnswers.toString(),
                          color: AppColors.success,
                        ),
                        _ResultStat(
                          icon: Icons.cancel,
                          label: 'Incorrect',
                          value: result.wrongAnswers.toString(),
                          color: AppColors.error,
                        ),
                        _ResultStat(
                          icon: Icons.remove_circle,
                          label: 'Skipped',
                          value: result.unattempted.toString(),
                          color: Colors.grey,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // 3. SUBJECT PERFORMANCE CARD
                if (result.subjectScores.isNotEmpty) ...[
                  Text('Subject Breakdown', style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 12),
                  Card(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: result.subjectScores.entries.map((e) {
                          return _SubjectBar(
                            subject: e.key,
                            percentage: e.value.percentage,
                            correct: e.value.correct,
                            total: e.value.total,
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],

                // 4. ADDITIONAL INFO CARD
                Text('Test Information', style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 12),
                Card(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        // Your Rank Row
                        attemptsCountAsync.when(
                          data: (total) {
                            final rankText = result.rank > 0
                                ? '#${result.rank} of $total'
                                : 'Calculating...';
                            return _InfoRow(
                              icon: Icons.leaderboard_outlined,
                              label: 'Your Rank',
                              value: rankText,
                            );
                          },
                          loading: () => const _InfoRow(
                            icon: Icons.leaderboard_outlined,
                            label: 'Your Rank',
                            value: 'Loading...',
                          ),
                          error: (_, __) => _InfoRow(
                            icon: Icons.leaderboard_outlined,
                            label: 'Your Rank',
                            value: result.rank > 0 ? '#${result.rank}' : 'N/A',
                          ),
                        ),
                        const Divider(),
                        _InfoRow(
                          icon: Icons.timer_outlined,
                          label: 'Time Taken',
                          value: _formatDuration(result.timeTakenSeconds.toDouble()),
                        ),
                        const Divider(),
                        _InfoRow(
                          icon: Icons.speed_outlined,
                          label: 'Avg. Time / Question',
                          value: result.totalQuestions > 0
                              ? _formatDuration(result.timeTakenSeconds / result.totalQuestions)
                              : '0s',
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 32),

                // 5. VIEW SOLUTIONS BUTTON
                ElevatedButton.icon(
                  onPressed: () {
                    context.push('/solutions?resultId=$resultId');
                  },
                  icon: const Icon(Icons.menu_book),
                  label: const Text('View Solutions'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _ResultStat extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _ResultStat({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: color, size: 32),
        const SizedBox(height: 8),
        Text(
          value,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.outline,
              ),
        ),
      ],
    );
  }
}

class _SubjectBar extends StatelessWidget {
  final String subject;
  final double percentage;
  final int correct;
  final int total;

  const _SubjectBar({
    required this.subject,
    required this.percentage,
    required this.correct,
    required this.total,
  });

  @override
  Widget build(BuildContext context) {
    final color = percentage >= 80.0
        ? AppColors.success
        : percentage >= 40.0
            ? AppColors.accentSaffron
            : AppColors.error;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  subject,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ),
              Text(
                '$correct/$total (${percentage.toStringAsFixed(1)}%)',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: color,
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: percentage / 100.0,
              backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
              color: color,
              minHeight: 8,
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(icon, size: 22, color: Theme.of(context).colorScheme.primary),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
          Text(
            value,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
        ],
      ),
    );
  }
}
