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
  final String? selectedOptionId;
  final VoidCallback? onBookmark;
  final VoidCallback? onRevealAnswer;
  final bool isBookmarked;

  const QuestionCard({
    super.key,
    required this.question,
    this.showAnswer = false,
    this.selectedOptionId,
    this.onBookmark,
    this.onRevealAnswer,
    this.isBookmarked = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final contentLang = ref.watch(contentLangProvider);
    final letters = ['A', 'B', 'C', 'D'];

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
              _badge(question.subject, AppColors.primaryNavy),
              const SizedBox(width: 8),
              _badge(question.difficulty, _difficultyColor(question.difficulty)),
              if (question.year != null) ...[
                const SizedBox(width: 8),
                _badge('${question.year}', Colors.teal),
              ],
            ]),
            const SizedBox(height: 12),

            // Question text
            BilingualText(
              tamilText: question.questionTa,
              englishText: question.questionEn,
              contentLang: contentLang,
              primaryStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 14),

            // Options
            ...List.generate(question.options.length, (i) {
              final opt = question.options[i];
              final isCorrect = showAnswer && opt.id == question.correctOptionId;
              final isWrong = showAnswer &&
                  selectedOptionId == opt.id &&
                  opt.id != question.correctOptionId;
              return OptionTile(
                option: opt,
                optionLetter: i < letters.length ? letters[i] : '${i + 1}',
                contentLang: contentLang,
                isSelected: selectedOptionId == opt.id,
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
                tamilText: question.explanationTa,
                englishText: question.explanationEn,
                contentLang: contentLang,
                primaryStyle: const TextStyle(fontSize: 13),
                secondaryStyle: TextStyle(fontSize: 12, color: Colors.grey.shade600),
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
          color: color.withOpacity(0.12),
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
    final idx = question.options
        .indexWhere((o) => o.id == question.correctOptionId);
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
