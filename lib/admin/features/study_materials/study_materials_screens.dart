import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:file_picker/file_picker.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../core/constants/admin_constants.dart';
import '../../../core/constants/app_constants.dart';
import '../../core/theme/admin_theme.dart';
import '../../shared/models/content_models.dart';
import '../../shared/services/admin_activity_log_service.dart';
import '../../shared/widgets/admin_empty_state.dart';
import '../../shared/widgets/admin_shell.dart';

final _fs = FirebaseFirestore.instance;

final materialsStreamProvider = StreamProvider<List<StudyMaterialModel>>((ref) {
  return _fs.collection(AdminConstants.studyMaterialsCollection)
      .orderBy('uploadedAt', descending: true).snapshots()
      .map((s) => s.docs.map((d) => StudyMaterialModel.fromFirestore(d)).toList());
});

class MaterialsListScreen extends ConsumerStatefulWidget {
  const MaterialsListScreen({super.key});
  @override
  ConsumerState<MaterialsListScreen> createState() => _MaterialsListScreenState();
}

class _MaterialsListScreenState extends ConsumerState<MaterialsListScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(adminPageTitleProvider.notifier).state = 'Study Materials';
    });
  }

  @override
  Widget build(BuildContext context) {
    final mAsync = ref.watch(materialsStreamProvider);
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      ElevatedButton.icon(onPressed: () => context.go('/admin/materials/upload'),
        icon: const Icon(Icons.upload_file, size: 18), label: const Text('Upload Material')),
      const SizedBox(height: 16),
      mAsync.when(
        data: (items) {
          if (items.isEmpty) return const AdminEmptyState(icon: Icons.menu_book_outlined, message: 'No study materials uploaded yet.');
          return Container(
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: AdminTheme.border)),
            child: SingleChildScrollView(scrollDirection: Axis.horizontal, child: DataTable(
              headingRowColor: WidgetStateProperty.all(AdminTheme.background),
              columns: const [
                DataColumn(label: Text('Title')), DataColumn(label: Text('Subject')),
                DataColumn(label: Text('Chapter')), DataColumn(label: Text('Size')),
                DataColumn(label: Text('Downloads')), DataColumn(label: Text('Uploaded')),
                DataColumn(label: Text('Actions')),
              ],
              rows: items.map((m) => DataRow(cells: [
                DataCell(SizedBox(width: 200, child: Text(m.titleEn.isNotEmpty ? m.titleEn : m.titleTa, overflow: TextOverflow.ellipsis))),
                DataCell(Text(m.subject)), DataCell(Text(m.chapter)),
                DataCell(Text(m.fileSizeFormatted)), DataCell(Text('${m.downloadCount}')),
                DataCell(Text(m.uploadedAt != null ? DateFormat('MMM dd, yyyy').format(m.uploadedAt!) : '—')),
                DataCell(IconButton(icon: const Icon(Icons.delete_outline, size: 18, color: AdminTheme.error),
                  onPressed: () => _delete(m))),
              ])).toList(),
            )),
          );
        },
        loading: () => const Center(child: Padding(padding: EdgeInsets.all(48), child: CircularProgressIndicator())),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
    ]);
  }

  Future<void> _delete(StudyMaterialModel m) async {
    final ok = await showDialog<bool>(context: context, builder: (c) => AlertDialog(
      title: const Text('Delete Material?'), content: const Text('File will also be removed from Storage.'),
      actions: [TextButton(onPressed: () => Navigator.pop(c, false), child: const Text('Cancel')),
        ElevatedButton(onPressed: () => Navigator.pop(c, true), style: ElevatedButton.styleFrom(backgroundColor: AdminTheme.error), child: const Text('Delete'))],
    ));
    if (ok == true) {
      if (m.storageRef.isNotEmpty) {
        try { 
          await FirebaseStorage.instance.ref(m.storageRef).delete();
        } catch (_) {}
      }
      await _fs.collection(AdminConstants.studyMaterialsCollection).doc(m.id).delete();
    }
  }
}

// ─── Upload Screen ───
class UploadMaterialScreen extends ConsumerStatefulWidget {
  const UploadMaterialScreen({super.key});
  @override
  ConsumerState<UploadMaterialScreen> createState() => _UploadMaterialScreenState();
}

class _UploadMaterialScreenState extends ConsumerState<UploadMaterialScreen> {
  final _formKey = GlobalKey<FormState>();
  String _subject = 'Tamil', _chapter = '', _titleTa = '', _titleEn = '', _descTa = '', _descEn = '';
  PlatformFile? _file;
  bool _uploading = false;
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(adminPageTitleProvider.notifier).state = 'Upload Study Material';
    });
  }

  Future<void> _pickFile() async {
    final result = await FilePicker.pickFiles(type: FileType.custom, allowedExtensions: ['pdf'], withData: true);
    if (result != null && result.files.isNotEmpty) setState(() => _file = result.files.first);
  }

  Future<void> _upload() async {
    if (!_formKey.currentState!.validate() || _file == null) return;
    setState(() { _uploading = true; });
    try {
      final storagePath = '${AppConstants.mediaStoragePath}/${AdminConstants.studyMaterialsPath}/$_subject/$_chapter/${DateTime.now().millisecondsSinceEpoch}.pdf';
      
      final ref = FirebaseStorage.instance.ref(storagePath);
      await ref.putData(
        _file!.bytes!,
        SettableMetadata(contentType: 'application/pdf'),
      );
      final url = await ref.getDownloadURL();

      await _fs.collection(AdminConstants.studyMaterialsCollection).add(StudyMaterialModel(
        titleTa: _titleTa, titleEn: _titleEn, descTa: _descTa, descEn: _descEn,
        subject: _subject, chapter: _chapter, storageRef: storagePath,
        downloadUrl: url, fileSize: _file!.size,
        contentType: 'application/pdf', uploadedBy: FirebaseAuth.instance.currentUser?.uid,
      ).toFirestore());
      await AdminActivityLogService.log(action: 'Uploaded study material', targetCollection: AdminConstants.studyMaterialsCollection);
      if (mounted) context.go('/admin/materials');
    } finally { if (mounted) setState(() => _uploading = false); }
  }

  @override
  Widget build(BuildContext context) {
    return Container(constraints: const BoxConstraints(maxWidth: 600), child: Form(key: _formKey,
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        DropdownButtonFormField<String>(initialValue: _subject, decoration: const InputDecoration(labelText: 'Subject'),
          items: AdminConstants.defaultSubjects.map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
          onChanged: (v) => setState(() => _subject = v!)),
        const SizedBox(height: 12),
        TextFormField(decoration: const InputDecoration(labelText: 'Chapter'), onChanged: (v) => _chapter = v, validator: (v) => v!.isEmpty ? 'Required' : null),
        const SizedBox(height: 12),
        TextFormField(decoration: const InputDecoration(labelText: 'Title (Tamil)'), onChanged: (v) => _titleTa = v, validator: (v) => v!.isEmpty ? 'Required' : null),
        const SizedBox(height: 12),
        TextFormField(decoration: const InputDecoration(labelText: 'Title (English)'), onChanged: (v) => _titleEn = v),
        const SizedBox(height: 12),
        TextFormField(decoration: const InputDecoration(labelText: 'Description (Tamil)'), maxLines: 2, onChanged: (v) => _descTa = v),
        const SizedBox(height: 12),
        TextFormField(decoration: const InputDecoration(labelText: 'Description (English)'), maxLines: 2, onChanged: (v) => _descEn = v),
        const SizedBox(height: 20),
        // File picker area
        GestureDetector(onTap: _pickFile, child: Container(
          width: double.infinity, height: 120,
          decoration: BoxDecoration(border: Border.all(color: _file != null ? AdminTheme.success : AdminTheme.border, width: 2, strokeAlign: BorderSide.strokeAlignInside),
            borderRadius: BorderRadius.circular(12), color: AdminTheme.background),
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            Icon(_file != null ? Icons.check_circle : Icons.cloud_upload_outlined, size: 32,
              color: _file != null ? AdminTheme.success : AdminTheme.textSecondary),
            const SizedBox(height: 8),
            Text(_file != null ? '${_file!.name} (${(_file!.size / 1024 / 1024).toStringAsFixed(1)} MB)' : 'Click to select PDF',
              style: TextStyle(color: _file != null ? AdminTheme.success : AdminTheme.textSecondary, fontWeight: FontWeight.w500)),
          ]),
        )),
        if (_uploading) ...[
          const SizedBox(height: 12),
          const LinearProgressIndicator(color: AdminTheme.saffron),
        ],
        const SizedBox(height: 24),
        Row(children: [
          OutlinedButton(onPressed: () => context.go('/admin/materials'), child: const Text('Cancel')),
          const SizedBox(width: 12),
          ElevatedButton(onPressed: _uploading || _file == null ? null : _upload,
            child: _uploading ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
              : const Text('Upload')),
        ]),
      ])));
  }
}
