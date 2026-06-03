import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../shared/providers/app_providers.dart';
import '../../../../shared/providers/firestore_providers.dart';

class LeaderboardScreen extends ConsumerWidget {
  const LeaderboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
          title: const Text('Leaderboard'),
          backgroundColor: AppColors.primaryNavy),
      body: _LeaderboardList(),
    );
  }
}

class _LeaderboardList extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final leaderboardAsync = ref.watch(leaderboardStreamProvider);
    final currentUser = ref.watch(currentUserProvider);

    return leaderboardAsync.when(
      loading: () => const Center(
          child: CircularProgressIndicator(
              strokeWidth: 2, color: AppColors.accentSaffron)),
      error: (_, __) => const Center(
          child: Text('Error loading leaderboard',
              style: TextStyle(color: Colors.grey))),
      data: (entries) {
        if (entries.isEmpty) {
          return Center(
              child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.leaderboard, color: Colors.grey.shade300, size: 64),
              const SizedBox(height: 12),
              Text('Leaderboard is empty',
                  style:
                      TextStyle(color: Colors.grey.shade500, fontSize: 16)),
              const SizedBox(height: 4),
              Text('Start taking tests to appear here!',
                  style:
                      TextStyle(color: Colors.grey.shade400, fontSize: 13)),
            ],
          ));
        }

        // Find current user's position
        int currentUserRank = -1;
        for (int i = 0; i < entries.length; i++) {
          if (entries[i]['id'] == currentUser?.uid ||
              entries[i]['userId'] == currentUser?.uid) {
            currentUserRank = i + 1;
            break;
          }
        }

        final top3 = entries.take(3).toList();
        final rest = entries.skip(3).toList();

        return Column(
          children: [
            // Top 3 podium
            if (top3.isNotEmpty)
              Container(
                padding: const EdgeInsets.symmetric(vertical: 24),
                decoration:
                    const BoxDecoration(gradient: AppColors.primaryGradient),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    if (top3.length > 1)
                      _PodiumUser(
                          rank: 2,
                          name: (top3[1]['name'] as String?) ?? 'Student',
                          score:
                              '${top3[1]['totalPoints'] ?? 0}',
                          height: 80),
                    _PodiumUser(
                        rank: 1,
                        name: (top3[0]['name'] as String?) ?? 'Student',
                        score: '${top3[0]['totalPoints'] ?? 0}',
                        height: 110,
                        isFirst: true),
                    if (top3.length > 2)
                      _PodiumUser(
                          rank: 3,
                          name: (top3[2]['name'] as String?) ?? 'Student',
                          score:
                              '${top3[2]['totalPoints'] ?? 0}',
                          height: 60),
                  ],
                ),
              ),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: rest.length,
                itemBuilder: (_, i) {
                  final entry = rest[i];
                  final rank = i + 4;
                  final name =
                      (entry['name'] as String?) ?? 'Student $rank';
                  final district =
                      (entry['district'] as String?) ?? '';
                  final points = entry['totalPoints'] ?? 0;
                  final accuracy = entry['accuracy'] ?? 0;

                  return Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                            color: Colors.black.withValues(alpha: 0.03),
                            blurRadius: 4)
                      ],
                    ),
                    child: Row(
                      children: [
                        SizedBox(
                            width: 36,
                            child: Text('#$rank',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.grey.shade600))),
                        CircleAvatar(
                            radius: 18,
                            backgroundColor:
                                AppColors.primaryNavy.withValues(alpha: 0.1),
                            child: Text(
                                name.isNotEmpty ? name[0].toUpperCase() : '?',
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold))),
                        const SizedBox(width: 12),
                        Expanded(
                            child: Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                children: [
                              Text(name,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.w500)),
                              if (district.isNotEmpty)
                                Text(district,
                                    style: TextStyle(
                                        fontSize: 11,
                                        color: Colors.grey.shade500)),
                            ])),
                        Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text('$points',
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.accentSaffron)),
                              Text('${accuracy is double ? accuracy.toStringAsFixed(0) : accuracy}% acc',
                                  style: TextStyle(
                                      fontSize: 11,
                                      color: Colors.grey.shade500)),
                            ]),
                      ],
                    ),
                  );
                },
              ),
            ),
            // Current user pinned at bottom
            if (currentUser != null)
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.accentSaffron.withValues(alpha: 0.08),
                  border: Border(
                      top: BorderSide(
                          color: AppColors.accentSaffron
                              .withValues(alpha: 0.2))),
                ),
                child: Row(
                  children: [
                    SizedBox(
                        width: 36,
                        child: Text(
                            currentUserRank > 0
                                ? '#$currentUserRank'
                                : '--',
                            style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: AppColors.accentSaffron))),
                    CircleAvatar(
                        radius: 18,
                        backgroundColor: AppColors.accentSaffron,
                        child: Text(
                            currentUser.name.isNotEmpty
                                ? currentUser.name[0].toUpperCase()
                                : 'Y',
                            style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold))),
                    const SizedBox(width: 12),
                    Expanded(
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                          const Text('You',
                              style: TextStyle(fontWeight: FontWeight.bold)),
                          Text(currentUser.district,
                              style: const TextStyle(fontSize: 11)),
                        ])),
                    Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text('${currentUser.totalPoints}',
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.accentSaffron)),
                          Text(
                              '${currentUser.accuracy.toStringAsFixed(0)}% acc',
                              style: const TextStyle(fontSize: 11)),
                        ]),
                  ],
                ),
              ),
          ],
        );
      },
    );
  }
}

class _PodiumUser extends StatelessWidget {
  final int rank;
  final String name, score;
  final double height;
  final bool isFirst;
  const _PodiumUser(
      {required this.rank,
      required this.name,
      required this.score,
      required this.height,
      this.isFirst = false});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (isFirst) const Text('👑', style: TextStyle(fontSize: 24)),
        CircleAvatar(
          radius: isFirst ? 30 : 24,
          backgroundColor: [
            Colors.amber,
            Colors.grey.shade400,
            Colors.brown.shade400
          ][rank - 1],
          child: Text('$rank',
              style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 18)),
        ),
        const SizedBox(height: 6),
        Text(name,
            style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 13)),
        Text(score,
            style: TextStyle(
                color: Colors.white.withValues(alpha: 0.7), fontSize: 12)),
        const SizedBox(height: 4),
        Container(
          width: 60,
          height: height,
          decoration: BoxDecoration(
            color: [
              Colors.amber.withValues(alpha: 0.3),
              Colors.grey.withValues(alpha: 0.3),
              Colors.brown.withValues(alpha: 0.3)
            ][rank - 1],
            borderRadius:
                const BorderRadius.vertical(top: Radius.circular(8)),
          ),
        ),
      ],
    );
  }
}
