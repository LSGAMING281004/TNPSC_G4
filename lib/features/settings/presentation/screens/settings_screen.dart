import 'dart:io';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/language/language_extension.dart';
import '../../../../core/language/language_provider.dart';
import '../../../../core/providers/app_providers.dart';
import '../../../../shared/providers/app_providers.dart';
import '../../../../core/services/push_notification_service.dart';
import '../../../../core/router/app_router.dart';
import '../../../auth/providers/auth_providers.dart';
import '../widgets/language_settings_section.dart';
import '../../../../shared/widgets/app_dialogs.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  String _appVersion = 'Loading...';
  late Box _settingsBox;

  // Local state for UI responsiveness before Hive sync
  String _fontSize = 'Medium';
  int _questionsPerSession = 50;
  String _difficulty = 'Mixed';
  bool _timerSound = true;
  bool _dailyReminder = true;
  bool _testAlerts = true;
  bool _currentAffairs = true;

  @override
  void initState() {
    super.initState();
    _initSettings();
    _initPackageInfo();
  }

  void _initSettings() {
    _settingsBox = Hive.box('settings_box');
    _fontSize = _settingsBox.get('fontSize', defaultValue: 'Medium');
    _questionsPerSession = _settingsBox.get('questionsPerSession', defaultValue: 50);
    _difficulty = _settingsBox.get('difficulty', defaultValue: 'Mixed');
    _timerSound = _settingsBox.get('timerSound', defaultValue: true);
    _dailyReminder = _settingsBox.get('notif_daily_reminder', defaultValue: true);
    _testAlerts = _settingsBox.get('notif_test_alerts', defaultValue: true);
    _currentAffairs = _settingsBox.get('notif_current_affairs', defaultValue: true);
  }

  Future<void> _initPackageInfo() async {
    final info = await PackageInfo.fromPlatform();
    if (mounted) {
      setState(() {
        _appVersion = 'v${info.version} (${info.buildNumber})';
      });
    }
  }

  void _saveSetting(String key, dynamic value) {
    _settingsBox.put(key, value);
    setState(() {}); // Rebuild UI
  }

  Future<void> _pickTime() async {
    final box = ref.read(settingsBoxProvider);
    final storedHour = box.get('reminder_hour', defaultValue: 8) as int;
    final storedMinute = box.get('reminder_minute', defaultValue: 0) as int;
    final initial = TimeOfDay(hour: storedHour, minute: storedMinute);
    
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: initial,
    );
    if (picked != null) {
      await box.put('reminder_hour', picked.hour);
      await box.put('reminder_minute', picked.minute);
      setState(() {});
    }
  }

  Future<void> _launchURL(String url) async {
    final uri = Uri.parse(url);
    final messenger = ScaffoldMessenger.of(context);
    try {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (_) {
      messenger.showSnackBar(const SnackBar(content: Text('Could not open link.')));
    }
  }

  String _formatBytes(int bytes) {
    if (bytes <= 0) return '0.0 KB';
    const suffixes = ['B', 'KB', 'MB', 'GB'];
    var i = (log(bytes) / log(1024)).floor();
    return '${(bytes / pow(1024, i)).toStringAsFixed(1)} ${suffixes[i]}';
  }

  @override
  Widget build(BuildContext context) {
    final themeMode = ref.watch(themeModeProvider);
    ref.watch(languageNotifierProvider); // Rebuild on language change
    final l10n = context.l10n;

    final iconColor = Theme.of(context).colorScheme.primary;
    final themeStr = switch (themeMode) {
      ThemeMode.light => 'Light',
      ThemeMode.dark => 'Dark',
      ThemeMode.system => 'System',
    };

    // Watch providers for reactive updates
    final dailyReminder = ref.watch(notifDailyReminderProvider);
    final testAlerts = ref.watch(notifTestAlertsProvider);
    final currentAffairs = ref.watch(notifCurrentAffairsProvider);
    final pdfQuality = ref.watch(pdfQualityProvider);

    final reminderHour = ref.watch(settingsBoxProvider).get('reminder_hour', defaultValue: 8) as int;
    final reminderMinute = ref.watch(settingsBoxProvider).get('reminder_minute', defaultValue: 0) as int;
    final reminderTime = TimeOfDay(hour: reminderHour, minute: reminderMinute);

    final cacheSizeAsync = ref.watch(cacheSizeProvider);
    final cacheSizeStr = cacheSizeAsync.when(
      data: (bytes) => _formatBytes(bytes),
      loading: () => 'Calculating...',
      error: (_, __) => '0.0 KB',
    );

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(l10n.settings),
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        children: [
          // 1. APPEARANCE
          _buildSectionHeader(context, 'Appearance', Icons.palette),
          const SizedBox(height: 8),
          const LanguageSettingsSection(),
          const SizedBox(height: 16),
          _buildCard(context, [
            ListTile(
              leading: Icon(Icons.dark_mode, color: iconColor),
              title: const Text('Theme'),
              trailing: DropdownButton<String>(
                value: themeStr,
                underline: const SizedBox(),
                items: const [
                  DropdownMenuItem(value: 'Light', child: Text('Light')),
                  DropdownMenuItem(value: 'Dark', child: Text('Dark')),
                  DropdownMenuItem(value: 'System', child: Text('System')),
                ],
                onChanged: (val) {
                  if (val == null) return;
                  final mode = switch (val) {
                    'Light' => ThemeMode.light,
                    'Dark' => ThemeMode.dark,
                    _ => ThemeMode.system,
                  };
                  ref.read(themeModeProvider.notifier).state = mode;
                  ref.read(settingsBoxProvider).put('themeMode', val.toLowerCase());
                },
              ),
            ),
            const Divider(height: 0),
            ListTile(
              leading: Icon(Icons.text_fields, color: iconColor),
              title: const Text('Font Size'),
              trailing: DropdownButton<String>(
                value: _fontSize,
                underline: const SizedBox(),
                items: const [
                  DropdownMenuItem(value: 'Small', child: Text('Small')),
                  DropdownMenuItem(value: 'Medium', child: Text('Medium')),
                  DropdownMenuItem(value: 'Large', child: Text('Large')),
                ],
                onChanged: (val) {
                  if (val != null) {
                    _fontSize = val;
                    _saveSetting('fontSize', val);
                  }
                },
              ),
            ),
          ]),
          const SizedBox(height: 24),

          // 2. NOTIFICATIONS
          _buildSectionHeader(context, 'Notifications', Icons.notifications),
          const SizedBox(height: 8),
          _buildCard(context, [
            SwitchListTile(
              title: const Text('Daily Study Reminder'),
              secondary: Icon(Icons.alarm, color: iconColor),
              value: _dailyReminder,
              activeThumbColor: AppColors.accentSaffron,
              onChanged: (val) {
                setState(() {
                  _dailyReminder = val;
                });
                ref.read(notifDailyReminderProvider.notifier).state = val;
                ref.read(settingsBoxProvider).put('notif_daily_reminder', val);
                if (val) {
                  PushNotificationService.subscribeToTopic('daily_reminder');
                } else {
                  PushNotificationService.unsubscribeFromTopic('daily_reminder');
                }
              },
            ),
            const Divider(height: 0),
            ListTile(
              enabled: _dailyReminder,
              leading: Icon(Icons.access_time, color: _dailyReminder ? iconColor : Theme.of(context).disabledColor),
              title: Text('Reminder Time', style: TextStyle(color: _dailyReminder ? null : Theme.of(context).disabledColor)),
              trailing: Text(
                MaterialLocalizations.of(context).formatTimeOfDay(reminderTime),
                style: TextStyle(
                  color: _dailyReminder ? AppColors.accentSaffron : Theme.of(context).disabledColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
              onTap: _dailyReminder ? _pickTime : null,
            ),
            const Divider(height: 0),
            SwitchListTile(
              title: const Text('Exam Countdown Alerts'),
              secondary: Icon(Icons.event, color: iconColor),
              value: _testAlerts,
              activeThumbColor: AppColors.accentSaffron,
              onChanged: (val) {
                setState(() {
                  _testAlerts = val;
                });
                ref.read(notifTestAlertsProvider.notifier).state = val;
                ref.read(settingsBoxProvider).put('notif_test_alerts', val);
                if (val) {
                  PushNotificationService.subscribeToTopic('test_alerts');
                } else {
                  PushNotificationService.unsubscribeFromTopic('test_alerts');
                }
              },
            ),
            const Divider(height: 0),
            SwitchListTile(
              title: const Text('Current Affairs Digest'),
              secondary: Icon(Icons.newspaper, color: iconColor),
              value: _currentAffairs,
              activeThumbColor: AppColors.accentSaffron,
              onChanged: (val) {
                setState(() {
                  _currentAffairs = val;
                });
                ref.read(notifCurrentAffairsProvider.notifier).state = val;
                ref.read(settingsBoxProvider).put('notif_current_affairs', val);
                if (val) {
                  PushNotificationService.subscribeToTopic('current_affairs');
                } else {
                  PushNotificationService.unsubscribeFromTopic('current_affairs');
                }
              },
            ),
          ]),
          const SizedBox(height: 24),

          // 3. STUDY PREFERENCES
          _buildSectionHeader(context, 'Study Preferences', Icons.menu_book),
          const SizedBox(height: 8),
          _buildCard(context, [
            ListTile(
              leading: Icon(Icons.format_list_numbered, color: iconColor),
              title: const Text('Questions per session'),
              trailing: DropdownButton<int>(
                value: _questionsPerSession,
                underline: const SizedBox(),
                items: [20, 50, 100].map((e) => DropdownMenuItem(value: e, child: Text('$e'))).toList(),
                onChanged: (val) {
                  if (val != null) {
                    _questionsPerSession = val;
                    _saveSetting('questionsPerSession', val);
                  }
                },
              ),
            ),
            const Divider(height: 0),
            ListTile(
              leading: Icon(Icons.trending_up, color: iconColor),
              title: const Text('Default Difficulty'),
              trailing: DropdownButton<String>(
                value: _difficulty,
                underline: const SizedBox(),
                items: ['Mixed', 'Easy', 'Medium', 'Hard'].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                onChanged: (val) {
                  if (val != null) {
                    _difficulty = val;
                    _saveSetting('difficulty', val);
                  }
                },
              ),
            ),
            const Divider(height: 0),
            SwitchListTile(
              title: const Text('Timer Sound'),
              secondary: Icon(Icons.volume_up, color: iconColor),
              value: _timerSound,
              activeThumbColor: AppColors.accentSaffron,
              onChanged: (val) {
                _timerSound = val;
                _saveSetting('timerSound', val);
              },
            ),
            const Divider(height: 0),
            ListTile(
              leading: Icon(Icons.picture_as_pdf, color: iconColor),
              title: const Text('PDF Download Quality'),
              trailing: DropdownButton<String>(
                value: pdfQuality,
                underline: const SizedBox(),
                items: const [
                  DropdownMenuItem(value: 'high', child: Text('High')),
                  DropdownMenuItem(value: 'low', child: Text('Low')),
                ],
                onChanged: (val) {
                  if (val != null) {
                    ref.read(pdfQualityProvider.notifier).state = val;
                    ref.read(settingsBoxProvider).put('pdf_quality', val);
                  }
                },
              ),
            ),
          ]),
          const SizedBox(height: 24),

          // 4. DATA & PRIVACY
          _buildSectionHeader(context, 'Data & Privacy', Icons.security),
          const SizedBox(height: 8),
          _buildCard(context, [
            ListTile(
              leading: Icon(Icons.delete_sweep, color: iconColor),
              title: const Text('Clear Cache'),
              trailing: Text(cacheSizeStr, style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant)),
              onTap: () async {
                final confirm = await showDialog<bool>(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: const Text('Clear Cache?'),
                    content: const Text('Downloaded study materials and audio will need to be re-downloaded.'),
                    actions: [
                      TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
                      TextButton(
                        onPressed: () => Navigator.pop(ctx, true),
                        child: const Text('Clear', style: TextStyle(color: Colors.red)),
                      ),
                    ],
                  ),
                );

                if (confirm == true) {
                  final bytesFreed = cacheSizeAsync.value ?? 0;
                  final formattedFreed = _formatBytes(bytesFreed);

                  // Clear temp dir
                  try {
                    final tempDir = await getTemporaryDirectory();
                    if (await tempDir.exists()) {
                      tempDir.listSync().forEach((entity) {
                        try {
                          entity.deleteSync(recursive: true);
                        } catch (_) {}
                      });
                    }
                  } catch (_) {}

                  // Clear cacheBox
                  await ref.read(cacheBoxProvider).clear();

                  // Clear downloaded_materials_box
                  final downloadedBox = Hive.box(AppConstants.downloadedMaterialsBox);
                  await downloadedBox.clear();

                  // Delete downloaded files from disk
                  try {
                    final appDir = await getApplicationDocumentsDirectory();
                    final downloadsDir = Directory('${appDir.path}/downloads');
                    if (await downloadsDir.exists()) {
                      await downloadsDir.delete(recursive: true);
                    }
                  } catch (_) {}

                  ref.invalidate(cacheSizeProvider);

                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Cache cleared ($formattedFreed freed)')),
                    );
                  }
                }
              },
            ),
            const Divider(height: 0),
            ListTile(
              leading: Icon(Icons.download, color: iconColor),
              title: const Text('Export my data (JSON)'),
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Exporting data to email... (Coming Soon)')));
              },
            ),
            const Divider(height: 0),
            ListTile(
              leading: const Icon(Icons.delete_forever, color: Colors.red),
              title: const Text('Delete Account', style: TextStyle(color: Colors.red)),
              onTap: () async {
                final confirmed = await showConfirmDialog(
                  context,
                  title: 'Delete Account?',
                  message: 'This action is irreversible. All your progress, test attempts, bookmarks, and conversations will be permanently deleted.',
                  confirmLabel: 'Proceed',
                  isDestructive: true,
                  icon: Icons.delete_forever,
                );
                if (confirmed && context.mounted) {
                  showDialog(
                    context: context,
                    barrierDismissible: false,
                    builder: (ctx) => const _DeleteAccountDialog(),
                  );
                }
              },
            ),
          ]),
          const SizedBox(height: 24),

          // 5. ABOUT
          _buildSectionHeader(context, 'About', Icons.info),
          const SizedBox(height: 8),
          _buildCard(context, [
            ListTile(
              leading: Icon(Icons.verified, color: iconColor),
              title: const Text('App Version'),
              trailing: Text(_appVersion, style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant)),
            ),
            const Divider(height: 0),
            ListTile(
              leading: Icon(Icons.gavel, color: iconColor),
              title: const Text('Licenses'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => showLicensePage(context: context, applicationName: 'TNPSC Master 2026', applicationVersion: _appVersion),
            ),
            const Divider(height: 0),
            ListTile(
              leading: Icon(Icons.privacy_tip, color: iconColor),
              title: const Text('Privacy Policy'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => _launchURL(AppConstants.privacyUrl),
            ),
            const Divider(height: 0),
            ListTile(
              leading: Icon(Icons.description, color: iconColor),
              title: const Text('Terms of Service'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => _launchURL(AppConstants.termsUrl),
            ),
          ]),
          const SizedBox(height: 24),

          // 6. SUPPORT
          _buildSectionHeader(context, 'Support', Icons.headset_mic),
          const SizedBox(height: 8),
          _buildCard(context, [
            ListTile(
              leading: const Icon(Icons.star, color: AppColors.accentSaffron),
              title: const Text('Rate Us'),
              onTap: () => _launchURL('market://details?id=${AppConstants.playStoreId}'),
            ),
            const Divider(height: 0),
            ListTile(
              leading: Icon(Icons.share, color: iconColor),
              title: const Text('Share App'),
              onTap: () => Share.share('Check out Thiral - TNPSC Group 4 Master 2026! It\'s amazing for exam prep. Download: https://play.google.com/store/apps/details?id=${AppConstants.playStoreId}'),
            ),
            const Divider(height: 0),
            ListTile(
              leading: Icon(Icons.bug_report, color: iconColor),
              title: const Text('Report a Bug'),
              onTap: () => _launchURL('mailto:${AppConstants.supportEmail}?subject=Bug Report: Thiral $_appVersion'),
            ),
          ]),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title, IconData icon) {
    final color = Theme.of(context).colorScheme.onSurfaceVariant;
    return Row(
      children: [
        Icon(icon, size: 20, color: color),
        const SizedBox(width: 8),
        Text(title, style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: color)),
      ],
    );
  }

  Widget _buildCard(BuildContext context, List<Widget> children) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF152A4A) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: isDark ? Colors.black.withValues(alpha: 0.2) : Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(children: children),
    );
  }
}

class _DeleteAccountDialog extends ConsumerStatefulWidget {
  const _DeleteAccountDialog();

  @override
  ConsumerState<_DeleteAccountDialog> createState() => _DeleteAccountDialogState();
}

class _DeleteAccountDialogState extends ConsumerState<_DeleteAccountDialog> {
  bool _isLoading = false;
  int _attempts = 0;
  String? _errorMessage;
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleDelete() async {
    final authRepo = ref.read(authRepositoryProvider);
    final user = authRepo.currentUser;
    if (user == null) {
      Navigator.pop(context);
      return;
    }

    if (_attempts >= 3) {
      setState(() {
        _errorMessage = 'Too many attempts, please try again later.';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    showLoadingDialog(context, message: 'Deleting account...');

    try {
      final providers = user.providerData.map((p) => p.providerId).toList();
      final isEmailUser = providers.contains('password');

      String? password;
      if (isEmailUser) {
        password = _passwordController.text.trim();
        if (password.isEmpty) {
          throw Exception('Password is required to delete your account.');
        }
      }

      await authRepo.deleteAccount(password: password);

      if (mounted) {
        hideLoadingDialog(context);
        Navigator.pop(context); // close dialog
        context.go(AppRoutes.login);
      }
    } catch (e) {
      _attempts++;
      if (mounted) {
        hideLoadingDialog(context);
      }
      setState(() {
        _isLoading = false;
        _errorMessage = e.toString().replaceAll('Exception:', '').trim();
        if (_attempts >= 3) {
          _errorMessage = 'Too many attempts, please try again later.';
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final authRepo = ref.read(authRepositoryProvider);
    final user = authRepo.currentUser;
    if (user == null) return const SizedBox.shrink();

    final providers = user.providerData.map((p) => p.providerId).toList();
    final isEmailUser = providers.contains('password');
    final isGoogleUser = providers.contains('google.com');

    return AlertDialog(
      title: const Text('Delete Account?'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'This action is irreversible. All your progress, test attempts, bookmarks, and AI conversations will be permanently deleted.',
              style: TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 16),
            if (isEmailUser) ...[
              const Text(
                'Please enter your password to confirm:',
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _passwordController,
                obscureText: _obscurePassword,
                decoration: InputDecoration(
                  labelText: 'Password',
                  border: const OutlineInputBorder(),
                  suffixIcon: IconButton(
                    icon: Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility),
                    onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                  ),
                ),
                enabled: !_isLoading && _attempts < 3,
              ),
              const SizedBox(height: 8),
            ] else if (isGoogleUser) ...[
              const Text(
                'Confirming will prompt Google Re-Authentication.',
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: AppColors.accentSaffron),
              ),
              const SizedBox(height: 8),
            ],
            if (_errorMessage != null) ...[
              Text(
                _errorMessage!,
                style: const TextStyle(color: Colors.red, fontSize: 13, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 8),
            ],
            if (_isLoading) ...[
              const SizedBox(height: 12),
              const Center(
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: AppColors.accentSaffron,
                ),
              ),
            ]
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: (_isLoading || _attempts >= 3) ? null : _handleDelete,
          child: const Text('Delete', style: TextStyle(color: Colors.red)),
        ),
      ],
    );
  }
}
