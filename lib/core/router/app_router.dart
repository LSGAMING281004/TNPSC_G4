import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

// Screens
import '../../features/auth/presentation/screens/splash_screen.dart';
import '../../features/auth/presentation/screens/onboarding_screen.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/register_screen.dart';
import '../../features/auth/presentation/screens/forgot_password_screen.dart';
import '../../features/dashboard/presentation/screens/dashboard_screen.dart';
import '../../features/mock_tests/presentation/screens/mock_test_list_screen.dart';
// Note: Changed from TestEngineScreen/TestResultScreen to existing app routes if exact names differ, assuming placeholders if they don't exist
import '../../features/mock_tests/presentation/screens/test_taking_screen.dart';
import '../../features/mock_tests/presentation/screens/test_result_screen.dart';
import '../../features/study_materials/presentation/screens/study_materials_home_screen.dart';
import '../../features/study_materials/presentation/screens/material_detail_screen.dart';
import '../../features/current_affairs/presentation/screens/current_affairs_screen.dart';
import '../../features/profile/presentation/screens/profile_screen.dart';
import '../../features/question_bank/presentation/screens/question_bank_home_screen.dart';
import '../../features/analytics/presentation/screens/analytics_screen.dart';
import '../../features/leaderboard/presentation/screens/leaderboard_screen.dart';
import '../../features/ai_assistant/presentation/screens/ai_assistant_screen.dart';
import '../../features/settings/presentation/screens/settings_screen.dart';
import '../../features/notifications/presentation/screens/notifications_screen.dart';
import '../../features/audio_books/presentation/screens/audio_books_home_screen.dart';

import '../../features/auth/providers/auth_providers.dart';
import '../../shared/widgets/main_shell_screen.dart';

// Dummy providers for Auth Guard - Replace with actual Firebase Auth providers
final isAdminProvider = StateProvider<bool>((ref) => false);
final isFirstLaunchProvider = StateProvider<bool>((ref) => false);

/// Named routes for the application
class AppRoutes {
  static const splash = 'splash';
  static const onboarding = 'onboarding';
  static const login = 'login';
  static const register = 'register';
  static const forgotPassword = 'forgot-password';
  static const home = 'home';
  static const dashboard = 'dashboard';
  static const tests = 'tests';
  static const materials = 'materials';
  static const current = 'current';
  static const profile = 'profile';
  static const test = 'test';
  static const testResult = 'test-result';
  static const questionBank = 'question-bank';
  static const questionFilter = 'question-filter';
  static const analytics = 'analytics';
  static const leaderboard = 'leaderboard';
  static const aiAssistant = 'ai-assistant';
  static const study = 'study';
  static const currentAffairsDetail = 'current-affairs-detail';
  static const settings = 'settings';
  static const achievements = 'achievements';
  static const syllabus = 'syllabus';
  static const previousPapers = 'previous-papers';
  static const audioBooks = 'audio-books';
  static const notifications = 'notifications';
  static const admin = 'admin';
}

final routerProvider = Provider<GoRouter>((ref) {
  final isAuthenticated = ref.watch(authStateProvider).value != null;
  final isAdmin = ref.watch(isAdminProvider);

  return GoRouter(
    initialLocation: '/',
    debugLogDiagnostics: true,
    redirect: (context, state) {
      final isAuthRoute = state.matchedLocation == '/login' ||
          state.matchedLocation == '/register' ||
          state.matchedLocation == '/forgot-password' ||
          state.matchedLocation == '/onboarding' ||
          state.matchedLocation == '/';

      if (!isAuthenticated && !isAuthRoute) {
        return '/login';
      }

      if (isAuthenticated && isAuthRoute) {
        // Prevent authenticated users from seeing login/onboarding
        if (state.matchedLocation != '/') return '/home/dashboard';
      }

      if (state.matchedLocation.startsWith('/admin') && !isAdmin) {
        return '/home/dashboard'; // Block non-admins
      }

      return null;
    },
    routes: [
      GoRoute(
        path: '/',
        name: AppRoutes.splash,
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/onboarding',
        name: AppRoutes.onboarding,
        builder: (context, state) => const OnboardingScreen(),
      ),
      GoRoute(
        path: '/login',
        name: AppRoutes.login,
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/register',
        name: AppRoutes.register,
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: '/forgot-password',
        name: AppRoutes.forgotPassword,
        builder: (context, state) => const ForgotPasswordScreen(),
      ),
      
      // Main App Shell
      ShellRoute(
        builder: (context, state, child) => MainShellScreen(child: child),
        routes: [
          GoRoute(
            path: '/home/dashboard',
            name: AppRoutes.dashboard,
            builder: (context, state) => const DashboardScreen(),
          ),
          GoRoute(
            path: '/home/tests',
            name: AppRoutes.tests,
            builder: (context, state) => const MockTestListScreen(),
          ),
          GoRoute(
            path: '/home/materials',
            name: AppRoutes.materials,
            builder: (context, state) => const StudyMaterialsHomeScreen(),
          ),
          GoRoute(
            path: '/home/current',
            name: AppRoutes.current,
            builder: (context, state) => const CurrentAffairsScreen(),
          ),
          GoRoute(
            path: '/home/profile',
            name: AppRoutes.profile,
            builder: (context, state) => const ProfileScreen(),
          ),
        ],
      ),

      // Standalone Routes (Full Screen)
      GoRoute(
        path: '/test/:testId',
        name: AppRoutes.test,
        builder: (context, state) => TestTakingScreen(
          testId: state.pathParameters['testId'] ?? '',
        ),
      ),
      GoRoute(
        path: '/test-result/:attemptId',
        name: AppRoutes.testResult,
        builder: (context, state) => TestResultScreen(
          resultId: state.pathParameters['attemptId'] ?? '',
        ),
      ),
      GoRoute(
        path: '/question-bank',
        name: AppRoutes.questionBank,
        builder: (context, state) => const QuestionBankHomeScreen(),
        routes: [
          GoRoute(
            path: 'filter',
            name: AppRoutes.questionFilter,
            builder: (context, state) => const Scaffold(body: Center(child: Text('Filter Screen'))), // Placeholder
          ),
        ]
      ),
      GoRoute(
        path: '/analytics',
        name: AppRoutes.analytics,
        builder: (context, state) => const AnalyticsScreen(),
      ),
      GoRoute(
        path: '/leaderboard',
        name: AppRoutes.leaderboard,
        builder: (context, state) => const LeaderboardScreen(),
      ),
      GoRoute(
        path: '/ai-assistant',
        name: AppRoutes.aiAssistant,
        builder: (context, state) => const AIAssistantScreen(),
      ),
      GoRoute(
        path: '/study/:materialId',
        name: AppRoutes.study,
        builder: (context, state) => MaterialDetailScreen(
          materialId: state.pathParameters['materialId'] ?? '',
        ),
      ),
      GoRoute(
        path: '/current-affairs/:id',
        name: AppRoutes.currentAffairsDetail,
        builder: (context, state) => const Scaffold(body: Center(child: Text('Article Detail Screen'))), // Placeholder
      ),
      GoRoute(
        path: '/settings',
        name: AppRoutes.settings,
        builder: (context, state) => const SettingsScreen(),
      ),
      GoRoute(
        path: '/achievements',
        name: AppRoutes.achievements,
        builder: (context, state) => const Scaffold(body: Center(child: Text('Achievements Screen'))), // Placeholder
      ),
      GoRoute(
        path: '/syllabus',
        name: AppRoutes.syllabus,
        builder: (context, state) => const Scaffold(body: Center(child: Text('Syllabus Screen'))), // Placeholder
      ),
      GoRoute(
        path: '/previous-papers',
        name: AppRoutes.previousPapers,
        builder: (context, state) => const Scaffold(body: Center(child: Text('Previous Papers Screen'))), // Placeholder
      ),
      GoRoute(
        path: '/audio-books',
        name: AppRoutes.audioBooks,
        builder: (context, state) => const AudioBooksHomeScreen(),
      ),
      GoRoute(
        path: '/notifications',
        name: AppRoutes.notifications,
        builder: (context, state) => const NotificationsScreen(),
      ),
      GoRoute(
        path: '/admin',
        name: AppRoutes.admin,
        builder: (context, state) => const Scaffold(body: Center(child: Text('Admin Dashboard Screen'))), // Placeholder
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Text('Page not found: ${state.error}'),
      ),
    ),
  );
});
