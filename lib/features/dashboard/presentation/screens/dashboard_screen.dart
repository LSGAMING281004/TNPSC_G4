import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:animate_do/animate_do.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/router/app_router.dart';
import '../../../../shared/providers/app_providers.dart';
import '../../../../shared/providers/firestore_providers.dart';
import '../../../../shared/widgets/dashboard/exam_countdown_widget.dart';
import '../../../../shared/widgets/dashboard/daily_study_target_widget.dart';
import '../../../../shared/widgets/dashboard/progress_summary_card.dart';
import '../../../../shared/widgets/dashboard/quick_action_grid.dart';
import '../../../../shared/widgets/dashboard/motivational_quote_widget.dart';
import '../../../../shared/widgets/dashboard/todays_current_affairs_card.dart';
import '../../../../shared/widgets/dashboard/weak_subjects_alert.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch real-time Firestore profile (also keeps currentUserProvider in sync)
    final userAsync = ref.watch(userProfileStreamProvider);
    final user = userAsync.valueOrNull ?? ref.watch(currentUserProvider);
    final userName = user?.name ?? 'Student';

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // App Bar
          SliverAppBar(
            expandedHeight: 120,
            floating: true,
            pinned: true,
            backgroundColor: AppColors.primaryNavy,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(gradient: AppColors.primaryGradient),
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Vanakkam, $userName! 👋',
                                style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'வணக்கம்! இன்று படிக்க ஆரம்பிப்போம்',
                                style: TextStyle(
                                  fontFamily: 'NotoSansTamil', fontSize: 13,
                                  color: Colors.white.withValues(alpha: 0.7),
                                ),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          onPressed: () => context.push(AppRoutes.notifications),
                          icon: Stack(
                            children: [
                              const Icon(Icons.notifications_outlined, color: Colors.white, size: 28),
                              Positioned(
                                right: 0, top: 0,
                                child: Container(
                                  width: 10, height: 10,
                                  decoration: const BoxDecoration(
                                    color: AppColors.accentSaffron, shape: BoxShape.circle,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          // Content
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                FadeInUp(child: const ExamCountdownWidget()),
                const SizedBox(height: 16),
                FadeInUp(delay: const Duration(milliseconds: 100), child: const DailyStudyTargetWidget()),
                const SizedBox(height: 16),
                FadeInUp(delay: const Duration(milliseconds: 200), child: const ProgressSummaryCard()),
                const SizedBox(height: 16),
                FadeInUp(delay: const Duration(milliseconds: 300), child: const QuickActionGrid()),
                const SizedBox(height: 16),
                FadeInUp(delay: const Duration(milliseconds: 400), child: const MotivationalQuoteWidget()),
                const SizedBox(height: 16),
                FadeInUp(delay: const Duration(milliseconds: 500), child: const TodaysCurrentAffairsCard()),
                const SizedBox(height: 16),
                FadeInUp(delay: const Duration(milliseconds: 600), child: const WeakSubjectsAlert()),
                const SizedBox(height: 24),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}
