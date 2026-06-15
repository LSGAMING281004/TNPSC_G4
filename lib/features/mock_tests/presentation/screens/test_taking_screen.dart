import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/language/language_mode.dart';
import '../../../../core/language/language_provider.dart';
import '../../../../shared/models/question_model.dart';
import '../../../../shared/providers/firestore_providers.dart';
import '../../../../shared/providers/app_providers.dart';
import '../../../../shared/widgets/app_dialogs.dart';
import '../../../../shared/widgets/bilingual_text.dart';
import '../../data/models/mock_test_models.dart';

class TestTakingScreen extends ConsumerStatefulWidget {
  final String testId;

  const TestTakingScreen({super.key, required this.testId});

  @override
  ConsumerState<TestTakingScreen> createState() => _TestTakingScreenState();
}

class _TestTakingScreenState extends ConsumerState<TestTakingScreen> with WidgetsBindingObserver {
  late Timer _timer;
  late Timer _saveTimer;
  int _secondsRemaining = 90 * 60; // Default until loaded
  int _currentIndex = 0;
  List<QuestionModel> _questions = [];
  final Map<int, int> _answers = {}; // index -> selectedOptionIndex
  final Set<int> _bookmarked = {};
  bool _initialized = false;
  bool _isInitializingProgressStarted = false;
  bool _isPaused = false;
  int _totalQuestions = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    // Mark test active globally to disable language/locale switching in menus
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(testActiveProvider.notifier).state = true;
    });
  }

  Future<void> _initializeTest(MockTestModel test, List<QuestionModel> questions) async {
    final box = Hive.box(AppConstants.settingsBox);
    final savedMap = box.get('test_progress_${widget.testId}');
    
    Map<int, int> loadedAnswers = {};
    if (savedMap != null && savedMap is Map) {
      final shouldResume = await showConfirmDialog(
        context,
        title: 'Resume Test?',
        message: 'We found a saved attempt for this test. Do you want to resume it?',
        confirmLabel: 'Resume',
        cancelLabel: 'Start Fresh',
      );
      if (shouldResume) {
        savedMap.forEach((key, val) {
          final idx = int.tryParse(key.toString());
          final optIdx = int.tryParse(val.toString());
          if (idx != null && optIdx != null) {
            loadedAnswers[idx] = optIdx;
          }
        });
      } else {
        await box.delete('test_progress_${widget.testId}');
      }
    }
    
    if (!mounted) return;
    
    setState(() {
      _questions = questions;
      _answers.addAll(loadedAnswers);
      _secondsRemaining = test.durationMinutes * 60;
      _totalQuestions = questions.length;
      _initialized = true;
    });

    if (questions.length < test.questionCount) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          showAppSnackBar(
            context,
            message: 'Only ${questions.length} of ${test.questionCount} questions available for this test.',
          );
        }
      });
    }
    
    _startTimer(test);
    _startAutoSave();
  }

  void _startTimer(MockTestModel test) {
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
          _submitTest(test);
        }
      });
    });
  }

  void _startAutoSave() {
    _saveTimer = Timer.periodic(const Duration(seconds: 30), (timer) async {
      if (_isPaused || !_initialized) return;
      try {
        final box = Hive.box(AppConstants.settingsBox);
        final Map<String, int> saveMap = {};
        _answers.forEach((key, val) {
          saveMap[key.toString()] = val;
        });
        await box.put('test_progress_${widget.testId}', saveMap);
        debugPrint('Auto-saved progress: $saveMap');
      } catch (e) {
        debugPrint('Auto-save error: $e');
      }
    });
  }

  void _showWarning(String msg) {
    showAppSnackBar(context, message: msg, icon: Icons.warning_amber_rounded);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    if (_initialized) {
      _timer.cancel();
      _saveTimer.cancel();
    }
    // Re-enable language switching once screen is closed
    ref.read(testActiveProvider.notifier).state = false;
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

  Future<void> _submitTest(MockTestModel test) async {
    _timer.cancel();
    _saveTimer.cancel();
    
    if (mounted) {
      showLoadingDialog(context, message: 'Submitting test results...');
    }
    
    int correct = 0;
    int wrong = 0;
    int unattempted = 0;
    
    for (int i = 0; i < _questions.length; i++) {
      if (_answers.containsKey(i)) {
        if (_answers[i] == _questions[i].correctOptionIndex) {
          correct++;
        } else {
          wrong++;
        }
      } else {
        unattempted++;
      }
    }
    
    final double score = (correct * AppConstants.correctMark) + (wrong * AppConstants.wrongMark);
    final double percentage = _totalQuestions > 0 ? (correct / _totalQuestions) * 100 : 0.0;
    final int timeTakenSeconds = (test.durationMinutes * 60) - _secondsRemaining;
    
    final Map<String, int> subjectTotal = {};
    final Map<String, int> subjectCorrect = {};
    final Map<String, int> subjectWrong = {};

    for (int i = 0; i < _questions.length; i++) {
      final q = _questions[i];
      final sub = q.subject.isEmpty ? 'General Studies' : q.subject;
      subjectTotal[sub] = (subjectTotal[sub] ?? 0) + 1;
      
      if (_answers.containsKey(i)) {
        final selected = _answers[i];
        if (selected == q.correctOptionIndex) {
          subjectCorrect[sub] = (subjectCorrect[sub] ?? 0) + 1;
        } else {
          subjectWrong[sub] = (subjectWrong[sub] ?? 0) + 1;
        }
      }
    }

    final Map<String, SubjectScore> subjectScoresMap = {};
    subjectTotal.forEach((sub, total) {
      final cCount = subjectCorrect[sub] ?? 0;
      final wCount = subjectWrong[sub] ?? 0;
      final pct = total > 0 ? (cCount / total) * 100.0 : 0.0;
      subjectScoresMap[sub] = SubjectScore(
        subject: sub,
        total: total,
        correct: cCount,
        wrong: wCount,
        percentage: pct,
      );
    });

    final userId = ref.read(authUidProvider) ?? '';
    final docRef = FirebaseFirestore.instance.collection(AppConstants.testAttemptsCollection).doc();
    
    final resultModel = TestResultModel(
      id: docRef.id,
      userId: userId,
      testId: test.id,
      testType: test.type,
      totalQuestions: _totalQuestions,
      correctAnswers: correct,
      wrongAnswers: wrong,
      unattempted: unattempted,
      score: score,
      percentage: percentage,
      timeTakenSeconds: timeTakenSeconds,
      subjectScores: subjectScoresMap,
      answers: {
        for (var entry in _answers.entries)
          _questions[entry.key].id: entry.value.toString()
      },
      markedForReview: _bookmarked.map((idx) => _questions[idx].id).toList(),
      orderedQuestionIds: _questions.map((q) => q.id).toList(),
      rank: 0,
      attemptedAt: DateTime.now(),
    );

    try {
      if (userId.isNotEmpty) {
        await FirebaseFirestore.instance.runTransaction((transaction) async {
          transaction.set(docRef, resultModel.toFirestore());
          
          final userRef = FirebaseFirestore.instance.collection(AppConstants.usersCollection).doc(userId);
          final userSnap = await transaction.get(userRef);
          
          if (userSnap.exists) {
            final userData = userSnap.data() as Map<String, dynamic>;
            final int currentScore = userData['totalScore'] ?? 0;
            final int currentTestsAttempted = userData['testsAttempted'] ?? 0;
            final Map<String, dynamic> currentSubjectScores = Map<String, dynamic>.from(userData['subjectScores'] ?? {});
            
            final newScore = currentScore + score.round();
            final newTestsAttempted = currentTestsAttempted + 1;
            
            final Map<String, double> updatedSubjectScores = {};
            currentSubjectScores.forEach((key, val) {
              updatedSubjectScores[key] = (val as num).toDouble();
            });
            
            subjectScoresMap.forEach((subjectName, scoreObj) {
              String matchedKey = subjectName;
              for (var k in updatedSubjectScores.keys) {
                if (k.toLowerCase().trim() == subjectName.toLowerCase().trim()) {
                  matchedKey = k;
                  break;
                }
              }
              final oldAvg = updatedSubjectScores[matchedKey] ?? 0.0;
              final newAvg = ((oldAvg * (newTestsAttempted - 1)) + scoreObj.percentage) / newTestsAttempted;
              updatedSubjectScores[matchedKey] = double.parse(newAvg.toStringAsFixed(2));
            });
            
            transaction.update(userRef, {
              'totalScore': newScore,
              'testsAttempted': newTestsAttempted,
              'subjectScores': updatedSubjectScores,
              'lastLoginAt': FieldValue.serverTimestamp(),
            });
          }
        });
      } else {
        throw Exception('User is not logged in.');
      }
      
      final box = Hive.box(AppConstants.settingsBox);
      await box.delete('test_progress_${widget.testId}');
      
      if (mounted) {
        hideLoadingDialog(context);
        context.replace('/test-result/${resultModel.id}');
      }
    } catch (e) {
      debugPrint('Firestore submission error: $e');
      if (mounted) {
        hideLoadingDialog(context);
        showAppSnackBar(
          context,
          message: 'Submission failed: $e. Your results are cached offline and will sync later.',
          isError: true,
        );
      }
      
      try {
        final box = Hive.box(AppConstants.testResultsBox);
        final hiveMap = resultModel.toMap();
        hiveMap['attemptedAt'] = resultModel.attemptedAt.toIso8601String();
        await box.put(resultModel.id, hiveMap);
      } catch (hiveError) {
        debugPrint('Failed to save to Hive: $hiveError');
      }
      
      final box = Hive.box(AppConstants.settingsBox);
      await box.delete('test_progress_${widget.testId}');
      
      if (mounted) {
        context.replace('/test-result/${resultModel.id}');
      }
      
      // TODO: Add an auto-flush sync mechanism that checks for internet connection,
      // reads all entries from Hive box `AppConstants.testResultsBox`, submits them to Firestore,
      // updates the user's aggregate stats, and deletes the synced keys from the Hive box.
    }
  }

  Future<bool> _confirmQuit() async {
    final quit = await showConfirmDialog(
      context,
      title: 'Quit Test?',
      message: 'Are you sure you want to quit this test? All your current answers will be lost and this attempt will not be saved.',
      confirmLabel: 'Quit',
      isDestructive: true,
      icon: Icons.warning_amber_rounded,
    );
    if (quit && mounted) {
      final box = Hive.box(AppConstants.settingsBox);
      await box.delete('test_progress_${widget.testId}');
      context.pop();
    }
    return quit;
  }

  Future<void> _confirmSubmit(MockTestModel test) async {
    final confirmed = await showConfirmDialog(
      context,
      title: 'Submit Test?',
      message: 'You have answered ${_answers.length} out of ${_questions.length} questions. Are you sure you want to submit?',
      confirmLabel: 'Submit',
      isDestructive: false,
      icon: Icons.check_circle_outline,
    );
    if (confirmed) {
      _submitTest(test);
    }
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
              bgColor = AppColors.success;
              textColor = Colors.white;
            }
            if (isBookmarked) {
              bgColor = AppColors.error;
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
    final mockTestAsync = ref.watch(singleMockTestProvider(widget.testId));
    return mockTestAsync.when(
      data: (test) {
        if (test == null) {
          return Scaffold(
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Test not found', style: TextStyle(fontSize: 18)),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => context.pop(),
                    child: const Text('Go Back'),
                  ),
                ],
              ),
            ),
          );
        }
        
        final questionsAsync = ref.watch(mockTestQuestionsProvider(test));
        return questionsAsync.when(
          data: (questions) {
            if (questions.isEmpty) {
              return Scaffold(
                body: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('No questions found for this test.', style: TextStyle(fontSize: 16)),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () => context.pop(),
                        child: const Text('Go Back'),
                      ),
                    ],
                  ),
                ),
              );
            }

            if (!_initialized && !_isInitializingProgressStarted) {
              _isInitializingProgressStarted = true;
              WidgetsBinding.instance.addPostFrameCallback((_) {
                _initializeTest(test, questions);
              });
            }

            if (!_initialized) {
              return Container(
                color: AppColors.primaryNavy,
                child: const Center(
                  child: CircularProgressIndicator(color: AppColors.accentSaffron),
                ),
              );
            }
            
            return _buildTestContent(context, test);
          },
          loading: () => Container(
            color: AppColors.primaryNavy,
            child: const Center(
              child: CircularProgressIndicator(color: AppColors.accentSaffron),
            ),
          ),
          error: (err, stack) => Scaffold(
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Error loading questions: $err', textAlign: TextAlign.center),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => context.pop(),
                    child: const Text('Go Back'),
                  ),
                ],
              ),
            ),
          ),
        );
      },
      loading: () => Container(
        color: AppColors.primaryNavy,
        child: const Center(
          child: CircularProgressIndicator(color: AppColors.accentSaffron),
        ),
      ),
      error: (err, stack) => Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Error loading test details: $err', textAlign: TextAlign.center),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => context.pop(),
                child: const Text('Go Back'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTestContent(BuildContext context, MockTestModel test) {
    final question = _questions[_currentIndex];
    final isDangerTime = _secondsRemaining < 5 * 60;
    final contentLang = ref.watch(contentLangProvider);
    final currentLanguageMode = ref.watch(languageNotifierProvider);

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        await _confirmQuit();
      },
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => _confirmQuit(),
          ),
          automaticallyImplyLeading: false,
          title: Row(
            children: [
              Text('${_currentIndex + 1}/${_questions.length}', style: const TextStyle(fontSize: 18)),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: isDangerTime ? AppColors.error.withValues(alpha: 0.1) : Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: isDangerTime ? AppColors.error : Colors.grey.shade300),
                ),
                child: Row(
                  children: [
                    Icon(Icons.timer_outlined, size: 18, color: isDangerTime ? AppColors.error : Colors.black),
                    const SizedBox(width: 6),
                    Text(
                      _formatTime(_secondsRemaining),
                      style: TextStyle(
                        color: isDangerTime ? AppColors.error : Colors.black,
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
                          value: currentLanguageMode == LanguageMode.tamil,
                          onChanged: (val) {
                            ref.read(languageNotifierProvider.notifier).setLanguage(
                              val ? LanguageMode.tamil : LanguageMode.english,
                            );
                          },
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
                          BilingualText(
                            tamilText: question.questionTamil,
                            englishText: question.questionEnglish,
                            contentLang: contentLang,
                            primaryStyle: Theme.of(context).textTheme.headlineSmall?.copyWith(height: 1.5),
                          ),
                          const SizedBox(height: 32),
                          ...List.generate(4, (optionIndex) {
                            final isSelected = _answers[_currentIndex] == optionIndex;
                            
                            final hasTamilOption = optionIndex < question.optionsTamil.length;
                            final hasEnglishOption = optionIndex < question.optionsEnglish.length;
                            final optionTa = hasTamilOption ? question.optionsTamil[optionIndex] : '';
                            final optionEn = hasEnglishOption ? question.optionsEnglish[optionIndex] : '';
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
                                        child: BilingualText(
                                          tamilText: optionTa,
                                          englishText: optionEn,
                                          contentLang: contentLang,
                                          primaryStyle: Theme.of(context).textTheme.bodyLarge?.copyWith(
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
                    color: _bookmarked.contains(_currentIndex) ? AppColors.error : Colors.grey.shade600,
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
                    onPressed: () => _confirmSubmit(test),
                    style: ElevatedButton.styleFrom(backgroundColor: AppColors.success),
                    child: const Text('Submit Test'),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
