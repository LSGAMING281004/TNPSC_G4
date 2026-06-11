// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'Thiral';

  @override
  String get loginTitle => 'Welcome Back';

  @override
  String get loginSubtitle => 'Your TNPSC journey continues';

  @override
  String get loginEmailHint => 'Email Address';

  @override
  String get loginPasswordHint => 'Password';

  @override
  String get loginButton => 'Login';

  @override
  String get loginGoogleButton => 'Continue with Google';

  @override
  String get loginGuestButton => 'Continue as Guest';

  @override
  String dashboardExamCountdown(int days) {
    return '$days days to exam';
  }

  @override
  String dashboardDailyTarget(int count) {
    return 'Today\'s Target: $count Questions';
  }

  @override
  String dashboardStreak(int days) {
    return '🔥 $days Day Streak';
  }

  @override
  String get appFullName => 'App Full Name';

  @override
  String get appTagline => 'App Tagline';

  @override
  String get welcomeTo => 'Welcome To';

  @override
  String get loading => 'Loading';

  @override
  String get error => 'Error';

  @override
  String get retry => 'Retry';

  @override
  String get cancel => 'Cancel';

  @override
  String get confirm => 'Confirm';

  @override
  String get save => 'Save';

  @override
  String get edit => 'Edit';

  @override
  String get delete => 'Delete';

  @override
  String get search => 'Search';

  @override
  String get noData => 'No Data';

  @override
  String get noInternet => 'No Internet';

  @override
  String get unknownError => 'Unknown Error';

  @override
  String get success => 'Success';

  @override
  String get submit => 'Submit';

  @override
  String get next => 'Next';

  @override
  String get back => 'Back';

  @override
  String get close => 'Close';

  @override
  String get share => 'Share';

  @override
  String get download => 'Download';

  @override
  String get viewAll => 'View All';

  @override
  String get seeMore => 'See More';

  @override
  String get by => 'By';

  @override
  String get points => 'Points';

  @override
  String get rank => 'Rank';

  @override
  String get accuracy => 'Accuracy';

  @override
  String get questions => 'Questions';

  @override
  String get minutes => 'Minutes';

  @override
  String get seconds => 'Seconds';

  @override
  String get hours => 'Hours';

  @override
  String get days => 'Days';

  @override
  String get streak => 'Streak';

  @override
  String get badge => 'Badge';

  @override
  String get premium => 'Premium';

  @override
  String get tryAgain => 'Try Again';

  @override
  String get goBack => 'Go Back';

  @override
  String get comingSoon => 'Coming Soon';

  @override
  String get optional => 'Optional';

  @override
  String get login => 'Login';

  @override
  String get register => 'Register';

  @override
  String get logout => 'Logout';

  @override
  String get email => 'Email';

  @override
  String get password => 'Password';

  @override
  String get confirmPassword => 'Confirm Password';

  @override
  String get name => 'Name';

  @override
  String get district => 'District';

  @override
  String get forgotPassword => 'Forgot Password';

  @override
  String get sendOtp => 'Send Otp';

  @override
  String get verifyOtp => 'Verify Otp';

  @override
  String get orContinueWith => 'Or Continue With';

  @override
  String get googleSignIn => 'Google Sign In';

  @override
  String get guestLogin => 'Guest Login';

  @override
  String get alreadyAccount => 'Already Account';

  @override
  String get noAccount => 'No Account';

  @override
  String get signUp => 'Sign Up';

  @override
  String get targetScore => 'Target Score';

  @override
  String get welcomeBack => 'Welcome Back';

  @override
  String get createAccount => 'Create Account';

  @override
  String get resetPassword => 'Reset Password';

  @override
  String get passwordChanged => 'Password Changed';

  @override
  String get invalidEmail => 'Invalid Email';

  @override
  String get weakPassword => 'Weak Password';

  @override
  String get emailNotFound => 'Email Not Found';

  @override
  String get wrongPassword => 'Wrong Password';

  @override
  String get networkError => 'Network Error';

  @override
  String get skip => 'Skip';

  @override
  String get getStarted => 'Get Started';

  @override
  String get onboardTitle1 => 'Onboard Title1';

  @override
  String get onboardSub1 => 'Onboard Sub1';

  @override
  String get onboardTitle2 => 'Onboard Title2';

  @override
  String get onboardSub2 => 'Onboard Sub2';

  @override
  String get onboardTitle3 => 'Onboard Title3';

  @override
  String get onboardSub3 => 'Onboard Sub3';

  @override
  String get onboardTitle4 => 'Onboard Title4';

  @override
  String get onboardSub4 => 'Onboard Sub4';

  @override
  String get home => 'Home';

  @override
  String get goodMorning => 'Good Morning';

  @override
  String get goodAfternoon => 'Good Afternoon';

  @override
  String get goodEvening => 'Good Evening';

  @override
  String get examIn => 'Exam In';

  @override
  String get daysLeft => 'Days Left';

  @override
  String get hoursLeft => 'Hours Left';

  @override
  String get dailyGoal => 'Daily Goal';

  @override
  String get questionsToday => 'Questions Today';

  @override
  String get studyStreak => 'Study Streak';

  @override
  String get streakDays => 'Streak Days';

  @override
  String get weeklyProgress => 'Weekly Progress';

  @override
  String get yourProgress => 'Your Progress';

  @override
  String get continueStudying => 'Continue Studying';

  @override
  String get quickActions => 'Quick Actions';

  @override
  String get todayCurrentAffairs => 'Today Current Affairs';

  @override
  String get weakSubjects => 'Weak Subjects';

  @override
  String get practiceMore => 'Practice More';

  @override
  String get homeTab => 'Home Tab';

  @override
  String get testsTab => 'Tests Tab';

  @override
  String get materialsTab => 'Materials Tab';

  @override
  String get analyticsTab => 'Analytics Tab';

  @override
  String get profileTab => 'Profile Tab';

  @override
  String get mockTests => 'Mock Tests';

  @override
  String get startTest => 'Start Test';

  @override
  String get fullMock => 'Full Mock';

  @override
  String get subjectTest => 'Subject Test';

  @override
  String get chapterTest => 'Chapter Test';

  @override
  String get dailyChallenge => 'Daily Challenge';

  @override
  String get testInstructions => 'Test Instructions';

  @override
  String get questionsCount => 'Questions Count';

  @override
  String get duration => 'Duration';

  @override
  String get difficulty => 'Difficulty';

  @override
  String get startNow => 'Start Now';

  @override
  String get language => 'Language';

  @override
  String get previous => 'Previous';

  @override
  String get submitTest => 'Submit Test';

  @override
  String get confirmSubmit => 'Confirm Submit';

  @override
  String get markForReview => 'Mark For Review';

  @override
  String get clearResponse => 'Clear Response';

  @override
  String get questionPalette => 'Question Palette';

  @override
  String get answered => 'Answered';

  @override
  String get unanswered => 'Unanswered';

  @override
  String get markedForReview => 'Marked For Review';

  @override
  String get timeLeft => 'Time Left';

  @override
  String get autoSubmit => 'Auto Submit';

  @override
  String get testResult => 'Test Result';

  @override
  String get yourScore => 'Your Score';

  @override
  String get correct => 'Correct';

  @override
  String get wrong => 'Wrong';

  @override
  String get unattempted => 'Unattempted';

  @override
  String get percentage => 'Percentage';

  @override
  String get viewSolutions => 'View Solutions';

  @override
  String get retake => 'Retake';

  @override
  String get nextTest => 'Next Test';

  @override
  String get timeAnalysis => 'Time Analysis';

  @override
  String get avgTimePerQuestion => 'Avg Time Per Question';

  @override
  String get strongSubjects => 'Strong Subjects';

  @override
  String get weakSubjectsResult => 'Weak Subjects Result';

  @override
  String get explanation => 'Explanation';

  @override
  String get reportError => 'Report Error';

  @override
  String get correctAnswer => 'Correct Answer';

  @override
  String get yourAnswer => 'Your Answer';

  @override
  String get questionBank => 'Question Bank';

  @override
  String get filter => 'Filter';

  @override
  String get subject => 'Subject';

  @override
  String get chapter => 'Chapter';

  @override
  String get topic => 'Topic';

  @override
  String get difficultyLevel => 'Difficulty Level';

  @override
  String get easy => 'Easy';

  @override
  String get medium => 'Medium';

  @override
  String get hard => 'Hard';

  @override
  String get searchQuestions => 'Search Questions';

  @override
  String get bookmarkAdded => 'Bookmark Added';

  @override
  String get bookmarkRemoved => 'Bookmark Removed';

  @override
  String get myBookmarks => 'My Bookmarks';

  @override
  String get revealAnswer => 'Reveal Answer';

  @override
  String get practiceSimilar => 'Practice Similar';

  @override
  String get noQuestionsFound => 'No Questions Found';

  @override
  String get allSubjects => 'All Subjects';

  @override
  String get studyMaterials => 'Study Materials';

  @override
  String get downloadPdf => 'Download Pdf';

  @override
  String get pdfDownloaded => 'Pdf Downloaded';

  @override
  String get openPdf => 'Open Pdf';

  @override
  String get bookmarkPage => 'Bookmark Page';

  @override
  String get shareNote => 'Share Note';

  @override
  String get downloadedMaterials => 'Downloaded Materials';

  @override
  String get storageUsed => 'Storage Used';

  @override
  String get deleteDownload => 'Delete Download';

  @override
  String get viewOnline => 'View Online';

  @override
  String get materialNotFound => 'Material Not Found';

  @override
  String get currentAffairs => 'Current Affairs';

  @override
  String get daily => 'Daily';

  @override
  String get monthly => 'Monthly';

  @override
  String get weeklyQuiz => 'Weekly Quiz';

  @override
  String get searchNews => 'Search News';

  @override
  String get readMore => 'Read More';

  @override
  String get source => 'Source';

  @override
  String get publishedOn => 'Published On';

  @override
  String get quizStart => 'Quiz Start';

  @override
  String get quizResult => 'Quiz Result';

  @override
  String get noArticles => 'No Articles';

  @override
  String get analytics => 'Analytics';

  @override
  String get overview => 'Overview';

  @override
  String get subjectPerformance => 'Subject Performance';

  @override
  String get testHistory => 'Test History';

  @override
  String get tips => 'Tips';

  @override
  String get totalAttempted => 'Total Attempted';

  @override
  String get avgAccuracy => 'Avg Accuracy';

  @override
  String get totalTime => 'Total Time';

  @override
  String get bestScore => 'Best Score';

  @override
  String get weakestSubject => 'Weakest Subject';

  @override
  String get strongestSubject => 'Strongest Subject';

  @override
  String get improvementTip => 'Improvement Tip';

  @override
  String get studyStreakLabel => 'Study Streak Label';

  @override
  String get noDataYet => 'No Data Yet';

  @override
  String get loadingChart => 'Loading Chart';

  @override
  String get leaderboard => 'Leaderboard';

  @override
  String get stateRank => 'State Rank';

  @override
  String get districtRank => 'District Rank';

  @override
  String get friendsRank => 'Friends Rank';

  @override
  String get weeklyRank => 'Weekly Rank';

  @override
  String get yourRank => 'Your Rank';

  @override
  String get noLeaderboard => 'No Leaderboard';

  @override
  String get aiAssistant => 'Ai Assistant';

  @override
  String get typeMessage => 'Type Message';

  @override
  String get askTnpsc => 'Ask Tnpsc';

  @override
  String get suggestedQuestions => 'Suggested Questions';

  @override
  String get thinking => 'Thinking';

  @override
  String get tapToAsk => 'Tap To Ask';

  @override
  String get clearChat => 'Clear Chat';

  @override
  String get profile => 'Profile';

  @override
  String get editProfile => 'Edit Profile';

  @override
  String get myAchievements => 'My Achievements';

  @override
  String get examReadiness => 'Exam Readiness';

  @override
  String get targetScoreLabel => 'Target Score Label';

  @override
  String get studyProgress => 'Study Progress';

  @override
  String get allBadges => 'All Badges';

  @override
  String get locked => 'Locked';

  @override
  String get unlocked => 'Unlocked';

  @override
  String get settings => 'Settings';

  @override
  String get appLanguage => 'App Language';

  @override
  String get darkMode => 'Dark Mode';

  @override
  String get notifications => 'Notifications';

  @override
  String get dailyReminder => 'Daily Reminder';

  @override
  String get clearCache => 'Clear Cache';

  @override
  String get privacyPolicy => 'Privacy Policy';

  @override
  String get terms => 'Terms';

  @override
  String get deleteAccount => 'Delete Account';

  @override
  String get version => 'Version';

  @override
  String get premiumBadge => 'Premium Badge';

  @override
  String get subjectTamil => 'Subject Tamil';

  @override
  String get subjectGS => 'Subject Gs';

  @override
  String get subjectAptitude => 'Subject Aptitude';

  @override
  String get fieldRequired => 'Field Required';

  @override
  String get passwordTooShort => 'Password Too Short';

  @override
  String get passwordMismatch => 'Password Mismatch';

  @override
  String get downloadFailed => 'Download Failed';

  @override
  String get uploadFailed => 'Upload Failed';

  @override
  String get testLoadFailed => 'Test Load Failed';

  @override
  String get questionsFailed => 'Questions Failed';

  @override
  String get sessionExpired => 'Session Expired';

  @override
  String get noInternetMsg => 'No Internet Msg';

  @override
  String get serverError => 'Server Error';
}
