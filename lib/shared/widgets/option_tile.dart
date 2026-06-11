import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import 'bilingual_text.dart';

/// Option tile for Mock Test and Question Bank.
class OptionTile extends StatelessWidget {
  final String textTa;
  final String textEn;
  final String optionLetter; // A / B / C / D
  final String contentLang;
  final bool isSelected;
  final bool? isCorrect;
  final bool? isWrong;
  final VoidCallback? onTap;

  const OptionTile({
    super.key,
    required this.textTa,
    required this.textEn,
    required this.optionLetter,
    required this.contentLang,
    required this.isSelected,
    this.isCorrect,
    this.isWrong,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final Color borderColor;
    final Color bgColor;

    if (isCorrect == true) {
      borderColor = isDark ? Colors.green.shade600 : Colors.green.shade400;
      bgColor = isDark ? Colors.green.shade900.withValues(alpha: 0.2) : Colors.green.shade50;
    } else if (isWrong == true) {
      borderColor = isDark ? Colors.red.shade600 : Colors.red.shade400;
      bgColor = isDark ? Colors.red.shade900.withValues(alpha: 0.2) : Colors.red.shade50;
    } else if (isSelected) {
      borderColor = isDark ? AppColors.accentSaffron : AppColors.primaryNavy;
      bgColor = isDark ? AppColors.accentSaffron.withValues(alpha: 0.08) : AppColors.primaryNavy.withValues(alpha: 0.06);
    } else {
      borderColor = isDark ? const Color(0xFF1F324E) : Colors.grey.shade300;
      bgColor = isDark ? const Color(0xFF152A4A) : Colors.white;
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
                    : (isDark ? const Color(0xFF1F324E) : Colors.grey.shade200),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: Text(
                  optionLetter,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                    color: isSelected || isCorrect == true || isWrong == true
                        ? (isDark && isSelected ? Colors.black87 : Colors.white)
                        : (isDark ? Colors.grey.shade300 : Colors.grey.shade700),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            // Option text
            Expanded(
              child: BilingualText(
                tamilText: textTa,
                englishText: textEn,
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
