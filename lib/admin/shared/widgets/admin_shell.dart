import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'admin_sidebar.dart';
import 'admin_top_bar.dart';

/// Provider to track the current page title for the top bar.
final adminPageTitleProvider = StateProvider<String>((ref) => 'Dashboard');

/// Admin shell layout: sidebar + top bar + content area.
class AdminShell extends ConsumerStatefulWidget {
  final Widget child;

  const AdminShell({super.key, required this.child});

  @override
  ConsumerState<AdminShell> createState() => _AdminShellState();
}

class _AdminShellState extends ConsumerState<AdminShell> {
  bool _hasAutoCollapsed = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final screenWidth = MediaQuery.of(context).size.width;
      final isMobile = screenWidth < 800;

      if (screenWidth < 900 && !isMobile && !_hasAutoCollapsed) {
        ref.read(sidebarCollapsedProvider.notifier).state = true;
        _hasAutoCollapsed = true;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final pageTitle = ref.watch(adminPageTitleProvider);
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 800;

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
                      physics: const AlwaysScrollableScrollPhysics(),
                      primary: false,
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(minHeight: 0),
                        child: widget.child,
                      ),
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
