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
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 800;

    return Container(
      height: AdminConstants.topBarHeight,
      padding: EdgeInsets.symmetric(horizontal: isMobile ? 12 : 24),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(color: AdminTheme.border, width: 1),
        ),
      ),
      child: Row(
        children: [
          if (isMobile) ...[
            IconButton(
              icon: const Icon(Icons.menu, color: AdminTheme.textPrimary),
              onPressed: () {
                Scaffold.of(context).openDrawer();
              },
            ),
            const SizedBox(width: 4),
          ],
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                fontSize: isMobile ? 18 : 20,
                fontWeight: FontWeight.w700,
                color: AdminTheme.textPrimary,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (actions != null) ...actions!,
          if (actions != null) const SizedBox(width: 16),
          // Project badge
          if (!isMobile) ...[
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
          ],
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
                if (!isMobile) ...[
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
              ],
            ),
        ],
      ),
    );
  }
}
