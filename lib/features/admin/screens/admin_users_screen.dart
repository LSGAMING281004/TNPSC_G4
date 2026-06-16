import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:data_table_2/data_table_2.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/app_colors.dart';

class AdminUsersScreen extends StatelessWidget {
  const AdminUsersScreen({super.key});

  Future<void> _toggleBanStatus(String uid, bool currentStatus) async {
    await FirebaseFirestore.instance.collection('users').doc(uid).update({
      'isBanned': !currentStatus,
    });
  }

  void _viewUserHistory(BuildContext context, String uid, String userName) {
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        child: SizedBox(
          width: 500,
          height: 500,
          child: Column(children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text('Test History — $userName',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                  .collection('test_attempts')
                  .where('userId', isEqualTo: uid)
                  .orderBy('completedAt', descending: true)
                  .limit(20)
                  .snapshots(),
                builder: (ctx, snap) {
                  if (!snap.hasData) return const Center(child: CircularProgressIndicator());
                  final docs = snap.data!.docs;
                  if (docs.isEmpty) return const Center(child: Text('No test history found.'));
                  return ListView.builder(
                    itemCount: docs.length,
                    itemBuilder: (ctx, i) {
                      final d = docs[i].data() as Map<String, dynamic>;
                      final date = (d['completedAt'] as Timestamp?)?.toDate();
                      return ListTile(
                        title: Text(d['testTitle'] ?? 'Test'),
                        subtitle: Text(date != null ? DateFormat('MMM d, yyyy – h:mm a').format(date) : 'Unknown date'),
                        trailing: Text('${d['score'] ?? 0}/${d['totalQuestions'] ?? 0}',
                          style: const TextStyle(fontWeight: FontWeight.bold)),
                      );
                    },
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8),
              child: TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Close')),
            ),
          ]),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0B1E36) : Colors.grey.shade100,
      appBar: AppBar(
        title: Text('User Management', style: TextStyle(color: isDark ? Colors.white : AppColors.primaryNavy, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Container(
          decoration: BoxDecoration(color: Theme.of(context).cardColor, borderRadius: BorderRadius.circular(12), boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10)]),
          child: StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance.collection('users').orderBy('createdAt', descending: true).snapshots(),
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
                  DataColumn2(label: Text('Name / Email'), size: ColumnSize.L),
                  DataColumn2(label: Text('Join Date'), size: ColumnSize.M),
                  DataColumn2(label: Text('Tests Taken'), size: ColumnSize.S, numeric: true),
                  DataColumn2(label: Text('Last Active'), size: ColumnSize.M),
                  DataColumn2(label: Text('Status'), size: ColumnSize.S),
                  DataColumn2(label: Text('Actions'), size: ColumnSize.S),
                ],
                rows: docs.map((doc) {
                  final data = doc.data() as Map<String, dynamic>;
                  final isBanned = data['isBanned'] ?? false;
                  final joinDate = (data['createdAt'] as Timestamp?)?.toDate();
                  final lastActive = (data['lastActiveAt'] as Timestamp?)?.toDate();
                  
                  return DataRow(
                    color: WidgetStateProperty.resolveWith<Color?>((states) => isBanned ? Colors.red.shade50 : null),
                    cells: [
                      DataCell(
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(data['name'] ?? 'Unknown', style: const TextStyle(fontWeight: FontWeight.bold)),
                            Text(data['email'] ?? '', style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
                          ],
                        )
                      ),
                      DataCell(Text(joinDate != null ? DateFormat('MMM d, yyyy').format(joinDate) : 'Unknown')),
                      DataCell(Text('${data['questionsAttempted'] ?? 0}')),
                      DataCell(Text(lastActive != null ? DateFormat('MMM d, yyyy').format(lastActive) : 'Never')),
                      DataCell(
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(color: isBanned ? Colors.red : Colors.green, borderRadius: BorderRadius.circular(8)),
                          child: Text(isBanned ? 'Banned' : 'Active', style: const TextStyle(fontSize: 12, color: Colors.white)),
                        ),
                      ),
                      DataCell(Row(
                        children: [
                          IconButton(
                            icon: Icon(isBanned ? Icons.check_circle : Icons.block, size: 20, color: isBanned ? Colors.green : Colors.red),
                            tooltip: isBanned ? 'Unban User' : 'Ban User',
                            onPressed: () => _toggleBanStatus(doc.id, isBanned),
                          ),
                          IconButton(
                            icon: const Icon(Icons.history, size: 20, color: Colors.blue),
                            tooltip: 'View History',
                            onPressed: () => _viewUserHistory(context, doc.id, data['name'] ?? 'Unknown'),
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
    );
  }
}
