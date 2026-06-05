import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:shimmer/shimmer.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../auth/providers/auth_providers.dart';
import '../providers/dashboard_providers.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  @override
  Widget build(BuildContext context) {
    final user = ref.watch(currentUserProvider);
    final statsAsync = ref.watch(dashboardStatsProvider);
    final affairsAsync = ref.watch(currentAffairsPreviewProvider);
    final leaderboardAsync = ref.watch(leaderboardPreviewProvider);
    final quote = ref.watch(dailyQuoteProvider);

    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            ref.invalidate(dashboardStatsProvider);
            ref.invalidate(currentAffairsPreviewProvider);
            ref.invalidate(leaderboardPreviewProvider);
          },
          child: CustomScrollView(
            slivers: [
              // 1. HEADER BAR
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _getGreeting(),
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: Colors.grey.shade600,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              user?.displayName ?? 'Scholar',
                              style: Theme.of(context).textTheme.headlineMedium,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Badge(
                          label: Text('3'),
                          child: Icon(Icons.notifications_outlined, size: 28),
                        ),
                        onPressed: () => context.push('/notifications'),
                      ),
                      const SizedBox(width: 8),
                      GestureDetector(
                        onTap: () => context.go('/home/profile'),
                        child: CircleAvatar(
                          radius: 20,
                          backgroundColor: Theme.of(context).colorScheme.primary.withValues(alpha: 0.2),
                          backgroundImage: user?.photoURL != null ? NetworkImage(user!.photoURL!) : null,
                          child: user?.photoURL == null 
                              ? Text((user?.displayName ?? 'S')[0].toUpperCase(), style: TextStyle(color: Theme.of(context).colorScheme.primary, fontWeight: FontWeight.bold))
                              : null,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // 2. EXAM COUNTDOWN CARD
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  child: _buildCountdownCard(context, statsAsync),
                ),
              ),

              // 3. DAILY TARGET STRIP
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  child: _buildDailyTarget(context, statsAsync),
                ),
              ),

              // 4. QUICK ACTION GRID
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  child: _buildQuickActions(context),
                ),
              ),

              // 5. SUBJECT PERFORMANCE MINI-CHART
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  child: _buildPerformanceChart(context, statsAsync),
                ),
              ),

              // 6. TODAY'S CURRENT AFFAIRS PREVIEW
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  child: _buildCurrentAffairs(context, affairsAsync),
                ),
              ),

              // 7. MOTIVATIONAL QUOTE
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  child: _buildMotivationalQuote(context, quote),
                ),
              ),

              // 8. LEADERBOARD PREVIEW
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 10, 20, 40),
                  child: _buildLeaderboard(context, leaderboardAsync),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good Morning 🌅 / காலை வணக்கம்';
    if (hour < 17) return 'Good Afternoon ☀️ / மதிய வணக்கம்';
    return 'Good Evening 🌙 / மாலை வணக்கம்';
  }

  Widget _buildCountdownCard(BuildContext context, AsyncValue<DashboardStats> statsAsync) {
    final daysRemaining = AppConstants.examTargetDate.difference(DateTime.now()).inDays;
    
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Theme.of(context).colorScheme.tertiary, // primaryNavy
            Theme.of(context).colorScheme.tertiary.withValues(alpha: 0.8), // dark blue
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).colorScheme.tertiary.withValues(alpha: 0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            right: -20,
            top: -20,
            child: Icon(Icons.local_fire_department, size: 120, color: Colors.white.withValues(alpha: 0.05)),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'TNPSC Group 4 Exam',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Colors.white70,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '$daysRemaining',
                    style: Theme.of(context).textTheme.displayLarge?.copyWith(
                      color: Colors.white,
                      height: 1,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 6.0),
                    child: Text(
                      'days remaining',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Theme.of(context).colorScheme.secondary, // flameGold
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              statsAsync.when(
                data: (stats) => Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Your readiness:', style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.white70)),
                          const SizedBox(height: 6),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: LinearProgressIndicator(
                              value: stats.readinessPercentage / 100,
                              backgroundColor: Colors.white.withValues(alpha: 0.2),
                              valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).colorScheme.secondary),
                              minHeight: 8,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    Text(
                      '${stats.readinessPercentage}%',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(color: Colors.white),
                    ),
                  ],
                ),
                loading: () => Shimmer.fromColors(
                  baseColor: Colors.white.withValues(alpha: 0.2),
                  highlightColor: Colors.white.withValues(alpha: 0.4),
                  child: Container(height: 20, width: 200, color: Colors.white),
                ),
                error: (_, __) => const SizedBox(),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDailyTarget(BuildContext context, AsyncValue<DashboardStats> statsAsync) {
    return statsAsync.when(
      data: (stats) {
        final progress = stats.todayTargetCompleted / stats.todayTargetTotal;
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Theme.of(context).cardTheme.color,
            borderRadius: BorderRadius.circular(16),
            boxShadow: Theme.of(context).cardTheme.shadowColor != null 
                ? [BoxShadow(color: Theme.of(context).cardTheme.shadowColor!, blurRadius: 8, offset: const Offset(0, 2))]
                : null,
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Today\'s Target: ${stats.todayTargetTotal} Questions',
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                    const SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: progress,
                        backgroundColor: Colors.grey.shade200,
                        valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).colorScheme.primary),
                        minHeight: 8,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${stats.todayTargetCompleted} completed',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey.shade600),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    const Text('🔥', style: TextStyle(fontSize: 20)),
                    Text(
                      '${stats.streakDays} Day',
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: Theme.of(context).colorScheme.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
      loading: () => Shimmer.fromColors(
        baseColor: Colors.grey.shade300,
        highlightColor: Colors.grey.shade100,
        child: Container(height: 80, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16))),
      ),
      error: (_, __) => const SizedBox(),
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 16,
      crossAxisSpacing: 16,
      childAspectRatio: 1.5,
      children: [
        _ActionCard(
          icon: Icons.play_circle_fill,
          titleEn: 'Start Mock Test',
          titleTa: 'மாதிரி தேர்வு',
          color: const Color(0xFFF07020), // Flame Orange
          onTap: () => context.go('/home/tests'),
          badge: 'New',
        ),
        _ActionCard(
          icon: Icons.auto_stories,
          titleEn: 'Question Bank',
          titleTa: 'கேள்வி வங்கி',
          color: const Color(0xFF2ECC71), // Success Green
          onTap: () => context.push('/question-bank'),
        ),
        _ActionCard(
          icon: Icons.menu_book,
          titleEn: 'Study Notes',
          titleTa: 'பாடக் குறிப்புகள்',
          color: const Color(0xFFF5C518), // Flame Gold
          onTap: () => context.go('/home/materials'),
        ),
        _ActionCard(
          icon: Icons.newspaper,
          titleEn: 'Current Affairs',
          titleTa: 'நடப்பு நிகழ்வுகள்',
          color: const Color(0xFFE74C3C), // Error Red
          onTap: () => context.go('/home/current'),
          badge: '3',
        ),
      ],
    );
  }

  Widget _buildPerformanceChart(BuildContext context, AsyncValue<DashboardStats> statsAsync) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Subject Performance', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 16),
        Container(
          height: 220,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Theme.of(context).cardTheme.color,
            borderRadius: BorderRadius.circular(16),
          ),
          child: statsAsync.when(
            data: (stats) {
              final subjects = stats.subjectScores.keys.toList();
              return BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  maxY: 100,
                  barTouchData: BarTouchData(enabled: false),
                  titlesData: FlTitlesData(
                    show: true,
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          if (value.toInt() < 0 || value.toInt() >= subjects.length) return const SizedBox();
                          final text = subjects[value.toInt()].split(' ').last; // Shorten
                          return Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Text(text, style: const TextStyle(fontSize: 10)),
                          );
                        },
                      ),
                    ),
                    leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  ),
                  gridData: const FlGridData(show: false),
                  borderData: FlBorderData(show: false),
                  barGroups: subjects.asMap().entries.map((e) {
                    final score = stats.subjectScores[e.value]!;
                    return BarChartGroupData(
                      x: e.key,
                      barRods: [
                        BarChartRodData(
                          toY: score,
                          color: score > 70 ? const Color(0xFF2ECC71) : (score > 40 ? const Color(0xFFF5C518) : const Color(0xFFE74C3C)),
                          width: 16,
                          borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
                        )
                      ],
                    );
                  }).toList(),
                ),
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (_, __) => const Center(child: Text('Failed to load chart')),
          ),
        ),
      ],
    );
  }

  Widget _buildCurrentAffairs(BuildContext context, AsyncValue<List<CurrentAffairPreview>> affairsAsync) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Today\'s Updates', style: Theme.of(context).textTheme.titleLarge),
            TextButton(
              onPressed: () => context.go('/home/current'),
              child: const Text('View All'),
            ),
          ],
        ),
        affairsAsync.when(
          data: (affairs) => Column(
            children: affairs.map((article) => Card(
              margin: const EdgeInsets.only(bottom: 12),
              child: ListTile(
                contentPadding: const EdgeInsets.all(16),
                title: Text(article.title, style: Theme.of(context).textTheme.titleMedium, maxLines: 2, overflow: TextOverflow.ellipsis),
                subtitle: Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(article.category, style: Theme.of(context).textTheme.labelSmall?.copyWith(color: Theme.of(context).colorScheme.primary)),
                      ),
                      const SizedBox(width: 12),
                      Text(DateFormat('MMM dd').format(article.date), style: Theme.of(context).textTheme.bodySmall),
                    ],
                  ),
                ),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => context.push('/current-affairs/${article.id}'),
              ),
            )).toList(),
          ),
          loading: () => Shimmer.fromColors(
            baseColor: Colors.grey.shade300,
            highlightColor: Colors.grey.shade100,
            child: Column(
              children: List.generate(3, (index) => Container(
                height: 80, margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
              )),
            ),
          ),
          error: (_, __) => const SizedBox(),
        ),
      ],
    );
  }

  Widget _buildMotivationalQuote(BuildContext context, Map<String, String> quote) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.secondary.withValues(alpha: 0.1), // Flame Gold
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Theme.of(context).colorScheme.secondary.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          const Icon(Icons.format_quote, size: 40, color: Color(0xFFF5C518)),
          const SizedBox(height: 12),
          Text(
            quote['tamil']!,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(height: 1.5),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Text(
            quote['english']!,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.grey.shade700,
              fontStyle: FontStyle.italic,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildLeaderboard(BuildContext context, AsyncValue<LeaderboardPreview> leaderboardAsync) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Leaderboard', style: Theme.of(context).textTheme.titleLarge),
            TextButton(
              onPressed: () => context.push('/leaderboard'),
              child: const Text('View Full'),
            ),
          ],
        ),
        leaderboardAsync.when(
          data: (data) => Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).cardTheme.color,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.emoji_events, color: Color(0xFFF5C518)),
                      const SizedBox(width: 8),
                      Text('Your Rank: #${data.userRank} in Tamil Nadu', style: Theme.of(context).textTheme.titleMedium),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    _LeaderboardPodium(user: data.topUsers[1], rank: 2, height: 80, color: Colors.grey.shade400),
                    _LeaderboardPodium(user: data.topUsers[0], rank: 1, height: 100, color: const Color(0xFFF5C518)),
                    _LeaderboardPodium(user: data.topUsers[2], rank: 3, height: 70, color: const Color(0xFFCD7F32)),
                  ],
                ),
              ],
            ),
          ),
          loading: () => Shimmer.fromColors(
            baseColor: Colors.grey.shade300,
            highlightColor: Colors.grey.shade100,
            child: Container(height: 200, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16))),
          ),
          error: (_, __) => const SizedBox(),
        ),
      ],
    );
  }
}

class _ActionCard extends StatelessWidget {
  final IconData icon;
  final String titleEn;
  final String titleTa;
  final Color color;
  final VoidCallback onTap;
  final String? badge;

  const _ActionCard({
    required this.icon,
    required this.titleEn,
    required this.titleTa,
    required this.color,
    required this.onTap,
    this.badge,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(icon, color: color, size: 28),
                  const Spacer(),
                  Text(titleEn, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                  Text(titleTa, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey.shade700)),
                ],
              ),
            ),
            if (badge != null)
              Positioned(
                top: 12,
                right: 12,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(8)),
                  child: Text(badge!, style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _LeaderboardPodium extends StatelessWidget {
  final LeaderboardUser user;
  final int rank;
  final double height;
  final Color color;

  const _LeaderboardPodium({required this.user, required this.rank, required this.height, required this.color});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CircleAvatar(
          radius: 20,
          backgroundColor: color.withValues(alpha: 0.2),
          child: Text(user.name[0], style: TextStyle(color: color, fontWeight: FontWeight.bold)),
        ),
        const SizedBox(height: 8),
        Text(user.name.split(' ').first, style: Theme.of(context).textTheme.bodySmall, overflow: TextOverflow.ellipsis),
        Text(user.score.toString(), style: Theme.of(context).textTheme.labelSmall?.copyWith(color: Colors.grey.shade600)),
        const SizedBox(height: 8),
        Container(
          width: 60,
          height: height,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.2),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
            border: Border(top: BorderSide(color: color, width: 4)),
          ),
          child: Center(
            child: Text('$rank', style: Theme.of(context).textTheme.headlineMedium?.copyWith(color: color, fontWeight: FontWeight.bold)),
          ),
        ),
      ],
    );
  }
}
