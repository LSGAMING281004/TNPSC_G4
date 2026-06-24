import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'admin_sidebar.dart';
import 'admin_top_bar.dart';

/// Provider to track the current page title for the top bar.
final adminPageTitleProvider = StateProvider<String>((ref) => 'Dashboard');

/// Admin shell layout: sidebar + top bar + content area.
class AdminShell extends ConsumerWidget {
  final Widget child;

  const AdminShell({super.key, required this.child});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pageTitle = ref.watch(adminPageTitleProvider);
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 800;

    // Auto-collapse sidebar on smaller screens
    if (screenWidth < 900 && !isMobile) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref.read(sidebarCollapsedProvider.notifier).state = true;
      });
    }

    return Scaffold(
      drawer: isMobile
          ? Drawer(
              child: AdminSidebar(
                currentRoute: GoRouterState.of(context).matchedLocation,
                onNavTap: (route) {
                  Navigator.of(context).pop(); // Close the drawer
                  context.go(route);
                },
              ),
            )
          : null,
      body: Row(
        children: [
          if (!isMobile)
            AdminSidebar(
              currentRoute: GoRouterState.of(context).matchedLocation,
              onNavTap: (route) => context.go(route),
            ),
          Expanded(
            child: Column(
              children: [
                AdminTopBar(title: pageTitle),
                Expanded(
                  child: Container(
                    color: const Color(0xFFF5F7FA),
                    child: SingleChildScrollView(
                      padding: EdgeInsets.all(isMobile ? 16 : 24),
                      child: child,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
