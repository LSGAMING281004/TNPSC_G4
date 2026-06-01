import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/router/app_router.dart';

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
              Tab(text: 'Full Test'), Tab(text: 'Subject'), Tab(text: 'Chapter'), Tab(text: 'Daily'),
            ],
          ),
        ),
        body: TabBarView(
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

class _TestList extends StatelessWidget {
  final String type;
  const _TestList({required this.type});

  @override
  Widget build(BuildContext context) {
    final tests = _getMockData(type);

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: tests.length,
      itemBuilder: (context, index) {
        final test = tests[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: InkWell(
            onTap: () => context.push('${AppRoutes.testInstructions}?testId=${test['id']}'),
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
                          color: AppColors.accentSaffron.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          type == 'full' ? Icons.assignment : type == 'daily' ? Icons.bolt : Icons.quiz,
                          color: AppColors.accentSaffron, size: 24,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(test['title']!, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                _InfoChip(icon: Icons.quiz, label: '${test['questions']} Qs'),
                                const SizedBox(width: 8),
                                _InfoChip(icon: Icons.timer, label: '${test['duration']} min'),
                                const SizedBox(width: 8),
                                _DifficultyChip(difficulty: test['difficulty']!),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const Icon(Icons.chevron_right, color: Colors.grey),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Text('Avg Score: ${test['avgScore']}%', style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
                      const SizedBox(width: 16),
                      Text('${test['attempts']} attempts', style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  List<Map<String, String>> _getMockData(String type) {
    switch (type) {
      case 'full':
        return [
          {'id': '1', 'title': 'Full Mock Test 1 - TNPSC Group IV', 'questions': '100', 'duration': '90', 'difficulty': 'medium', 'avgScore': '62', 'attempts': '1.2K'},
          {'id': '2', 'title': 'Full Mock Test 2 - TNPSC Group IV', 'questions': '100', 'duration': '90', 'difficulty': 'hard', 'avgScore': '55', 'attempts': '890'},
          {'id': '3', 'title': 'Full Mock Test 3 - VAO Pattern', 'questions': '100', 'duration': '90', 'difficulty': 'medium', 'avgScore': '58', 'attempts': '650'},
        ];
      case 'subject':
        return [
          {'id': '4', 'title': 'Tamil Language Test', 'questions': '50', 'duration': '45', 'difficulty': 'medium', 'avgScore': '68', 'attempts': '2.1K'},
          {'id': '5', 'title': 'General Studies Test', 'questions': '50', 'duration': '45', 'difficulty': 'hard', 'avgScore': '52', 'attempts': '1.8K'},
          {'id': '6', 'title': 'Aptitude & Mental Ability', 'questions': '50', 'duration': '45', 'difficulty': 'easy', 'avgScore': '72', 'attempts': '1.5K'},
        ];
      case 'chapter':
        return [
          {'id': '7', 'title': 'Indian History - Chapter 1', 'questions': '25', 'duration': '20', 'difficulty': 'easy', 'avgScore': '75', 'attempts': '3.2K'},
          {'id': '8', 'title': 'Tamil Grammar', 'questions': '25', 'duration': '20', 'difficulty': 'medium', 'avgScore': '65', 'attempts': '2.8K'},
          {'id': '9', 'title': 'Indian Geography', 'questions': '25', 'duration': '20', 'difficulty': 'medium', 'avgScore': '60', 'attempts': '2.1K'},
        ];
      case 'daily':
        return [
          {'id': '10', 'title': 'Daily Challenge - Today', 'questions': '10', 'duration': '10', 'difficulty': 'medium', 'avgScore': '70', 'attempts': '5.4K'},
          {'id': '11', 'title': 'Yesterday\'s Challenge', 'questions': '10', 'duration': '10', 'difficulty': 'easy', 'avgScore': '78', 'attempts': '4.2K'},
        ];
      default:
        return [];
    }
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
        Text(label, style: TextStyle(fontSize: 11, color: Colors.grey.shade600)),
      ],
    );
  }
}

class _DifficultyChip extends StatelessWidget {
  final String difficulty;
  const _DifficultyChip({required this.difficulty});

  @override
  Widget build(BuildContext context) {
    final color = difficulty == 'easy' ? AppColors.difficultyEasy
        : difficulty == 'hard' ? AppColors.difficultyHard : AppColors.difficultyMedium;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(color: color.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(4)),
      child: Text(difficulty.toUpperCase(), style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: color)),
    );
  }
}
