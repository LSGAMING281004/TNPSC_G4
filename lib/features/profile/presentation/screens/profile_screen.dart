import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/router/app_router.dart';
import '../../../../shared/providers/app_providers.dart';
import '../../../auth/presentation/providers/auth_providers.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 220, pinned: true, backgroundColor: AppColors.primaryNavy,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(gradient: AppColors.primaryGradient),
                child: SafeArea(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 20),
                      CircleAvatar(
                        radius: 44,
                        backgroundColor: AppColors.accentSaffron,
                        child: Text(
                          (user?.name.isNotEmpty == true) ? user!.name[0].toUpperCase() : 'S',
                          style: const TextStyle(fontSize: 36, color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(user?.name ?? 'Student', style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                      Text(user?.email ?? '', style: TextStyle(color: Colors.white.withValues(alpha: 0.7), fontSize: 13)),
                    ],
                  ),
                ),
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverList(delegate: SliverChildListDelegate([
              // Stats row
              Row(
                children: [
                  _ProfileStat(label: 'Questions', value: '1,256'),
                  _ProfileStat(label: 'Accuracy', value: '72%'),
                  _ProfileStat(label: 'Streak', value: '7 🔥'),
                  _ProfileStat(label: 'Rank', value: '#42'),
                ],
              ),
              const SizedBox(height: 20),
              // Exam readiness
              Card(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Exam Readiness', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
                      const SizedBox(height: 12),
                      LinearProgressIndicator(
                        value: 0.65, backgroundColor: AppColors.accentSaffron.withValues(alpha: 0.15),
                        valueColor: const AlwaysStoppedAnimation<Color>(AppColors.accentSaffron),
                        borderRadius: BorderRadius.circular(4), minHeight: 10,
                      ),
                      const SizedBox(height: 8),
                      const Text('65% Ready', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.accentSaffron)),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              // Achievements
              const Text('Achievements', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
              const SizedBox(height: 12),
              SizedBox(
                height: 100,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: [
                    _AchievementBadge(icon: Icons.play_arrow, label: 'First Step', unlocked: true),
                    _AchievementBadge(icon: Icons.local_fire_department, label: 'Streak Master', unlocked: true),
                    _AchievementBadge(icon: Icons.looks_one, label: 'Century', unlocked: false),
                    _AchievementBadge(icon: Icons.translate, label: 'Tamil Scholar', unlocked: false),
                    _AchievementBadge(icon: Icons.speed, label: 'Speed Demon', unlocked: false),
                    _AchievementBadge(icon: Icons.star, label: 'Perfect Score', unlocked: false),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              // Menu items
              _MenuTile(icon: Icons.leaderboard, label: 'Leaderboard', onTap: () => context.push(AppRoutes.leaderboard)),
              _MenuTile(icon: Icons.settings, label: 'Settings', onTap: () => context.push(AppRoutes.settings)),
              _MenuTile(icon: Icons.help_outline, label: 'Help & Support', onTap: () {}),
              _MenuTile(icon: Icons.privacy_tip, label: 'Privacy Policy', onTap: () {}),
              _MenuTile(icon: Icons.info_outline, label: 'About App', onTap: () {}),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity, height: 52,
                child: OutlinedButton.icon(
                  onPressed: () async {
                    await ref.read(authNotifierProvider.notifier).signOut();
                    if (context.mounted) context.go(AppRoutes.login);
                  },
                  icon: const Icon(Icons.logout, color: AppColors.error),
                  label: const Text('Logout', style: TextStyle(color: AppColors.error, fontWeight: FontWeight.bold)),
                  style: OutlinedButton.styleFrom(side: const BorderSide(color: AppColors.error), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
                ),
              ),
              const SizedBox(height: 24),
            ])),
          ),
        ],
      ),
    );
  }
}

class _ProfileStat extends StatelessWidget {
  final String label, value;
  const _ProfileStat({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Expanded(child: Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 14),
        child: Column(children: [
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
          const SizedBox(height: 4),
          Text(label, style: TextStyle(fontSize: 11, color: Colors.grey.shade600)),
        ]),
      ),
    ));
  }
}

class _AchievementBadge extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool unlocked;
  const _AchievementBadge({required this.icon, required this.label, required this.unlocked});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 80, margin: const EdgeInsets.only(right: 12),
      child: Column(
        children: [
          Container(
            width: 56, height: 56,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: unlocked ? AppColors.accentSaffron.withValues(alpha: 0.15) : Colors.grey.withValues(alpha: 0.1),
              border: Border.all(color: unlocked ? AppColors.accentSaffron : Colors.grey.shade300, width: 2),
            ),
            child: Icon(icon, color: unlocked ? AppColors.accentSaffron : Colors.grey.shade400, size: 26),
          ),
          const SizedBox(height: 6),
          Text(label, textAlign: TextAlign.center, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w500, color: unlocked ? null : Colors.grey)),
        ],
      ),
    );
  }
}

class _MenuTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  const _MenuTile({required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: Icon(icon, color: AppColors.primaryNavy),
        title: Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
        trailing: const Icon(Icons.chevron_right, size: 20),
        onTap: onTap,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}
