import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/language/language_provider.dart';
import '../../../../shared/models/question_model.dart';
import '../../../../shared/providers/firestore_providers.dart';
import '../../../../shared/widgets/bilingual_text.dart';
import '../../../../shared/providers/bookmark_actions.dart';

class QuestionDetailScreen extends ConsumerStatefulWidget {
  final String questionId;
  const QuestionDetailScreen({super.key, required this.questionId});

  @override
  ConsumerState<QuestionDetailScreen> createState() => _QuestionDetailScreenState();
}

class _QuestionDetailScreenState extends ConsumerState<QuestionDetailScreen> {
  bool _revealed = false;
  int? _selected;

  @override
  Widget build(BuildContext context) {
    final contentLang = ref.watch(contentLangProvider);
    final questionAsyncVal = ref.watch(singleQuestionProvider(widget.questionId));

    return questionAsyncVal.when(
      loading: () => Scaffold(
        appBar: AppBar(title: const Text('Question')),
        body: const Center(
          child: CircularProgressIndicator(color: AppColors.accentSaffron),
        ),
      ),
      error: (err, stack) => Scaffold(
        appBar: AppBar(title: const Text('Question')),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 48, color: AppColors.error),
                const SizedBox(height: 16),
                Text('Failed to load question: $err', textAlign: TextAlign.center),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => ref.invalidate(singleQuestionProvider(widget.questionId)),
                  child: const Text('Retry'),
                ),
              ],
            ),
          ),
        ),
      ),
      data: (QuestionModel? question) {
        if (question == null) {
          return Scaffold(
            appBar: AppBar(title: const Text('Question')),
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Question not found', style: TextStyle(fontSize: 16)),
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

        final optionsCount = question.optionsTamil.length;

        final isBookmarked = ref.watch(isBookmarkedProvider(question.id));

        return Scaffold(
          appBar: AppBar(
            title: const Text('Question'),
            actions: [
              IconButton(
                icon: Icon(
                  isBookmarked ? Icons.bookmark : Icons.bookmark_border,
                  color: isBookmarked ? AppColors.accentSaffron : null,
                ),
                onPressed: () => toggleBookmark(context, ref, question.id),
              ),
            ],
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Subject, Chapter & Difficulty Chips
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        question.subject.replaceAll('_', ' ').toUpperCase(),
                        style: TextStyle(
                          fontSize: 11,
                          color: Theme.of(context).colorScheme.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    if (question.chapter.isNotEmpty)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.secondary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          question.chapter.toUpperCase(),
                          style: TextStyle(
                            fontSize: 11,
                            color: Theme.of(context).colorScheme.secondary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: _getDifficultyColor(question.difficulty).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        question.difficulty.toUpperCase(),
                        style: TextStyle(
                          fontSize: 11,
                          color: _getDifficultyColor(question.difficulty),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    if (question.year > 0)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: Colors.orange.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '${question.year}',
                          style: const TextStyle(
                            fontSize: 11,
                            color: Colors.orange,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 20),

                // Question Text
                BilingualText(
                  tamilText: question.questionTamil,
                  englishText: question.questionEnglish,
                  contentLang: contentLang,
                  primaryStyle: const TextStyle(fontSize: 17, fontWeight: FontWeight.w600, height: 1.5),
                  secondaryStyle: TextStyle(fontSize: 15, color: Colors.grey, height: 1.5),
                ),
                const SizedBox(height: 24),

                // Options List
                ...List.generate(optionsCount, (i) {
                  final isSelected = _selected == i;
                  final isCorrect = i == question.correctOptionIndex;
                  final optionLetter = 'ABCD'[i];

                  final bgOptionColor = _revealed
                      ? (isCorrect
                          ? AppColors.success.withValues(alpha: 0.1)
                          : isSelected
                              ? AppColors.error.withValues(alpha: 0.1)
                              : Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.5))
                      : (isSelected
                          ? AppColors.accentSaffron.withValues(alpha: 0.1)
                          : Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.5));

                  final borderOptionColor = _revealed
                      ? (isCorrect
                          ? AppColors.success
                          : isSelected
                              ? AppColors.error
                              : Theme.of(context).colorScheme.outlineVariant)
                      : (isSelected
                          ? AppColors.accentSaffron
                          : Theme.of(context).colorScheme.outlineVariant);

                  final circleBgColor = _revealed
                      ? (isCorrect
                          ? AppColors.success
                          : isSelected
                              ? AppColors.error
                              : Theme.of(context).colorScheme.surfaceContainerHighest)
                      : (isSelected
                          ? AppColors.accentSaffron
                          : Theme.of(context).colorScheme.surfaceContainerHighest);

                  return GestureDetector(
                    onTap: !_revealed ? () => setState(() => _selected = i) : null,
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: bgOptionColor,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: borderOptionColor,
                          width: isSelected || (isCorrect && _revealed) ? 2 : 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: circleBgColor,
                            ),
                            child: Center(
                              child: Text(
                                optionLetter,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: isSelected || (isCorrect && _revealed)
                                      ? Colors.white
                                      : Theme.of(context).colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: BilingualText(
                              tamilText: question.optionsTamil[i],
                              englishText: question.optionsEnglish[i],
                              contentLang: contentLang,
                              primaryStyle: const TextStyle(fontSize: 15),
                              secondaryStyle: TextStyle(fontSize: 13, color: Theme.of(context).colorScheme.onSurfaceVariant),
                            ),
                          ),
                          if (_revealed && isCorrect)
                            const Icon(Icons.check_circle, color: AppColors.success, size: 20),
                          if (_revealed && isSelected && !isCorrect)
                            const Icon(Icons.cancel, color: AppColors.error, size: 20),
                        ],
                      ),
                    ),
                  );
                }),
                const SizedBox(height: 16),

                // Reveal Answer Button
                if (!_revealed)
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: _selected != null ? () => setState(() => _revealed = true) : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.accentSaffron,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                      child: const Text(
                        'Reveal Answer',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                    ),
                  ),

                // Post-Reveal Explanation
                if (_revealed) ...[
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.info.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(
                          children: [
                            Icon(Icons.lightbulb, color: AppColors.info, size: 20),
                            SizedBox(width: 8),
                            Text(
                              'Explanation',
                              style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.info),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        BilingualText(
                          tamilText: question.explanationTamil,
                          englishText: question.explanationEnglish,
                          contentLang: contentLang,
                          primaryStyle: const TextStyle(fontSize: 14, height: 1.5),
                          secondaryStyle: TextStyle(fontSize: 13, color: Theme.of(context).colorScheme.onSurfaceVariant, height: 1.5),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: OutlinedButton.icon(
                      onPressed: () {
                        // TODO(bookmarks): wire to practice similar, see Prompt 7
                      },
                      icon: const Icon(Icons.refresh, size: 18),
                      label: const Text('Practice Similar'),
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  Color _getDifficultyColor(String difficulty) {
    switch (difficulty.toLowerCase()) {
      case 'easy':
        return AppColors.success;
      case 'hard':
        return AppColors.error;
      case 'medium':
      default:
        return AppColors.accentSaffron;
    }
  }
}
