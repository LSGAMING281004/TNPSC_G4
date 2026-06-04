import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_colors.dart';
import '../../core/language/language_mode.dart';
import '../../core/language/language_provider.dart';

/// Full 3-segment language toggle (used in Settings + Onboarding)
class LanguageModeToggle extends ConsumerWidget {
  final bool compact; // if true → icon only, no text

  const LanguageModeToggle({super.key, this.compact = false});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final current = ref.watch(languageNotifierProvider);
    final testActive = ref.watch(testActiveProvider);

    return Tooltip(
      message: testActive
          ? 'Cannot change language during an active test\nதேர்வு நடக்கும்போது மொழியை மாற்ற முடியாது'
          : '',
      child: IgnorePointer(
        ignoring: testActive,
        child: Opacity(
          opacity: testActive ? 0.4 : 1.0,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(compact ? 20 : 12),
              border: Border.all(color: Colors.grey.shade300),
            ),
            padding: const EdgeInsets.all(3),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: LanguageMode.values.map((mode) {
                final isActive = current == mode;
                return GestureDetector(
                  onTap: () => ref
                      .read(languageNotifierProvider.notifier)
                      .setLanguage(mode),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: compact
                        ? const EdgeInsets.symmetric(horizontal: 10, vertical: 6)
                        : const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: isActive ? AppColors.primaryNavy : Colors.transparent,
                      borderRadius: BorderRadius.circular(compact ? 18 : 10),
                    ),
                    child: Text(
                      compact ? _shortLabel(mode) : mode.displayName,
                      style: TextStyle(
                        fontSize: compact ? 11 : 13,
                        fontWeight: FontWeight.w600,
                        color: isActive ? Colors.white : Colors.grey.shade700,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ),
      ),
    );
  }

  String _shortLabel(LanguageMode mode) {
    switch (mode) {
      case LanguageMode.tamil:   return 'த';
      case LanguageMode.english: return 'EN';
      case LanguageMode.both:    return 'இ+E';
    }
  }
}
