import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/language/language_provider.dart';
import '../../../core/language/language_extension.dart';
import '../../../shared/models/question_model.dart';
import '../../../shared/widgets/bilingual_text.dart';
import '../../../shared/widgets/option_tile.dart';

/// Live test-taking question view. Reads contentLangProvider internally.
class TestQuestionView extends ConsumerWidget {
  final QuestionModel question;
  final int questionNumber;
  final int totalQuestions;
  final String? selectedOptionId;
  final bool isMarkedForReview;
  final ValueChanged<String> onOptionSelected;
  final VoidCallback onMarkForReview;
  final VoidCallback onClearResponse;

  const TestQuestionView({
    super.key,
    required this.question,
    required this.questionNumber,
    required this.totalQuestions,
    this.selectedOptionId,
    this.isMarkedForReview = false,
    required this.onOptionSelected,
    required this.onMarkForReview,
    required this.onClearResponse,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final contentLang = ref.watch(contentLangProvider);
    final letters = ['A', 'B', 'C', 'D'];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Question number — always numeric, no translation needed
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Text(
            'Q $questionNumber / $totalQuestions',
            style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade600),
          ),
        ),

        // Question text
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: BilingualText(
            tamilText: question.questionTa,
            englishText: question.questionEn,
            contentLang: contentLang,
            primaryStyle: const TextStyle(
                fontSize: 16, fontWeight: FontWeight.w500, height: 1.5),
          ),
        ),
        const SizedBox(height: 16),

        // Options
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            children: List.generate(question.options.length, (i) {
              final opt = question.options[i];
              return OptionTile(
                option: opt,
                optionLetter: i < letters.length ? letters[i] : '${i + 1}',
                contentLang: contentLang,
                isSelected: selectedOptionId == opt.id,
                onTap: () => onOptionSelected(opt.id),
              );
            }),
          ),
        ),
        const SizedBox(height: 8),

        // Action buttons — always English in UI per spec
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(children: [
            OutlinedButton.icon(
              onPressed: onMarkForReview,
              icon: Icon(
                isMarkedForReview ? Icons.flag : Icons.flag_outlined,
                size: 16,
              ),
              label: Text(context.s.markForReview),
              style: OutlinedButton.styleFrom(
                foregroundColor:
                    isMarkedForReview ? Colors.orange : Colors.grey.shade700,
                side: BorderSide(
                    color: isMarkedForReview
                        ? Colors.orange
                        : Colors.grey.shade400),
              ),
            ),
            const SizedBox(width: 8),
            if (selectedOptionId != null)
              OutlinedButton.icon(
                onPressed: onClearResponse,
                icon: const Icon(Icons.clear, size: 16),
                label: Text(context.s.clearResponse),
                style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.grey.shade700,
                    side: BorderSide(color: Colors.grey.shade400)),
              ),
          ]),
        ),
      ],
    );
  }
}
