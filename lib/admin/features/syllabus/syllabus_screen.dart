import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/constants/admin_constants.dart';
import '../../core/theme/admin_theme.dart';
import '../../shared/widgets/admin_shell.dart';

final _fs = FirebaseFirestore.instance;

class SyllabusScreen extends ConsumerStatefulWidget {
  const SyllabusScreen({super.key});
  @override
  ConsumerState<SyllabusScreen> createState() => _SyllabusScreenState();
}

class _SyllabusScreenState extends ConsumerState<SyllabusScreen> {
  String? _selectedSubject;
  String? _selectedChapterId;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(adminPageTitleProvider.notifier).state = 'Syllabus Manager';
    });
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(height: 550, child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      // Column 1: Subjects
      _col('Subjects', _subjectsCol()),
      const SizedBox(width: 16),
      // Column 2: Chapters
      _col('Chapters', _chaptersCol()),
      const SizedBox(width: 16),
      // Column 3: Topics
      _col('Topics', _topicsCol()),
    ]));
  }

  Widget _col(String title, Widget child) => Expanded(child: Container(
    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: AdminTheme.border)),
    child: Column(children: [
      Container(padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(color: AdminTheme.background, borderRadius: const BorderRadius.vertical(top: Radius.circular(12))),
        child: Row(children: [Text(title, style: const TextStyle(fontWeight: FontWeight.w600))])),
      const Divider(height: 1),
      Expanded(child: child),
    ]),
  ));

  Widget _subjectsCol() {
    return StreamBuilder<QuerySnapshot>(
      stream: _fs.collection(AdminConstants.syllabusCollection).snapshots(),
      builder: (ctx, snap) {
        if (!snap.hasData) return const Center(child: CircularProgressIndicator());
        final docs = snap.data!.docs;
        if (docs.isEmpty) {
          return Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
            const Text('No subjects', style: TextStyle(color: AdminTheme.textSecondary)),
            const SizedBox(height: 8),
            TextButton.icon(icon: const Icon(Icons.add, size: 16), label: const Text('Initialize'),
              onPressed: () async {
                for (final s in AdminConstants.defaultSubjects) {
                  await _fs.collection(AdminConstants.syllabusCollection).doc(s).set({'name': s, 'order': AdminConstants.defaultSubjects.indexOf(s)});
                }
              }),
          ]));
        }
        return ListView(children: docs.map((d) {
          final name = d.id;
          final selected = _selectedSubject == name;
          return ListTile(
            title: Text(name, style: TextStyle(fontWeight: selected ? FontWeight.w600 : FontWeight.normal)),
            selected: selected, selectedTileColor: AdminTheme.saffron.withValues(alpha: 0.08),
            leading: Icon(Icons.subject, size: 18, color: selected ? AdminTheme.saffron : AdminTheme.textSecondary),
            onTap: () => setState(() { _selectedSubject = name; _selectedChapterId = null; }),
          );
        }).toList());
      },
    );
  }

  Widget _chaptersCol() {
    if (_selectedSubject == null) return const Center(child: Text('Select a subject', style: TextStyle(color: AdminTheme.textSecondary)));
    return Column(children: [
      Expanded(child: StreamBuilder<QuerySnapshot>(
        stream: _fs.collection(AdminConstants.syllabusCollection).doc(_selectedSubject)
            .collection('chapters').orderBy('order').snapshots(),
        builder: (ctx, snap) {
          if (!snap.hasData) return const Center(child: CircularProgressIndicator());
          final docs = snap.data!.docs;
          if (docs.isEmpty) return const Center(child: Text('No chapters', style: TextStyle(color: AdminTheme.textSecondary)));
          return ReorderableListView(
            onReorder: (old, newIdx) async {
              for (var i = 0; i < docs.length; i++) {
                await docs[i].reference.update({'order': i});
              }
            },
            children: docs.map((d) {
              final data = d.data() as Map<String, dynamic>;
              final selected = _selectedChapterId == d.id;
              return ListTile(key: ValueKey(d.id),
                title: Text(data['nameEn'] ?? d.id, style: TextStyle(fontWeight: selected ? FontWeight.w600 : FontWeight.normal, fontSize: 13)),
                subtitle: data['nameTa'] != null ? Text(data['nameTa'], style: const TextStyle(fontSize: 11)) : null,
                selected: selected, selectedTileColor: AdminTheme.saffron.withValues(alpha: 0.08),
                onTap: () => setState(() => _selectedChapterId = d.id),
                trailing: IconButton(icon: const Icon(Icons.delete_outline, size: 16, color: AdminTheme.error),
                  onPressed: () => d.reference.delete()),
              );
            }).toList(),
          );
        },
      )),
      _addBar('Add Chapter', (nameTa, nameEn) async {
        final chaps = await _fs.collection(AdminConstants.syllabusCollection).doc(_selectedSubject).collection('chapters').get();
        await _fs.collection(AdminConstants.syllabusCollection).doc(_selectedSubject).collection('chapters').add({
          'nameTa': nameTa, 'nameEn': nameEn, 'order': chaps.size, 'topicCount': 0,
        });
      }),
    ]);
  }

  Widget _topicsCol() {
    if (_selectedSubject == null || _selectedChapterId == null) return const Center(child: Text('Select a chapter', style: TextStyle(color: AdminTheme.textSecondary)));
    return Column(children: [
      Expanded(child: StreamBuilder<QuerySnapshot>(
        stream: _fs.collection(AdminConstants.syllabusCollection).doc(_selectedSubject)
            .collection('chapters').doc(_selectedChapterId).collection('topics').orderBy('order').snapshots(),
        builder: (ctx, snap) {
          if (!snap.hasData) return const Center(child: CircularProgressIndicator());
          final docs = snap.data!.docs;
          if (docs.isEmpty) return const Center(child: Text('No topics', style: TextStyle(color: AdminTheme.textSecondary)));
          return ListView(children: docs.map((d) {
            final data = d.data() as Map<String, dynamic>;
            return ListTile(
              title: Text(data['nameEn'] ?? d.id, style: const TextStyle(fontSize: 13)),
              subtitle: data['nameTa'] != null ? Text(data['nameTa'], style: const TextStyle(fontSize: 11)) : null,
              trailing: Row(mainAxisSize: MainAxisSize.min, children: [
                if (data['isImportant'] == true) const Icon(Icons.star, size: 16, color: AdminTheme.saffron),
                IconButton(icon: const Icon(Icons.delete_outline, size: 16, color: AdminTheme.error), onPressed: () => d.reference.delete()),
              ]),
            );
          }).toList());
        },
      )),
      _addBar('Add Topic', (nameTa, nameEn) async {
        final topics = await _fs.collection(AdminConstants.syllabusCollection).doc(_selectedSubject)
            .collection('chapters').doc(_selectedChapterId).collection('topics').get();
        await _fs.collection(AdminConstants.syllabusCollection).doc(_selectedSubject)
            .collection('chapters').doc(_selectedChapterId).collection('topics').add({
          'nameTa': nameTa, 'nameEn': nameEn, 'order': topics.size, 'isImportant': false, 'questionCount': 0,
        });
      }),
    ]);
  }

  Widget _addBar(String hint, Future<void> Function(String nameTa, String nameEn) onAdd) {
    final tCtrl = TextEditingController(), eCtrl = TextEditingController();
    return Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(border: Border(top: BorderSide(color: AdminTheme.border))),
      child: Row(children: [
        Expanded(child: SizedBox(height: 34, child: TextField(controller: tCtrl, decoration: InputDecoration(hintText: '$hint (Ta)', contentPadding: const EdgeInsets.symmetric(horizontal: 8), border: OutlineInputBorder(borderRadius: BorderRadius.circular(6))), style: const TextStyle(fontSize: 12)))),
        const SizedBox(width: 4),
        Expanded(child: SizedBox(height: 34, child: TextField(controller: eCtrl, decoration: InputDecoration(hintText: '$hint (En)', contentPadding: const EdgeInsets.symmetric(horizontal: 8), border: OutlineInputBorder(borderRadius: BorderRadius.circular(6))), style: const TextStyle(fontSize: 12)))),
        const SizedBox(width: 4),
        SizedBox(height: 34, child: IconButton(icon: const Icon(Icons.add_circle, color: AdminTheme.saffron, size: 22),
          onPressed: () async { if (eCtrl.text.isNotEmpty) { await onAdd(tCtrl.text, eCtrl.text); tCtrl.clear(); eCtrl.clear(); } })),
      ]));
  }
}
