import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/router/app_router.dart';

class TestResultScreen extends StatelessWidget {
  final String resultId;
  const TestResultScreen({super.key, required this.resultId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              const SizedBox(height: 20),
              // Score circle
              Container(
                width: 160, height: 160,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const LinearGradient(colors: [AppColors.accentSaffron, AppColors.accentSaffronLight]),
                  boxShadow: [BoxShadow(color: AppColors.accentSaffron.withValues(alpha: 0.3), blurRadius: 20)],
                ),
                child: const Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('72', style: TextStyle(color: Colors.white, fontSize: 48, fontWeight: FontWeight.bold)),
                    Text('/100', style: TextStyle(color: Colors.white70, fontSize: 18)),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              const Text('Good Job! 🎉', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              Text('72% Score', style: TextStyle(fontSize: 16, color: Colors.grey.shade600)),
              const SizedBox(height: 24),
              // Stats row
              Row(
                children: [
                  _ResultStat(label: 'Correct', value: '72', color: AppColors.success, icon: Icons.check_circle),
                  const SizedBox(width: 12),
                  _ResultStat(label: 'Wrong', value: '18', color: AppColors.error, icon: Icons.cancel),
                  const SizedBox(width: 12),
                  _ResultStat(label: 'Skipped', value: '10', color: Colors.grey, icon: Icons.remove_circle),
                ],
              ),
              const SizedBox(height: 20),
              // Performance card
              Card(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Subject Performance', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
                      const SizedBox(height: 16),
                      _SubjectBar(subject: 'Tamil', percentage: 80, color: AppColors.tamilSubject),
                      const SizedBox(height: 12),
                      _SubjectBar(subject: 'General Studies', percentage: 65, color: AppColors.gsSubject),
                      const SizedBox(height: 12),
                      _SubjectBar(subject: 'Aptitude', percentage: 72, color: AppColors.aptitudeSubject),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              // Additional info
              Card(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      _InfoRow(icon: Icons.leaderboard, label: 'Your Rank', value: '#42 of 1,200'),
                      const Divider(),
                      _InfoRow(icon: Icons.timer, label: 'Avg Time/Question', value: '45 sec'),
                      const Divider(),
                      _InfoRow(icon: Icons.speed, label: 'Time Taken', value: '72 min'),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity, height: 56,
                child: ElevatedButton.icon(
                  onPressed: () => context.push('${AppRoutes.solutions}?resultId=$resultId'),
                  icon: const Icon(Icons.visibility, color: Colors.white),
                  label: const Text('View Solutions', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.accentSaffron, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity, height: 56,
                child: OutlinedButton(
                  onPressed: () => context.go(AppRoutes.dashboard),
                  style: OutlinedButton.styleFrom(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
                  child: const Text('Back to Dashboard', style: TextStyle(fontSize: 16)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ResultStat extends StatelessWidget {
  final String label, value;
  final Color color;
  final IconData icon;
  const _ResultStat({required this.label, required this.value, required this.color, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: color.withValues(alpha: 0.08), borderRadius: BorderRadius.circular(14)),
        child: Column(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 8),
            Text(value, style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: color)),
            Text(label, style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
          ],
        ),
      ),
    );
  }
}

class _SubjectBar extends StatelessWidget {
  final String subject;
  final int percentage;
  final Color color;
  const _SubjectBar({required this.subject, required this.percentage, required this.color});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(subject, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
            const Spacer(),
            Text('$percentage%', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: color)),
          ],
        ),
        const SizedBox(height: 6),
        LinearProgressIndicator(
          value: percentage / 100, backgroundColor: color.withValues(alpha: 0.15),
          valueColor: AlwaysStoppedAnimation<Color>(color), borderRadius: BorderRadius.circular(4), minHeight: 8,
        ),
      ],
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label, value;
  const _InfoRow({required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, color: AppColors.accentSaffron, size: 22),
          const SizedBox(width: 12),
          Text(label, style: const TextStyle(fontSize: 14)),
          const Spacer(),
          Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
