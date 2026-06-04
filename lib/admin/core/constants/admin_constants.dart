/// Constants used across the admin panel.
class AdminConstants {
  AdminConstants._();

  static const String appName = 'TNPSC Admin Console';
  static const String firebaseProject = 'tnpsc-group-4-master-2026';

  // Sidebar width
  static const double sidebarExpandedWidth = 240.0;
  static const double sidebarCollapsedWidth = 60.0;
  static const double topBarHeight = 64.0;

  // Pagination
  static const int questionsPerPage = 25;
  static const int usersPerPage = 50;
  static const int activityLogLimit = 20;

  // Firestore collection names
  static const String usersCollection = 'users';
  static const String questionsCollection = 'questions';
  static const String mockTestsCollection = 'mock_tests';
  static const String testAttemptsCollection = 'test_attempts';
  static const String studyMaterialsCollection = 'study_materials';
  static const String currentAffairsCollection = 'current_affairs';
  static const String notificationsCollection = 'notifications';
  static const String syllabusCollection = 'syllabus';
  static const String previousPapersCollection = 'previous_papers';
  static const String adminUsersCollection = 'adminUsers';
  static const String adminActivityLogCollection = 'admin_activity_log';
  static const String adminConfigCollection = 'admin_config';
  static const String analyticsSummaryCollection = 'analytics_summary';
  static const String metadataCollection = 'metadata';
  static const String audioBooksCollection = 'audio_books';
  static const String quotesCollection = 'quotes';

  // Admin roles
  static const String roleSuperAdmin = 'superAdmin';
  static const String roleContentAdmin = 'contentAdmin';
  static const String roleViewer = 'viewer';
  static const String roleUser = 'user';

  // Firebase Storage paths
  static const String questionImagesPath = 'questions/images';
  static const String studyMaterialsPath = 'study_materials';
  static const String currentAffairsImagesPath = 'current_affairs/images';
  static const String previousPapersPath = 'previous_papers';
  static const String audioBooksAudioPath = 'audio_books/audio';
  static const String audioBooksCoverPath = 'audio_books/covers';

  // Subjects
  static const List<String> defaultSubjects = [
    'Tamil',
    'General Studies',
    'Aptitude & Mental Ability',
  ];

  // Difficulties
  static const List<String> difficulties = ['Easy', 'Medium', 'Hard'];

  // Mock test types
  static const List<String> testTypes = [
    'Full Mock',
    'Subject-wise',
    'Chapter-wise',
    'Daily Challenge',
  ];

  // Mock test statuses
  static const List<String> testStatuses = ['Draft', 'Active', 'Archived'];

  // Current affairs categories
  static const List<String> caCategories = [
    'Tamil Nadu',
    'India',
    'Economy',
    'Science & Tech',
    'Sports',
    'Environment',
    'International',
  ];

  // Notification topics
  static const Map<String, String> notificationTopics = {
    'All Users': 'all_users',
    'Premium Users': 'premium_users',
    'Daily Reminder': 'daily_reminders',
    'New Mock Test': 'mock_test_alerts',
    'Current Affairs': 'current_affairs',
    'Exam Updates': 'exam_updates',
  };
}
