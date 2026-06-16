import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/language/language_provider.dart';

import '../../../../shared/providers/app_providers.dart';
import '../../../../shared/providers/firestore_providers.dart';
import '../../../../shared/widgets/bilingual_text.dart';
import '../../../../shared/widgets/app_dialogs.dart';


class SolutionScreen extends ConsumerStatefulWidget {
  final String resultId;
  const SolutionScreen({super.key, required this.resultId});

  @override
  ConsumerState<SolutionScreen> createState() => _SolutionScreenState();
}

class _SolutionScreenState extends ConsumerState<SolutionScreen> {
  final Set<String> _reportedQuestions = {};

  Future<void> _reportQuestionError(String questionId) async {
    final uid = ref.read(authUidProvider) ?? '';
    if (uid.isEmpty) return;

    try {
      await FirebaseFirestore.instance.collection('question_reports').add({
        'questionId': questionId,
        'userId': uid,
        'reportedAt': FieldValue.serverTimestamp(),
        'testResultId': widget.resultId,
      });

      setState(() {
        _reportedQuestions.add(questionId);
      });

      if (mounted) {
        showAppSnackBar(
          context,
          message: "Thanks — we'll review this question.",
          isSuccess: true,
        );
      }
    } catch (e) {
      if (mounted) {
        showAppSnackBar(
          context,
          message: 'Failed to report error: $e',
          isError: true,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final contentLang = ref.watch(contentLangProvider);
    final resultAsync = ref.watch(singleTestResultProvider(widget.resultId));

    return resultAsync.when(
      loading: () => Scaffold(
        appBar: AppBar(title: const Text('Solutions')),
        body: const Center(
          child: CircularProgressIndicator(color: AppColors.accentSaffron),
        ),
      ),
      error: (err, stack) => Scaffold(
        appBar: AppBar(title: const Text('Solutions')),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 48, color: AppColors.error),
                const SizedBox(height: 16),
                Text('Failed to load result: $err', textAlign: TextAlign.center),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => ref.invalidate(singleTestResultProvider(widget.resultId)),
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
            appBar: AppBar(title: const Text('Solutions')),
            body: const Center(
              child: Text('Result not found.'),
            ),
          );
        }

        final questionIds = result.orderedQuestionIds.isNotEmpty
            ? result.orderedQuestionIds
            : result.answers.keys.toList();

        if (questionIds.isEmpty) {
          return Scaffold(
            appBar: AppBar(title: const Text('Solutions')),
            body: const Center(
              child: Text('No questions recorded for this attempt.'),
            ),
          );
        }

        final questionsAsync = ref.watch(questionsByIdsProvider(questionIds));

        return Scaffold(
          appBar: AppBar(title: const Text('Solutions')),
          body: questionsAsync.when(
            loading: () => const Center(
              child: CircularProgressIndicator(color: AppColors.accentSaffron),
            ),
            error: (qErr, qStack) => Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline, size: 48, color: AppColors.error),
                    const SizedBox(height: 16),
                    Text('Failed to load questions: $qErr', textAlign: TextAlign.center),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () => ref.invalidate(questionsByIdsProvider(questionIds)),
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            ),
            data: (questions) {
              if (questions.isEmpty) {
                return const Center(
                  child: Text('No questions found.'),
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: questions.length,
                itemBuilder: (context, index) {
                  final question = questions[index];
                  final userAnswerIndexStr = result.answers[question.id];
                  final userAnswerIndex = userAnswerIndexStr != null ? int.tryParse(userAnswerIndexStr) : null;
                  final isCorrect = userAnswerIndex == question.correctOptionIndex;
                  final wasMarkedForReview = result.markedForReview.contains(question.id);
                  final isUnattempted = userAnswerIndex == null;

                  return Card(
                    margin: const EdgeInsets.only(bottom: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: (isUnattempted
                                          ? Colors.grey
                                          : isCorrect
                                              ? AppColors.success
                                              : AppColors.error)
                                      .withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  'Q${index + 1}',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: isUnattempted
                                        ? Colors.grey.shade600
                                        : isCorrect
                                            ? AppColors.success
                                            : AppColors.error,
                                  ),
                                ),
                              ),
                              if (wasMarkedForReview) ...[
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: AppColors.accentSaffron.withValues(alpha: 0.15),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: const Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(Icons.bookmark, color: AppColors.accentSaffron, size: 12),
                                      SizedBox(width: 4),
                                      Text(
                                        'Marked for Review',
                                        style: TextStyle(
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold,
                                          color: AppColors.accentSaffron,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                              const Spacer(),
                              Icon(
                                isUnattempted
                                    ? Icons.help_outline
                                    : isCorrect
                                        ? Icons.check_circle
                                        : Icons.cancel,
                                color: isUnattempted
                                    ? Colors.grey
                                    : isCorrect
                                        ? AppColors.success
                                        : AppColors.error,
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          BilingualText(
                            tamilText: question.questionTamil,
                            englishText: question.questionEnglish,
                            contentLang: contentLang,
                            primaryStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                          ),
                          const SizedBox(height: 12),
                          ...List.generate(
                            question.optionsTamil.length,
                            (i) {
                              final isCorrectOpt = i == question.correctOptionIndex;
                              final isUserChoice = i == userAnswerIndex;
                              final optionTa = question.optionsTamil[i];
                              final optionEn = question.optionsEnglish.length > i ? question.optionsEnglish[i] : '';

                              Color tileBg;
                              Color tileBorder;
                              if (isCorrectOpt) {
                                tileBg = AppColors.success.withValues(alpha: 0.08);
                                tileBorder = AppColors.success;
                              } else if (isUserChoice && !isCorrectOpt) {
                                tileBg = AppColors.error.withValues(alpha: 0.08);
                                tileBorder = AppColors.error;
                              } else {
                                tileBg = Colors.grey.withValues(alpha: 0.05);
                                tileBorder = isDark ? Colors.grey.shade800 : Colors.grey.shade300;
                              }

                              return Container(
                                margin: const EdgeInsets.only(bottom: 8),
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: tileBg,
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(color: tileBorder),
                                ),
                                child: Row(
                                  children: [
                                    Text('${'ABCD'[i]}. ', style: const TextStyle(fontWeight: FontWeight.w600)),
                                    Expanded(
                                      child: BilingualText(
                                        tamilText: optionTa,
                                        englishText: optionEn,
                                        contentLang: contentLang,
                                        primaryStyle: const TextStyle(fontSize: 13),
                                      ),
                                    ),
                                    if (isCorrectOpt)
                                      const Icon(Icons.check, color: AppColors.success, size: 18),
                                    if (isUserChoice && !isCorrectOpt)
                                      const Icon(Icons.close, color: AppColors.error, size: 18),
                                  ],
                                ),
                              );
                            },
                          ),
                          if (isUnattempted) ...[
                            const SizedBox(height: 4),
                            const Text(
                              'Not attempted',
                              style: TextStyle(
                                fontSize: 12,
                                fontStyle: FontStyle.italic,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                          const SizedBox(height: 12),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: AppColors.info.withValues(alpha: 0.08),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Row(
                                  children: [
                                    Icon(Icons.lightbulb, color: AppColors.info, size: 18),
                                    SizedBox(width: 6),
                                    Text('Explanation', style: TextStyle(fontWeight: FontWeight.w600, color: AppColors.info)),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                BilingualText(
                                  tamilText: question.explanationTamil,
                                  englishText: question.explanationEnglish,
                                  contentLang: contentLang,
                                  primaryStyle: const TextStyle(fontSize: 13, height: 1.5),
                                ),
                              ],
                            ),
                          ),
                          Align(
                            alignment: Alignment.centerRight,
                            child: _reportedQuestions.contains(question.id)
                                ? const Padding(
                                    padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 12.0),
                                    child: Text(
                                      'Reported',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  )
                                : TextButton.icon(
                                    onPressed: () => _reportQuestionError(question.id),
                                    icon: const Icon(Icons.flag_outlined, size: 16),
                                    label: const Text('Report Error', style: TextStyle(fontSize: 12)),
                                  ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          ),
        );
      },
    );
  }
}
