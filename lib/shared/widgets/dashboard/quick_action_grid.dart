import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/router/app_router.dart';
import '../../../../shared/utils/guest_restrictions.dart';

class QuickActionGrid extends ConsumerWidget {
  const QuickActionGrid({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final actions = [
      _QuickAction('Mock Test', Icons.assignment, AppColors.accentSaffron, AppRoutes.mockTests),
      _QuickAction('Questions', Icons.quiz, AppColors.info, AppRoutes.questionBank),
      _QuickAction('Study Notes', Icons.menu_book, AppColors.success, AppRoutes.studyMaterials),
      _QuickAction('Current Affairs', Icons.newspaper, AppColors.tamilSubject, AppRoutes.currentAffairs),
      _QuickAction('Past Papers', Icons.history_edu, AppColors.warning, AppRoutes.questionBank),
      _QuickAction('AI Chatbot', Icons.smart_toy, AppColors.gsSubject, AppRoutes.aiAssistant),
      _QuickAction('Audio Books', Icons.headphones, const Color(0xFF9B59B6), AppRoutes.audioBooks),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Quick Actions', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
        const SizedBox(height: 12),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3, mainAxisSpacing: 12, crossAxisSpacing: 12, childAspectRatio: 1,
          ),
          itemCount: actions.length,
          itemBuilder: (context, index) {
            final action = actions[index];
            return GestureDetector(
              onTap: () {
                if (action.route == AppRoutes.aiAssistant) {
                  if (!GuestRestrictions.check(context, ref, featureName: 'AI Chatbot')) {
                    return;
                  }
                }
                context.push(action.route);
              },
              child: Container(
                decoration: BoxDecoration(
                  color: action.color.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: action.color.withValues(alpha: 0.2)),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: action.color.withValues(alpha: 0.15),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(action.icon, color: action.color, size: 26),
                    ),
                    const SizedBox(height: 8),
                    Text(action.label, textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}

class _QuickAction {
  final String label;
  final IconData icon;
  final Color color;
  final String route;
  const _QuickAction(this.label, this.icon, this.color, this.route);
}
