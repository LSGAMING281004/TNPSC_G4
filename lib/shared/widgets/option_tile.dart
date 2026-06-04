import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../shared/models/question_model.dart';
import 'bilingual_text.dart';

/// Option tile for Mock Test and Question Bank.
class OptionTile extends StatelessWidget {
  final OptionModel option;
  final String optionLetter; // A / B / C / D
  final String contentLang;
  final bool isSelected;
  final bool? isCorrect;
  final bool? isWrong;
  final VoidCallback? onTap;

  const OptionTile({
    super.key,
    required this.option,
    required this.optionLetter,
    required this.contentLang,
    required this.isSelected,
    this.isCorrect,
    this.isWrong,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final Color borderColor;
    final Color bgColor;

    if (isCorrect == true) {
      borderColor = Colors.green.shade400;
      bgColor = Colors.green.shade50;
    } else if (isWrong == true) {
      borderColor = Colors.red.shade400;
      bgColor = Colors.red.shade50;
    } else if (isSelected) {
      borderColor = AppColors.primaryNavy;
      bgColor = AppColors.primaryNavy.withOpacity(0.06);
    } else {
      borderColor = Colors.grey.shade300;
      bgColor = Colors.white;
    }

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          color: bgColor,
          border: Border.all(color: borderColor, width: 1.5),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Letter badge
            Container(
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                color: isSelected || isCorrect == true || isWrong == true
                    ? borderColor
                    : Colors.grey.shade200,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: Text(
                  optionLetter,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                    color: isSelected || isCorrect == true || isWrong == true
                        ? Colors.white
                        : Colors.grey.shade700,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            // Option text
            Expanded(
              child: BilingualText(
                tamilText: option.textTa,
                englishText: option.textEn,
                contentLang: contentLang,
                primaryStyle: const TextStyle(fontSize: 14),
                secondaryStyle: const TextStyle(fontSize: 12),
              ),
            ),
            // Correct / wrong icon
            if (isCorrect == true)
              const Icon(Icons.check_circle, color: Colors.green, size: 20),
            if (isWrong == true)
              const Icon(Icons.cancel, color: Colors.red, size: 20),
          ],
        ),
      ),
    );
  }
}
