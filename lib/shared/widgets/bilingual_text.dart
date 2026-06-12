import 'package:flutter/material.dart';
import '../../core/language/question_display_helper.dart';

/// Universal bilingual text widget.
/// Pass tamilText, englishText and the current contentLang ('ta'|'en'|'both').
class BilingualText extends StatelessWidget {
  final String tamilText;
  final String englishText;
  final String contentLang;
  final TextStyle? primaryStyle;
  final TextStyle? secondaryStyle;

  const BilingualText({
    super.key,
    required this.tamilText,
    required this.englishText,
    required this.contentLang,
    this.primaryStyle,
    this.secondaryStyle,
  });

  @override
  Widget build(BuildContext context) {
    final primary = primaryStyle ??
        const TextStyle(fontSize: 15, fontWeight: FontWeight.w400);
    final secondary = secondaryStyle ??
        TextStyle(fontSize: 13, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6));

    switch (contentLang) {
      case 'ta':
        final text = tamilText.isNotEmpty ? tamilText : englishText;
        final hasMissing = tamilText.isEmpty && englishText.isNotEmpty;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(text,
                style: primary.copyWith(fontFamily: 'NotoSansTamil')),
            if (hasMissing) _missingBadge(QuestionDisplayHelper.missingTamilBadge()),
          ],
        );

      case 'en':
        final text = englishText.isNotEmpty ? englishText : tamilText;
        final hasMissing = englishText.isEmpty && tamilText.isNotEmpty;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(text, style: primary),
            if (hasMissing) _missingBadge(QuestionDisplayHelper.missingEnglishBadge()),
          ],
        );

      case 'both':
      default:
        // If one side is empty, show the other without the divider
        if (tamilText.isEmpty) {
          return Text(englishText, style: primary);
        }
        if (englishText.isEmpty) {
          return Text(tamilText,
              style: primary.copyWith(fontFamily: 'NotoSansTamil'));
        }
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(tamilText,
                style: primary.copyWith(fontFamily: 'NotoSansTamil')),
            const SizedBox(height: 4),
            Divider(height: 1, thickness: 0.5, color: Theme.of(context).colorScheme.outlineVariant),
            const SizedBox(height: 4),
            Text(englishText,
                style: secondary.copyWith(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6))),
          ],
        );
    }
  }

  Widget _missingBadge(String label) {
    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
        decoration: BoxDecoration(
          color: Colors.orange.shade50,
          border: Border.all(color: Colors.orange.shade200),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Text(label,
            style: TextStyle(fontSize: 11, color: Colors.orange.shade700)),
      ),
    );
  }
}
