import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/language/language_provider.dart';
import '../../core/constants/app_colors.dart';
import 'language_toggle.dart';

/// Standard reusable AppBar with compact language toggle in actions.
class AppBarWidget extends ConsumerWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? extraActions;
  final bool showLanguageToggle;
  final Widget? leading;

  const AppBarWidget({
    super.key,
    required this.title,
    this.extraActions,
    this.showLanguageToggle = true,
    this.leading,
  });

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // watch so AppBar rebuilds when language changes
    ref.watch(languageNotifierProvider);

    return AppBar(
      backgroundColor: AppColors.primaryNavy,
      foregroundColor: Colors.white,
      leading: leading,
      title: Text(title,
          style: const TextStyle(
              fontSize: 17, fontWeight: FontWeight.w600, color: Colors.white)),
      actions: [
        if (showLanguageToggle)
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: Center(child: LanguageModeToggle(compact: true)),
          ),
        ...?extraActions,
      ],
    );
  }
}
