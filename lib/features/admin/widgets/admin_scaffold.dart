import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_colors.dart';

class AdminScaffold extends StatelessWidget {
  final Widget child;
  final String currentLocation;

  const AdminScaffold({super.key, required this.child, required this.currentLocation});

  int _getSelectedIndex() {
    if (currentLocation.contains('/admin/questions')) return 1;
    if (currentLocation.contains('/admin/current_affairs')) return 2;
    if (currentLocation.contains('/admin/users')) return 3;
    if (currentLocation.contains('/admin/notifications')) return 4;
    return 0; // dashboard
  }

  void _onNavigate(BuildContext context, int index) {
    switch (index) {
      case 0:
        context.go('/admin');
        break;
      case 1:
        context.go('/admin/questions');
        break;
      case 2:
        context.go('/admin/current_affairs');
        break;
      case 3:
        context.go('/admin/users');
        break;
      case 4:
        context.go('/admin/notifications');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    // Platform restriction
    if (!kIsWeb) {
      return Scaffold(
        appBar: AppBar(title: const Text('Access Denied')),
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.desktop_windows, size: 64, color: Colors.grey),
              const SizedBox(height: 16),
              const Text('The Admin Console is only accessible via Web.', style: TextStyle(fontSize: 18)),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => context.go('/'),
                child: const Text('Return Home'),
              ),
            ],
          ),
        ),
      );
    }

    final isLargeScreen = MediaQuery.of(context).size.width >= 800;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: isLargeScreen ? null : AppBar(
        title: const Text('Admin Console'),
        backgroundColor: isDark ? const Color(0xFF0F2038) : AppColors.primaryNavy,
      ),
      drawer: isLargeScreen ? null : _buildDrawer(context),
      body: Row(
        children: [
          if (isLargeScreen)
            NavigationRail(
              backgroundColor: AppColors.primaryNavy,
              selectedIconTheme: const IconThemeData(color: AppColors.accentSaffron),
              unselectedIconTheme: const IconThemeData(color: Colors.white70),
              selectedLabelTextStyle: const TextStyle(color: AppColors.accentSaffron, fontWeight: FontWeight.bold),
              unselectedLabelTextStyle: const TextStyle(color: Colors.white70),
              indicatorColor: AppColors.accentSaffron.withValues(alpha: 0.2),
              extended: true,
              selectedIndex: _getSelectedIndex(),
              onDestinationSelected: (index) => _onNavigate(context, index),
              leading: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    const Icon(Icons.admin_panel_settings, color: Colors.white, size: 32),
                    const SizedBox(width: 8),
                    const Text('TNPSC Admin', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
              destinations: const [
                NavigationRailDestination(icon: Icon(Icons.dashboard), label: Text('Dashboard')),
                NavigationRailDestination(icon: Icon(Icons.library_books), label: Text('Questions')),
                NavigationRailDestination(icon: Icon(Icons.public), label: Text('Current Affairs')),
                NavigationRailDestination(icon: Icon(Icons.people), label: Text('Users')),
                NavigationRailDestination(icon: Icon(Icons.notifications), label: Text('Notifications')),
              ],
            ),
          const VerticalDivider(thickness: 1, width: 1, color: Colors.black12),
          Expanded(child: child),
        ],
      ),
    );
  }

  Widget _buildDrawer(BuildContext context) {
    return Drawer(
      backgroundColor: AppColors.primaryNavy,
      child: ListView(
        children: [
          const DrawerHeader(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.admin_panel_settings, color: Colors.white, size: 48),
                SizedBox(height: 8),
                Text('TNPSC Admin', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
          _drawerItem(context, 0, Icons.dashboard, 'Dashboard'),
          _drawerItem(context, 1, Icons.library_books, 'Questions'),
          _drawerItem(context, 2, Icons.public, 'Current Affairs'),
          _drawerItem(context, 3, Icons.people, 'Users'),
          _drawerItem(context, 4, Icons.notifications, 'Notifications'),
        ],
      ),
    );
  }

  Widget _drawerItem(BuildContext context, int index, IconData icon, String title) {
    final isSelected = _getSelectedIndex() == index;
    return ListTile(
      leading: Icon(icon, color: isSelected ? AppColors.accentSaffron : Colors.white70),
      title: Text(title, style: TextStyle(color: isSelected ? AppColors.accentSaffron : Colors.white70, fontWeight: isSelected ? FontWeight.bold : FontWeight.normal)),
      onTap: () {
        Navigator.pop(context); // close drawer
        _onNavigate(context, index);
      },
    );
  }
}
