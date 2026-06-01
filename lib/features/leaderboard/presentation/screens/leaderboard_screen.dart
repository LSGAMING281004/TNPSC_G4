import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

class LeaderboardScreen extends StatelessWidget {
  const LeaderboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Leaderboard'), backgroundColor: AppColors.primaryNavy,
          bottom: const TabBar(
            isScrollable: true, indicatorColor: AppColors.accentSaffron,
            labelColor: Colors.white, unselectedLabelColor: Colors.white54,
            tabs: [Tab(text: 'State'), Tab(text: 'District'), Tab(text: 'Friends'), Tab(text: 'Weekly')],
          ),
        ),
        body: TabBarView(children: List.generate(4, (_) => _LeaderboardList())),
      ),
    );
  }
}

class _LeaderboardList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Top 3 podium
        Container(
          padding: const EdgeInsets.symmetric(vertical: 24),
          decoration: const BoxDecoration(gradient: AppColors.primaryGradient),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              _PodiumUser(rank: 2, name: 'Priya K', score: '1,890', height: 80),
              _PodiumUser(rank: 1, name: 'Raj M', score: '2,150', height: 110, isFirst: true),
              _PodiumUser(rank: 3, name: 'Kumar S', score: '1,720', height: 60),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: 20,
            itemBuilder: (_, i) {
              final rank = i + 4;
              return Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 4)],
                ),
                child: Row(
                  children: [
                    SizedBox(width: 36, child: Text('#$rank', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey.shade600))),
                    CircleAvatar(radius: 18, backgroundColor: AppColors.primaryNavy.withValues(alpha: 0.1),
                      child: Text(String.fromCharCode(65 + i % 26), style: const TextStyle(fontWeight: FontWeight.bold))),
                    const SizedBox(width: 12),
                    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text('Student $rank', style: const TextStyle(fontWeight: FontWeight.w500)),
                      Text('Chennai', style: TextStyle(fontSize: 11, color: Colors.grey.shade500)),
                    ])),
                    Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                      Text('${2150 - rank * 45}', style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.accentSaffron)),
                      Text('${72 - i}% acc', style: TextStyle(fontSize: 11, color: Colors.grey.shade500)),
                    ]),
                  ],
                ),
              );
            },
          ),
        ),
        // Current user pinned
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.accentSaffron.withValues(alpha: 0.08),
            border: Border(top: BorderSide(color: AppColors.accentSaffron.withValues(alpha: 0.2))),
          ),
          child: const Row(
            children: [
              SizedBox(width: 36, child: Text('#42', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.accentSaffron))),
              CircleAvatar(radius: 18, backgroundColor: AppColors.accentSaffron, child: Text('Y', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
              SizedBox(width: 12),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('You', style: TextStyle(fontWeight: FontWeight.bold)),
                Text('Chennai', style: TextStyle(fontSize: 11)),
              ])),
              Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                Text('1,250', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.accentSaffron)),
                Text('72% acc', style: TextStyle(fontSize: 11)),
              ]),
            ],
          ),
        ),
      ],
    );
  }
}

class _PodiumUser extends StatelessWidget {
  final int rank;
  final String name, score;
  final double height;
  final bool isFirst;
  const _PodiumUser({required this.rank, required this.name, required this.score, required this.height, this.isFirst = false});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (isFirst) const Text('👑', style: TextStyle(fontSize: 24)),
        CircleAvatar(
          radius: isFirst ? 30 : 24,
          backgroundColor: [Colors.amber, Colors.grey.shade400, Colors.brown.shade400][rank - 1],
          child: Text('$rank', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
        ),
        const SizedBox(height: 6),
        Text(name, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 13)),
        Text(score, style: TextStyle(color: Colors.white.withValues(alpha: 0.7), fontSize: 12)),
        const SizedBox(height: 4),
        Container(
          width: 60, height: height,
          decoration: BoxDecoration(
            color: [Colors.amber.withValues(alpha: 0.3), Colors.grey.withValues(alpha: 0.3), Colors.brown.withValues(alpha: 0.3)][rank - 1],
            borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
          ),
        ),
      ],
    );
  }
}
