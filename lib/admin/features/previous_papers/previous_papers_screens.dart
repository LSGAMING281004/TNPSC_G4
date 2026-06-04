import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:file_picker/file_picker.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/admin_constants.dart';
import '../../../core/constants/app_constants.dart';
import '../../core/theme/admin_theme.dart';
import '../../shared/services/admin_activity_log_service.dart';
import '../../shared/widgets/admin_empty_state.dart';
import '../../shared/widgets/admin_shell.dart';

final _fs = FirebaseFirestore.instance;

final prevPapersProvider = StreamProvider<List<Map<String, dynamic>>>((ref) {
  return _fs.collection(AdminConstants.previousPapersCollection)
      .orderBy('year', descending: true).snapshots()
      .map((s) => s.docs.map((d) => {'id': d.id, ...d.data()}).toList());
});

class PreviousPapersScreen extends ConsumerStatefulWidget {
  const PreviousPapersScreen({super.key});
  @override
  ConsumerState<PreviousPapersScreen> createState() => _PreviousPapersScreenState();
}

class _PreviousPapersScreenState extends ConsumerState<PreviousPapersScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(adminPageTitleProvider.notifier).state = 'Previous Papers';
    });
  }

  @override
  Widget build(BuildContext context) {
    final pAsync = ref.watch(prevPapersProvider);
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      ElevatedButton.icon(onPressed: () => context.go('/admin/previous-papers/add'),
        icon: const Icon(Icons.add, size: 18), label: const Text('Add Paper')),
      const SizedBox(height: 16),
      pAsync.when(
        data: (papers) {
          if (papers.isEmpty) return const AdminEmptyState(icon: Icons.history_edu_outlined, message: 'No previous papers uploaded yet.');
          // Group by year
          final grouped = <int, List<Map<String, dynamic>>>{};
          for (final p in papers) {
            final year = p['year'] ?? 0;
            grouped.putIfAbsent(year, () => []).add(p);
          }
          return Column(children: grouped.entries.map((entry) => Container(
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: AdminTheme.border)),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Container(padding: const EdgeInsets.all(14), decoration: BoxDecoration(color: AdminTheme.background, borderRadius: const BorderRadius.vertical(top: Radius.circular(12))),
                child: Text('${entry.key}', style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16))),
              ...entry.value.map((p) => ListTile(
                leading: const Icon(Icons.picture_as_pdf, color: AdminTheme.error),
                title: Text('${p['subject'] ?? 'Full'} — ${p['part'] ?? 'Full'}'),
                subtitle: Text('${p['totalQuestions'] ?? 0} questions • ${p['duration'] ?? 0} min'),
                trailing: IconButton(icon: const Icon(Icons.delete_outline, size: 18, color: AdminTheme.error),
                  onPressed: () async {
                    if (p['storageRef'] != null) {
                      try {
                        await Supabase.instance.client.storage
                            .from(AppConstants.supabaseMediaBucket)
                            .remove([p['storageRef']]);
                      } catch (_) {}
                    }
                    await _fs.collection(AdminConstants.previousPapersCollection).doc(p['id']).delete();
                  }),
              )),
            ]),
          )).toList());
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
    ]);
  }
}

class AddPaperScreen extends ConsumerStatefulWidget {
  const AddPaperScreen({super.key});
  @override
  ConsumerState<AddPaperScreen> createState() => _AddPaperScreenState();
}

class _AddPaperScreenState extends ConsumerState<AddPaperScreen> {
  final _formKey = GlobalKey<FormState>();
  int _year = DateTime.now().year - 1;
  String _subject = 'Full Paper', _part = 'Full';
  int _totalQ = 200, _totalMarks = 300, _duration = 180;
  PlatformFile? _pdf;
  bool _uploading = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(adminPageTitleProvider.notifier).state = 'Add Previous Paper';
    });
  }

  Future<void> _pickPdf() async {
    final r = await FilePicker.platform.pickFiles(type: FileType.custom, allowedExtensions: ['pdf'], withData: true);
    if (r != null && r.files.isNotEmpty) setState(() => _pdf = r.files.first);
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate() || _pdf == null) return;
    setState(() => _uploading = true);
    try {
      final path = '${AdminConstants.previousPapersPath}/$_year/${DateTime.now().millisecondsSinceEpoch}.pdf';
      
      await Supabase.instance.client.storage
          .from(AppConstants.supabaseMediaBucket)
          .uploadBinary(
            path,
            _pdf!.bytes!,
            fileOptions: const FileOptions(contentType: 'application/pdf', upsert: true),
          );
          
      final url = Supabase.instance.client.storage
          .from(AppConstants.supabaseMediaBucket)
          .getPublicUrl(path);
          
      await _fs.collection(AdminConstants.previousPapersCollection).add({
        'year': _year, 'subject': _subject, 'part': _part,
        'totalQuestions': _totalQ, 'totalMarks': _totalMarks, 'duration': _duration,
        'storageRef': path, 'downloadUrl': url, 'downloadCount': 0,
        'uploadedBy': FirebaseAuth.instance.currentUser?.uid,
        'uploadedAt': FieldValue.serverTimestamp(),
      });
      await AdminActivityLogService.log(action: 'Added previous paper', targetCollection: AdminConstants.previousPapersCollection);
      if (mounted) context.go('/admin/previous-papers');
    } finally { if (mounted) setState(() => _uploading = false); }
  }

  @override
  Widget build(BuildContext context) {
    return Container(constraints: const BoxConstraints(maxWidth: 500), child: Form(key: _formKey,
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        TextFormField(initialValue: '$_year', decoration: const InputDecoration(labelText: 'Year'), keyboardType: TextInputType.number,
          onChanged: (v) => _year = int.tryParse(v) ?? _year, validator: (v) => v!.isEmpty ? 'Required' : null),
        const SizedBox(height: 12),
        DropdownButtonFormField<String>(initialValue: _subject, decoration: const InputDecoration(labelText: 'Subject'),
          items: ['Full Paper', 'Tamil', 'General Studies', 'Aptitude'].map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
          onChanged: (v) => setState(() => _subject = v!)),
        const SizedBox(height: 12),
        DropdownButtonFormField<String>(initialValue: _part, decoration: const InputDecoration(labelText: 'Part'),
          items: ['Full', 'Part A', 'Part B'].map((p) => DropdownMenuItem(value: p, child: Text(p))).toList(),
          onChanged: (v) => setState(() => _part = v!)),
        const SizedBox(height: 12),
        Row(children: [
          Expanded(child: TextFormField(initialValue: '$_totalQ', decoration: const InputDecoration(labelText: 'Questions'), keyboardType: TextInputType.number, onChanged: (v) => _totalQ = int.tryParse(v) ?? _totalQ)),
          const SizedBox(width: 12),
          Expanded(child: TextFormField(initialValue: '$_totalMarks', decoration: const InputDecoration(labelText: 'Marks'), keyboardType: TextInputType.number, onChanged: (v) => _totalMarks = int.tryParse(v) ?? _totalMarks)),
          const SizedBox(width: 12),
          Expanded(child: TextFormField(initialValue: '$_duration', decoration: const InputDecoration(labelText: 'Duration (min)'), keyboardType: TextInputType.number, onChanged: (v) => _duration = int.tryParse(v) ?? _duration)),
        ]),
        const SizedBox(height: 20),
        GestureDetector(onTap: _pickPdf, child: Container(
          width: double.infinity, height: 100,
          decoration: BoxDecoration(border: Border.all(color: _pdf != null ? AdminTheme.success : AdminTheme.border, width: 2),
            borderRadius: BorderRadius.circular(12), color: AdminTheme.background),
          child: Center(child: Text(_pdf != null ? _pdf!.name : 'Click to select PDF', style: TextStyle(color: _pdf != null ? AdminTheme.success : AdminTheme.textSecondary))),
        )),
        const SizedBox(height: 24),
        Row(children: [
          OutlinedButton(onPressed: () => context.go('/admin/previous-papers'), child: const Text('Cancel')),
          const SizedBox(width: 12),
          ElevatedButton(onPressed: _uploading || _pdf == null ? null : _save,
            child: _uploading ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
              : const Text('Upload Paper')),
        ]),
      ])));
  }
}
