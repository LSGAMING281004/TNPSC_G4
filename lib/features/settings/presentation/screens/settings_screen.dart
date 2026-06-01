import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../shared/providers/app_providers.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDarkMode = ref.watch(isDarkModeProvider);
    final language = ref.watch(languageProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Settings'), backgroundColor: AppColors.primaryNavy),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _SectionTitle('Appearance'),
          Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            child: Column(children: [
              SwitchListTile(
                title: const Text('Dark Mode'),
                subtitle: const Text('இருள் பயன்முறை'),
                secondary: const Icon(Icons.dark_mode),
                value: isDarkMode,
                activeThumbColor: AppColors.accentSaffron,
                onChanged: (v) {
                  ref.read(isDarkModeProvider.notifier).state = v;
                  ref.read(settingsBoxProvider).put('isDarkMode', v);
                },
              ),
              const Divider(height: 0),
              ListTile(
                leading: const Icon(Icons.language),
                title: const Text('Language'),
                subtitle: const Text('மொழி'),
                trailing: DropdownButton<String>(
                  value: language,
                  underline: const SizedBox(),
                  items: const [
                    DropdownMenuItem(value: 'en', child: Text('English')),
                    DropdownMenuItem(value: 'ta', child: Text('தமிழ்')),
                    DropdownMenuItem(value: 'both', child: Text('Both')),
                  ],
                  onChanged: (v) {
                    ref.read(languageProvider.notifier).state = v!;
                    ref.read(settingsBoxProvider).put('language', v);
                  },
                ),
              ),
            ]),
          ),
          const SizedBox(height: 16),
          _SectionTitle('Notifications'),
          Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            child: Column(children: [
              SwitchListTile(title: const Text('Daily Study Reminder'), value: true, activeThumbColor: AppColors.accentSaffron, onChanged: (v) {}),
              const Divider(height: 0),
              SwitchListTile(title: const Text('New Test Alerts'), value: true, activeThumbColor: AppColors.accentSaffron, onChanged: (v) {}),
              const Divider(height: 0),
              SwitchListTile(title: const Text('Current Affairs Digest'), value: true, activeThumbColor: AppColors.accentSaffron, onChanged: (v) {}),
              const Divider(height: 0),
              ListTile(
                leading: const Icon(Icons.access_time),
                title: const Text('Reminder Time'),
                trailing: const Text('8:00 AM', style: TextStyle(color: AppColors.accentSaffron, fontWeight: FontWeight.w600)),
                onTap: () {},
              ),
            ]),
          ),
          const SizedBox(height: 16),
          _SectionTitle('Downloads'),
          Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            child: Column(children: [
              ListTile(
                leading: const Icon(Icons.high_quality),
                title: const Text('PDF Quality'),
                trailing: DropdownButton<String>(
                  value: 'High', underline: const SizedBox(),
                  items: const [DropdownMenuItem(value: 'Low', child: Text('Low')), DropdownMenuItem(value: 'High', child: Text('High'))],
                  onChanged: (v) {},
                ),
              ),
              const Divider(height: 0),
              ListTile(
                leading: const Icon(Icons.delete_sweep),
                title: const Text('Clear Cache'),
                subtitle: const Text('45 MB used'),
                trailing: TextButton(onPressed: () {}, child: const Text('Clear', style: TextStyle(color: AppColors.error))),
              ),
            ]),
          ),
          const SizedBox(height: 16),
          _SectionTitle('Legal'),
          Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            child: Column(children: [
              ListTile(leading: const Icon(Icons.privacy_tip), title: const Text('Privacy Policy'), trailing: const Icon(Icons.chevron_right, size: 20), onTap: () {}),
              const Divider(height: 0),
              ListTile(leading: const Icon(Icons.description), title: const Text('Terms of Service'), trailing: const Icon(Icons.chevron_right, size: 20), onTap: () {}),
            ]),
          ),
          const SizedBox(height: 16),
          _SectionTitle('Account'),
          Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            child: ListTile(
              leading: const Icon(Icons.delete_forever, color: AppColors.error),
              title: const Text('Delete Account', style: TextStyle(color: AppColors.error)),
              onTap: () => showDialog(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: const Text('Delete Account?'),
                  content: const Text('This action is irreversible. All your data will be permanently deleted.'),
                  actions: [
                    TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
                    TextButton(onPressed: () {}, child: const Text('Delete', style: TextStyle(color: AppColors.error))),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),
          Center(child: Text('v1.0.0', style: TextStyle(color: Colors.grey.shade400))),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle(this.title);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(title, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.grey.shade600)),
    );
  }
}
