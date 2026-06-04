import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/router/app_router.dart';
import '../../../../shared/providers/app_providers.dart';
import '../../../../shared/providers/firestore_providers.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../../../../shared/utils/guest_restrictions.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(userProfileStreamProvider);
    final user = userAsync.valueOrNull ?? ref.watch(currentUserProvider);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 220,
            pinned: true,
            backgroundColor: AppColors.primaryNavy,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration:
                    const BoxDecoration(gradient: AppColors.primaryGradient),
                child: SafeArea(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 20),
                      CircleAvatar(
                        radius: 44,
                        backgroundColor: AppColors.accentSaffron,
                        backgroundImage: user?.photoURL != null &&
                                user!.photoURL!.isNotEmpty
                            ? NetworkImage(user.photoURL!)
                            : null,
                        child: (user?.photoURL == null ||
                                user!.photoURL!.isEmpty)
                            ? Text(
                                (user?.name.isNotEmpty == true)
                                    ? user!.name[0].toUpperCase()
                                    : 'S',
                                style: const TextStyle(
                                    fontSize: 36,
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold),
                              )
                            : null,
                      ),
                      const SizedBox(height: 12),
                      Text(user?.name ?? 'Student',
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold)),
                      Text(user?.email ?? '',
                          style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.7),
                              fontSize: 13)),
                    ],
                  ),
                ),
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverList(
                delegate: SliverChildListDelegate([
              // Real stats row
              Row(
                children: [
                  _ProfileStat(
                      label: 'Questions',
                      value: _formatNum(user?.questionsAttempted ?? 0)),
                  _ProfileStat(
                      label: 'Accuracy',
                      value:
                          '${(user?.accuracy ?? 0).toStringAsFixed(0)}%'),
                  _ProfileStat(
                      label: 'Streak',
                      value: '${user?.studyStreak ?? 0} 🔥'),
                  _ProfileStat(
                      label: 'Points',
                      value: _formatNum(user?.totalPoints ?? 0)),
                ],
              ),
              const SizedBox(height: 20),
              // Exam readiness — computed from accuracy + questions attempted
              _ExamReadinessCard(user: user),
              const SizedBox(height: 16),
              // Achievements — dynamic based on real stats
              const Text('Achievements',
                  style:
                      TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
              const SizedBox(height: 12),
              SizedBox(
                height: 100,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: [
                    _AchievementBadge(
                        icon: Icons.play_arrow,
                        label: 'First Step',
                        unlocked: (user?.questionsAttempted ?? 0) > 0),
                    _AchievementBadge(
                        icon: Icons.local_fire_department,
                        label: 'Streak Master',
                        unlocked: (user?.studyStreak ?? 0) >= 7),
                    _AchievementBadge(
                        icon: Icons.looks_one,
                        label: 'Century',
                        unlocked:
                            (user?.questionsAttempted ?? 0) >= 100),
                    _AchievementBadge(
                        icon: Icons.star,
                        label: '500 Club',
                        unlocked:
                            (user?.questionsAttempted ?? 0) >= 500),
                    _AchievementBadge(
                        icon: Icons.speed,
                        label: 'Sharpshooter',
                        unlocked: (user?.accuracy ?? 0) >= 80),
                    _AchievementBadge(
                        icon: Icons.emoji_events,
                        label: 'Top Scorer',
                        unlocked: (user?.totalPoints ?? 0) >= 1000),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              // Menu items

              _MenuTile(
                  icon: Icons.leaderboard,
                  label: 'Leaderboard',
                  onTap: () {
                    if (GuestRestrictions.check(context, ref, featureName: 'Leaderboard')) {
                      context.push(AppRoutes.leaderboard);
                    }
                  }),
              _MenuTile(
                  icon: Icons.settings,
                  label: 'Settings',
                  onTap: () => context.push(AppRoutes.settings)),
              _MenuTile(
                  icon: Icons.help_outline,
                  label: 'Help & Support',
                  onTap: () {}),
              _MenuTile(
                  icon: Icons.privacy_tip,
                  label: 'Privacy Policy',
                  onTap: () {}),
              _MenuTile(
                  icon: Icons.info_outline,
                  label: 'About App',
                  onTap: () {}),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: OutlinedButton.icon(
                  onPressed: () async {
                    await ref
                        .read(authNotifierProvider.notifier)
                        .signOut();
                    if (context.mounted) context.go(AppRoutes.login);
                  },
                  icon: const Icon(Icons.logout, color: AppColors.error),
                  label: const Text('Logout',
                      style: TextStyle(
                          color: AppColors.error,
                          fontWeight: FontWeight.bold)),
                  style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: AppColors.error),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14))),
                ),
              ),
              const SizedBox(height: 24),
            ])),
          ),
        ],
      ),
    );
  }

  String _formatNum(int n) {
    if (n >= 1000) return '${(n / 1000).toStringAsFixed(1)}K';
    return '$n';
  }
}

class _ExamReadinessCard extends StatelessWidget {
  final dynamic user;
  const _ExamReadinessCard({required this.user});

  @override
  Widget build(BuildContext context) {
    // Compute readiness: weighted combination of accuracy + questions + streak
    final accuracy = (user?.accuracy ?? 0.0) as double;
    final questions = (user?.questionsAttempted ?? 0) as int;
    final streak = (user?.studyStreak ?? 0) as int;

    // Score out of 100:  accuracy(40%) + questions/500(30%) + streak/30(30%)
    final readiness = ((accuracy * 0.4) +
            ((questions / 500).clamp(0.0, 1.0) * 30) +
            ((streak / 30).clamp(0.0, 1.0) * 30))
        .clamp(0.0, 100.0);
    final readinessPercent = readiness / 100;

    return Card(
      shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Exam Readiness',
                style:
                    TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
            const SizedBox(height: 12),
            LinearProgressIndicator(
              value: readinessPercent,
              backgroundColor:
                  AppColors.accentSaffron.withValues(alpha: 0.15),
              valueColor: AlwaysStoppedAnimation<Color>(
                  readiness > 60
                      ? AppColors.success
                      : readiness > 30
                          ? AppColors.warning
                          : AppColors.error),
              borderRadius: BorderRadius.circular(4),
              minHeight: 10,
            ),
            const SizedBox(height: 8),
            Text('${readiness.toStringAsFixed(0)}% Ready',
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: readiness > 60
                        ? AppColors.success
                        : readiness > 30
                            ? AppColors.warning
                            : AppColors.error)),
          ],
        ),
      ),
    );
  }
}

class _ProfileStat extends StatelessWidget {
  final String label, value;
  const _ProfileStat({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Expanded(
        child: Card(
      shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 14),
        child: Column(children: [
          Text(value,
              style: const TextStyle(
                  fontWeight: FontWeight.bold, fontSize: 18)),
          const SizedBox(height: 4),
          Text(label,
              style:
                  TextStyle(fontSize: 11, color: Colors.grey.shade600)),
        ]),
      ),
    ));
  }
}

class _AchievementBadge extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool unlocked;
  const _AchievementBadge(
      {required this.icon, required this.label, required this.unlocked});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 80,
      margin: const EdgeInsets.only(right: 12),
      child: Column(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: unlocked
                  ? AppColors.accentSaffron.withValues(alpha: 0.15)
                  : Colors.grey.withValues(alpha: 0.1),
              border: Border.all(
                  color: unlocked
                      ? AppColors.accentSaffron
                      : Colors.grey.shade300,
                  width: 2),
            ),
            child: Icon(icon,
                color: unlocked
                    ? AppColors.accentSaffron
                    : Colors.grey.shade400,
                size: 26),
          ),
          const SizedBox(height: 6),
          Text(label,
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                  color: unlocked ? null : Colors.grey)),
        ],
      ),
    );
  }
}

class _MenuTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  const _MenuTile(
      {required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: Icon(icon, color: AppColors.primaryNavy),
        title: Text(label,
            style: const TextStyle(fontWeight: FontWeight.w500)),
        trailing: const Icon(Icons.chevron_right, size: 20),
        onTap: onTap,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}
