import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../../shared/models/test_attempt_model.dart';
import '../../../../shared/models/question_model.dart';
import '../../providers/test_providers.dart';

class TestResultScreen extends ConsumerStatefulWidget {
  final String resultId;

  const TestResultScreen({super.key, required this.resultId});

  @override
  ConsumerState<TestResultScreen> createState() => _TestResultScreenState();
}

class _TestResultScreenState extends ConsumerState<TestResultScreen> with SingleTickerProviderStateMixin {
  late AnimationController _scoreAnimController;
  late Animation<double> _scoreAnimation;

  @override
  void initState() {
    super.initState();
    _scoreAnimController = AnimationController(vsync: this, duration: const Duration(seconds: 2));
    _scoreAnimation = Tween<double>(begin: 0, end: 1).animate(CurvedAnimation(parent: _scoreAnimController, curve: Curves.easeOutCubic));
    _scoreAnimController.forward();
  }

  @override
  void dispose() {
    _scoreAnimController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final attemptAsync = ref.watch(testResultProvider(widget.resultId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Test Result'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => context.go('/home/dashboard'),
        ),
      ),
      body: attemptAsync.when(
        data: (attempt) => _buildResultContent(context, attempt),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error loading result: $e')),
      ),
      bottomNavigationBar: SafeArea(
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), offset: const Offset(0, -4), blurRadius: 10)],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              OutlinedButton.icon(
                onPressed: () => context.go('/home/dashboard'),
                icon: const Icon(Icons.home),
                label: const Text('Home'),
              ),
              ElevatedButton.icon(
                onPressed: () {
                  // Share logic
                },
                icon: const Icon(Icons.share),
                label: const Text('Share Result'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildResultContent(BuildContext context, TestAttemptModel attempt) {
    final percentage = (attempt.score / attempt.totalQuestions) * 100;
    final isPass = percentage >= 40; // Example passing mark

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 1. SCORE CARD
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: isPass 
                  ? [const Color(0xFF2ECC71), const Color(0xFF27AE60)]
                  : [const Color(0xFFE74C3C), const Color(0xFFC0392B)],
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(20)),
                  child: Text(
                    isPass ? 'PASSED' : 'FAILED',
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, letterSpacing: 1.5),
                  ),
                ),
                const SizedBox(height: 16),
                AnimatedBuilder(
                  animation: _scoreAnimation,
                  builder: (context, child) {
                    final currentScore = (attempt.score * _scoreAnimation.value).toInt();
                    return Text(
                      '$currentScore / ${attempt.totalQuestions}',
                      style: Theme.of(context).textTheme.displayLarge?.copyWith(color: Colors.white, fontWeight: FontWeight.bold),
                    );
                  },
                ),
                const SizedBox(height: 8),
                Text(
                  '${percentage.toStringAsFixed(1)}%',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(color: Colors.white70),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Quick Stats
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _StatItem(icon: Icons.check_circle, label: 'Correct', value: attempt.correctCount.toString(), color: const Color(0xFF2ECC71)),
              _StatItem(icon: Icons.cancel, label: 'Incorrect', value: attempt.incorrectCount.toString(), color: const Color(0xFFE74C3C)),
              _StatItem(icon: Icons.remove_circle, label: 'Skipped', value: attempt.skippedCount.toString(), color: Colors.grey),
            ],
          ),
          const SizedBox(height: 32),

          // 2. BREAKDOWN TABLE
          Text('Subject Breakdown', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 16),
          Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: attempt.subjectScores.entries.map((e) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(child: Text(e.key, style: Theme.of(context).textTheme.bodyMedium)),
                        Text('${e.value} Correct', style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF2ECC71))),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
          const SizedBox(height: 32),

          // 3. TIME ANALYSIS (Simplified horizontal bar representing avg time vs total)
          Text('Time Analysis', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 16),
          Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Total Time Taken'),
                      Text('${attempt.timeTakenSeconds ~/ 60}m ${attempt.timeTakenSeconds % 60}s', style: const TextStyle(fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const Divider(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Avg. Time per Question'),
                      Text('${(attempt.timeTakenSeconds / attempt.totalQuestions).toStringAsFixed(1)}s', style: const TextStyle(fontWeight: FontWeight.bold)),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 32),

          // 4. REVIEW SECTION
          Text('Review Answers', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 16),
          _ReviewSection(testId: attempt.testId, attempt: attempt),
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _StatItem({required this.icon, required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: color, size: 32),
        const SizedBox(height: 8),
        Text(value, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
        Text(label, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey.shade600)),
      ],
    );
  }
}

class _ReviewSection extends ConsumerWidget {
  final String testId;
  final TestAttemptModel attempt;

  const _ReviewSection({required this.testId, required this.attempt});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final questionsAsync = ref.watch(testQuestionsProvider(testId));

    return questionsAsync.when(
      data: (questions) {
        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: questions.length,
          itemBuilder: (context, index) {
            final q = questions[index];
            final answerMap = attempt.answers.firstWhere(
              (a) => a['questionId'] == q.id, 
              orElse: () => {'selectedOption': -1, 'isCorrect': false}
            );
            
            final selectedOption = answerMap['selectedOption'] as int;
            final isCorrect = answerMap['isCorrect'] as bool;
            final isSkipped = selectedOption == -1;

            Color statusColor = isSkipped ? Colors.grey : (isCorrect ? const Color(0xFF2ECC71) : const Color(0xFFE74C3C));
            IconData statusIcon = isSkipped ? Icons.remove_circle : (isCorrect ? Icons.check_circle : Icons.cancel);

            return Card(
              margin: const EdgeInsets.only(bottom: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(color: statusColor.withValues(alpha: 0.3)),
              ),
              child: Theme(
                data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
                child: ExpansionTile(
                  leading: Icon(statusIcon, color: statusColor),
                  title: Text('Question ${index + 1}', style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text(isSkipped ? 'Skipped' : (isCorrect ? 'Correct' : 'Incorrect'), style: TextStyle(color: statusColor)),
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(q.questionEnglish, style: Theme.of(context).textTheme.titleMedium),
                          const SizedBox(height: 16),
                          ...List.generate(4, (optIdx) {
                            final isUserChoice = optIdx == selectedOption;
                            final isActualCorrect = optIdx == q.correctOptionIndex;
                            
                            Color bgColor = Colors.grey.shade100;
                            Color borderColor = Colors.grey.shade300;
                            
                            if (isActualCorrect) {
                              bgColor = const Color(0xFF2ECC71).withValues(alpha: 0.1);
                              borderColor = const Color(0xFF2ECC71);
                            } else if (isUserChoice && !isActualCorrect) {
                              bgColor = const Color(0xFFE74C3C).withValues(alpha: 0.1);
                              borderColor = const Color(0xFFE74C3C);
                            }

                            return Container(
                              margin: const EdgeInsets.only(bottom: 8),
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: bgColor,
                                border: Border.all(color: borderColor),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                children: [
                                  Text(String.fromCharCode(65 + optIdx), style: const TextStyle(fontWeight: FontWeight.bold)),
                                  const SizedBox(width: 16),
                                  Expanded(child: Text(q.optionsEnglish[optIdx])),
                                  if (isUserChoice) const Icon(Icons.person, size: 16, color: Colors.grey),
                                  if (isActualCorrect) const Icon(Icons.check, size: 16, color: Color(0xFF2ECC71)),
                                ],
                              ),
                            );
                          }),
                          const SizedBox(height: 16),
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(color: Colors.blue.shade50, borderRadius: BorderRadius.circular(8)),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Row(
                                  children: [
                                    Icon(Icons.lightbulb, color: Colors.amber, size: 20),
                                    SizedBox(width: 8),
                                    Text('Explanation', style: TextStyle(fontWeight: FontWeight.bold)),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Text(q.explanationEnglish),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => const Text('Failed to load review details.'),
    );
  }
}
