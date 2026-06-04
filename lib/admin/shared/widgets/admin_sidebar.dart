import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/admin_constants.dart';
import '../../core/theme/admin_theme.dart';
import '../providers/admin_auth_provider.dart';

/// Navigation item definition for the sidebar.
class _NavItem {
  final String label;
  final IconData icon;
  final String route;
  final List<String>? requiredRoles;

  const _NavItem({
    required this.label,
    required this.icon,
    required this.route,
    this.requiredRoles,
  });
}

// Nav items list
const _allNavItems = <_NavItem>[
  _NavItem(label: 'Dashboard', icon: Icons.dashboard_rounded, route: '/admin/dashboard'),
  _NavItem(label: 'Questions', icon: Icons.quiz_rounded, route: '/admin/questions',
      requiredRoles: ['superAdmin', 'contentAdmin']),
  _NavItem(label: 'Mock Tests', icon: Icons.assignment_rounded, route: '/admin/mock-tests',
      requiredRoles: ['superAdmin', 'contentAdmin']),
  _NavItem(label: 'Study Materials', icon: Icons.menu_book_rounded, route: '/admin/materials',
      requiredRoles: ['superAdmin', 'contentAdmin']),
  _NavItem(label: 'Audio Books', icon: Icons.headphones_rounded, route: '/admin/audio-books',
      requiredRoles: ['superAdmin', 'contentAdmin']),
  _NavItem(label: 'Current Affairs', icon: Icons.newspaper_rounded, route: '/admin/current-affairs',
      requiredRoles: ['superAdmin', 'contentAdmin']),
  _NavItem(label: 'Daily Inspiration', icon: Icons.format_quote_rounded, route: '/admin/quotes',
      requiredRoles: ['superAdmin', 'contentAdmin']),
  _NavItem(label: 'Users', icon: Icons.people_rounded, route: '/admin/users'),
  _NavItem(label: 'Notifications', icon: Icons.notifications_rounded, route: '/admin/notifications',
      requiredRoles: ['superAdmin', 'contentAdmin']),
  _NavItem(label: 'Analytics', icon: Icons.analytics_rounded, route: '/admin/analytics'),
  _NavItem(label: 'Syllabus', icon: Icons.account_tree_rounded, route: '/admin/syllabus',
      requiredRoles: ['superAdmin', 'contentAdmin']),
  _NavItem(label: 'Previous Papers', icon: Icons.history_edu_rounded, route: '/admin/previous-papers',
      requiredRoles: ['superAdmin', 'contentAdmin']),
  _NavItem(label: 'Settings', icon: Icons.settings_rounded, route: '/admin/settings',
      requiredRoles: ['superAdmin']),
];

/// Sidebar collapsed state provider
final sidebarCollapsedProvider = StateProvider<bool>((ref) => false);

/// Admin sidebar navigation widget.
class AdminSidebar extends ConsumerWidget {
  final String currentRoute;
  final void Function(String route) onNavTap;

  const AdminSidebar({
    super.key,
    required this.currentRoute,
    required this.onNavTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isCollapsed = ref.watch(sidebarCollapsedProvider);
    final adminState = ref.watch(adminAuthProvider);
    final role = adminState.user?.role ?? '';
    final width = isCollapsed
        ? AdminConstants.sidebarCollapsedWidth
        : AdminConstants.sidebarExpandedWidth;

    final filteredItems = _allNavItems.where((item) {
      if (item.requiredRoles == null) return true;
      return item.requiredRoles!.contains(role);
    }).toList();

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width: width,
      decoration: const BoxDecoration(
        color: AdminTheme.navy,
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 8,
            offset: Offset(2, 0),
          ),
        ],
      ),
      child: Column(
        children: [
          // Logo area
          Container(
            height: AdminConstants.topBarHeight,
            padding: EdgeInsets.symmetric(horizontal: isCollapsed ? 8 : 20),
            alignment: isCollapsed ? Alignment.center : Alignment.centerLeft,
            child: isCollapsed
                ? const Icon(Icons.school_rounded, color: AdminTheme.saffron, size: 28)
                : Row(
                    children: [
                      const Icon(Icons.school_rounded, color: AdminTheme.saffron, size: 28),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'TNPSC Admin',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.95),
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
          ),
          Divider(color: Colors.white.withValues(alpha: 0.08), height: 1),
          const SizedBox(height: 8),
          // Navigation items
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              children: filteredItems.map((item) {
                final isActive = currentRoute.startsWith(item.route);
                return _SidebarItem(
                  icon: item.icon,
                  label: item.label,
                  isActive: isActive,
                  isCollapsed: isCollapsed,
                  onTap: () => onNavTap(item.route),
                );
              }).toList(),
            ),
          ),
          // Role badge
          if (!isCollapsed && adminState.user != null) ...[
            Divider(color: Colors.white.withValues(alpha: 0.08), height: 1),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 16,
                    backgroundColor: AdminTheme.saffron.withValues(alpha: 0.2),
                    child: Text(
                      (adminState.user!.name.isNotEmpty
                              ? adminState.user!.name[0]
                              : 'A')
                          .toUpperCase(),
                      style: const TextStyle(
                        color: AdminTheme.saffron,
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          adminState.user!.name,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        Container(
                          margin: const EdgeInsets.only(top: 2),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 1,
                          ),
                          decoration: BoxDecoration(
                            color: _roleBadgeColor(role).withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            _roleLabel(role),
                            style: TextStyle(
                              color: _roleBadgeColor(role),
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
          // Sign out + collapse toggle
          Padding(
            padding: const EdgeInsets.only(left: 8, right: 8, bottom: 12),
            child: Column(
              children: [
                _SidebarItem(
                  icon: Icons.logout_rounded,
                  label: 'Sign Out',
                  isActive: false,
                  isCollapsed: isCollapsed,
                  onTap: () => ref.read(adminAuthProvider.notifier).signOut(),
                  color: AdminTheme.error,
                ),
                const SizedBox(height: 4),
                _SidebarItem(
                  icon: isCollapsed
                      ? Icons.chevron_right_rounded
                      : Icons.chevron_left_rounded,
                  label: 'Collapse',
                  isActive: false,
                  isCollapsed: isCollapsed,
                  onTap: () => ref
                      .read(sidebarCollapsedProvider.notifier)
                      .state = !isCollapsed,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _roleBadgeColor(String role) {
    switch (role) {
      case 'superAdmin':
        return AdminTheme.saffron;
      case 'contentAdmin':
        return AdminTheme.info;
      case 'viewer':
        return AdminTheme.success;
      default:
        return AdminTheme.textSecondary;
    }
  }

  String _roleLabel(String role) {
    switch (role) {
      case 'superAdmin':
        return 'Super Admin';
      case 'contentAdmin':
        return 'Content Admin';
      case 'viewer':
        return 'Viewer';
      default:
        return role;
    }
  }
}

class _SidebarItem extends StatefulWidget {
  final IconData icon;
  final String label;
  final bool isActive;
  final bool isCollapsed;
  final VoidCallback onTap;
  final Color? color;

  const _SidebarItem({
    required this.icon,
    required this.label,
    required this.isActive,
    required this.isCollapsed,
    required this.onTap,
    this.color,
  });

  @override
  State<_SidebarItem> createState() => _SidebarItemState();
}

class _SidebarItemState extends State<_SidebarItem> {
  bool _hovering = false;

  @override
  Widget build(BuildContext context) {
    final activeColor = widget.color ?? AdminTheme.saffron;
    final bgColor = widget.isActive
        ? activeColor.withValues(alpha: 0.12)
        : _hovering
            ? Colors.white.withValues(alpha: 0.06)
            : Colors.transparent;

    return MouseRegion(
      onEnter: (_) => setState(() => _hovering = true),
      onExit: (_) => setState(() => _hovering = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          margin: const EdgeInsets.only(bottom: 2),
          padding: EdgeInsets.symmetric(
            horizontal: widget.isCollapsed ? 0 : 12,
            vertical: 10,
          ),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(10),
            border: widget.isActive
                ? Border(
                    left: BorderSide(color: activeColor, width: 3),
                  )
                : null,
          ),
          child: widget.isCollapsed
              ? Tooltip(
                  message: widget.label,
                  child: Center(
                    child: Icon(
                      widget.icon,
                      size: 20,
                      color: widget.isActive
                          ? activeColor
                          : Colors.white.withValues(alpha: 0.6),
                    ),
                  ),
                )
              : Row(
                  children: [
                    Icon(
                      widget.icon,
                      size: 20,
                      color: widget.isActive
                          ? activeColor
                          : Colors.white.withValues(alpha: 0.6),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        widget.label,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight:
                              widget.isActive ? FontWeight.w600 : FontWeight.w400,
                          color: widget.isActive
                              ? Colors.white
                              : Colors.white.withValues(alpha: 0.7),
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}
