import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_colors.dart';
import '../../core/language/language_provider.dart';
import '../../shared/models/question_model.dart';
import 'bilingual_text.dart';
import 'option_tile.dart';

/// Full question card for Question Bank and review screens.
/// Reads contentLangProvider internally — no need to pass contentLang from parent.
class QuestionCard extends ConsumerWidget {
  final QuestionModel question;
  final bool showAnswer;
  final int? selectedOptionIndex;
  final VoidCallback? onBookmark;
  final VoidCallback? onRevealAnswer;
  final bool isBookmarked;

  const QuestionCard({
    super.key,
    required this.question,
    this.showAnswer = false,
    this.selectedOptionIndex,
    this.onBookmark,
    this.onRevealAnswer,
    this.isBookmarked = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final contentLang = ref.watch(contentLangProvider);
    final letters = ['A', 'B', 'C', 'D'];
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final subjectBadgeColor = isDark ? Colors.blue.shade300 : AppColors.primaryNavy;
    final yearBadgeColor = isDark ? Colors.tealAccent : Colors.teal;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header: subject + difficulty badges
            Row(children: [
              _badge(question.subject, subjectBadgeColor),
              const SizedBox(width: 8),
              _badge(question.difficulty, _difficultyColor(question.difficulty)),
              ...[
              const SizedBox(width: 8),
              _badge('${question.year}', yearBadgeColor),
            ],
            ]),
            const SizedBox(height: 12),

            // Question text
            BilingualText(
              tamilText: question.questionTamil,
              englishText: question.questionEnglish,
              contentLang: contentLang,
              primaryStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 14),

            // Options
            ...List.generate(question.optionsTamil.length, (i) {
              final isCorrect = showAnswer && i == question.correctOptionIndex;
              final isWrong = showAnswer &&
                  selectedOptionIndex == i &&
                  i != question.correctOptionIndex;
              return OptionTile(
                textTa: question.optionsTamil[i],
                textEn: question.optionsEnglish.length > i ? question.optionsEnglish[i] : question.optionsTamil[i],
                optionLetter: i < letters.length ? letters[i] : '${i + 1}',
                contentLang: contentLang,
                isSelected: selectedOptionIndex == i,
                isCorrect: isCorrect ? true : null,
                isWrong: isWrong ? true : null,
              );
            }),

            // Answer + explanation
            if (showAnswer) ...[
              const Divider(height: 24),
              _correctAnswerLabel(context),
              const SizedBox(height: 8),
              BilingualText(
                tamilText: question.explanationTamil,
                englishText: question.explanationEnglish,
                contentLang: contentLang,
                primaryStyle: const TextStyle(fontSize: 13),
                secondaryStyle: TextStyle(fontSize: 12, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6)),
              ),
            ],

            // Footer actions
            const SizedBox(height: 8),
            Row(children: [
              IconButton(
                icon: Icon(
                  isBookmarked ? Icons.bookmark : Icons.bookmark_border,
                  color: AppColors.accentSaffron,
                ),
                onPressed: onBookmark,
              ),
              if (!showAnswer)
                TextButton(
                  onPressed: onRevealAnswer,
                  child: const Text('Reveal Answer'),
                ),
              const Spacer(),
              TextButton(onPressed: () {}, child: const Text('Practice Similar')),
            ]),
          ],
        ),
      ),
    );
  }

  Widget _badge(String label, Color color) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(label,
            style: TextStyle(
                fontSize: 11, fontWeight: FontWeight.w600, color: color)),
      );

  Color _difficultyColor(String d) {
    switch (d.toLowerCase()) {
      case 'easy':   return Colors.green;
      case 'hard':   return Colors.red;
      default:       return Colors.orange;
    }
  }

  Widget _correctAnswerLabel(BuildContext context) {
    final idx = question.correctOptionIndex;
    final letters = ['A', 'B', 'C', 'D'];
    final letter = idx >= 0 && idx < letters.length ? letters[idx] : '?';
    return Row(children: [
      const Icon(Icons.check_circle, color: Colors.green, size: 16),
      const SizedBox(width: 4),
      Text('Correct Answer: $letter',
          style: const TextStyle(
              fontWeight: FontWeight.w600, color: Colors.green, fontSize: 13)),
    ]);
  }
}
