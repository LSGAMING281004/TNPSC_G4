import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

class AnalyticsScreen extends StatelessWidget {
  const AnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Analytics'), backgroundColor: AppColors.primaryNavy,
          bottom: const TabBar(
            isScrollable: true, indicatorColor: AppColors.accentSaffron,
            labelColor: Colors.white, unselectedLabelColor: Colors.white54,
            tabs: [Tab(text: 'Overview'), Tab(text: 'Subjects'), Tab(text: 'Test History'), Tab(text: 'Tips')],
          ),
        ),
        body: TabBarView(
          children: [_OverviewTab(), _SubjectsTab(), _TestHistoryTab(), _TipsTab()],
        ),
      ),
    );
  }
}

class _OverviewTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Streak
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(gradient: AppColors.saffronGradient, borderRadius: BorderRadius.circular(20)),
            child: const Row(
              children: [
                Text('🔥', style: TextStyle(fontSize: 40)),
                SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('7 Day Streak!', style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
                    Text('Keep it going!', style: TextStyle(color: Colors.white70)),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _StatBox(label: 'Questions', value: '1,256', icon: Icons.quiz, color: AppColors.info),
              const SizedBox(width: 12),
              _StatBox(label: 'Accuracy', value: '72%', icon: Icons.check_circle, color: AppColors.success),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _StatBox(label: 'Time Spent', value: '48h', icon: Icons.timer, color: AppColors.tamilSubject),
              const SizedBox(width: 12),
              _StatBox(label: 'Tests Taken', value: '23', icon: Icons.assignment, color: AppColors.warning),
            ],
          ),
          const SizedBox(height: 20),
          // Activity heatmap placeholder
          Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Activity Heatmap', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 100,
                    child: GridView.builder(
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 7, mainAxisSpacing: 4, crossAxisSpacing: 4),
                      itemCount: 28,
                      itemBuilder: (_, i) {
                        final intensity = [0.0, 0.2, 0.5, 0.8, 1.0][i % 5];
                        return Container(
                          decoration: BoxDecoration(
                            color: AppColors.success.withValues(alpha: intensity == 0 ? 0.08 : intensity),
                            borderRadius: BorderRadius.circular(3),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatBox extends StatelessWidget {
  final String label, value;
  final IconData icon;
  final Color color;
  const _StatBox({required this.label, required this.value, required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, color: color, size: 24),
              const SizedBox(height: 10),
              Text(value, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
              Text(label, style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
            ],
          ),
        ),
      ),
    );
  }
}

class _SubjectsTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _SubjectCard(subject: 'Tamil', accuracy: 78, avgTime: '38s', strongest: 'Thirukkural', weakest: 'Grammar', color: AppColors.tamilSubject),
        _SubjectCard(subject: 'General Studies', accuracy: 65, avgTime: '45s', strongest: 'Geography', weakest: 'History', color: AppColors.gsSubject),
        _SubjectCard(subject: 'Aptitude', accuracy: 72, avgTime: '52s', strongest: 'Percentage', weakest: 'Time & Distance', color: AppColors.aptitudeSubject),
      ],
    );
  }
}

class _SubjectCard extends StatelessWidget {
  final String subject, strongest, weakest;
  final int accuracy;
  final String avgTime;
  final Color color;
  const _SubjectCard({required this.subject, required this.accuracy, required this.avgTime, required this.strongest, required this.weakest, required this.color});

  @override
  Widget build(BuildContext context) {
    final statusColor = accuracy > 70 ? AppColors.success : accuracy > 40 ? AppColors.warning : AppColors.error;
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(width: 4, height: 40, decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(2))),
                const SizedBox(width: 12),
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(subject, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
                  Text('Avg time: $avgTime', style: TextStyle(fontSize: 12, color: Colors.grey.shade500)),
                ]),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(color: statusColor.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)),
                  child: Text('$accuracy%', style: TextStyle(fontWeight: FontWeight.bold, color: statusColor)),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                const Icon(Icons.arrow_upward, color: AppColors.success, size: 16),
                Text(' Best: $strongest', style: const TextStyle(fontSize: 12, color: AppColors.success)),
                const SizedBox(width: 16),
                const Icon(Icons.arrow_downward, color: AppColors.error, size: 16),
                Text(' Weak: $weakest', style: const TextStyle(fontSize: 12, color: AppColors.error)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _TestHistoryTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: 10,
      itemBuilder: (_, i) => Card(
        margin: const EdgeInsets.only(bottom: 10),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        child: ListTile(
          leading: CircleAvatar(
            backgroundColor: (i % 2 == 0 ? AppColors.success : AppColors.warning).withValues(alpha: 0.1),
            child: Text('${72 - i * 3}%', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: i % 2 == 0 ? AppColors.success : AppColors.warning)),
          ),
          title: Text('Mock Test ${10 - i}', style: const TextStyle(fontWeight: FontWeight.w500)),
          subtitle: Text('May ${20 - i}, 2026 • 100 questions', style: const TextStyle(fontSize: 12)),
          trailing: const Icon(Icons.chevron_right),
        ),
      ),
    );
  }
}

class _TipsTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final tips = [
      {'title': 'Focus on Tamil Grammar', 'desc': 'Your grammar accuracy is 55%. Practice verb conjugations daily.', 'icon': Icons.language},
      {'title': 'Review Indian History', 'desc': 'Revise the freedom movement chapter - your weakest area.', 'icon': Icons.history},
      {'title': 'Speed up Aptitude', 'desc': 'Average 52s per question. Try mental math shortcuts.', 'icon': Icons.speed},
      {'title': 'Take More Full Tests', 'desc': 'You\'ve taken 23 tests. Aim for 2 full tests per week.', 'icon': Icons.assignment},
    ];
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: tips.length,
      itemBuilder: (_, i) => Card(
        margin: const EdgeInsets.only(bottom: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(color: AppColors.info.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)),
                child: Icon(tips[i]['icon'] as IconData, color: AppColors.info),
              ),
              const SizedBox(width: 14),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(tips[i]['title'] as String, style: const TextStyle(fontWeight: FontWeight.w600)),
                const SizedBox(height: 4),
                Text(tips[i]['desc'] as String, style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
              ])),
            ],
          ),
        ),
      ),
    );
  }
}
