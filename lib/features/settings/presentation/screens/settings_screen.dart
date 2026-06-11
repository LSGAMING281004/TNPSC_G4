import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:share_plus/share_plus.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/language/language_extension.dart';
import '../../../../core/language/language_provider.dart';
import '../../../../core/providers/app_providers.dart';
import '../../../../shared/providers/app_providers.dart';
import '../widgets/language_settings_section.dart';

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
  bool _dailyReminder = true;
  TimeOfDay _reminderTime = const TimeOfDay(hour: 8, minute: 0);
  bool _examAlerts = true;
  int _questionsPerSession = 50;
  String _difficulty = 'Mixed';
  bool _timerSound = true;

  @override
  void initState() {
    super.initState();
    _initSettings();
    _initPackageInfo();
  }

  void _initSettings() {
    _settingsBox = Hive.box('settings_box');
    _fontSize = _settingsBox.get('fontSize', defaultValue: 'Medium');
    _dailyReminder = _settingsBox.get('dailyReminder', defaultValue: true);
    
    final storedHour = _settingsBox.get('reminderHour', defaultValue: 8);
    final storedMinute = _settingsBox.get('reminderMinute', defaultValue: 0);
    _reminderTime = TimeOfDay(hour: storedHour, minute: storedMinute);
    
    _examAlerts = _settingsBox.get('examAlerts', defaultValue: true);
    _questionsPerSession = _settingsBox.get('questionsPerSession', defaultValue: 50);
    _difficulty = _settingsBox.get('difficulty', defaultValue: 'Mixed');
    _timerSound = _settingsBox.get('timerSound', defaultValue: true);
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
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _reminderTime,
    );
    if (picked != null) {
      setState(() => _reminderTime = picked);
      _settingsBox.put('reminderHour', picked.hour);
      _settingsBox.put('reminderMinute', picked.minute);
    }
  }

  Future<void> _launchURL(String url) async {
    final uri = Uri.parse(url);
    final messenger = ScaffoldMessenger.of(context);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      messenger.showSnackBar(const SnackBar(content: Text('Could not open link')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeMode = ref.watch(themeModeProvider);
    final isDarkMode = ref.watch(isDarkModeProvider);
    ref.watch(languageNotifierProvider); // Rebuild on language change
    final l10n = context.l10n;

    final iconColor = isDarkMode ? AppColors.accentSaffron : AppColors.primaryNavy;
    final themeStr = switch (themeMode) {
      ThemeMode.light => 'Light',
      ThemeMode.dark => 'Dark',
      ThemeMode.system => 'System',
    };

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
                _dailyReminder = val;
                _saveSetting('dailyReminder', val);
              },
            ),
            if (_dailyReminder) ...[
              const Divider(height: 0),
              ListTile(
                leading: const Icon(Icons.access_time, color: Colors.transparent),
                title: const Text('Reminder Time'),
                trailing: Text(
                  _reminderTime.format(context),
                  style: const TextStyle(color: AppColors.accentSaffron, fontWeight: FontWeight.bold),
                ),
                onTap: _pickTime,
              ),
            ],
            const Divider(height: 0),
            SwitchListTile(
              title: const Text('Exam Countdown Alerts'),
              secondary: Icon(Icons.event, color: iconColor),
              value: _examAlerts,
              activeThumbColor: AppColors.accentSaffron,
              onChanged: (val) {
                _examAlerts = val;
                _saveSetting('examAlerts', val);
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
          ]),
          const SizedBox(height: 24),

          // 4. DATA & PRIVACY
          _buildSectionHeader(context, 'Data & Privacy', Icons.security),
          const SizedBox(height: 8),
          _buildCard(context, [
            ListTile(
              leading: Icon(Icons.delete_sweep, color: iconColor),
              title: const Text('Clear Cache'),
              onTap: () async {
                final messenger = ScaffoldMessenger.of(context);
                await Hive.box('bookmarks_box').clear();
                messenger.showSnackBar(const SnackBar(content: Text('Cache cleared successfully')));
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
              onTap: () {
                showDialog(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: const Text('Delete Account?'),
                    content: const Text('This action is irreversible and will delete all your data and progress.'),
                    actions: [
                      TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
                      TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Delete', style: TextStyle(color: Colors.red))),
                    ],
                  ),
                );
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
              trailing: Text(_appVersion, style: const TextStyle(color: Colors.grey)),
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
              onTap: () => _launchURL('https://example.com/privacy'),
            ),
            const Divider(height: 0),
            ListTile(
              leading: Icon(Icons.description, color: iconColor),
              title: const Text('Terms of Service'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => _launchURL('https://example.com/terms'),
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
              onTap: () => _launchURL('market://details?id=com.tnpsc.master'),
            ),
            const Divider(height: 0),
            ListTile(
              leading: Icon(Icons.share, color: iconColor),
              title: const Text('Share App'),
              onTap: () => Share.share('Check out TNPSC Master 2026! It\'s amazing for exam prep. Download: https://example.com/app'),
            ),
            const Divider(height: 0),
            ListTile(
              leading: Icon(Icons.bug_report, color: iconColor),
              title: const Text('Report a Bug'),
              onTap: () => _launchURL('mailto:support@example.com?subject=Bug Report: TNPSC Master $_appVersion'),
            ),
          ]),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title, IconData icon) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final color = isDark ? Colors.grey.shade400 : Colors.grey.shade600;
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
