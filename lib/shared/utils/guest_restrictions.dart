import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/router/app_router.dart';
import '../providers/app_providers.dart';

/// Utility to check and restrict guest users from accessing authenticated-only features.
class GuestRestrictions {
  /// Checks if the current user is a guest.
  static bool isGuest(WidgetRef ref) {
    final user = ref.read(currentUserProvider);
    // Guest user has empty email
    return user == null || user.email.isEmpty;
  }

  /// Checks if action is allowed. If not, displays a Dialog and returns false.
  static bool check(BuildContext context, WidgetRef ref, {required String featureName}) {
    if (!isGuest(ref)) return true;

    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            const Icon(Icons.lock_outline, color: Colors.orange, size: 28),
            const SizedBox(width: 10),
            Text('Sign In Required'),
          ],
        ),
        content: Text(
          'The "$featureName" feature is not available for Guest users. Please Sign In with Google or Email to unlock this and track your progress.',
          style: const TextStyle(fontSize: 14, height: 1.4),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: () {
              Navigator.pop(context);
              // Cleanly navigate to login screen
              context.go(AppRoutes.login);
            },
            child: const Text('Sign In'),
          ),
        ],
      ),
    );

    return false;
  }
}
