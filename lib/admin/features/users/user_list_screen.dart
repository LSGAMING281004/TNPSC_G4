import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import '../../core/constants/admin_constants.dart';
import '../../core/theme/admin_theme.dart';
import '../../shared/widgets/admin_empty_state.dart';
import '../../shared/widgets/admin_shell.dart';

final _fs = FirebaseFirestore.instance;

final usersStreamProvider = StreamProvider<List<Map<String, dynamic>>>((ref) {
  return _fs.collection(AdminConstants.usersCollection)
      .orderBy('createdAt', descending: true).limit(50).snapshots()
      .map((s) => s.docs.map((d) => {'id': d.id, ...d.data()}).toList());
});

class UserListScreen extends ConsumerStatefulWidget {
  const UserListScreen({super.key});
  @override
  ConsumerState<UserListScreen> createState() => _UserListScreenState();
}

class _UserListScreenState extends ConsumerState<UserListScreen> {
  String? _selectedUserId;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(adminPageTitleProvider.notifier).state = 'Users';
    });
  }

  @override
  Widget build(BuildContext context) {
    final usersAsync = ref.watch(usersStreamProvider);
    return Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      // User list
      Expanded(flex: 2, child: usersAsync.when(
        data: (users) {
          if (users.isEmpty) return const AdminEmptyState(icon: Icons.people_outline, message: 'No users registered yet.');
          return Container(
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: AdminTheme.border)),
            child: SingleChildScrollView(scrollDirection: Axis.horizontal, child: DataTable(
              headingRowColor: WidgetStateProperty.all(AdminTheme.background),
              columns: const [
                DataColumn(label: Text('Name')), DataColumn(label: Text('Email')),
                DataColumn(label: Text('Joined')), DataColumn(label: Text('Last Active')),
                DataColumn(label: Text('Status')), DataColumn(label: Text('Actions')),
              ],
              rows: users.map((u) {
                final createdAt = (u['createdAt'] as Timestamp?)?.toDate();
                final lastSeen = (u['lastSeenAt'] as Timestamp?)?.toDate();
                final suspended = u['isSuspended'] == true;
                return DataRow(
                  selected: _selectedUserId == u['id'],
                  cells: [
                    DataCell(Row(children: [
                      CircleAvatar(radius: 14, backgroundColor: AdminTheme.navy.withValues(alpha: 0.1),
                        child: Text((u['name'] ?? 'U')[0].toUpperCase(), style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600))),
                      const SizedBox(width: 8),
                      Text(u['name'] ?? 'Unknown', overflow: TextOverflow.ellipsis),
                    ])),
                    DataCell(Text(u['email'] ?? '—')),
                    DataCell(Text(createdAt != null ? DateFormat('MMM dd, yy').format(createdAt) : '—')),
                    DataCell(Text(lastSeen != null ? _timeAgo(lastSeen) : '—', style: const TextStyle(fontSize: 12))),
                    DataCell(Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(color: (suspended ? AdminTheme.error : AdminTheme.success).withValues(alpha: 0.1), borderRadius: BorderRadius.circular(4)),
                      child: Text(suspended ? 'Suspended' : 'Active',
                        style: TextStyle(fontSize: 11, color: suspended ? AdminTheme.error : AdminTheme.success, fontWeight: FontWeight.w600)),
                    )),
                    DataCell(Row(mainAxisSize: MainAxisSize.min, children: [
                      IconButton(icon: const Icon(Icons.visibility_outlined, size: 18),
                        onPressed: () => setState(() => _selectedUserId = u['id']), tooltip: 'View'),
                      IconButton(icon: Icon(suspended ? Icons.check_circle_outline : Icons.block_outlined, size: 18,
                        color: suspended ? AdminTheme.success : AdminTheme.error),
                        onPressed: () => _fs.collection(AdminConstants.usersCollection).doc(u['id']).update({'isSuspended': !suspended}),
                        tooltip: suspended ? 'Activate' : 'Suspend'),
                    ])),
                  ],
                );
              }).toList(),
            )),
          );
        },
        loading: () => const Center(child: Padding(padding: EdgeInsets.all(48), child: CircularProgressIndicator())),
        error: (e, _) => Center(child: Text('Error: $e')),
      )),
      // User detail drawer
      if (_selectedUserId != null) ...[
        const SizedBox(width: 16),
        SizedBox(width: 320, child: UserDetailDrawer(userId: _selectedUserId!, onClose: () => setState(() => _selectedUserId = null))),
      ],
    ]);
  }

  String _timeAgo(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }
}

class UserDetailDrawer extends StatelessWidget {
  final String userId;
  final VoidCallback onClose;
  const UserDetailDrawer({super.key, required this.userId, required this.onClose});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14), border: Border.all(color: AdminTheme.border)),
      child: StreamBuilder<DocumentSnapshot>(
        stream: _fs.collection(AdminConstants.usersCollection).doc(userId).snapshots(),
        builder: (context, snap) {
          if (!snap.hasData || !snap.data!.exists) return const Center(child: CircularProgressIndicator());
          final u = snap.data!.data() as Map<String, dynamic>;
          return SingleChildScrollView(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              const Text('User Details', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
              const Spacer(),
              IconButton(icon: const Icon(Icons.close, size: 18), onPressed: onClose),
            ]),
            const Divider(),
            CircleAvatar(radius: 28, backgroundColor: AdminTheme.saffron,
              child: Text((u['name'] ?? 'U')[0].toUpperCase(), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 22))),
            const SizedBox(height: 12),
            Text(u['name'] ?? 'Unknown', style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
            Text(u['email'] ?? '', style: const TextStyle(color: AdminTheme.textSecondary, fontSize: 13)),
            const SizedBox(height: 16),
            _detailRow('District', u['district'] ?? '—'),
            _detailRow('Role', u['role'] ?? 'user'),
            _detailRow('Premium', u['isPremium'] == true ? 'Yes' : 'No'),
            _detailRow('Study Streak', '${u['studyStreak'] ?? 0} days'),
            const SizedBox(height: 16),
            // Test stats
            StreamBuilder<QuerySnapshot>(
              stream: _fs.collection(AdminConstants.testAttemptsCollection).where('userId', isEqualTo: userId).snapshots(),
              builder: (ctx, snap) {
                final count = snap.data?.size ?? 0;
                return _detailRow('Tests Taken', '$count');
              },
            ),
          ]));
        },
      ),
    );
  }

  Widget _detailRow(String label, String value) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Row(children: [
      SizedBox(width: 100, child: Text(label, style: const TextStyle(color: AdminTheme.textSecondary, fontSize: 12))),
      Expanded(child: Text(value, style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 13))),
    ]),
  );
}
