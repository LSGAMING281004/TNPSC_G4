import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/language/language_mode.dart';
import '../../../../core/language/language_provider.dart';
import '../../../../core/language/language_extension.dart';
import '../../../../shared/widgets/bilingual_text.dart';

/// Language section for the Settings screen.
/// Auto-saves on tap — no "Apply" button needed.
class LanguageSettingsSection extends ConsumerWidget {
  const LanguageSettingsSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final current = ref.watch(languageNotifierProvider);
    final l10n = context.l10n;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: Text(l10n.appLanguage,
              style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6))),
        ),
        Card(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          elevation: 1,
          child: Column(
            children: LanguageMode.values.map((mode) {
              final isSelected = current == mode;
              return _LanguageOptionTile(
                mode: mode,
                isSelected: isSelected,
                onTap: () => ref
                    .read(languageNotifierProvider.notifier)
                    .setLanguage(mode),
              );
            }).toList(),
          ),
        ),
        const SizedBox(height: 16),
        // Live preview card
        _LanguagePreviewCard(currentLang: current.contentLang),
      ],
    );
  }
}

class _LanguageOptionTile extends StatelessWidget {
  final LanguageMode mode;
  final bool isSelected;
  final VoidCallback onTap;

  const _LanguageOptionTile({
    required this.mode,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final subtitle = _subtitle(mode);
    final color = _modeColor(context, mode);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      decoration: BoxDecoration(
        color: isSelected ? color.withValues(alpha: 0.06) : Colors.transparent,
        borderRadius: BorderRadius.circular(14),
      ),
      child: ListTile(
        onTap: onTap,
        leading: Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: isSelected ? color : Theme.of(context).colorScheme.surfaceContainerHighest,
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              _icon(mode),
              style: const TextStyle(fontSize: 14),
            ),
          ),
        ),
        title: Text(mode.displayName,
            style: TextStyle(
                fontWeight: FontWeight.w600,
                color: isSelected ? color : Theme.of(context).colorScheme.onSurface)),
        subtitle: Text(subtitle,
            style: TextStyle(fontSize: 12, color: Theme.of(context).colorScheme.onSurfaceVariant)),
        trailing: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: 22,
          height: 22,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
                color: isSelected ? color : Theme.of(context).colorScheme.outline, width: 2),
            color: isSelected ? color : Colors.transparent,
          ),
          child: isSelected
              ? const Icon(Icons.check, size: 12, color: Colors.white)
              : null,
        ),
      ),
    );
  }

  String _subtitle(LanguageMode m) {
    switch (m) {
      case LanguageMode.tamil:
        return 'பயன்பாடு மற்றும் கேள்விகள் தமிழில் காட்டப்படும்';
      case LanguageMode.english:
        return 'App and questions shown in English';
      case LanguageMode.both:
        return 'App in English • Questions in Tamil + English';
    }
  }

  String _icon(LanguageMode m) {
    switch (m) {
      case LanguageMode.tamil:   return 'த';
      case LanguageMode.english: return 'E';
      case LanguageMode.both:    return '🔀';
    }
  }

  Color _modeColor(BuildContext context, LanguageMode m) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    switch (m) {
      case LanguageMode.tamil:   return AppColors.accentSaffronDark;
      case LanguageMode.english: return isDark ? AppColors.info : AppColors.primaryNavy;
      case LanguageMode.both:    return AppColors.success;
    }
  }
}

class _LanguagePreviewCard extends StatelessWidget {
  final String currentLang;
  const _LanguagePreviewCard({required this.currentLang});

  static const String _sampleTa =
      'இந்தியாவின் தேசிய பறவை எது?';
  static const String _sampleEn =
      'What is the national bird of India?';
  static const String _optTa = 'அ) மயில்';
  static const String _optEn = 'A) Peacock';

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Preview / முன்னோட்டம்',
            style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5))),
        const SizedBox(height: 6),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
                color: Theme.of(context).colorScheme.outlineVariant),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              BilingualText(
                tamilText: _sampleTa,
                englishText: _sampleEn,
                contentLang: currentLang,
                primaryStyle: TextStyle(
                    fontSize: 14,
                    color: Theme.of(context).colorScheme.onSurface),
              ),
              const SizedBox(height: 8),
              BilingualText(
                tamilText: _optTa,
                englishText: _optEn,
                contentLang: currentLang,
                primaryStyle: const TextStyle(
                    fontSize: 13,
                    color: AppColors.success),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
