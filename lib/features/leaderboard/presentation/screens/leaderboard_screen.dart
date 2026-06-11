import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../shared/models/leaderboard_entry_model.dart';
import '../../../../shared/providers/app_providers.dart';
import '../../../../shared/providers/firestore_providers.dart';
import '../../../auth/providers/auth_providers.dart';

class LeaderboardScreen extends ConsumerStatefulWidget {
  const LeaderboardScreen({super.key});

  @override
  ConsumerState<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends ConsumerState<LeaderboardScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Leaderboard'),
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          indicatorColor: AppColors.accentSaffron,
          labelColor: isDark ? Colors.white : AppColors.primaryNavy,
          unselectedLabelColor: isDark ? Colors.white54 : Colors.grey.shade600,
          tabs: const [
            Tab(text: 'State-wide'),
            Tab(text: 'District'),
            Tab(text: 'Weekly'),
            Tab(text: 'Friends'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildLeaderboardView(context, ref, 'state'),
          _buildLeaderboardView(context, ref, 'district'),
          _buildLeaderboardView(context, ref, 'weekly'),
          _buildLeaderboardView(context, ref, 'friends'),
        ],
      ),
    );
  }

  Widget _buildLeaderboardView(BuildContext context, WidgetRef ref, String filter) {
    final leaderboardAsync = ref.watch(leaderboardStreamProvider);
    final currentUser = ref.watch(userModelProvider).value;
    final currentUserId = ref.watch(authUidProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return leaderboardAsync.when(
      loading: () => const Center(child: CircularProgressIndicator(color: AppColors.accentSaffron)),
      error: (_, __) => const Center(child: Text('Error loading leaderboard', style: TextStyle(color: Colors.grey))),
      data: (maps) {
        if (maps.isEmpty) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.leaderboard, color: isDark ? Colors.grey.shade700 : Colors.grey.shade300, size: 64),
                const SizedBox(height: 12),
                Text('Leaderboard is empty', style: TextStyle(color: isDark ? Colors.grey.shade400 : Colors.grey.shade500, fontSize: 16)),
                const SizedBox(height: 4),
                Text('Start taking tests to appear here!', style: TextStyle(color: isDark ? Colors.grey.shade500 : Colors.grey.shade400, fontSize: 13)),
              ],
            ),
          );
        }

        // Map and sort dynamically
        var entries = maps.map((m) => LeaderboardEntry.fromMap(m)).toList();
        
        // Dynamic filtering
        if (filter == 'district' && currentUser != null) {
          entries = entries.where((e) => e.district == currentUser.district).toList();
        } else if (filter == 'weekly') {
          entries.sort((a, b) => b.weeklyScore.compareTo(a.weeklyScore));
        } else {
          // Default State-wide sort
          entries.sort((a, b) => b.totalScore.compareTo(a.totalScore));
        }

        if (entries.isEmpty) {
          return const Center(child: Text('No entries found for this filter.'));
        }

        final top3 = entries.take(3).toList();
        final rest = entries.skip(3).toList();

        LeaderboardEntry? myEntry;
        int myRank = -1;
        for (int i = 0; i < entries.length; i++) {
          if (entries[i].userId == currentUserId) {
            myEntry = entries[i];
            myRank = i + 1;
            break;
          }
        }

        return Column(
          children: [
            _buildWeeklyChallengeCard(),
            Expanded(
              child: CustomScrollView(
                slivers: [
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 24.0),
                      child: _buildPodium(top3, filter == 'weekly', isDark),
                    ),
                  ),
                  SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final entry = rest[index];
                        final rank = index + 4; // Since top 3 are in podium
                        final isMe = entry.userId == currentUserId;

                        return _buildListRow(entry, rank, isMe, filter == 'weekly', isDark);
                      },
                      childCount: rest.length,
                    ),
                  ),
                ],
              ),
            ),
            if (myEntry != null)
              Container(
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF152A4A) : Colors.white,
                  boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 10, offset: const Offset(0, -2))],
                ),
                child: _buildListRow(myEntry, myRank, true, filter == 'weekly', isDark),
              ),
          ],
        );
      },
    );
  }

  Widget _buildWeeklyChallengeCard() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [AppColors.accentSaffron, AppColors.accentSaffron.withValues(alpha: 0.8)]),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: AppColors.accentSaffron.withValues(alpha: 0.3), blurRadius: 8, offset: const Offset(0, 4)),
        ],
      ),
      child: Row(
        children: [
          const Icon(Icons.stars, color: Colors.white, size: 40),
          const SizedBox(width: 16),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Weekly Challenge', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                SizedBox(height: 4),
                Text('Score 80%+ in Mock Test this week → Win ⭐ 500 points', style: TextStyle(color: Colors.white, fontSize: 12)),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: AppColors.accentSaffron,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              minimumSize: Size.zero,
            ),
            child: const Text('Start', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Widget _buildPodium(List<LeaderboardEntry> top3, bool isWeekly, bool isDark) {
    if (top3.isEmpty) return const SizedBox.shrink();

    final first = top3.isNotEmpty ? top3[0] : null;
    final second = top3.length > 1 ? top3[1] : null;
    final third = top3.length > 2 ? top3[2] : null;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        if (second != null) _buildPodiumPlace(second, 2, const Color(0xFFC0C0C0), 100, isWeekly, isDark),
        const SizedBox(width: 12),
        if (first != null) _buildPodiumPlace(first, 1, const Color(0xFFFFD700), 140, isWeekly, isDark),
        const SizedBox(width: 12),
        if (third != null) _buildPodiumPlace(third, 3, const Color(0xFFCD7F32), 80, isWeekly, isDark),
      ],
    );
  }

  Widget _buildPodiumPlace(LeaderboardEntry entry, int rank, Color color, double height, bool isWeekly, bool isDark) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Stack(
          alignment: Alignment.bottomRight,
          children: [
            CircleAvatar(
              radius: rank == 1 ? 40 : 30,
              backgroundColor: color,
              child: CircleAvatar(
                radius: rank == 1 ? 36 : 27,
                backgroundColor: isDark ? const Color(0xFF152A4A) : Colors.white,
                backgroundImage: entry.photoUrl != null ? CachedNetworkImageProvider(entry.photoUrl!) : null,
                child: entry.photoUrl == null ? Icon(Icons.person, color: Colors.grey.shade400, size: rank == 1 ? 40 : 30) : null,
              ),
            ),
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(color: color, shape: BoxShape.circle, border: Border.all(color: isDark ? Theme.of(context).scaffoldBackgroundColor : Colors.white, width: 2)),
              child: Text('$rank', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
            )
          ],
        ),
        const SizedBox(height: 8),
        Text(_maskName(entry.userName), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
        Text(
          '${isWeekly ? entry.weeklyScore : entry.totalScore} pts',
          style: TextStyle(color: isDark ? Colors.white : AppColors.primaryNavy, fontWeight: FontWeight.w600, fontSize: 12),
        ),
        const SizedBox(height: 8),
        Container(
          width: rank == 1 ? 90 : 80,
          height: height,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.2),
            borderRadius: const BorderRadius.only(topLeft: Radius.circular(8), topRight: Radius.circular(8)),
            border: Border(top: BorderSide(color: color, width: 4)),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.emoji_events, color: color.withValues(alpha: 0.5), size: rank == 1 ? 48 : 32),
            ],
          ),
        ),
      ],
    );
  }

  String _maskName(String name) {
    if (name.length <= 3) return '$name***';
    return '${name.substring(0, 3)}***';
  }

  Widget _buildListRow(LeaderboardEntry entry, int rank, bool isMe, bool isWeekly, bool isDark) {
    return Container(
      color: isMe ? AppColors.accentSaffron.withValues(alpha: 0.1) : Colors.transparent,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          SizedBox(
            width: 30,
            child: Text('#$rank', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: isMe ? AppColors.accentSaffron : (isDark ? Colors.grey.shade400 : Colors.grey.shade600))),
          ),
          const SizedBox(width: 8),
          CircleAvatar(
            radius: 20,
            backgroundColor: isDark ? Colors.grey.shade800 : Colors.grey.shade200,
            backgroundImage: entry.photoUrl != null ? CachedNetworkImageProvider(entry.photoUrl!) : null,
            child: entry.photoUrl == null ? const Icon(Icons.person, color: Colors.grey) : null,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isMe ? 'You' : _maskName(entry.userName),
                  style: TextStyle(fontWeight: isMe ? FontWeight.bold : FontWeight.w500, fontSize: 16),
                ),
                Text(entry.district, style: TextStyle(color: isDark ? Colors.grey.shade400 : Colors.grey.shade600, fontSize: 12)),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text('${isWeekly ? entry.weeklyScore : entry.totalScore}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              Text('pts', style: TextStyle(color: isDark ? Colors.grey.shade400 : Colors.grey.shade500, fontSize: 12)),
            ],
          ),
        ],
      ),
    );
  }
}
