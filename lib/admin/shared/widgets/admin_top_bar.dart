import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/admin_constants.dart';
import '../../core/theme/admin_theme.dart';
import '../providers/admin_auth_provider.dart';

/// Top app bar for admin pages — shows page title, admin name, and project badge.
class AdminTopBar extends ConsumerWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;

  const AdminTopBar({super.key, required this.title, this.actions});

  @override
  Size get preferredSize => const Size.fromHeight(AdminConstants.topBarHeight);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final admin = ref.watch(currentAdminProvider);

    return Container(
      height: AdminConstants.topBarHeight,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(color: AdminTheme.border, width: 1),
        ),
      ),
      child: Row(
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: AdminTheme.textPrimary,
            ),
          ),
          const Spacer(),
          if (actions != null) ...actions!,
          if (actions != null) const SizedBox(width: 16),
          // Project badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: AdminTheme.navy.withValues(alpha: 0.06),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.cloud_outlined, size: 14, color: AdminTheme.textSecondary),
                const SizedBox(width: 6),
                Text(
                  AdminConstants.firebaseProject,
                  style: const TextStyle(
                    fontSize: 11,
                    color: AdminTheme.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          // Admin avatar + name
          if (admin != null)
            Row(
              children: [
                CircleAvatar(
                  radius: 16,
                  backgroundColor: AdminTheme.saffron,
                  child: Text(
                    (admin.name.isNotEmpty ? admin.name[0] : 'A').toUpperCase(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  admin.name,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: AdminTheme.textPrimary,
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }
}
