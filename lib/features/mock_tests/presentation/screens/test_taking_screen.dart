import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'dart:async';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/router/app_router.dart';

class TestTakingScreen extends ConsumerStatefulWidget {
  final String testId;
  const TestTakingScreen({super.key, required this.testId});

  @override
  ConsumerState<TestTakingScreen> createState() => _TestTakingScreenState();
}

class _TestTakingScreenState extends ConsumerState<TestTakingScreen> {
  int _currentQuestion = 0;
  final Map<int, int> _answers = {};
  final Set<int> _markedForReview = {};
  final int _totalQuestions = 10; // Demo: 10 questions

  final List<Map<String, dynamic>> _questions = List.generate(10, (i) => {
    'question': 'Sample question ${i + 1}: Which of the following is correct regarding the Tamil Nadu state administration?',
    'questionTa': 'மாதிரி கேள்வி ${i + 1}: தமிழ்நாடு மாநில நிர்வாகம் குறித்த பின்வருவனவற்றில் எது சரியானது?',
    'options': ['Option A - First choice', 'Option B - Second choice', 'Option C - Third choice', 'Option D - Fourth choice'],
    'correct': (i % 4),
  });

  void _submitTest() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Submit Test?'),
        content: Text('Answered: ${_answers.length}/$_totalQuestions\nMarked for Review: ${_markedForReview.length}'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              context.go('${AppRoutes.testResult}?resultId=demo');
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.accentSaffron),
            child: const Text('Submit', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final q = _questions[_currentQuestion];

    return PopScope(
      canPop: false,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: AppColors.primaryNavy,
          leading: IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => showDialog(
              context: context,
              builder: (ctx) => AlertDialog(
                title: const Text('Quit Test?'),
                content: const Text('Your progress will be lost.'),
                actions: [
                  TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Continue')),
                  TextButton(onPressed: () { Navigator.pop(ctx); context.go(AppRoutes.mockTests); }, child: const Text('Quit', style: TextStyle(color: AppColors.error))),
                ],
              ),
            ),
          ),
          title: Text('Q ${_currentQuestion + 1}/$_totalQuestions'),
          actions: [
            _TestCountdownTimer(
              initialSeconds: 90 * 60,
              onTimeUp: _submitTest,
            ),
            IconButton(
              icon: const Icon(Icons.grid_view),
              onPressed: () => _showQuestionPalette(),
            ),
          ],
        ),
        body: Column(
          children: [
            // Progress bar
            LinearProgressIndicator(
              value: (_currentQuestion + 1) / _totalQuestions,
              backgroundColor: Colors.grey.shade200,
              valueColor: const AlwaysStoppedAnimation<Color>(AppColors.accentSaffron),
              minHeight: 3,
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Question text
                    Text(q['question'], style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500, height: 1.5)),
                    const SizedBox(height: 8),
                    Text(q['questionTa'], style: const TextStyle(fontFamily: 'NotoSansTamil', fontSize: 14, color: Colors.grey, height: 1.5)),
                    const SizedBox(height: 24),
                    // Options
                    ...List.generate(4, (i) {
                      final isSelected = _answers[_currentQuestion] == i;
                      final labels = ['A', 'B', 'C', 'D'];
                      return GestureDetector(
                        onTap: () => setState(() => _answers[_currentQuestion] = i),
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: isSelected ? AppColors.accentSaffron.withValues(alpha: 0.1) : Colors.grey.withValues(alpha: 0.05),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: isSelected ? AppColors.accentSaffron : Colors.grey.shade300,
                              width: isSelected ? 2 : 1,
                            ),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 36, height: 36,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: isSelected ? AppColors.accentSaffron : Colors.grey.shade200,
                                ),
                                child: Center(
                                  child: Text(labels[i], style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: isSelected ? Colors.white : Colors.grey.shade600,
                                  )),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(child: Text(q['options'][i], style: TextStyle(fontSize: 15, fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal))),
                            ],
                          ),
                        ),
                      );
                    }),
                  ],
                ),
              ),
            ),
            // Bottom actions
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, -2))],
              ),
              child: Row(
                children: [
                  if (_currentQuestion > 0)
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => setState(() => _currentQuestion--),
                        style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 14)),
                        child: const Text('Previous'),
                      ),
                    ),
                  if (_currentQuestion > 0) const SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => setState(() {
                        if (_markedForReview.contains(_currentQuestion)) {
                          _markedForReview.remove(_currentQuestion);
                        } else {
                          _markedForReview.add(_currentQuestion);
                        }
                      }),
                      icon: Icon(
                        _markedForReview.contains(_currentQuestion) ? Icons.bookmark : Icons.bookmark_border,
                        size: 18,
                      ),
                      label: const Text('Review', style: TextStyle(fontSize: 13)),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        foregroundColor: AppColors.markedForReview,
                        side: const BorderSide(color: AppColors.markedForReview),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        if (_currentQuestion < _totalQuestions - 1) {
                          setState(() => _currentQuestion++);
                        } else {
                          _submitTest();
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.accentSaffron,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: Text(
                        _currentQuestion < _totalQuestions - 1 ? 'Next' : 'Submit',
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showQuestionPalette() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Question Palette', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            // Legend
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _LegendItem(color: AppColors.answered, label: 'Answered'),
                _LegendItem(color: AppColors.unanswered, label: 'Unanswered'),
                _LegendItem(color: AppColors.markedForReview, label: 'Review'),
                _LegendItem(color: AppColors.currentQuestion, label: 'Current'),
              ],
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8, runSpacing: 8,
              children: List.generate(_totalQuestions, (i) {
                Color bg;
                if (i == _currentQuestion) {
                  bg = AppColors.currentQuestion;
                } else if (_markedForReview.contains(i)) {
                  bg = AppColors.markedForReview;
                } else if (_answers.containsKey(i)) {
                  bg = AppColors.answered;
                } else {
                  bg = AppColors.unanswered;
                }

                return GestureDetector(
                  onTap: () { setState(() => _currentQuestion = i); Navigator.pop(context); },
                  child: Container(
                    width: 44, height: 44,
                    decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(10)),
                    child: Center(child: Text('${i + 1}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
                  ),
                );
              }),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}

class _LegendItem extends StatelessWidget {
  final Color color;
  final String label;
  const _LegendItem({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(width: 12, height: 12, decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(3))),
        const SizedBox(width: 4),
        Text(label, style: const TextStyle(fontSize: 11)),
      ],
    );
  }
}

class _TestCountdownTimer extends StatefulWidget {
  final int initialSeconds;
  final VoidCallback onTimeUp;

  const _TestCountdownTimer({
    required this.initialSeconds,
    required this.onTimeUp,
  });

  @override
  State<_TestCountdownTimer> createState() => _TestCountdownTimerState();
}

class _TestCountdownTimerState extends State<_TestCountdownTimer> {
  late int _secondsLeft;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _secondsLeft = widget.initialSeconds;
    _startTimer();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) {
        if (_secondsLeft > 0) {
          setState(() => _secondsLeft--);
        } else {
          _timer?.cancel();
          widget.onTimeUp();
        }
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  String _formatTime(int seconds) {
    final m = seconds ~/ 60;
    final s = seconds % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final isTimeLow = _secondsLeft < 300;
    return Container(
      margin: const EdgeInsets.only(right: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: isTimeLow
            ? AppColors.error.withValues(alpha: 0.2)
            : Colors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Icon(Icons.timer, size: 18, color: isTimeLow ? AppColors.error : Colors.white),
          const SizedBox(width: 4),
          Text(
            _formatTime(_secondsLeft),
            style: TextStyle(
              color: isTimeLow ? AppColors.error : Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }
}
