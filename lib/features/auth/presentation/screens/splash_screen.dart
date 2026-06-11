import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../providers/auth_providers.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkAuthState();
  }

  Future<void> _checkAuthState() async {
    // Wait for animation to finish
    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) return;

    final box = Hive.box('settings_box');
    final onboardingDone = box.get('onboarding_done', defaultValue: false) as bool;
    
    // Check if user is logged in via Riverpod provider
    final user = ref.read(currentUserProvider);

    if (!onboardingDone) {
      context.go('/onboarding');
    } else if (user == null) {
      context.go('/login');
    } else {
      context.go('/home/dashboard');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Thiral Flame Logo (simplified as icon for now)
            const Icon(
              Icons.local_fire_department,
              size: 100,
              color: Color(0xFFF07020),
            ).animate()
             .scale(duration: 800.ms, curve: Curves.easeOutBack)
             .fadeIn(duration: 800.ms)
             .shimmer(delay: 800.ms, duration: 1000.ms),
            
            const SizedBox(height: 24),
            
            Text(
              'THIRAL',
              style: Theme.of(context).textTheme.displayMedium?.copyWith(
                color: Theme.of(context).colorScheme.primary,
                letterSpacing: 2,
              ),
            ).animate().fadeIn(delay: 400.ms, duration: 800.ms),
            
            const SizedBox(height: 8),
            
            Text(
              'TNPSC Group 4 Master',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
              ),
            ).animate().fadeIn(delay: 600.ms, duration: 800.ms),
          ],
        ),
      ),
    );
  }
}
