/// Application-wide constants for TNPSC Group 4 Master 2026
class AppConstants {
  AppConstants._();

  // App Info
  static const String appName         = 'Thiral';
  static const String appNameTamil    = 'திறல்';
  static const String appFullName     = 'Thiral — TNPSC Group 4 Master 2026';
  static const String appTagline      = 'Master every skill. Crack every exam.';
  static const String appTaglineTamil = 'திறல் பெறு · வெற்றி அடை';
  static const String packageId       = 'com.thiral.app';
  static const String bundleId        = 'com.thiral.app';
  static const String appDomain       = 'thiral.app';
  static const String appVersion      = '1.0.0';
  static const String playStoreId     = 'com.thiral.app';
  static const String appStoreId      = 'REPLACE_WITH_APPLE_ID';
  static const String supportEmail    = 'support@thiral.app';
  static const String privacyUrl      = 'https://thiral.app/privacy';
  static const String termsUrl        = 'https://thiral.app/terms';

  // Exam Info
  static final DateTime examDate = DateTime(2026, 12, 15); // Update when official date released
  static const DateTime examTargetDate = DateTime(2026, 12, 15);
  static const String examName = 'TNPSC Group IV & VAO 2026';
  static const String examNameTamil = 'TNPSC குரூப் IV & VAO';
  static const int totalQuestions = 100;
  static const int examDurationMinutes = 90;

  // Test Configuration
  static const int fullMockQuestions = 100;
  static const int fullMockDurationMinutes = 90;
  static const int subjectTestQuestions = 50;
  static const int subjectTestDurationMinutes = 45;
  static const int chapterTestQuestions = 25;
  static const int chapterTestDurationMinutes = 20;
  static const int dailyChallengeQuestions = 10;
  static const int dailyChallengeDurationMinutes = 10;

  // Marking Scheme
  static const double correctMark = 1.0;
  static const double wrongMark = -0.33;

  // AI System Prompt (Gemini)
  static const String aiSystemPrompt = '''
You are TamilBot, an expert TNPSC Group 4 exam coach. Answer in simple Tamil and English. 
Focus on TNPSC syllabus topics. Keep answers exam-focused and concise. 
When asked for practice questions, format them as numbered MCQs with options A/B/C/D.
Subjects: Tamil Language, General Studies (History, Geography, Polity, Economy, Science), 
Aptitude & Mental Ability.
''';

  // Hive Box Names
  static const String userBox = 'user_box';
  static const String settingsBox = 'settings_box';
  static const String bookmarksBox = 'bookmarks_box';
  static const String downloadedMaterialsBox = 'downloaded_materials_box';
  static const String readingProgressBox = 'reading_progress_box';
  static const String quotesBox = 'quotes_box';
  static const String cacheBox = 'cache_box';
  static const String testResultsBox = 'test_results_box';
  static const String notificationsBox = 'notifications_box';

  // Firestore Collections
  static const String usersCollection = 'users';
  static const String questionsCollection = 'questions';
  static const String mockTestsCollection = 'mock_tests';
  static const String studyMaterialsCollection = 'study_materials';
  static const String currentAffairsCollection = 'current_affairs';
  static const String notificationsCollection = 'notifications';
  static const String leaderboardCollection = 'leaderboard';
  static const String achievementsCollection = 'achievements';
  static const String testAttemptsCollection = 'test_attempts';
  static const String conversationsCollection = 'conversations';
  static const String quotesCollection = 'quotes';
  static const String syllabusCollection = 'syllabus';
  static const String previousPapersCollection = 'previous_papers';
  static const String audioBooksCollection = 'audio_books';

  // Subjects
  static const List<String> subjects = ['Tamil', 'General Studies', 'Aptitude & Mental Ability'];
  static const List<String> subjectsTamil = ['தமிழ்', 'பொது அறிவு', 'எண்கணிதம் & மனக்கணக்கு'];

  // Districts of Tamil Nadu
  static const List<String> districts = [
    'Ariyalur', 'Chengalpattu', 'Chennai', 'Coimbatore', 'Cuddalore',
    'Dharmapuri', 'Dindigul', 'Erode', 'Kallakurichi', 'Kancheepuram',
    'Karur', 'Krishnagiri', 'Madurai', 'Mayiladuthurai', 'Nagapattinam',
    'Namakkal', 'Nilgiris', 'Perambalur', 'Pudukkottai', 'Ramanathapuram',
    'Ranipet', 'Salem', 'Sivagangai', 'Tenkasi', 'Thanjavur',
    'Theni', 'Thoothukudi', 'Tiruchirappalli', 'Tirunelveli', 'Tirupattur',
    'Tiruvallur', 'Tiruvannamalai', 'Tiruvarur', 'Vellore', 'Viluppuram',
    'Virudhunagar',
  ];

  // Pagination
  static const int leaderboardPageSize = 20;
  static const int questionsPageSize = 20;
  static const int currentAffairsPageSize = 10;

  // Achievement IDs
  static const String achievementFirstStep = 'first_step';
  static const String achievementStreakMaster = 'streak_master';
  static const String achievementCentury = 'century';
  static const String achievementTamilScholar = 'tamil_scholar';
  static const String achievementSpeedDemon = 'speed_demon';
  static const String achievementPerfectScore = 'perfect_score';
  static const String achievementNightOwl = 'night_owl';
  static const String achievementEarlyBird = 'early_bird';
}
