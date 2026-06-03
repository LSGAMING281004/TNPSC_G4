import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../../core/constants/admin_constants.dart';
import '../../core/theme/admin_theme.dart';
import '../../shared/widgets/admin_shell.dart';

final _fs = FirebaseFirestore.instance;

class AdminAnalyticsScreen extends ConsumerStatefulWidget {
  const AdminAnalyticsScreen({super.key});
  @override
  ConsumerState<AdminAnalyticsScreen> createState() => _AdminAnalyticsScreenState();
}

class _AdminAnalyticsScreenState extends ConsumerState<AdminAnalyticsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabs;

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 4, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(adminPageTitleProvider.notifier).state = 'Analytics';
    });
  }

  @override
  void dispose() { _tabs.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      Container(
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10), border: Border.all(color: AdminTheme.border)),
        child: TabBar(controller: _tabs, indicatorColor: AdminTheme.saffron, labelColor: AdminTheme.saffron,
          unselectedLabelColor: AdminTheme.textSecondary, indicatorSize: TabBarIndicatorSize.label,
          tabs: const [Tab(text: 'Users'), Tab(text: 'Tests'), Tab(text: 'Content'), Tab(text: 'Engagement')]),
      ),
      const SizedBox(height: 20),
      SizedBox(height: 600, child: TabBarView(controller: _tabs, children: [
        _UserAnalytics(), _TestAnalytics(), _ContentAnalytics(), _EngagementAnalytics(),
      ])),
    ]);
  }
}

class _UserAnalytics extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      // User counts from Firestore
      StreamBuilder<QuerySnapshot>(
        stream: _fs.collection(AdminConstants.usersCollection).snapshots(),
        builder: (ctx, snap) {
          final total = snap.data?.size ?? 0;
          return _MetricRow(items: [
            _Metric('Total Users', '$total', Icons.people, AdminTheme.info),
          ]);
        },
      ),
      StreamBuilder<QuerySnapshot>(
        stream: _fs.collection(AdminConstants.usersCollection)
            .where('lastSeenAt', isGreaterThanOrEqualTo: Timestamp.fromDate(DateTime.now().subtract(const Duration(days: 1)))).snapshots(),
        builder: (ctx, snap) => _MetricRow(items: [
          _Metric('DAU', '${snap.data?.size ?? 0}', Icons.today, AdminTheme.success),
        ]),
      ),
      const SizedBox(height: 20),
      _chartCard('Premium vs Free', SizedBox(height: 200, child: StreamBuilder<QuerySnapshot>(
        stream: _fs.collection(AdminConstants.usersCollection).snapshots(),
        builder: (ctx, snap) {
          if (!snap.hasData) return const Center(child: CircularProgressIndicator());
          int premium = 0, free = 0;
          for (final doc in snap.data!.docs) {
            final d = doc.data() as Map<String, dynamic>;
            if (d['isPremium'] == true) {
              premium++;
            } else {
              free++;
            }
          }
          if (premium + free == 0) return const Center(child: Text('No data'));
          return PieChart(PieChartData(sectionsSpace: 2, centerSpaceRadius: 36, sections: [
            PieChartSectionData(value: premium.toDouble(), title: '$premium', color: AdminTheme.saffron, radius: 45,
              titleStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 12)),
            PieChartSectionData(value: free.toDouble(), title: '$free', color: AdminTheme.info, radius: 45,
              titleStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 12)),
          ]));
        },
      ))),
    ]));
  }
}

class _TestAnalytics extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(child: Column(children: [
      StreamBuilder<QuerySnapshot>(
        stream: _fs.collection(AdminConstants.testAttemptsCollection).snapshots(),
        builder: (ctx, snap) => _MetricRow(items: [
          _Metric('Total Attempts', '${snap.data?.size ?? 0}', Icons.assignment_turned_in, AdminTheme.success),
        ]),
      ),
      const SizedBox(height: 20),
      _chartCard('Tests per Day (14 days)', SizedBox(height: 200, child: FutureBuilder<QuerySnapshot>(
        future: _fs.collection(AdminConstants.testAttemptsCollection)
            .where('attemptedAt', isGreaterThanOrEqualTo: Timestamp.fromDate(DateTime.now().subtract(const Duration(days: 14)))).get(),
        builder: (ctx, snap) {
          if (!snap.hasData) return const Center(child: CircularProgressIndicator());
          final counts = <int, int>{};
          for (var i = 0; i < 14; i++) {
            counts[i] = 0;
          }
          for (final doc in snap.data!.docs) {
            final ts = ((doc.data() as Map<String, dynamic>)['attemptedAt'] as Timestamp?)?.toDate();
            if (ts != null) {
              final daysAgo = DateTime.now().difference(ts).inDays;
              if (daysAgo < 14) counts[daysAgo] = (counts[daysAgo] ?? 0) + 1;
            }
          }
          final maxY = counts.values.fold<int>(0, (a, b) => a > b ? a : b).toDouble();
          return BarChart(BarChartData(
            maxY: maxY + 2,
            barGroups: counts.entries.map((e) => BarChartGroupData(x: 13 - e.key,
              barRods: [BarChartRodData(toY: e.value.toDouble(), color: AdminTheme.saffron, width: 12, borderRadius: BorderRadius.circular(3))]
            )).toList(),
            titlesData: FlTitlesData(
              bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, getTitlesWidget: (v, _) {
                final d = DateTime.now().subtract(Duration(days: 13 - v.toInt()));
                return Text(DateFormat('dd').format(d), style: const TextStyle(fontSize: 10, color: AdminTheme.textSecondary));
              })),
              leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 28,
                getTitlesWidget: (v, _) => Text(v.toInt().toString(), style: const TextStyle(fontSize: 10, color: AdminTheme.textSecondary)))),
              topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            ),
            borderData: FlBorderData(show: false), gridData: FlGridData(show: true, drawVerticalLine: false),
          ));
        },
      ))),
    ]));
  }
}

class _ContentAnalytics extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(child: Column(children: [
      StreamBuilder<QuerySnapshot>(
        stream: _fs.collection(AdminConstants.questionsCollection).snapshots(),
        builder: (ctx, snap) => _MetricRow(items: [_Metric('Questions', '${snap.data?.size ?? 0}', Icons.quiz, AdminTheme.info)]),
      ),
      StreamBuilder<QuerySnapshot>(
        stream: _fs.collection(AdminConstants.studyMaterialsCollection).snapshots(),
        builder: (ctx, snap) => _MetricRow(items: [_Metric('Materials', '${snap.data?.size ?? 0}', Icons.menu_book, AdminTheme.success)]),
      ),
      StreamBuilder<QuerySnapshot>(
        stream: _fs.collection(AdminConstants.currentAffairsCollection).snapshots(),
        builder: (ctx, snap) => _MetricRow(items: [_Metric('Articles', '${snap.data?.size ?? 0}', Icons.newspaper, AdminTheme.warning)]),
      ),
    ]));
  }
}

class _EngagementAnalytics extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(child: Column(children: [
      StreamBuilder<QuerySnapshot>(
        stream: _fs.collection(AdminConstants.notificationsCollection).snapshots(),
        builder: (ctx, snap) => _MetricRow(items: [_Metric('Notifications Sent', '${snap.data?.size ?? 0}', Icons.notifications, AdminTheme.saffron)]),
      ),
    ]));
  }
}

// Helper widgets
class _Metric {
  final String label, value;
  final IconData icon;
  final Color color;
  const _Metric(this.label, this.value, this.icon, this.color);
}

class _MetricRow extends StatelessWidget {
  final List<_Metric> items;
  const _MetricRow({required this.items});
  @override
  Widget build(BuildContext context) {
    return Wrap(spacing: 16, runSpacing: 12, children: items.map((m) => Container(
      width: 200, padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: AdminTheme.border)),
      child: Row(children: [
        Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: m.color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
          child: Icon(m.icon, size: 20, color: m.color)),
        const SizedBox(width: 12),
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(m.value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
          Text(m.label, style: const TextStyle(fontSize: 11, color: AdminTheme.textSecondary)),
        ]),
      ]),
    )).toList());
  }
}

Widget _chartCard(String title, Widget child) => Container(
  padding: const EdgeInsets.all(20),
  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14), border: Border.all(color: AdminTheme.border)),
  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    Text(title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600)), const SizedBox(height: 16), child,
  ]),
);
