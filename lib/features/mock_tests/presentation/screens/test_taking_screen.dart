import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../shared/models/question_model.dart';
import '../../providers/test_providers.dart';

class TestTakingScreen extends ConsumerStatefulWidget {
  final String testId;

  const TestTakingScreen({super.key, required this.testId});

  @override
  ConsumerState<TestTakingScreen> createState() => _TestTakingScreenState();
}

class _TestTakingScreenState extends ConsumerState<TestTakingScreen> with WidgetsBindingObserver {
  late Timer _timer;
  late Timer _saveTimer;
  int _secondsRemaining = 90 * 60; // Default 90 mins, should be fetched
  bool _isTamil = true;
  int _currentIndex = 0;
  List<QuestionModel> _questions = [];
  final Map<int, int> _answers = {}; // index -> selectedOptionIndex
  final Set<int> _bookmarked = {};
  bool _isLoading = true;
  bool _isPaused = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _loadTest();
  }

  Future<void> _loadTest() async {
    // In real app, fetch test details to get actual duration
    final questions = await ref.read(testQuestionsProvider(widget.testId).future);
    
    if (!mounted) return;
    
    setState(() {
      _questions = questions;
      _isLoading = false;
    });

    ref.read(activeTestProvider.notifier).startTest('currentUser', widget.testId, questions.length);

    _startTimer();
    _startAutoSave();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_isPaused) return;
      
      setState(() {
        if (_secondsRemaining > 0) {
          _secondsRemaining--;
          
          // Warnings
          if (_secondsRemaining == 10 * 60) _showWarning('10 minutes remaining!');
          if (_secondsRemaining == 5 * 60) _showWarning('5 minutes remaining!');
          if (_secondsRemaining == 1 * 60) _showWarning('1 minute remaining! Hurry up!');
        } else {
          _timer.cancel();
          _submitTest();
        }
      });
    });
  }

  void _startAutoSave() {
    _saveTimer = Timer.periodic(const Duration(seconds: 30), (timer) {
      if (_isPaused) return;
      // In real app, save _answers to Hive here
    });
  }

  void _showWarning(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg), duration: const Duration(seconds: 2)));
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _timer.cancel();
    _saveTimer.cancel();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused || state == AppLifecycleState.inactive) {
      _isPaused = true;
    } else if (state == AppLifecycleState.resumed) {
      _isPaused = false;
    }
  }

  Future<void> _submitTest() async {
    _timer.cancel();
    _saveTimer.cancel();
    
    // Process answers into ActiveTestNotifier
    for (var entry in _answers.entries) {
      final q = _questions[entry.key];
      final isCorrect = entry.value == q.correctOptionIndex;
      ref.read(activeTestProvider.notifier).updateAnswer(
        q.id, entry.value, isCorrect, 60, q.subject // mock 60s time spent
      );
    }

    final totalTimeTaken = (90 * 60) - _secondsRemaining;
    await ref.read(activeTestProvider.notifier).submitTest(totalTimeTaken);

    if (!mounted) return;
    final attemptId = ref.read(activeTestProvider)!.id;
    context.replace('/test-result/$attemptId');
  }

  void _confirmSubmit() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Submit Test?'),
        content: Text('You have answered ${_answers.length} out of ${_questions.length} questions. Are you sure you want to submit?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              _submitTest();
            },
            child: const Text('Submit'),
          ),
        ],
      ),
    );
  }

  void _showQuestionMap() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        minChildSize: 0.4,
        maxChildSize: 0.9,
        expand: false,
        builder: (_, controller) => GridView.builder(
          padding: const EdgeInsets.all(24),
          controller: controller,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 5,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
          ),
          itemCount: _questions.length,
          itemBuilder: (context, index) {
            final isAnswered = _answers.containsKey(index);
            final isBookmarked = _bookmarked.contains(index);
            final isCurrent = index == _currentIndex;

            Color bgColor = Colors.grey.shade200;
            Color textColor = Colors.black;

            if (isAnswered) {
              bgColor = const Color(0xFF2ECC71); // Green
              textColor = Colors.white;
            }
            if (isBookmarked) {
              bgColor = const Color(0xFFE74C3C); // Red
              textColor = Colors.white;
            }

            return InkWell(
              onTap: () {
                Navigator.pop(ctx);
                setState(() => _currentIndex = index);
              },
              child: Container(
                decoration: BoxDecoration(
                  color: bgColor,
                  shape: BoxShape.circle,
                  border: isCurrent ? Border.all(color: Theme.of(context).colorScheme.primary, width: 3) : null,
                ),
                alignment: Alignment.center,
                child: Text('${index + 1}', style: TextStyle(color: textColor, fontWeight: FontWeight.bold)),
              ),
            );
          },
        ),
      ),
    );
  }

  String _formatTime(int seconds) {
    final m = seconds ~/ 60;
    final s = seconds % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final question = _questions[_currentIndex];
    final isDangerTime = _secondsRemaining < 5 * 60;

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Row(
          children: [
            Text('${_currentIndex + 1}/${_questions.length}', style: const TextStyle(fontSize: 18)),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: isDangerTime ? Colors.red.withValues(alpha: 0.1) : Colors.grey.shade100,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: isDangerTime ? Colors.red : Colors.grey.shade300),
              ),
              child: Row(
                children: [
                  Icon(Icons.timer_outlined, size: 18, color: isDangerTime ? Colors.red : Colors.black),
                  const SizedBox(width: 6),
                  Text(
                    _formatTime(_secondsRemaining),
                    style: TextStyle(
                      color: isDangerTime ? Colors.red : Colors.black,
                      fontWeight: FontWeight.bold,
                      fontFeatures: const [FontFeature.tabularFigures()],
                    ),
                  ),
                ],
              ),
            ),
            const Spacer(),
            IconButton(
              icon: Icon(_isPaused ? Icons.play_arrow : Icons.pause),
              onPressed: () {
                setState(() => _isPaused = !_isPaused);
              },
            ),
          ],
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(4.0),
          child: LinearProgressIndicator(
            value: (_currentIndex + 1) / _questions.length,
            backgroundColor: Colors.grey.shade200,
            valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).colorScheme.primary),
          ),
        ),
      ),
      body: _isPaused 
          ? const Center(child: Text('Test Paused', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)))
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      const Text('English'),
                      Switch(
                        value: _isTamil,
                        onChanged: (val) => setState(() => _isTamil = val),
                        activeThumbColor: Theme.of(context).colorScheme.primary,
                      ),
                      const Text('தமிழ்'),
                    ],
                  ),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _isTamil ? question.questionTamil : question.questionEnglish,
                          style: Theme.of(context).textTheme.headlineSmall?.copyWith(height: 1.5),
                        ),
                        const SizedBox(height: 32),
                        ...List.generate(4, (optionIndex) {
                          final isSelected = _answers[_currentIndex] == optionIndex;
                          final optionText = _isTamil ? question.optionsTamil[optionIndex] : question.optionsEnglish[optionIndex];
                          final label = String.fromCharCode(65 + optionIndex); // A, B, C, D

                          return Padding(
                            padding: const EdgeInsets.only(bottom: 16.0),
                            child: InkWell(
                              onTap: () {
                                setState(() {
                                  _answers[_currentIndex] = optionIndex;
                                });
                              },
                              borderRadius: BorderRadius.circular(12),
                              child: Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: isSelected ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.1) : Colors.white,
                                  border: Border.all(
                                    color: isSelected ? Theme.of(context).colorScheme.primary : Colors.grey.shade300,
                                    width: isSelected ? 2 : 1,
                                  ),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 32,
                                      height: 32,
                                      alignment: Alignment.center,
                                      decoration: BoxDecoration(
                                        color: isSelected ? Theme.of(context).colorScheme.primary : Colors.grey.shade100,
                                        shape: BoxShape.circle,
                                      ),
                                      child: Text(
                                        label,
                                        style: TextStyle(
                                          color: isSelected ? Colors.white : Colors.black,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: Text(
                                        optionText,
                                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                          fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        }),
                      ],
                    ),
                  ),
                ),
              ],
            ),
      bottomNavigationBar: SafeArea(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), offset: const Offset(0, -4), blurRadius: 10)],
          ),
          child: Row(
            children: [
              IconButton(
                onPressed: () {
                  setState(() {
                    if (_bookmarked.contains(_currentIndex)) {
                      _bookmarked.remove(_currentIndex);
                    } else {
                      _bookmarked.add(_currentIndex);
                    }
                  });
                },
                icon: Icon(
                  _bookmarked.contains(_currentIndex) ? Icons.bookmark : Icons.bookmark_border,
                  color: _bookmarked.contains(_currentIndex) ? const Color(0xFFE74C3C) : Colors.grey.shade600,
                ),
              ),
              IconButton(
                onPressed: _showQuestionMap,
                icon: const Icon(Icons.grid_view),
              ),
              const Spacer(),
              if (_currentIndex > 0)
                OutlinedButton(
                  onPressed: () => setState(() => _currentIndex--),
                  child: const Text('Previous'),
                ),
              const SizedBox(width: 12),
              if (_currentIndex < _questions.length - 1)
                ElevatedButton(
                  onPressed: () => setState(() => _currentIndex++),
                  child: const Text('Next'),
                )
              else
                ElevatedButton(
                  onPressed: _confirmSubmit,
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF2ECC71)),
                  child: const Text('Submit Test'),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
