import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/constants/admin_constants.dart';
import '../../core/theme/admin_theme.dart';
import '../../shared/widgets/admin_shell.dart';

final _fs = FirebaseFirestore.instance;

class AdminSettingsScreen extends ConsumerStatefulWidget {
  const AdminSettingsScreen({super.key});
  @override
  ConsumerState<AdminSettingsScreen> createState() => _AdminSettingsScreenState();
}

class _AdminSettingsScreenState extends ConsumerState<AdminSettingsScreen> {
  bool _loading = true, _saving = false;
  // App config
  bool _maintenanceMode = false, _registrationOpen = true, _aiEnabled = true;
  String _minVersion = '1.0.0';
  DateTime _examDate = DateTime(2026, 9, 20);
  int _defaultTestDuration = 90, _freeQuestionsPerDay = 10, _freeTestsPerMonth = 5, _freePdfLimit = 3;
  // Leaderboard
  String _resetDay = 'Monday';
  int _pointsPerCorrect = 10, _pointsPerTest = 50;
  bool _leaderboardEnabled = true;

  @override
  void initState() {
    super.initState();
    _loadConfig();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(adminPageTitleProvider.notifier).state = 'Settings';
    });
  }

  Future<void> _loadConfig() async {
    try {
      final doc = await _fs.collection(AdminConstants.adminConfigCollection).doc('app_settings').get();
      if (doc.exists) {
        final d = doc.data()!;
        setState(() {
          _maintenanceMode = d['maintenanceMode'] ?? false;
          _registrationOpen = d['registrationOpen'] ?? true;
          _aiEnabled = d['aiEnabled'] ?? true;
          _minVersion = d['minVersion'] ?? '1.0.0';
          _examDate = (d['examDate'] as Timestamp?)?.toDate() ?? _examDate;
          _defaultTestDuration = d['defaultTestDuration'] ?? 90;
          _freeQuestionsPerDay = d['freeQuestionsPerDay'] ?? 10;
          _freeTestsPerMonth = d['freeTestsPerMonth'] ?? 5;
          _freePdfLimit = d['freePdfLimit'] ?? 3;
          _resetDay = d['leaderboardResetDay'] ?? 'Monday';
          _pointsPerCorrect = d['pointsPerCorrect'] ?? 10;
          _pointsPerTest = d['pointsPerTest'] ?? 50;
          _leaderboardEnabled = d['leaderboardEnabled'] ?? true;
        });
      }
    } finally { setState(() => _loading = false); }
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    try {
      await _fs.collection(AdminConstants.adminConfigCollection).doc('app_settings').set({
        'maintenanceMode': _maintenanceMode, 'registrationOpen': _registrationOpen,
        'aiEnabled': _aiEnabled, 'minVersion': _minVersion,
        'examDate': Timestamp.fromDate(_examDate),
        'defaultTestDuration': _defaultTestDuration,
        'freeQuestionsPerDay': _freeQuestionsPerDay, 'freeTestsPerMonth': _freeTestsPerMonth,
        'freePdfLimit': _freePdfLimit,
        'leaderboardResetDay': _resetDay, 'pointsPerCorrect': _pointsPerCorrect,
        'pointsPerTest': _pointsPerTest, 'leaderboardEnabled': _leaderboardEnabled,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Settings saved!')));
    } finally { if (mounted) setState(() => _saving = false); }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Center(child: CircularProgressIndicator());
    return Container(constraints: const BoxConstraints(maxWidth: 700), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _section('App Configuration', [
        _toggle('Maintenance Mode', _maintenanceMode, (v) => setState(() => _maintenanceMode = v)),
        _toggle('Registration Open', _registrationOpen, (v) => setState(() => _registrationOpen = v)),
        _toggle('AI Chatbot Enabled', _aiEnabled, (v) => setState(() => _aiEnabled = v)),
        _textField('Min App Version', _minVersion, (v) => _minVersion = v),
      ]),
      const SizedBox(height: 24),
      _section('Content Settings', [
        _numberField('Default Test Duration (min)', _defaultTestDuration, (v) => _defaultTestDuration = v),
        _numberField('Free Questions/Day', _freeQuestionsPerDay, (v) => _freeQuestionsPerDay = v),
        _numberField('Free Tests/Month', _freeTestsPerMonth, (v) => _freeTestsPerMonth = v),
        _numberField('Free PDF Downloads', _freePdfLimit, (v) => _freePdfLimit = v),
      ]),
      const SizedBox(height: 24),
      _section('Leaderboard Settings', [
        _toggle('Leaderboard Enabled', _leaderboardEnabled, (v) => setState(() => _leaderboardEnabled = v)),
        _numberField('Points per Correct Answer', _pointsPerCorrect, (v) => _pointsPerCorrect = v),
        _numberField('Points per Test Completed', _pointsPerTest, (v) => _pointsPerTest = v),
      ]),
      const SizedBox(height: 32),
      ElevatedButton.icon(onPressed: _saving ? null : _save,
        icon: _saving ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
          : const Icon(Icons.save, size: 18),
        label: const Text('Save Settings')),
    ]));
  }

  Widget _section(String title, List<Widget> children) => Container(
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14), border: Border.all(color: AdminTheme.border)),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
      const SizedBox(height: 12),
      ...children,
    ]),
  );

  Widget _toggle(String label, bool value, void Function(bool) onChanged) => SwitchListTile(
    title: Text(label, style: const TextStyle(fontSize: 14)),
    value: value, onChanged: onChanged, activeThumbColor: AdminTheme.saffron, contentPadding: EdgeInsets.zero,
  );

  Widget _textField(String label, String value, void Function(String) onChanged) => Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: TextFormField(initialValue: value, decoration: InputDecoration(labelText: label), onChanged: onChanged),
  );

  Widget _numberField(String label, int value, void Function(int) onChanged) => Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: TextFormField(initialValue: '$value', decoration: InputDecoration(labelText: label),
      keyboardType: TextInputType.number, onChanged: (v) => onChanged(int.tryParse(v) ?? value)),
  );
}
