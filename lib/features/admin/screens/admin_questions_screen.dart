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
      final rows = const CsvDecoder().convert(csvString);
      
      final batch = FirebaseFirestore.instance.batch();
      
      // Skip header row
      for (final row in rows.skip(1)) {
        if (row.length < 10) continue; // Basic validation
        
        final docRef = FirebaseFirestore.instance.collection('questions').doc();
        
        // Parse options delimited by '|'
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
      }

      await batch.commit();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Imported ${rows.length - 1} questions successfully!')));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to import: $e')));
      }
    } finally {
      if (mounted) setState(() => _isImporting = false);
    }
  }

  void _deleteQuestion(String id) async {
    await FirebaseFirestore.instance.collection('questions').doc(id).delete();
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
        child: Container(
          decoration: BoxDecoration(color: Theme.of(context).cardColor, borderRadius: BorderRadius.circular(12), boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10)]),
          child: StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance.collection('questions').orderBy('createdAt', descending: true).limit(100).snapshots(),
            builder: (context, snapshot) {
              if (snapshot.hasError) return Center(child: Text('Error: ${snapshot.error}'));
              if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

              final docs = snapshot.data!.docs;

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
                          IconButton(icon: const Icon(Icons.edit, size: 20, color: Colors.blue), onPressed: () {}),
                          IconButton(icon: const Icon(Icons.delete, size: 20, color: Colors.red), onPressed: () => _deleteQuestion(doc.id)),
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
