import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/admin_constants.dart';
import '../../core/theme/admin_theme.dart';
import '../../shared/services/admin_activity_log_service.dart';
import '../../shared/widgets/admin_shell.dart';

class CreateMockTestScreen extends ConsumerStatefulWidget {
  final String? testId;
  const CreateMockTestScreen({super.key, this.testId});
  @override
  ConsumerState<CreateMockTestScreen> createState() => _CreateMockTestScreenState();
}

class _CreateMockTestScreenState extends ConsumerState<CreateMockTestScreen> {
  final _formKey = GlobalKey<FormState>();
  final _fs = FirebaseFirestore.instance;
  bool _saving = false;

  String _titleTa = '', _titleEn = '';
  String _type = 'Full Mock';
  String? _subject;
  int _duration = 90, _totalQ = 100, _passingScore = 40;
  double _easyPct = 30, _medPct = 50, _hardPct = 20;
  String _status = 'Draft';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(adminPageTitleProvider.notifier).state = 'Create Mock Test';
    });
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    try {
      final data = {
        'title_ta': _titleTa, 'title_en': _titleEn,
        'type': _type, 'subject': _subject,
        'durationMinutes': _duration, 'totalQuestions': _totalQ,
        'questionIds': [], 'difficultyDist': {'Easy': _easyPct.round(), 'Medium': _medPct.round(), 'Hard': _hardPct.round()},
        'passingScore': _passingScore, 'status': _status,
        'createdBy': FirebaseAuth.instance.currentUser?.uid,
        'createdAt': FieldValue.serverTimestamp(),
      };
      await _fs.collection(AdminConstants.mockTestsCollection).add(data);
      await AdminActivityLogService.log(action: 'Created mock test', targetCollection: AdminConstants.mockTestsCollection);
      if (mounted) context.go('/admin/mock-tests');
    } finally { if (mounted) setState(() => _saving = false); }
  }

  @override
  Widget build(BuildContext context) {
    return Container(constraints: const BoxConstraints(maxWidth: 700), child: Form(key: _formKey,
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        TextFormField(decoration: const InputDecoration(labelText: 'Test Name (Tamil)'), onChanged: (v) => _titleTa = v, validator: (v) => v!.isEmpty ? 'Required' : null),
        const SizedBox(height: 12),
        TextFormField(decoration: const InputDecoration(labelText: 'Test Name (English)'), onChanged: (v) => _titleEn = v, validator: (v) => v!.isEmpty ? 'Required' : null),
        const SizedBox(height: 16),
        Wrap(spacing: 12, runSpacing: 12, children: [
          SizedBox(width: 200, child: DropdownButtonFormField<String>(initialValue: _type, decoration: const InputDecoration(labelText: 'Test Type'),
            items: AdminConstants.testTypes.map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(),
            onChanged: (v) => setState(() => _type = v!))),
          if (_type != 'Full Mock') SizedBox(width: 200, child: DropdownButtonFormField<String>(initialValue: _subject, decoration: const InputDecoration(labelText: 'Subject'),
            items: AdminConstants.defaultSubjects.map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
            onChanged: (v) => setState(() => _subject = v))),
          SizedBox(width: 130, child: TextFormField(initialValue: '$_duration', decoration: const InputDecoration(labelText: 'Duration (min)'),
            keyboardType: TextInputType.number, onChanged: (v) => _duration = int.tryParse(v) ?? 90)),
          SizedBox(width: 130, child: TextFormField(initialValue: '$_totalQ', decoration: const InputDecoration(labelText: 'Total Qs'),
            keyboardType: TextInputType.number, onChanged: (v) => _totalQ = int.tryParse(v) ?? 100)),
          SizedBox(width: 130, child: TextFormField(initialValue: '$_passingScore', decoration: const InputDecoration(labelText: 'Pass %'),
            keyboardType: TextInputType.number, onChanged: (v) => _passingScore = int.tryParse(v) ?? 40)),
        ]),
        const SizedBox(height: 20),
        const Text('Difficulty Distribution', style: TextStyle(fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        _slider('Easy', _easyPct, AdminTheme.success, (v) => setState(() { _easyPct = v; _hardPct = (100 - _easyPct - _medPct).clamp(0, 100); })),
        _slider('Medium', _medPct, AdminTheme.warning, (v) => setState(() { _medPct = v; _hardPct = (100 - _easyPct - _medPct).clamp(0, 100); })),
        _slider('Hard', _hardPct, AdminTheme.error, null),
        const SizedBox(height: 16),
        DropdownButtonFormField<String>(initialValue: _status, decoration: const InputDecoration(labelText: 'Status'),
          items: AdminConstants.testStatuses.map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
          onChanged: (v) => setState(() => _status = v!)),
        const SizedBox(height: 32),
        Row(children: [
          OutlinedButton(onPressed: () => context.go('/admin/mock-tests'), child: const Text('Cancel')),
          const SizedBox(width: 12),
          ElevatedButton(onPressed: _saving ? null : _save, child: _saving
            ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
            : const Text('Create Test')),
        ]),
      ])));
  }

  Widget _slider(String label, double val, Color c, void Function(double)? onChanged) => Padding(
    padding: const EdgeInsets.only(bottom: 4),
    child: Row(children: [
      SizedBox(width: 60, child: Text(label, style: TextStyle(color: c, fontWeight: FontWeight.w600, fontSize: 13))),
      Expanded(child: Slider(value: val, min: 0, max: 100, divisions: 20, activeColor: c,
        onChanged: onChanged, label: '${val.round()}%')),
      SizedBox(width: 40, child: Text('${val.round()}%', textAlign: TextAlign.right, style: const TextStyle(fontSize: 13))),
    ]),
  );
}
