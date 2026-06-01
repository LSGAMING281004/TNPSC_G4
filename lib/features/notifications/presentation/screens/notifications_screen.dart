import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final notifications = [
      _Notif(title: 'New Mock Test Available!', body: 'Full Mock Test 4 is ready. Take the test now.', time: '2h ago', icon: Icons.assignment, color: AppColors.accentSaffron, read: false),
      _Notif(title: 'Daily Study Reminder', body: 'You haven\'t studied today. Complete your daily target.', time: '5h ago', icon: Icons.timer, color: AppColors.info, read: false),
      _Notif(title: 'Achievement Unlocked! 🎉', body: 'You earned "Streak Master" badge for 7-day streak.', time: '1d ago', icon: Icons.emoji_events, color: AppColors.warning, read: true),
      _Notif(title: 'Current Affairs Update', body: 'Today\'s digest is ready with 8 new articles.', time: '1d ago', icon: Icons.newspaper, color: AppColors.tamilSubject, read: true),
      _Notif(title: 'Exam Reminder', body: 'TNPSC Group 4 Exam is 111 days away. Stay focused!', time: '2d ago', icon: Icons.event, color: AppColors.error, read: true),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'), backgroundColor: AppColors.primaryNavy,
        actions: [TextButton(onPressed: () {}, child: const Text('Mark all read', style: TextStyle(color: AppColors.accentSaffron, fontSize: 12)))],
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: notifications.length,
        itemBuilder: (_, i) {
          final n = notifications[i];
          return Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: n.read ? Theme.of(context).cardColor : AppColors.accentSaffron.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(14),
              border: n.read ? null : Border.all(color: AppColors.accentSaffron.withValues(alpha: 0.2)),
              boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 4)],
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(color: n.color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)),
                  child: Icon(n.icon, color: n.color, size: 22),
                ),
                const SizedBox(width: 12),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(n.title, style: TextStyle(fontWeight: n.read ? FontWeight.w500 : FontWeight.w700, fontSize: 14)),
                  const SizedBox(height: 4),
                  Text(n.body, style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
                  const SizedBox(height: 6),
                  Text(n.time, style: TextStyle(fontSize: 11, color: Colors.grey.shade400)),
                ])),
                if (!n.read) Container(width: 8, height: 8, decoration: const BoxDecoration(color: AppColors.accentSaffron, shape: BoxShape.circle)),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _Notif {
  final String title, body, time;
  final IconData icon;
  final Color color;
  final bool read;
  _Notif({required this.title, required this.body, required this.time, required this.icon, required this.color, required this.read});
}
