import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../features/auth/presentation/screens/splash_screen.dart';
import '../../features/auth/presentation/screens/onboarding_screen.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/register_screen.dart';
import '../../features/auth/presentation/screens/forgot_password_screen.dart';
import '../../features/dashboard/presentation/screens/dashboard_screen.dart';
import '../../features/mock_tests/presentation/screens/mock_test_list_screen.dart';
import '../../features/mock_tests/presentation/screens/test_instructions_screen.dart';
import '../../features/mock_tests/presentation/screens/test_taking_screen.dart';
import '../../features/mock_tests/presentation/screens/test_result_screen.dart';
import '../../features/mock_tests/presentation/screens/solution_screen.dart';
import '../../features/question_bank/presentation/screens/question_bank_home_screen.dart';
import '../../features/question_bank/presentation/screens/question_detail_screen.dart';
import '../../features/question_bank/presentation/screens/bookmarked_questions_screen.dart';
import '../../features/study_materials/presentation/screens/study_materials_home_screen.dart';
import '../../features/study_materials/presentation/screens/material_detail_screen.dart';
import '../../features/study_materials/presentation/screens/download_manager_screen.dart';
import '../../features/current_affairs/presentation/screens/current_affairs_screen.dart';
import '../../features/analytics/presentation/screens/analytics_screen.dart';
import '../../features/leaderboard/presentation/screens/leaderboard_screen.dart';
import '../../features/ai_assistant/presentation/screens/ai_assistant_screen.dart';
import '../../features/profile/presentation/screens/profile_screen.dart';
import '../../features/settings/presentation/screens/settings_screen.dart';
import '../../features/notifications/presentation/screens/notifications_screen.dart';
import '../../features/audio_books/presentation/screens/audio_books_home_screen.dart';
import '../../features/audio_books/presentation/screens/audio_player_screen.dart';
import '../constants/app_colors.dart';
import '../../shared/utils/guest_restrictions.dart';

/// Named routes for the application
class AppRoutes {
  static const String splash = '/';
  static const String onboarding = '/onboarding';
  static const String login = '/login';
  static const String register = '/register';
  static const String forgotPassword = '/forgot-password';
  static const String dashboard = '/dashboard';
  static const String mockTests = '/mock-tests';
  static const String testInstructions = '/test-instructions';
  static const String testTaking = '/test-taking';
  static const String testResult = '/test-result';
  static const String solutions = '/solutions';
  static const String questionBank = '/question-bank';
  static const String questionDetail = '/question-detail';
  static const String bookmarks = '/bookmarks';
  static const String studyMaterials = '/study-materials';
  static const String materialDetail = '/material-detail';
  static const String downloadManager = '/download-manager';
  static const String currentAffairs = '/current-affairs';
  static const String analytics = '/analytics';
  static const String leaderboard = '/leaderboard';
  static const String aiAssistant = '/ai-assistant';
  static const String profile = '/profile';
  static const String settings = '/settings';
  static const String notifications = '/notifications';
  static const String audioBooks = '/audio-books';
  static const String audioPlayer = '/audio-player';
}

/// GoRouter provider
final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: AppRoutes.splash,
    debugLogDiagnostics: true,
    routes: [
      GoRoute(
        path: AppRoutes.splash,
        name: 'splash',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: AppRoutes.onboarding,
        name: 'onboarding',
        builder: (context, state) => const OnboardingScreen(),
      ),
      GoRoute(
        path: AppRoutes.login,
        name: 'login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: AppRoutes.register,
        name: 'register',
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: AppRoutes.forgotPassword,
        name: 'forgotPassword',
        builder: (context, state) => const ForgotPasswordScreen(),
      ),
      // Main app shell with bottom navigation
      ShellRoute(
        builder: (context, state, child) => MainShell(child: child),
        routes: [
          GoRoute(
            path: AppRoutes.dashboard,
            name: 'dashboard',
            builder: (context, state) => const DashboardScreen(),
          ),
          GoRoute(
            path: AppRoutes.mockTests,
            name: 'mockTests',
            builder: (context, state) => const MockTestListScreen(),
          ),
          GoRoute(
            path: AppRoutes.studyMaterials,
            name: 'studyMaterials',
            builder: (context, state) => const StudyMaterialsHomeScreen(),
          ),
          GoRoute(
            path: AppRoutes.analytics,
            name: 'analytics',
            builder: (context, state) => const AnalyticsScreen(),
          ),
          GoRoute(
            path: AppRoutes.profile,
            name: 'profile',
            builder: (context, state) => const ProfileScreen(),
          ),
        ],
      ),
      // Standalone routes (no bottom nav)
      GoRoute(
        path: AppRoutes.testInstructions,
        name: 'testInstructions',
        builder: (context, state) => TestInstructionsScreen(
          testId: state.uri.queryParameters['testId'] ?? '',
        ),
      ),
      GoRoute(
        path: AppRoutes.testTaking,
        name: 'testTaking',
        builder: (context, state) => TestTakingScreen(
          testId: state.uri.queryParameters['testId'] ?? '',
        ),
      ),
      GoRoute(
        path: AppRoutes.testResult,
        name: 'testResult',
        builder: (context, state) => TestResultScreen(
          resultId: state.uri.queryParameters['resultId'] ?? '',
        ),
      ),
      GoRoute(
        path: AppRoutes.solutions,
        name: 'solutions',
        builder: (context, state) => SolutionScreen(
          resultId: state.uri.queryParameters['resultId'] ?? '',
        ),
      ),
      GoRoute(
        path: AppRoutes.questionBank,
        name: 'questionBank',
        builder: (context, state) => const QuestionBankHomeScreen(),
      ),
      GoRoute(
        path: AppRoutes.questionDetail,
        name: 'questionDetail',
        builder: (context, state) => QuestionDetailScreen(
          questionId: state.uri.queryParameters['questionId'] ?? '',
        ),
      ),
      GoRoute(
        path: AppRoutes.bookmarks,
        name: 'bookmarks',
        builder: (context, state) => const BookmarkedQuestionsScreen(),
      ),
      GoRoute(
        path: AppRoutes.materialDetail,
        name: 'materialDetail',
        builder: (context, state) => MaterialDetailScreen(
          materialId: state.uri.queryParameters['materialId'] ?? '',
        ),
      ),
      GoRoute(
        path: AppRoutes.downloadManager,
        name: 'downloadManager',
        builder: (context, state) => const DownloadManagerScreen(),
      ),
      GoRoute(
        path: AppRoutes.currentAffairs,
        name: 'currentAffairs',
        builder: (context, state) => const CurrentAffairsScreen(),
      ),
      GoRoute(
        path: AppRoutes.leaderboard,
        name: 'leaderboard',
        builder: (context, state) => const LeaderboardScreen(),
      ),
      GoRoute(
        path: AppRoutes.aiAssistant,
        name: 'aiAssistant',
        builder: (context, state) => const AIAssistantScreen(),
      ),
      GoRoute(
        path: AppRoutes.settings,
        name: 'settings',
        builder: (context, state) => const SettingsScreen(),
      ),
      GoRoute(
        path: AppRoutes.notifications,
        name: 'notifications',
        builder: (context, state) => const NotificationsScreen(),
      ),
      GoRoute(
        path: AppRoutes.audioBooks,
        name: 'audioBooks',
        builder: (context, state) => const AudioBooksHomeScreen(),
      ),
      GoRoute(
        path: AppRoutes.audioPlayer,
        name: 'audioPlayer',
        builder: (context, state) => AudioPlayerScreen(
          bookId: state.uri.queryParameters['bookId'] ?? '',
        ),
      ),
    ],
    redirect: (context, state) {
      // Allow unrestricted direct navigation (offline/guest-first access)
      return null;
    },
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Text('Page not found: ${state.error}'),
      ),
    ),
  );
});



/// Main shell with bottom navigation bar
class MainShell extends ConsumerWidget {
  final Widget child;

  const MainShell({super.key, required this.child});

  int _currentIndex(BuildContext context) {
    final location = GoRouterState.of(context).matchedLocation;
    if (location.startsWith(AppRoutes.dashboard)) return 0;
    if (location.startsWith(AppRoutes.mockTests)) return 1;
    if (location.startsWith(AppRoutes.studyMaterials)) return 2;
    if (location.startsWith(AppRoutes.analytics)) return 3;
    if (location.startsWith(AppRoutes.profile)) return 4;
    return 0;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: child,
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex(context),
        onDestinationSelected: (index) {
          if (index == 3) {
            if (!GuestRestrictions.check(context, ref, featureName: 'Analytics')) {
              return;
            }
          }
          switch (index) {
            case 0: context.go(AppRoutes.dashboard); break;
            case 1: context.go(AppRoutes.mockTests); break;
            case 2: context.go(AppRoutes.studyMaterials); break;
            case 3: context.go(AppRoutes.analytics); break;
            case 4: context.go(AppRoutes.profile); break;
          }
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home, color: AppColors.accentSaffron),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.quiz_outlined),
            selectedIcon: Icon(Icons.quiz, color: AppColors.accentSaffron),
            label: 'Tests',
          ),
          NavigationDestination(
            icon: Icon(Icons.menu_book_outlined),
            selectedIcon: Icon(Icons.menu_book, color: AppColors.accentSaffron),
            label: 'Materials',
          ),
          NavigationDestination(
            icon: Icon(Icons.analytics_outlined),
            selectedIcon: Icon(Icons.analytics, color: AppColors.accentSaffron),
            label: 'Analytics',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outlined),
            selectedIcon: Icon(Icons.person, color: AppColors.accentSaffron),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
