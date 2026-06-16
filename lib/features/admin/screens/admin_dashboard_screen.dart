import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../../core/constants/app_colors.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});
  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  List<FlSpot> _userGrowthSpots = [];
  bool _loadingChart = true;

  @override
  void initState() {
    super.initState();
    _loadUserGrowthData();
  }

  Future<void> _loadUserGrowthData() async {
    final thirtyDaysAgo = DateTime.now().subtract(const Duration(days: 30));
    final snapshot = await FirebaseFirestore.instance
        .collection('users')
        .where('createdAt', isGreaterThan: Timestamp.fromDate(thirtyDaysAgo))
        .orderBy('createdAt')
        .get();

    final Map<int, int> dayCounts = {};
    for (final doc in snapshot.docs) {
      final createdAt = (doc['createdAt'] as Timestamp?)?.toDate();
      if (createdAt == null) continue;
      final dayIndex = DateTime.now().difference(createdAt).inDays;
      final reversedDay = 30 - dayIndex;
      dayCounts[reversedDay] = (dayCounts[reversedDay] ?? 0) + 1;
    }

    int cumulative = 0;
    final spots = <FlSpot>[];
    for (int day = 0; day <= 30; day++) {
      cumulative += dayCounts[day] ?? 0;
      spots.add(FlSpot(day.toDouble(), cumulative.toDouble()));
    }

    if (mounted) setState(() { _userGrowthSpots = spots; _loadingChart = false; });
  }

  Future<void> _refreshStats() async {
    final usersCount = await FirebaseFirestore.instance.collection('users').count().get();
    final questionsCount = await FirebaseFirestore.instance.collection('questions').count().get();
    final attemptsCount = await FirebaseFirestore.instance.collection('test_attempts').count().get();
    
    final today = DateTime.now();
    final todayStart = DateTime(today.year, today.month, today.day);
    final activeToday = await FirebaseFirestore.instance.collection('users')
      .where('lastActiveAt', isGreaterThan: Timestamp.fromDate(todayStart))
      .count().get();

    await FirebaseFirestore.instance.collection('analytics_summary').doc('daily').set({
      'totalUsers': usersCount.count,
      'totalQuestions': questionsCount.count,
      'totalAttempts': attemptsCount.count,
      'todayActiveUsers': activeToday.count,
      'lastUpdated': FieldValue.serverTimestamp(),
    });

    if (mounted) ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Stats refreshed!')));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Dashboard Overview', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.primaryNavy)),
                ElevatedButton.icon(
                  onPressed: _refreshStats,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Refresh Stats'),
                ),
              ],
            ),
            const SizedBox(height: 24),
            _buildStatsRow(),
            const SizedBox(height: 32),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(flex: 2, child: _buildGrowthChart()),
                const SizedBox(width: 24),
                Expanded(flex: 1, child: _buildRecentQuestions()),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsRow() {
    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance.collection('analytics_summary').doc('daily').snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
        final data = snapshot.data?.data() as Map<String, dynamic>? ?? {};

        return Row(
          children: [
            Expanded(child: _buildStatCard('Total Users', '${data['totalUsers'] ?? 0}', Icons.people, Colors.blue)),
            const SizedBox(width: 16),
            Expanded(child: _buildStatCard('Total Questions', '${data['totalQuestions'] ?? 0}', Icons.library_books, Colors.orange)),
            const SizedBox(width: 16),
            Expanded(child: _buildStatCard('Tests Taken', '${data['totalAttempts'] ?? 0}', Icons.assignment, Colors.purple)),
            const SizedBox(width: 16),
            Expanded(child: _buildStatCard('Active Today', '${data['todayActiveUsers'] ?? 0}', Icons.local_fire_department, Colors.red)),
          ],
        );
      },
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 4))]),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: color.withValues(alpha: 0.1), shape: BoxShape.circle),
            child: Icon(icon, color: color, size: 32),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: TextStyle(color: Colors.grey.shade600, fontSize: 14)),
              const SizedBox(height: 4),
              Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 24, color: AppColors.primaryNavy)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildGrowthChart() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10)]),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('User Growth (Last 30 Days)', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.primaryNavy)),
          const SizedBox(height: 24),
          SizedBox(
            height: 300,
            child: LineChart(
              LineChartData(
                gridData: FlGridData(show: true, drawVerticalLine: false, getDrawingHorizontalLine: (value) => FlLine(color: Colors.grey.shade200, strokeWidth: 1)),
                titlesData: FlTitlesData(
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 30,
                      interval: 5,
                      getTitlesWidget: (value, meta) => Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Text('Day ${value.toInt()}', style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
                      ),
                    ),
                  ),
                ),
                borderData: FlBorderData(show: false),
                lineBarsData: [
                  LineChartBarData(
                    spots: _loadingChart ? const [FlSpot(0, 0)] : (_userGrowthSpots.isEmpty ? const [FlSpot(0, 0)] : _userGrowthSpots),
                    isCurved: true,
                    color: AppColors.accentSaffron,
                    barWidth: 4,
                    isStrokeCapRound: true,
                    dotData: const FlDotData(show: false),
                    belowBarData: BarAreaData(show: true, color: AppColors.accentSaffron.withValues(alpha: 0.2)),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentQuestions() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10)]),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Recently Added Questions', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.primaryNavy)),
          const SizedBox(height: 16),
          StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance.collection('questions').orderBy('createdAt', descending: true).limit(5).snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
              final docs = snapshot.data!.docs;
              if (docs.isEmpty) return const Text('No recent questions.');

              return ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: docs.length,
                separatorBuilder: (_, __) => const Divider(),
                itemBuilder: (context, index) {
                  final data = docs[index].data() as Map<String, dynamic>;
                  return ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(data['questionTamil'] ?? '', maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
                    subtitle: Text('${data['subject']} • ${data['difficulty']}', style: TextStyle(color: Colors.grey.shade500, fontSize: 11)),
                    trailing: const Icon(Icons.chevron_right),
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }
}
