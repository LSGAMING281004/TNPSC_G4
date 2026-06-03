import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../features/auth/admin_login_screen.dart';
import '../../features/dashboard/admin_dashboard_screen.dart';
import '../../features/questions/question_list_screen.dart';
import '../../features/questions/add_edit_question_screen.dart';
import '../../features/questions/bulk_import_screen.dart';
import '../../features/mock_tests/mock_test_list_screen.dart';
import '../../features/mock_tests/create_mock_test_screen.dart';
import '../../features/study_materials/study_materials_screens.dart';
import '../../features/current_affairs/current_affairs_screens.dart';
import '../../features/users/user_list_screen.dart';
import '../../features/notifications/notification_screens.dart';
import '../../features/analytics/admin_analytics_screen.dart';
import '../../features/syllabus/syllabus_screen.dart';
import '../../features/previous_papers/previous_papers_screens.dart';
import '../../features/settings/admin_settings_screen.dart';
import '../../shared/widgets/admin_shell.dart';
import '../../shared/providers/admin_auth_provider.dart';

final adminRouterProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(adminAuthProvider);

  return GoRouter(
    initialLocation: '/admin/login',
    debugLogDiagnostics: true,
    redirect: (context, state) {
      final isLoggedIn = authState.status == AdminAuthStatus.authenticated;
      final isLoginRoute = state.matchedLocation == '/admin/login';

      if (!isLoggedIn && !isLoginRoute) return '/admin/login';
      if (isLoggedIn && isLoginRoute) return '/admin/dashboard';
      return null;
    },
    routes: [
      GoRoute(
        path: '/admin/login',
        builder: (context, state) => const AdminLoginScreen(),
      ),
      ShellRoute(
        builder: (context, state, child) => AdminShell(child: child),
        routes: [
          GoRoute(path: '/admin/dashboard', builder: (_, __) => const AdminDashboardScreen()),
          GoRoute(path: '/admin/questions', builder: (_, __) => const QuestionListScreen()),
          GoRoute(path: '/admin/questions/add', builder: (_, __) => const AddEditQuestionScreen()),
          GoRoute(path: '/admin/questions/edit', builder: (_, state) =>
            AddEditQuestionScreen(questionId: state.uri.queryParameters['id'])),
          GoRoute(path: '/admin/questions/import', builder: (_, __) => const BulkImportScreen()),
          GoRoute(path: '/admin/mock-tests', builder: (_, __) => const MockTestListScreen()),
          GoRoute(path: '/admin/mock-tests/create', builder: (_, __) => const CreateMockTestScreen()),
          GoRoute(path: '/admin/mock-tests/edit', builder: (_, state) =>
            CreateMockTestScreen(testId: state.uri.queryParameters['id'])),
          GoRoute(path: '/admin/materials', builder: (_, __) => const MaterialsListScreen()),
          GoRoute(path: '/admin/materials/upload', builder: (_, __) => const UploadMaterialScreen()),
          GoRoute(path: '/admin/current-affairs', builder: (_, __) => const CurrentAffairsListScreen()),
          GoRoute(path: '/admin/current-affairs/add', builder: (_, __) => const AddEditArticleScreen()),
          GoRoute(path: '/admin/current-affairs/edit', builder: (_, state) =>
            AddEditArticleScreen(articleId: state.uri.queryParameters['id'])),
          GoRoute(path: '/admin/users', builder: (_, __) => const UserListScreen()),
          GoRoute(path: '/admin/notifications', builder: (_, __) => const NotificationHistoryScreen()),
          GoRoute(path: '/admin/notifications/compose', builder: (_, __) => const NotificationComposeScreen()),
          GoRoute(path: '/admin/analytics', builder: (_, __) => const AdminAnalyticsScreen()),
          GoRoute(path: '/admin/syllabus', builder: (_, __) => const SyllabusScreen()),
          GoRoute(path: '/admin/previous-papers', builder: (_, __) => const PreviousPapersScreen()),
          GoRoute(path: '/admin/previous-papers/add', builder: (_, __) => const AddPaperScreen()),
          GoRoute(path: '/admin/settings', builder: (_, __) => const AdminSettingsScreen()),
        ],
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(child: Text('Admin page not found: ${state.error}')),
    ),
  );
});
