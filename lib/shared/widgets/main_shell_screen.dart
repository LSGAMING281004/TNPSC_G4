import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// The main application shell that wraps the bottom navigation bar.
class MainShellScreen extends StatelessWidget {
  final Widget child;

  const MainShellScreen({super.key, required this.child});

  int _calculateSelectedIndex(BuildContext context) {
    final String location = GoRouterState.of(context).matchedLocation;
    if (location.startsWith('/home/dashboard')) return 0;
    if (location.startsWith('/home/tests')) return 1;
    if (location.startsWith('/home/materials')) return 2;
    if (location.startsWith('/home/current')) return 3;
    if (location.startsWith('/home/profile')) return 4;
    return 0; // Default to Home
  }

  void _onItemTapped(int index, BuildContext context) {
    switch (index) {
      case 0:
        context.go('/home/dashboard');
        break;
      case 1:
        context.go('/home/tests');
        break;
      case 2:
        context.go('/home/materials');
        break;
      case 3:
        context.go('/home/current');
        break;
      case 4:
        context.go('/home/profile');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: child,
      bottomNavigationBar: NavigationBar(
        selectedIndex: _calculateSelectedIndex(context),
        onDestinationSelected: (index) => _onItemTapped(index, context),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.house_outlined),
            selectedIcon: Icon(Icons.house),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.quiz_outlined),
            selectedIcon: Icon(Icons.quiz),
            label: 'Tests',
          ),
          NavigationDestination(
            icon: Icon(Icons.menu_book_outlined),
            selectedIcon: Icon(Icons.menu_book),
            label: 'Materials',
          ),
          NavigationDestination(
            icon: Icon(Icons.newspaper_outlined),
            selectedIcon: Icon(Icons.newspaper),
            label: 'Current Affairs',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outlined),
            selectedIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
