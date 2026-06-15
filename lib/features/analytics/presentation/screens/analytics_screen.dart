import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../providers/analytics_providers.dart';
import '../../../../shared/models/test_attempt_model.dart';
import '../../../../shared/providers/firestore_providers.dart';

class AnalyticsScreen extends ConsumerWidget {
  const AnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Analytics'),
          elevation: 0,
          bottom: const TabBar(
            indicatorColor: AppColors.accentSaffron,
            labelColor: AppColors.accentSaffron,
            unselectedLabelColor: Colors.grey,
            tabs: [
              Tab(text: 'Dashboard'),
              Tab(text: 'Test History'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            CustomScrollView(
              slivers: [
                SliverToBoxAdapter(child: _buildOverviewRow(ref, isDark)),
                SliverToBoxAdapter(child: _buildSectionTitle('Subject Performance', 'Current vs Last Week', isDark)),
                SliverToBoxAdapter(child: _buildRadarChart(context, ref, isDark)),
                SliverToBoxAdapter(child: _buildSectionTitle('Score Trend', 'Last 10 Tests', isDark)),
                SliverToBoxAdapter(child: _buildTrendLineChart(context, ref)),
                SliverToBoxAdapter(child: _buildSectionTitle('Activity Heatmap', 'Last 90 Days', isDark)),
                SliverToBoxAdapter(child: _buildActivityHeatmap(context, ref, isDark)),
                SliverToBoxAdapter(child: _buildSectionTitle('Weak Topics', 'Focus on these areas', isDark)),
                SliverToBoxAdapter(child: _buildWeakTopicsTable(context, ref)),
                SliverToBoxAdapter(child: _buildSectionTitle('Improvement Tips', 'Auto-generated insights', isDark)),
                SliverToBoxAdapter(child: _buildImprovementTips(context, ref)),
                const SliverPadding(padding: EdgeInsets.only(bottom: 40)),
              ],
            ),
            const _TestHistoryTab(),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title, String subtitle, bool isDark) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          Text(subtitle, style: TextStyle(fontSize: 12, color: isDark ? Colors.grey.shade400 : Colors.grey.shade600)),
        ],
      ),
    );
  }

  Widget _buildOverviewRow(WidgetRef ref, bool isDark) {
    final statsAsync = ref.watch(analyticsStatsProvider);

    return statsAsync.when(
      loading: () => const SizedBox(height: 100, child: Center(child: CircularProgressIndicator())),
      error: (_, __) => const SizedBox(height: 100, child: Center(child: Text('Error loading stats'))),
      data: (stats) {
        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          child: Row(
            children: [
              _OverviewCard(title: 'Tests Taken', value: '${stats.testsTaken}', icon: Icons.assignment, color: isDark ? Colors.white : AppColors.primaryNavy),
              _OverviewCard(title: 'Avg Score', value: '${stats.avgScore.toStringAsFixed(1)}%', icon: Icons.analytics, color: AppColors.accentSaffron),
              _OverviewCard(title: 'Best Score', value: '${stats.bestScore}%', icon: Icons.emoji_events, color: AppColors.success),
              _OverviewCard(title: 'Time Studied', value: _formatTime(stats.totalTimeStudied), icon: Icons.timer, color: AppColors.info),
            ],
          ),
        );
      },
    );
  }

  String _formatTime(int seconds) {
    if (seconds < 3600) {
      return '${(seconds / 60).ceil()}m';
    }
    return '${(seconds / 3600).toStringAsFixed(1)}h';
  }

  Widget _buildRadarChart(BuildContext context, WidgetRef ref, bool isDark) {
    final radarAsync = ref.watch(radarChartProvider);

    return radarAsync.when(
      loading: () => const SizedBox(height: 300, child: Center(child: CircularProgressIndicator())),
      error: (_, __) => const SizedBox(height: 300, child: Center(child: Text('Error loading chart'))),
      data: (data) {
        final current = data['current'] ?? {};
        final previous = data['previous'] ?? {};

        if (current.isEmpty && previous.isEmpty) {
          return const SizedBox(height: 200, child: Center(child: Text('Not enough data to display radar chart.')));
        }

        // 5 standard axes
        final subjects = ['Gen. Tamil', 'Gen. English', 'GK', 'Aptitude', 'Mental Ability'];

        RadarDataSet createDataSet(Map<String, double> source, Color color) {
          return RadarDataSet(
            fillColor: color.withValues(alpha: 0.2),
            borderColor: color,
            entryRadius: 3,
            dataEntries: subjects.map((subj) {
              double val = 0;
              // fuzzy match
              final key = source.keys.firstWhere((k) => k.toLowerCase().contains(subj.toLowerCase().replaceAll('gen. ', '')), orElse: () => '');
              if (key.isNotEmpty) val = source[key]!;
              return RadarEntry(value: val);
            }).toList(),
            borderWidth: 2,
          );
        }

        return Container(
          height: 300,
          margin: const EdgeInsets.symmetric(horizontal: 16),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(color: Theme.of(context).cardColor, borderRadius: BorderRadius.circular(16)),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _LegendItem(color: AppColors.accentSaffron, label: 'Current Week'),
                  const SizedBox(width: 16),
                  _LegendItem(color: isDark ? Colors.blue : AppColors.primaryNavy, label: 'Last Week'),
                ],
              ),
              Expanded(
                child: RadarChart(
                  RadarChartData(
                    radarShape: RadarShape.polygon,
                    tickCount: 5,
                    ticksTextStyle: const TextStyle(fontSize: 10, color: Colors.transparent),
                    titleTextStyle: TextStyle(color: isDark ? Colors.white70 : Colors.black87, fontSize: 10),
                    titlePositionPercentageOffset: 0.1,
                    getTitle: (index, angle) {
                      return RadarChartTitle(
                        text: subjects[index],
                        angle: 0, // Keep titles straight
                      );
                    },
                    dataSets: [
                      if (previous.isNotEmpty) createDataSet(previous, isDark ? Colors.blue : AppColors.primaryNavy),
                      if (current.isNotEmpty) createDataSet(current, AppColors.accentSaffron),
                    ],
                  ),
                  swapAnimationDuration: const Duration(milliseconds: 400),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTrendLineChart(BuildContext context, WidgetRef ref) {
    final trendAsync = ref.watch(trendLineProvider);

    return trendAsync.when(
      loading: () => const SizedBox(height: 250, child: Center(child: CircularProgressIndicator())),
      error: (_, __) => const SizedBox(height: 250, child: Center(child: Text('Error loading chart'))),
      data: (attempts) {
        if (attempts.length < 2) {
          return const SizedBox(height: 150, child: Center(child: Text('Take at least 2 tests to see your trend.')));
        }

        final spots = attempts.asMap().entries.map((e) {
          return FlSpot(e.key.toDouble(), e.value.score.toDouble());
        }).toList();

        final isUpward = attempts.last.score >= attempts.first.score;

        return Container(
          height: 250,
          margin: const EdgeInsets.symmetric(horizontal: 16),
          padding: const EdgeInsets.only(right: 16, top: 16, bottom: 16),
          decoration: BoxDecoration(color: Theme.of(context).cardColor, borderRadius: BorderRadius.circular(16)),
          child: LineChart(
            LineChartData(
              gridData: const FlGridData(show: false),
              titlesData: FlTitlesData(
                rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 22,
                    getTitlesWidget: (value, meta) {
                      if (value.toInt() < 0 || value.toInt() >= attempts.length) return const SizedBox();
                      if (value.toInt() % 2 != 0) return const SizedBox(); // Show alternate
                      final date = attempts[value.toInt()].startedAt;
                      return Text('${date.day}/${date.month}', style: const TextStyle(fontSize: 10));
                    },
                  ),
                ),
              ),
              borderData: FlBorderData(show: false),
              minY: 0,
              maxY: 100,
              lineBarsData: [
                LineChartBarData(
                  spots: spots,
                  isCurved: true,
                  color: isUpward ? AppColors.success : AppColors.warning,
                  barWidth: 3,
                  isStrokeCapRound: true,
                  dotData: const FlDotData(show: true),
                  belowBarData: BarAreaData(
                    show: true,
                    color: (isUpward ? AppColors.success : AppColors.warning).withValues(alpha: 0.1),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildActivityHeatmap(BuildContext context, WidgetRef ref, bool isDark) {
    final heatmapAsync = ref.watch(heatmapProvider);

    return heatmapAsync.when(
      loading: () => const SizedBox(height: 150, child: Center(child: CircularProgressIndicator())),
      error: (_, __) => const SizedBox(height: 150, child: Center(child: Text('Error loading heatmap'))),
      data: (activityMap) {
        // Last 90 days
        final today = DateTime.now();
        final days = List.generate(90, (i) {
          final date = today.subtract(Duration(days: 89 - i));
          return DateTime(date.year, date.month, date.day);
        });

        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(color: Theme.of(context).cardColor, borderRadius: BorderRadius.circular(16)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: 120, // 7 rows * ~15px + spacing
                child: GridView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: days.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 7, // 7 days a week
                    mainAxisSpacing: 4,
                    crossAxisSpacing: 4,
                  ),
                  itemBuilder: (context, index) {
                    final date = days[index];
                    final questions = activityMap[date] ?? 0;
                    
                    Color color = isDark ? const Color(0xFF1F324E) : Colors.grey.shade200;
                    if (questions > 0) color = AppColors.success.withValues(alpha: 0.2);
                    if (questions >= 20) color = AppColors.success.withValues(alpha: 0.5);
                    if (questions >= 50) color = AppColors.success.withValues(alpha: 0.8);
                    if (questions >= 100) color = AppColors.success;

                    return Tooltip(
                      message: '${date.day}/${date.month}: $questions Qs',
                      child: Container(
                        decoration: BoxDecoration(
                          color: color,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  const Text('Less ', style: TextStyle(fontSize: 10)),
                  Container(width: 10, height: 10, color: isDark ? const Color(0xFF1F324E) : Colors.grey.shade200),
                  const SizedBox(width: 4),
                  Container(width: 10, height: 10, color: AppColors.success.withValues(alpha: 0.2)),
                  const SizedBox(width: 4),
                  Container(width: 10, height: 10, color: AppColors.success.withValues(alpha: 0.5)),
                  const SizedBox(width: 4),
                  Container(width: 10, height: 10, color: AppColors.success),
                  const Text(' More', style: TextStyle(fontSize: 10)),
                ],
              )
            ],
          ),
        );
      },
    );
  }

  Widget _buildWeakTopicsTable(BuildContext context, WidgetRef ref) {
    final topicsAsync = ref.watch(weakTopicsProvider);

    return topicsAsync.when(
      loading: () => const SizedBox(height: 100, child: Center(child: CircularProgressIndicator())),
      error: (_, __) => const SizedBox(height: 100, child: Center(child: Text('Error loading weak topics'))),
      data: (topics) {
        if (topics.isEmpty) {
          return const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Text('Take more tests to identify your weak topics.'),
          );
        }

        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Column(
            children: topics.map((topic) {
              return ListTile(
                title: Text(topic.topic, style: const TextStyle(fontWeight: FontWeight.w500)),
                subtitle: Text('Avg Score: ${topic.avgScore.toStringAsFixed(1)}%'),
                trailing: ElevatedButton(
                  onPressed: () {
                    context.push('/question-bank');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.accentSaffron.withValues(alpha: 0.1),
                    foregroundColor: AppColors.accentSaffron,
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  ),
                  child: const Text('Practice Now', style: TextStyle(fontSize: 12)),
                ),
              );
            }).toList(),
          ),
        );
      },
    );
  }

  Widget _buildImprovementTips(BuildContext context, WidgetRef ref) {
    final tipsAsync = ref.watch(improvementTipsProvider);

    return tipsAsync.when(
      loading: () => const SizedBox(height: 100, child: Center(child: CircularProgressIndicator())),
      error: (_, __) => const SizedBox(height: 100, child: Center(child: Text('Error loading tips'))),
      data: (tips) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            children: tips.map((tip) {
              final isPositive = tip.contains('Great job') || tip.contains('steady');
              return Card(
                margin: const EdgeInsets.only(bottom: 8),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                color: isPositive ? AppColors.success.withValues(alpha: 0.05) : AppColors.warning.withValues(alpha: 0.05),
                child: ListTile(
                  leading: Icon(
                    isPositive ? Icons.thumb_up_alt : Icons.lightbulb,
                    color: isPositive ? AppColors.success : AppColors.accentSaffron,
                  ),
                  title: Text(tip, style: const TextStyle(fontSize: 14)),
                ),
              );
            }).toList(),
          ),
        );
      },
    );
  }
}

class _OverviewCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _OverviewCard({required this.title, required this.value, required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      width: 130,
      margin: const EdgeInsets.only(right: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 12),
          Text(value, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(title, style: TextStyle(fontSize: 12, color: isDark ? Colors.grey.shade400 : Colors.grey.shade600)),
        ],
      ),
    );
  }
}

class _LegendItem extends StatelessWidget {
  final Color color;
  final String label;

  const _LegendItem({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(width: 12, height: 12, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 6),
        Text(label, style: const TextStyle(fontSize: 12)),
      ],
    );
  }
}

class _TestHistoryTab extends ConsumerWidget {
  const _TestHistoryTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final attemptsAsync = ref.watch(testAttemptsProvider);

    return attemptsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator(color: AppColors.accentSaffron)),
      error: (err, stack) => Center(child: Text('Error loading test history: $err')),
      data: (attempts) {
        if (attempts.isEmpty) {
          return const Center(
            child: Text('No test attempts found. Take a test to see history!'),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.only(top: 8, bottom: 40),
          itemCount: attempts.length,
          itemBuilder: (context, index) {
            final attempt = attempts[index];
            return _TestHistoryItem(attempt: attempt);
          },
        );
      },
    );
  }
}

class _TestHistoryItem extends ConsumerWidget {
  final TestAttemptModel attempt;

  const _TestHistoryItem({required this.attempt});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final testAsync = ref.watch(singleMockTestProvider(attempt.testId));
    final date = attempt.completedAt ?? attempt.startedAt;
    final formattedDate = '${date.day}/${date.month}/${date.year} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return testAsync.when(
      loading: () => const ListTile(title: Text('Loading test info...')),
      error: (_, __) => _buildTile(context, 'Mock Test (${attempt.testId})', formattedDate, isDark),
      data: (test) {
        final title = test?.title ?? 'Mock Test';
        return _buildTile(context, title, formattedDate, isDark);
      },
    );
  }

  Widget _buildTile(BuildContext context, String title, String formattedDate, bool isDark) {
    final scorePercent = attempt.totalQuestions > 0 ? (attempt.correctCount / attempt.totalQuestions * 100).round() : 0;
    
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 0,
      color: Theme.of(context).cardColor,
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        leading: CircleAvatar(
          radius: 24,
          backgroundColor: AppColors.primaryNavy.withValues(alpha: 0.1),
          child: const Icon(Icons.assignment_turned_in, color: AppColors.primaryNavy),
        ),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 6),
            Text(
              formattedDate,
              style: TextStyle(fontSize: 12, color: isDark ? Colors.grey.shade400 : Colors.grey.shade600),
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                _buildStatMiniBadge(Icons.check_circle_outline, '${attempt.correctCount} Correct', AppColors.success),
                const SizedBox(width: 8),
                _buildStatMiniBadge(Icons.cancel_outlined, '${attempt.incorrectCount} Incorrect', AppColors.error),
              ],
            ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '${attempt.score} Pts',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.accentSaffron),
                ),
                Text(
                  '$scorePercent%',
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
            const SizedBox(width: 8),
            const Icon(Icons.chevron_right, color: Colors.grey),
          ],
        ),
        onTap: () {
          context.push('/test-result/${attempt.id}');
        },
      ),
    );
  }

  Widget _buildStatMiniBadge(IconData icon, String text, Color color) {
    return Row(
      children: [
        Icon(icon, size: 12, color: color),
        const SizedBox(width: 2),
        Text(text, style: TextStyle(fontSize: 10, color: color, fontWeight: FontWeight.w500)),
      ],
    );
  }
}
