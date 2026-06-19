// Removed dart:html for Wasm compatibility
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:data_table_2/data_table_2.dart';
import 'package:file_picker/file_picker.dart';
import 'package:csv/csv.dart';

import '../../../../core/constants/app_colors.dart';

class AdminQuestionsScreen extends StatefulWidget {
  const AdminQuestionsScreen({super.key});

  @override
  State<AdminQuestionsScreen> createState() => _AdminQuestionsScreenState();
}

class _AdminQuestionsScreenState extends State<AdminQuestionsScreen> {
  bool _isImporting = false;
  String _searchQuery = '';
  String _filterSubject = 'All';
  final _searchCtrl = TextEditingController();

  void _downloadCsvTemplate() {
    const headers = 'QuestionTamil,QuestionEnglish,OptionsTamil (|-separated),OptionsEnglish (|-separated),CorrectOptionIndex (0-3),Subject,Topic,Chapter,Difficulty (easy/medium/hard),Year';
    const example = 'தமிழ்நாட்டின் தலைநகர் எது?,What is the capital of Tamil Nadu?,சென்னை|கோயம்புத்தூர்|மதுரை|திருச்சி,Chennai|Coimbatore|Madurai|Trichy,0,General Studies,Tamil Nadu,Geography,easy,2023';
    final csvContent = '$headers\n$example';
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('CSV Template text printed to console. Download requires web-specific implementation.')),
    );
    print('--- CSV TEMPLATE ---');
    print(csvContent);
  }

  Future<void> _importQuestionsFromCsv() async {
    final result = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['csv'],
      withData: true,
    );

    if (result == null || result.files.single.bytes == null) return;

    setState(() => _isImporting = true);

    try {
      final csvString = utf8.decode(result.files.single.bytes!);
      final rows = Csv().decode(csvString);
      
      final allRows = rows.skip(1).toList();
      int importedCount = 0;

      for (int i = 0; i < allRows.length; i += 400) {
        final chunk = allRows.sublist(i, i + 400 > allRows.length ? allRows.length : i + 400);
        final batch = FirebaseFirestore.instance.batch();

        for (final row in chunk) {
          if (row.length < 10) continue;
          
          final docRef = FirebaseFirestore.instance.collection('questions').doc();
          
          final optionsTamil = row[2].toString().split('|');
          final optionsEnglish = row[3].toString().split('|');
          
          batch.set(docRef, {
            'id': docRef.id,
            'questionTamil': row[0].toString(),
            'questionEnglish': row[1].toString(),
            'optionsTamil': optionsTamil,
            'optionsEnglish': optionsEnglish,
            'correctOptionIndex': int.tryParse(row[4].toString()) ?? 0,
            'subject': row[5].toString(),
            'topic': row[6].toString(),
            'chapter': row[7].toString(),
            'difficulty': row[8].toString(),
            'year': int.tryParse(row[9].toString()) ?? 0,
            'createdAt': FieldValue.serverTimestamp(),
            'isVerified': true,
          });
          importedCount++;
        }
        await batch.commit();
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Imported $importedCount questions successfully!')));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to import: $e')));
      }
    } finally {
      if (mounted) setState(() => _isImporting = false);
    }
  }

  void _editQuestion(String docId, Map<String, dynamic> data) {
    final questionTamilCtrl = TextEditingController(text: data['questionTamil'] ?? '');
    final questionEnglishCtrl = TextEditingController(text: data['questionEnglish'] ?? '');
    final correctIndexCtrl = TextEditingController(text: '${data['correctOptionIndex'] ?? 0}');
    String difficulty = data['difficulty'] ?? 'easy';

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: const Text('Edit Question', style: TextStyle(fontWeight: FontWeight.bold)),
          content: SizedBox(
            width: 600,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(controller: questionTamilCtrl,
                    decoration: const InputDecoration(labelText: 'Question (Tamil)', border: OutlineInputBorder()),
                    maxLines: 3),
                  const SizedBox(height: 12),
                  TextField(controller: questionEnglishCtrl,
                    decoration: const InputDecoration(labelText: 'Question (English)', border: OutlineInputBorder()),
                    maxLines: 3),
                  const SizedBox(height: 12),
                  TextField(controller: correctIndexCtrl,
                    decoration: const InputDecoration(labelText: 'Correct Option Index (0-3)', border: OutlineInputBorder()),
                    keyboardType: TextInputType.number),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    initialValue: difficulty,
                    decoration: const InputDecoration(labelText: 'Difficulty', border: OutlineInputBorder()),
                    items: ['easy', 'medium', 'hard']
                      .map((d) => DropdownMenuItem(value: d, child: Text(d))).toList(),
                    onChanged: (v) => setDialogState(() => difficulty = v!),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.accentSaffron, foregroundColor: Colors.white),
              onPressed: () async {
                await FirebaseFirestore.instance.collection('questions').doc(docId).update({
                  'questionTamil': questionTamilCtrl.text.trim(),
                  'questionEnglish': questionEnglishCtrl.text.trim(),
                  'correctOptionIndex': int.tryParse(correctIndexCtrl.text) ?? 0,
                  'difficulty': difficulty,
                  'updatedAt': FieldValue.serverTimestamp(),
                });
                if (mounted) {
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Question updated!')));
                }
              },
              child: const Text('Save Changes'),
            ),
          ],
        ),
      ),
    );
  }

  void _deleteQuestion(String id, String questionText) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Row(children: [
          Icon(Icons.warning, color: Colors.red),
          SizedBox(width: 8),
          Text('Delete Question?'),
        ]),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('This action cannot be undone.'),
            const SizedBox(height: 8),
            Text(questionText, maxLines: 2, overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontStyle: FontStyle.italic, color: Colors.grey)),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await FirebaseFirestore.instance.collection('questions').doc(id).delete();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Question deleted.'), backgroundColor: Colors.red));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0B1E36) : Colors.grey.shade100,
      appBar: AppBar(
        title: Text('Question Bank', style: TextStyle(color: isDark ? Colors.white : AppColors.primaryNavy, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          ElevatedButton.icon(
            onPressed: _downloadCsvTemplate,
            icon: const Icon(Icons.download),
            label: const Text('CSV Template'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green, foregroundColor: Colors.white),
          ),
          const SizedBox(width: 16),
          ElevatedButton.icon(
            onPressed: _isImporting ? null : _importQuestionsFromCsv,
            icon: _isImporting ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2)) : const Icon(Icons.upload_file),
            label: Text(_isImporting ? 'Importing...' : 'Bulk CSV Import'),
            style: ElevatedButton.styleFrom(backgroundColor: isDark ? Colors.blue : AppColors.primaryNavy, foregroundColor: Colors.white),
          ),
          const SizedBox(width: 16),
          ElevatedButton.icon(
            onPressed: () {
              // Open modal or dialog to add a single question
            },
            icon: const Icon(Icons.add),
            label: const Text('Add Question'),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.accentSaffron, foregroundColor: Colors.white),
          ),
          const SizedBox(width: 24),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchCtrl,
                    decoration: InputDecoration(
                      hintText: 'Search questions in Tamil or English...',
                      prefixIcon: const Icon(Icons.search),
                      suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(icon: const Icon(Icons.clear),
                            onPressed: () { _searchCtrl.clear(); setState(() => _searchQuery = ''); })
                        : null,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    onChanged: (v) => setState(() => _searchQuery = v.toLowerCase()),
                  ),
                ),
                const SizedBox(width: 16),
                DropdownButton<String>(
                  value: _filterSubject,
                  items: ['All', 'General Studies', 'General Tamil', 'Aptitude & Mental Ability',
                          'History', 'Geography', 'Science', 'Polity']
                    .map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
                  onChanged: (v) => setState(() => _filterSubject = v!),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(
              child: Container(
                decoration: BoxDecoration(color: Theme.of(context).cardColor, borderRadius: BorderRadius.circular(12), boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10)]),
                child: StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance.collection('questions').orderBy('createdAt', descending: true).limit(100).snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.hasError) return Center(child: Text('Error: ${snapshot.error}'));
                    if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

                    final allDocs = snapshot.data!.docs;
                    final docs = allDocs.where((doc) {
                      final data = doc.data() as Map<String, dynamic>;
                      final matchesSearch = _searchQuery.isEmpty
                          || (data['questionTamil'] ?? '').toLowerCase().contains(_searchQuery)
                          || (data['questionEnglish'] ?? '').toLowerCase().contains(_searchQuery);
                      final matchesSubject = _filterSubject == 'All'
                          || data['subject'] == _filterSubject;
                      return matchesSearch && matchesSubject;
                    }).toList();

                    return DataTable2(
                columnSpacing: 12,
                horizontalMargin: 24,
                minWidth: 1000,
                headingRowColor: WidgetStateProperty.all(isDark ? Colors.grey.shade900 : Colors.grey.shade50),
                columns: const [
                  DataColumn2(label: Text('Tamil Text'), size: ColumnSize.L),
                  DataColumn2(label: Text('Subject'), size: ColumnSize.S),
                  DataColumn2(label: Text('Topic'), size: ColumnSize.M),
                  DataColumn2(label: Text('Difficulty'), size: ColumnSize.S),
                  DataColumn2(label: Text('Actions'), size: ColumnSize.S, numeric: true),
                ],
                rows: docs.map((doc) {
                  final data = doc.data() as Map<String, dynamic>;
                  return DataRow(
                    cells: [
                      DataCell(Text(data['questionTamil'] ?? '', maxLines: 1, overflow: TextOverflow.ellipsis)),
                      DataCell(Text(data['subject'] ?? '')),
                      DataCell(Text(data['topic'] ?? '')),
                      DataCell(
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(color: _getDifficultyColor(data['difficulty']), borderRadius: BorderRadius.circular(8)),
                          child: Text(data['difficulty'] ?? 'easy', style: const TextStyle(fontSize: 12, color: Colors.white)),
                        ),
                      ),
                      DataCell(Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit, size: 20, color: Colors.blue),
                            tooltip: 'Edit Question',
                            onPressed: () => _editQuestion(doc.id, data),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete, size: 20, color: Colors.red),
                            onPressed: () => _deleteQuestion(doc.id, data['questionTamil'] ?? ''),
                          ),
                        ],
                      )),
                    ],
                  );
                }).toList(),
              );
            },
          ),
        ),
      ),
          ],
        ),
      ),
    );
  }

  Color _getDifficultyColor(String? diff) {
    switch (diff?.toLowerCase()) {
      case 'hard': return Colors.red;
      case 'medium': return Colors.orange;
      case 'easy': default: return Colors.green;
    }
  }
}
