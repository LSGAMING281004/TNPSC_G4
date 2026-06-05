import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../constants/app_constants.dart';
// Conditional import is cleanest to prevent any potential platform runtime issues
// We can use dart:js dynamically or standard javascript interop.
import 'dart:js' as js;

class PwaService {
  static const String _pwaBoxName = 'pwa_settings';
  static const String _installedKey = 'pwa_installed_key';

  static Future<void> init() async {
    if (!kIsWeb) return;
    await Hive.openBox(_pwaBoxName);
  }

  static bool get isAlreadyInstalled {
    if (!kIsWeb) return false;
    final box = Hive.box(_pwaBoxName);
    return box.get(_installedKey, defaultValue: false) as bool;
  }

  static void markAsInstalled() {
    if (!kIsWeb) return;
    final box = Hive.box(_pwaBoxName);
    box.put(_installedKey, true);
  }

  static bool checkPromptAvailable() {
    if (!kIsWeb) return false;
    try {
      // Check if deferredPrompt is stored on window
      final hasPrompt = js.context.hasProperty('deferredPrompt') && 
          js.context['deferredPrompt'] != null;
      return hasPrompt;
    } catch (e) {
      debugPrint('Error checking PWA prompt: $e');
      return false;
    }
  }

  static Future<void> triggerInstallPrompt(BuildContext context) async {
    if (!kIsWeb) return;
    try {
      if (checkPromptAvailable()) {
        final deferredPrompt = js.context['deferredPrompt'];
        if (deferredPrompt != null) {
          // Trigger the install prompt
          js.context.callMethod('triggerPwaPrompt');
          markAsInstalled();
          
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${AppConstants.appName} install initiated!'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Installation is only available if supported by your browser.'),
          ),
        );
      }
    } catch (e) {
      debugPrint('Error triggering PWA install: $e');
    }
  }

  static void showInstallBannerIfNeeded(BuildContext context) {
    if (!kIsWeb || isAlreadyInstalled) return;

    // Wait for the window event
    Future.delayed(const Duration(seconds: 5), () {
      if (checkPromptAvailable()) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Row(
              children: [
                Icon(Icons.download, color: Colors.white),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Install ${AppConstants.appName} on your device for quick offline access!',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
            duration: const Duration(seconds: 10),
            backgroundColor: const Color(0xFF0B1E36),
            action: SnackBarAction(
              label: 'INSTALL',
              textColor: const Color(0xFFFFC107),
              onPressed: () => triggerInstallPrompt(context),
            ),
          ),
        );
      }
    });
  }
}
