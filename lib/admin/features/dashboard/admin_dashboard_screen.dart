import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/admin_theme.dart';
import '../../core/constants/admin_constants.dart';
import '../../shared/widgets/admin_stat_card.dart';
import '../../shared/widgets/admin_empty_state.dart';
import '../../shared/widgets/admin_shell.dart';
import '../../../shared/utils/time_format.dart';

// ─── Firestore Stream Providers ───
final _firestore = FirebaseFirestore.instance;

final totalUsersProvider = StreamProvider<int>((ref) {
  return _firestore
      .collection(AdminConstants.usersCollection)
      .snapshots()
      .map((s) => s.size);
});

final totalQuestionsProvider = StreamProvider<int>((ref) {
  return _firestore
      .collection(AdminConstants.questionsCollection)
      .snapshots()
      .map((s) => s.size);
});

final totalMockTestsProvider = StreamProvider<int>((ref) {
  return _firestore
      .collection(AdminConstants.mockTestsCollection)
      .snapshots()
      .map((s) => s.size);
});

final todayActiveUsersProvider = StreamProvider<int>((ref) {
  final now = DateTime.now();
  final todayStart = DateTime(now.year, now.month, now.day);
  return _firestore
      .collection(AdminConstants.usersCollection)
      .where('lastSeenAt', isGreaterThanOrEqualTo: Timestamp.fromDate(todayStart))
      .snapshots()
      .map((s) => s.size);
});

final totalAudioBooksProvider = StreamProvider<int>((ref) {
  return _firestore
      .collection('audio_books')
      .where('isActive', isEqualTo: true)
      .snapshots()
      .map((s) => s.size);
});

final totalStudyMaterialsProvider = StreamProvider<int>((ref) {
  return _firestore
      .collection('study_materials')
      .snapshots()
      .map((s) => s.size);
});

final recentActivityProvider = StreamProvider<List<Map<String, dynamic>>>((ref) {
  return _firestore
      .collection(AdminConstants.adminActivityLogCollection)
      .orderBy('timestamp', descending: true)
      .limit(AdminConstants.activityLogLimit)
      .snapshots()
      .map((s) => s.docs.map((d) => {'id': d.id, ...d.data()}).toList());
});

final userGrowthProvider = FutureProvider<List<MapEntry<String, int>>>((ref) async {
  final now = DateTime.now();
  final thirtyDaysAgo = now.subtract(const Duration(days: 30));
  final snap = await _firestore
      .collection(AdminConstants.usersCollection)
      .where('createdAt', isGreaterThanOrEqualTo: Timestamp.fromDate(thirtyDaysAgo))
      .get();

  final counts = <String, int>{};
  for (var i = 0; i < 30; i++) {
    final date = now.subtract(Duration(days: 29 - i));
    counts[DateFormat('MM/dd').format(date)] = 0;
  }

  for (final doc in snap.docs) {
    final ts = (doc.data()['createdAt'] as Timestamp?)?.toDate();
    if (ts != null) {
      final key = DateFormat('MM/dd').format(ts);
      counts[key] = (counts[key] ?? 0) + 1;
    }
  }

  return counts.entries.toList();
});

final subjectDistributionProvider =
    FutureProvider<Map<String, int>>((ref) async {
  final snap =
      await _firestore.collection(AdminConstants.questionsCollection).get();

  final dist = <String, int>{};
  for (final doc in snap.docs) {
    final subject = doc.data()['subject'] as String? ?? 'Unknown';
    dist[subject] = (dist[subject] ?? 0) + 1;
  }
  return dist;
});

/// Admin Dashboard Screen
class AdminDashboardScreen extends ConsumerStatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  ConsumerState<AdminDashboardScreen> createState() =>
      _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends ConsumerState<AdminDashboardScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(adminPageTitleProvider.notifier).state = 'Dashboard';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ─── Stats Row 1: Core Metrics ───
        _buildStatCards(),
        const SizedBox(height: 12),
        // ─── Stats Row 2: Content Metrics ───
        _buildContentStatCards(),
        const SizedBox(height: 24),
        // ─── Charts Row ───
        LayoutBuilder(
          builder: (context, constraints) {
            if (constraints.maxWidth > 800) {
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(flex: 2, child: _buildUserGrowthChart()),
                  const SizedBox(width: 20),
                  Expanded(child: _buildSubjectPieChart()),
                ],
              );
            }
            return Column(
              children: [
                _buildUserGrowthChart(),
                const SizedBox(height: 20),
                _buildSubjectPieChart(),
              ],
            );
          },
        ),
        const SizedBox(height: 24),
        // ─── Quick Actions + Activity Feed ───
        LayoutBuilder(
          builder: (context, constraints) {
            if (constraints.maxWidth > 800) {
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: _buildQuickActions()),
                  const SizedBox(width: 20),
                  Expanded(flex: 2, child: _buildActivityFeed()),
                ],
              );
            }
            return Column(
              children: [
                _buildQuickActions(),
                const SizedBox(height: 20),
                _buildActivityFeed(),
              ],
            );
          },
        ),
      ],
    );
  }

  Widget _buildStatCards() {
    final users = ref.watch(totalUsersProvider);
    final questions = ref.watch(totalQuestionsProvider);
    final tests = ref.watch(totalMockTestsProvider);
    final activeToday = ref.watch(todayActiveUsersProvider);

    return LayoutBuilder(
      builder: (context, constraints) {
        final double spacing = 16.0;
        int crossCount = 4;
        if (constraints.maxWidth < 600) {
          crossCount = 1;
        } else if (constraints.maxWidth < 900) {
          crossCount = 2;
        }
        final cardWidth = (constraints.maxWidth - (crossCount - 1) * spacing) / crossCount;

        return Wrap(
          spacing: spacing,
          runSpacing: spacing,
          children: [
            SizedBox(
              width: cardWidth,
              child: AdminStatCard(
                label: 'Total Users',
                value: users.when(
                  data: (v) => _formatNumber(v),
                  loading: () => '—',
                  error: (_, __) => 'Err',
                ),
                icon: Icons.people_rounded,
                color: AdminTheme.info,
                isLoading: users.isLoading,
              ),
            ),
            SizedBox(
              width: cardWidth,
              child: AdminStatCard(
                label: 'Questions Added',
                value: questions.when(
                  data: (v) => _formatNumber(v),
                  loading: () => '—',
                  error: (_, __) => 'Err',
                ),
                icon: Icons.quiz_rounded,
                color: AdminTheme.success,
                isLoading: questions.isLoading,
              ),
            ),
            SizedBox(
              width: cardWidth,
              child: AdminStatCard(
                label: 'Mock Tests',
                value: tests.when(
                  data: (v) => _formatNumber(v),
                  loading: () => '—',
                  error: (_, __) => 'Err',
                ),
                icon: Icons.assignment_rounded,
                color: AdminTheme.saffron,
                isLoading: tests.isLoading,
              ),
            ),
            SizedBox(
              width: cardWidth,
              child: AdminStatCard(
                label: "Today's Active",
                value: activeToday.when(
                  data: (v) => _formatNumber(v),
                  loading: () => '—',
                  error: (_, __) => 'Err',
                ),
                icon: Icons.trending_up_rounded,
                color: AdminTheme.warning,
                isLoading: activeToday.isLoading,
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildContentStatCards() {
    final audioBooks = ref.watch(totalAudioBooksProvider);
    final materials = ref.watch(totalStudyMaterialsProvider);

    return LayoutBuilder(
      builder: (context, constraints) {
        final double spacing = 12.0;
        int crossCount = 2;
        if (constraints.maxWidth < 600) {
          crossCount = 1;
        }
        final cardWidth = (constraints.maxWidth - (crossCount - 1) * spacing) / crossCount;

        return Wrap(
          spacing: spacing,
          runSpacing: spacing,
          children: [
            SizedBox(
              width: cardWidth,
              child: AdminStatCard(
                label: 'Study Materials',
                value: materials.when(
                  data: (v) => _formatNumber(v),
                  loading: () => '—',
                  error: (_, __) => 'Err',
                ),
                icon: Icons.menu_book_rounded,
                color: const Color(0xFF2980B9),
                isLoading: materials.isLoading,
              ),
            ),
            SizedBox(
              width: cardWidth,
              child: AdminStatCard(
                label: 'Audio Books',
                value: audioBooks.when(
                  data: (v) => _formatNumber(v),
                  loading: () => '—',
                  error: (_, __) => 'Err',
                ),
                icon: Icons.headphones_rounded,
                color: const Color(0xFF9B59B6),
                isLoading: audioBooks.isLoading,
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildUserGrowthChart() {
    final growth = ref.watch(userGrowthProvider);

    return _ChartCard(
      title: 'User Registrations (30 Days)',
      child: growth.when(
        data: (entries) {
          if (entries.every((e) => e.value == 0)) {
            return const AdminEmptyState(
              icon: Icons.people_outline,
              message: 'No users registered yet.',
            );
          }
          final maxY = entries
              .map((e) => e.value.toDouble())
              .fold<double>(0, (a, b) => a > b ? a : b);
          return SizedBox(
            height: 240,
            child: LineChart(
              LineChartData(
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: (maxY / 4).clamp(1, double.infinity),
                  getDrawingHorizontalLine: (value) => FlLine(
                    color: AdminTheme.border,
                    strokeWidth: 1,
                  ),
                ),
                titlesData: FlTitlesData(
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 28,
                      interval: 5,
                      getTitlesWidget: (value, meta) {
                        final i = value.toInt();
                        if (i < 0 || i >= entries.length) {
                          return const SizedBox.shrink();
                        }
                        return Text(
                          entries[i].key,
                          style: const TextStyle(fontSize: 10, color: AdminTheme.textSecondary),
                        );
                      },
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 32,
                      getTitlesWidget: (value, meta) => Text(
                        value.toInt().toString(),
                        style: const TextStyle(fontSize: 10, color: AdminTheme.textSecondary),
                      ),
                    ),
                  ),
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                ),
                borderData: FlBorderData(show: false),
                lineBarsData: [
                  LineChartBarData(
                    spots: entries
                        .asMap()
                        .entries
                        .map((e) => FlSpot(e.key.toDouble(), e.value.value.toDouble()))
                        .toList(),
                    isCurved: true,
                    gradient: const LinearGradient(
                      colors: [AdminTheme.saffron, AdminTheme.info],
                    ),
                    barWidth: 3,
                    dotData: const FlDotData(show: false),
                    belowBarData: BarAreaData(
                      show: true,
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          AdminTheme.saffron.withValues(alpha: 0.15),
                          AdminTheme.info.withValues(alpha: 0.02),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
        loading: () => const SizedBox(
          height: 240,
          child: Center(child: CircularProgressIndicator()),
        ),
        error: (e, _) => SizedBox(
          height: 240,
          child: Center(child: Text('Error: $e')),
        ),
      ),
    );
  }

  Widget _buildSubjectPieChart() {
    final dist = ref.watch(subjectDistributionProvider);

    return _ChartCard(
      title: 'Subject Distribution',
      child: dist.when(
        data: (data) {
          if (data.isEmpty) {
            return const AdminEmptyState(
              icon: Icons.pie_chart_outline,
              message: 'No questions yet.',
            );
          }
          final total = data.values.fold<int>(0, (a, b) => a + b);
          final colors = [
            const Color(0xFF9B59B6),
            const Color(0xFF2980B9),
            const Color(0xFF27AE60),
            AdminTheme.saffron,
            AdminTheme.warning,
          ];
          return SizedBox(
            height: 240,
            child: Column(
              children: [
                Expanded(
                  child: PieChart(
                    PieChartData(
                      sectionsSpace: 2,
                      centerSpaceRadius: 40,
                      sections: data.entries.toList().asMap().entries.map((e) {
                        final pct = (e.value.value / total * 100);
                        return PieChartSectionData(
                          value: e.value.value.toDouble(),
                          title: '${pct.toStringAsFixed(0)}%',
                          color: colors[e.key % colors.length],
                          radius: 50,
                          titleStyle: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 16,
                  runSpacing: 6,
                  children: data.entries.toList().asMap().entries.map((e) {
                    return Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 10,
                          height: 10,
                          decoration: BoxDecoration(
                            color: colors[e.key % colors.length],
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          '${e.value.key} (${e.value.value})',
                          style: const TextStyle(
                            fontSize: 11,
                            color: AdminTheme.textSecondary,
                          ),
                        ),
                      ],
                    );
                  }).toList(),
                ),
              ],
            ),
          );
        },
        loading: () => const SizedBox(
          height: 240,
          child: Center(child: CircularProgressIndicator()),
        ),
        error: (e, _) => SizedBox(
          height: 240,
          child: Center(child: Text('Error: $e')),
        ),
      ),
    );
  }

  Widget _buildQuickActions() {
    return _ChartCard(
      title: 'Quick Actions',
      child: Column(
        children: [
          _QuickActionTile(
            icon: Icons.add_circle_outline,
            label: 'Add Question',
            color: AdminTheme.info,
            route: '/admin/questions/add',
          ),
          _QuickActionTile(
            icon: Icons.upload_file,
            label: 'Upload PDF',
            color: AdminTheme.success,
            route: '/admin/materials/upload',
          ),
          _QuickActionTile(
            icon: Icons.notifications_active_outlined,
            label: 'Send Notification',
            color: AdminTheme.warning,
            route: '/admin/notifications/compose',
          ),
          _QuickActionTile(
            icon: Icons.newspaper_outlined,
            label: 'Add Current Affairs',
            color: AdminTheme.saffron,
            route: '/admin/current-affairs/add',
          ),
          _QuickActionTile(
            icon: Icons.headphones_rounded,
            label: 'Add Audio Book',
            color: const Color(0xFF9B59B6),
            route: '/admin/audio-books/add',
          ),
        ],
      ),
    );
  }

  Widget _buildActivityFeed() {
    final activity = ref.watch(recentActivityProvider);

    return _ChartCard(
      title: 'Recent Activity',
      child: activity.when(
        data: (items) {
          if (items.isEmpty) {
            return const AdminEmptyState(
              icon: Icons.history,
              message: 'No activity recorded yet.',
            );
          }
          return Column(
            children: items.map((item) {
              final ts = (item['timestamp'] as Timestamp?)?.toDate();
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: AdminTheme.saffron.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.bolt, size: 16, color: AdminTheme.saffron),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item['action'] ?? 'Unknown action',
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Text(
                            '${item['targetCollection']} ${item['targetId'] ?? ''}',
                            style: const TextStyle(
                              fontSize: 11,
                              color: AdminTheme.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (ts != null)
                      Text(
                        formatTimeAgo(ts),
                        style: const TextStyle(
                          fontSize: 11,
                          color: AdminTheme.textSecondary,
                        ),
                      ),
                  ],
                ),
              );
            }).toList(),
          );
        },
        loading: () => const Center(
          child: Padding(
            padding: EdgeInsets.all(24),
            child: CircularProgressIndicator(),
          ),
        ),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
    );
  }

  String _formatNumber(int n) {
    if (n >= 1000000) return '${(n / 1000000).toStringAsFixed(1)}M';
    if (n >= 1000) return '${(n / 1000).toStringAsFixed(1)}K';
    return n.toString();
  }
}

// ─── Helper Widgets ───

class _ChartCard extends StatelessWidget {
  final String title;
  final Widget child;

  const _ChartCard({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AdminTheme.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: AdminTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }
}

class _QuickActionTile extends StatefulWidget {
  final IconData icon;
  final String label;
  final Color color;
  final String route;

  const _QuickActionTile({
    required this.icon,
    required this.label,
    required this.color,
    required this.route,
  });

  @override
  State<_QuickActionTile> createState() => _QuickActionTileState();
}

class _QuickActionTileState extends State<_QuickActionTile> {
  bool _hovering = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovering = true),
      onExit: (_) => setState(() => _hovering = false),
      child: GestureDetector(
        onTap: () {
          context.go(widget.route);
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: _hovering
                ? widget.color.withValues(alpha: 0.06)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: _hovering ? widget.color.withValues(alpha: 0.3) : AdminTheme.border,
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: widget.color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(widget.icon, size: 18, color: widget.color),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  widget.label,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: _hovering ? widget.color : AdminTheme.textPrimary,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              Icon(
                Icons.arrow_forward_ios,
                size: 14,
                color: _hovering ? widget.color : AdminTheme.textSecondary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
