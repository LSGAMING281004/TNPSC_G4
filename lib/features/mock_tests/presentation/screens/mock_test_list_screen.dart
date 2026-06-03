import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/router/app_router.dart';
import '../../../../shared/providers/firestore_providers.dart';

class MockTestListScreen extends ConsumerWidget {
  const MockTestListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Mock Tests'),
          backgroundColor: AppColors.primaryNavy,
          bottom: const TabBar(
            isScrollable: true,
            indicatorColor: AppColors.accentSaffron,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white54,
            tabs: [
              Tab(text: 'Full Test'),
              Tab(text: 'Subject'),
              Tab(text: 'Chapter'),
              Tab(text: 'Daily'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            _TestList(type: 'full'),
            _TestList(type: 'subject'),
            _TestList(type: 'chapter'),
            _TestList(type: 'daily'),
          ],
        ),
      ),
    );
  }
}

class _TestList extends ConsumerWidget {
  final String type;
  const _TestList({required this.type});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final testsAsync = ref.watch(mockTestsStreamProvider(type));

    return testsAsync.when(
      loading: () => const Center(
          child: CircularProgressIndicator(
              strokeWidth: 2, color: AppColors.accentSaffron)),
      error: (e, _) => Center(
          child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.error_outline, color: Colors.grey, size: 48),
          const SizedBox(height: 12),
          Text('Error loading tests', style: TextStyle(color: Colors.grey.shade600)),
        ],
      )),
      data: (tests) {
        if (tests.isEmpty) {
          return Center(
              child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.quiz_outlined, color: Colors.grey.shade300, size: 64),
              const SizedBox(height: 12),
              Text('No tests available yet',
                  style: TextStyle(color: Colors.grey.shade500, fontSize: 16)),
              const SizedBox(height: 4),
              Text('Tests will appear here once added by admin',
                  style: TextStyle(color: Colors.grey.shade400, fontSize: 13)),
            ],
          ));
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: tests.length,
          itemBuilder: (context, index) {
            final test = tests[index];
            final title =
                (test['title'] as String?) ?? 'Mock Test ${index + 1}';
            final questions = test['totalQuestions'] ?? test['questions'] ?? 0;
            final duration = test['durationMinutes'] ?? test['duration'] ?? 0;
            final difficulty =
                (test['difficulty'] as String?) ?? 'medium';

            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
              child: InkWell(
                onTap: () => context.push(
                    '${AppRoutes.testInstructions}?testId=${test['id']}'),
                borderRadius: BorderRadius.circular(16),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: AppColors.accentSaffron
                                  .withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              type == 'full'
                                  ? Icons.assignment
                                  : type == 'daily'
                                      ? Icons.bolt
                                      : Icons.quiz,
                              color: AppColors.accentSaffron,
                              size: 24,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(title,
                                    style: const TextStyle(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 15)),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    _InfoChip(
                                        icon: Icons.quiz,
                                        label: '$questions Qs'),
                                    const SizedBox(width: 8),
                                    _InfoChip(
                                        icon: Icons.timer,
                                        label: '$duration min'),
                                    const SizedBox(width: 8),
                                    _DifficultyChip(difficulty: difficulty),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          const Icon(Icons.chevron_right, color: Colors.grey),
                        ],
                      ),
                      if (test['subject'] != null) ...[
                        const SizedBox(height: 8),
                        Text('Subject: ${test['subject']}',
                            style: TextStyle(
                                fontSize: 12, color: Colors.grey.shade600)),
                      ],
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;
  const _InfoChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: Colors.grey.shade500),
        const SizedBox(width: 3),
        Text(label,
            style: TextStyle(fontSize: 11, color: Colors.grey.shade600)),
      ],
    );
  }
}

class _DifficultyChip extends StatelessWidget {
  final String difficulty;
  const _DifficultyChip({required this.difficulty});

  @override
  Widget build(BuildContext context) {
    final color = difficulty == 'easy'
        ? AppColors.difficultyEasy
        : difficulty == 'hard'
            ? AppColors.difficultyHard
            : AppColors.difficultyMedium;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
          color: color.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(4)),
      child: Text(difficulty.toUpperCase(),
          style: TextStyle(
              fontSize: 9, fontWeight: FontWeight.bold, color: color)),
    );
  }
}
