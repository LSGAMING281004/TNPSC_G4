import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:data_table_2/data_table_2.dart';
import '../../../../core/constants/app_colors.dart';

class AdminTestsScreen extends StatelessWidget {
  const AdminTestsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0B1E36) : Colors.grey.shade100,
      appBar: AppBar(
        title: Text('Mock Tests', style: TextStyle(
          color: isDark ? Colors.white : AppColors.primaryNavy,
          fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          ElevatedButton.icon(
            onPressed: () => _showCreateTestDialog(context),
            icon: const Icon(Icons.add),
            label: const Text('Create Test'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.accentSaffron,
              foregroundColor: Colors.white),
          ),
          const SizedBox(width: 24),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Container(
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10)]),
          child: StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('tests')
                .orderBy('createdAt', descending: true)
                .snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
              final docs = snapshot.data!.docs;
              if (docs.isEmpty) return const Center(child: Text('No tests yet. Create one!'));

              return DataTable2(
                columnSpacing: 12,
                horizontalMargin: 24,
                minWidth: 900,
                headingRowColor: WidgetStateProperty.all(
                  isDark ? Colors.grey.shade900 : Colors.grey.shade50),
                columns: const [
                  DataColumn2(label: Text('Test Name'), size: ColumnSize.L),
                  DataColumn2(label: Text('Subject'), size: ColumnSize.M),
                  DataColumn2(label: Text('Questions'), size: ColumnSize.S, numeric: true),
                  DataColumn2(label: Text('Duration'), size: ColumnSize.S),
                  DataColumn2(label: Text('Attempts'), size: ColumnSize.S, numeric: true),
                  DataColumn2(label: Text('Status'), size: ColumnSize.S),
                  DataColumn2(label: Text('Actions'), size: ColumnSize.S),
                ],
                rows: docs.map((doc) {
                  final data = doc.data() as Map<String, dynamic>;
                  final isActive = data['isActive'] ?? true;
                  return DataRow(cells: [
                    DataCell(Text(data['title'] ?? '', style: const TextStyle(fontWeight: FontWeight.w500))),
                    DataCell(Text(data['subject'] ?? 'All')),
                    DataCell(Text('${data['questionCount'] ?? 0}')),
                    DataCell(Text('${data['durationMinutes'] ?? 90} min')),
                    DataCell(Text('${data['attemptCount'] ?? 0}')),
                    DataCell(Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: isActive ? Colors.green : Colors.grey,
                        borderRadius: BorderRadius.circular(8)),
                      child: Text(isActive ? 'Active' : 'Inactive',
                        style: const TextStyle(color: Colors.white, fontSize: 12)),
                    )),
                    DataCell(Row(children: [
                      IconButton(
                        icon: Icon(isActive ? Icons.pause_circle : Icons.play_circle,
                          color: isActive ? Colors.orange : Colors.green, size: 20),
                        tooltip: isActive ? 'Deactivate' : 'Activate',
                        onPressed: () => FirebaseFirestore.instance
                            .collection('tests').doc(doc.id)
                            .update({'isActive': !isActive}),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red, size: 20),
                        tooltip: 'Delete Test',
                        onPressed: () async {
                          final ok = await showDialog<bool>(
                            context: context,
                            builder: (ctx) => AlertDialog(
                              title: const Text('Delete Test?'),
                              content: const Text('All attempt history will be lost.'),
                              actions: [
                                TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
                                ElevatedButton(
                                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
                                  onPressed: () => Navigator.pop(ctx, true),
                                  child: const Text('Delete')),
                              ],
                            ),
                          );
                          if (ok == true) {
                            await FirebaseFirestore.instance.collection('tests').doc(doc.id).delete();
                          }
                        },
                      ),
                    ])),
                  ]);
                }).toList(),
              );
            },
          ),
        ),
      ),
    );
  }

  void _showCreateTestDialog(BuildContext context) {
    final nameCtrl = TextEditingController();
    String subject = 'General Studies';
    final questionsCtrl = TextEditingController(text: '100');
    final durationCtrl = TextEditingController(text: '90');

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: const Text('Create Mock Test', style: TextStyle(fontWeight: FontWeight.bold)),
          content: SizedBox(
            width: 500,
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              TextField(controller: nameCtrl,
                decoration: const InputDecoration(labelText: 'Test Name', border: OutlineInputBorder())),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: subject,
                decoration: const InputDecoration(labelText: 'Subject', border: OutlineInputBorder()),
                items: ['General Studies', 'General Tamil', 'Aptitude & Mental Ability', 'All Subjects']
                  .map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
                onChanged: (v) => setDialogState(() => subject = v!),
              ),
              const SizedBox(height: 12),
              Row(children: [
                Expanded(child: TextField(controller: questionsCtrl,
                  decoration: const InputDecoration(labelText: 'Questions', border: OutlineInputBorder()),
                  keyboardType: TextInputType.number)),
                const SizedBox(width: 12),
                Expanded(child: TextField(controller: durationCtrl,
                  decoration: const InputDecoration(labelText: 'Duration (min)', border: OutlineInputBorder()),
                  keyboardType: TextInputType.number)),
              ]),
            ]),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.accentSaffron, foregroundColor: Colors.white),
              onPressed: () async {
                if (nameCtrl.text.isEmpty) return;
                await FirebaseFirestore.instance.collection('tests').add({
                  'title': nameCtrl.text.trim(),
                  'subject': subject,
                  'questionCount': int.tryParse(questionsCtrl.text) ?? 100,
                  'durationMinutes': int.tryParse(durationCtrl.text) ?? 90,
                  'isActive': true,
                  'attemptCount': 0,
                  'createdAt': FieldValue.serverTimestamp(),
                });
                if (ctx.mounted) Navigator.pop(ctx);
              },
              child: const Text('Create'),
            ),
          ],
        ),
      ),
    );
  }
}
