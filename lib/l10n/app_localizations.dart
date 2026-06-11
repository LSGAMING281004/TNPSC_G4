import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_ta.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('ta'),
  ];

  /// No description provided for @appName.
  ///
  /// In en, this message translates to:
  /// **'Thiral'**
  String get appName;

  /// No description provided for @loginTitle.
  ///
  /// In en, this message translates to:
  /// **'Welcome Back'**
  String get loginTitle;

  /// No description provided for @loginSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Your TNPSC journey continues'**
  String get loginSubtitle;

  /// No description provided for @loginEmailHint.
  ///
  /// In en, this message translates to:
  /// **'Email Address'**
  String get loginEmailHint;

  /// No description provided for @loginPasswordHint.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get loginPasswordHint;

  /// No description provided for @loginButton.
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get loginButton;

  /// No description provided for @loginGoogleButton.
  ///
  /// In en, this message translates to:
  /// **'Continue with Google'**
  String get loginGoogleButton;

  /// No description provided for @loginGuestButton.
  ///
  /// In en, this message translates to:
  /// **'Continue as Guest'**
  String get loginGuestButton;

  /// No description provided for @dashboardExamCountdown.
  ///
  /// In en, this message translates to:
  /// **'{days} days to exam'**
  String dashboardExamCountdown(int days);

  /// No description provided for @dashboardDailyTarget.
  ///
  /// In en, this message translates to:
  /// **'Today\'s Target: {count} Questions'**
  String dashboardDailyTarget(int count);

  /// No description provided for @dashboardStreak.
  ///
  /// In en, this message translates to:
  /// **'🔥 {days} Day Streak'**
  String dashboardStreak(int days);

  /// No description provided for @appFullName.
  ///
  /// In en, this message translates to:
  /// **'App Full Name'**
  String get appFullName;

  /// No description provided for @appTagline.
  ///
  /// In en, this message translates to:
  /// **'App Tagline'**
  String get appTagline;

  /// No description provided for @welcomeTo.
  ///
  /// In en, this message translates to:
  /// **'Welcome To'**
  String get welcomeTo;

  /// No description provided for @loading.
  ///
  /// In en, this message translates to:
  /// **'Loading'**
  String get loading;

  /// No description provided for @error.
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get error;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @confirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get confirm;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @edit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get edit;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @search.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get search;

  /// No description provided for @noData.
  ///
  /// In en, this message translates to:
  /// **'No Data'**
  String get noData;

  /// No description provided for @noInternet.
  ///
  /// In en, this message translates to:
  /// **'No Internet'**
  String get noInternet;

  /// No description provided for @unknownError.
  ///
  /// In en, this message translates to:
  /// **'Unknown Error'**
  String get unknownError;

  /// No description provided for @success.
  ///
  /// In en, this message translates to:
  /// **'Success'**
  String get success;

  /// No description provided for @submit.
  ///
  /// In en, this message translates to:
  /// **'Submit'**
  String get submit;

  /// No description provided for @next.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get next;

  /// No description provided for @back.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get back;

  /// No description provided for @close.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// No description provided for @share.
  ///
  /// In en, this message translates to:
  /// **'Share'**
  String get share;

  /// No description provided for @download.
  ///
  /// In en, this message translates to:
  /// **'Download'**
  String get download;

  /// No description provided for @viewAll.
  ///
  /// In en, this message translates to:
  /// **'View All'**
  String get viewAll;

  /// No description provided for @seeMore.
  ///
  /// In en, this message translates to:
  /// **'See More'**
  String get seeMore;

  /// No description provided for @by.
  ///
  /// In en, this message translates to:
  /// **'By'**
  String get by;

  /// No description provided for @points.
  ///
  /// In en, this message translates to:
  /// **'Points'**
  String get points;

  /// No description provided for @rank.
  ///
  /// In en, this message translates to:
  /// **'Rank'**
  String get rank;

  /// No description provided for @accuracy.
  ///
  /// In en, this message translates to:
  /// **'Accuracy'**
  String get accuracy;

  /// No description provided for @questions.
  ///
  /// In en, this message translates to:
  /// **'Questions'**
  String get questions;

  /// No description provided for @minutes.
  ///
  /// In en, this message translates to:
  /// **'Minutes'**
  String get minutes;

  /// No description provided for @seconds.
  ///
  /// In en, this message translates to:
  /// **'Seconds'**
  String get seconds;

  /// No description provided for @hours.
  ///
  /// In en, this message translates to:
  /// **'Hours'**
  String get hours;

  /// No description provided for @days.
  ///
  /// In en, this message translates to:
  /// **'Days'**
  String get days;

  /// No description provided for @streak.
  ///
  /// In en, this message translates to:
  /// **'Streak'**
  String get streak;

  /// No description provided for @badge.
  ///
  /// In en, this message translates to:
  /// **'Badge'**
  String get badge;

  /// No description provided for @premium.
  ///
  /// In en, this message translates to:
  /// **'Premium'**
  String get premium;

  /// No description provided for @tryAgain.
  ///
  /// In en, this message translates to:
  /// **'Try Again'**
  String get tryAgain;

  /// No description provided for @goBack.
  ///
  /// In en, this message translates to:
  /// **'Go Back'**
  String get goBack;

  /// No description provided for @comingSoon.
  ///
  /// In en, this message translates to:
  /// **'Coming Soon'**
  String get comingSoon;

  /// No description provided for @optional.
  ///
  /// In en, this message translates to:
  /// **'Optional'**
  String get optional;

  /// No description provided for @login.
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get login;

  /// No description provided for @register.
  ///
  /// In en, this message translates to:
  /// **'Register'**
  String get register;

  /// No description provided for @logout.
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get logout;

  /// No description provided for @email.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get email;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// No description provided for @confirmPassword.
  ///
  /// In en, this message translates to:
  /// **'Confirm Password'**
  String get confirmPassword;

  /// No description provided for @name.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get name;

  /// No description provided for @district.
  ///
  /// In en, this message translates to:
  /// **'District'**
  String get district;

  /// No description provided for @forgotPassword.
  ///
  /// In en, this message translates to:
  /// **'Forgot Password'**
  String get forgotPassword;

  /// No description provided for @sendOtp.
  ///
  /// In en, this message translates to:
  /// **'Send Otp'**
  String get sendOtp;

  /// No description provided for @verifyOtp.
  ///
  /// In en, this message translates to:
  /// **'Verify Otp'**
  String get verifyOtp;

  /// No description provided for @orContinueWith.
  ///
  /// In en, this message translates to:
  /// **'Or Continue With'**
  String get orContinueWith;

  /// No description provided for @googleSignIn.
  ///
  /// In en, this message translates to:
  /// **'Google Sign In'**
  String get googleSignIn;

  /// No description provided for @guestLogin.
  ///
  /// In en, this message translates to:
  /// **'Guest Login'**
  String get guestLogin;

  /// No description provided for @alreadyAccount.
  ///
  /// In en, this message translates to:
  /// **'Already Account'**
  String get alreadyAccount;

  /// No description provided for @noAccount.
  ///
  /// In en, this message translates to:
  /// **'No Account'**
  String get noAccount;

  /// No description provided for @signUp.
  ///
  /// In en, this message translates to:
  /// **'Sign Up'**
  String get signUp;

  /// No description provided for @targetScore.
  ///
  /// In en, this message translates to:
  /// **'Target Score'**
  String get targetScore;

  /// No description provided for @welcomeBack.
  ///
  /// In en, this message translates to:
  /// **'Welcome Back'**
  String get welcomeBack;

  /// No description provided for @createAccount.
  ///
  /// In en, this message translates to:
  /// **'Create Account'**
  String get createAccount;

  /// No description provided for @resetPassword.
  ///
  /// In en, this message translates to:
  /// **'Reset Password'**
  String get resetPassword;

  /// No description provided for @passwordChanged.
  ///
  /// In en, this message translates to:
  /// **'Password Changed'**
  String get passwordChanged;

  /// No description provided for @invalidEmail.
  ///
  /// In en, this message translates to:
  /// **'Invalid Email'**
  String get invalidEmail;

  /// No description provided for @weakPassword.
  ///
  /// In en, this message translates to:
  /// **'Weak Password'**
  String get weakPassword;

  /// No description provided for @emailNotFound.
  ///
  /// In en, this message translates to:
  /// **'Email Not Found'**
  String get emailNotFound;

  /// No description provided for @wrongPassword.
  ///
  /// In en, this message translates to:
  /// **'Wrong Password'**
  String get wrongPassword;

  /// No description provided for @networkError.
  ///
  /// In en, this message translates to:
  /// **'Network Error'**
  String get networkError;

  /// No description provided for @skip.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get skip;

  /// No description provided for @getStarted.
  ///
  /// In en, this message translates to:
  /// **'Get Started'**
  String get getStarted;

  /// No description provided for @onboardTitle1.
  ///
  /// In en, this message translates to:
  /// **'Onboard Title1'**
  String get onboardTitle1;

  /// No description provided for @onboardSub1.
  ///
  /// In en, this message translates to:
  /// **'Onboard Sub1'**
  String get onboardSub1;

  /// No description provided for @onboardTitle2.
  ///
  /// In en, this message translates to:
  /// **'Onboard Title2'**
  String get onboardTitle2;

  /// No description provided for @onboardSub2.
  ///
  /// In en, this message translates to:
  /// **'Onboard Sub2'**
  String get onboardSub2;

  /// No description provided for @onboardTitle3.
  ///
  /// In en, this message translates to:
  /// **'Onboard Title3'**
  String get onboardTitle3;

  /// No description provided for @onboardSub3.
  ///
  /// In en, this message translates to:
  /// **'Onboard Sub3'**
  String get onboardSub3;

  /// No description provided for @onboardTitle4.
  ///
  /// In en, this message translates to:
  /// **'Onboard Title4'**
  String get onboardTitle4;

  /// No description provided for @onboardSub4.
  ///
  /// In en, this message translates to:
  /// **'Onboard Sub4'**
  String get onboardSub4;

  /// No description provided for @home.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get home;

  /// No description provided for @goodMorning.
  ///
  /// In en, this message translates to:
  /// **'Good Morning'**
  String get goodMorning;

  /// No description provided for @goodAfternoon.
  ///
  /// In en, this message translates to:
  /// **'Good Afternoon'**
  String get goodAfternoon;

  /// No description provided for @goodEvening.
  ///
  /// In en, this message translates to:
  /// **'Good Evening'**
  String get goodEvening;

  /// No description provided for @examIn.
  ///
  /// In en, this message translates to:
  /// **'Exam In'**
  String get examIn;

  /// No description provided for @daysLeft.
  ///
  /// In en, this message translates to:
  /// **'Days Left'**
  String get daysLeft;

  /// No description provided for @hoursLeft.
  ///
  /// In en, this message translates to:
  /// **'Hours Left'**
  String get hoursLeft;

  /// No description provided for @dailyGoal.
  ///
  /// In en, this message translates to:
  /// **'Daily Goal'**
  String get dailyGoal;

  /// No description provided for @questionsToday.
  ///
  /// In en, this message translates to:
  /// **'Questions Today'**
  String get questionsToday;

  /// No description provided for @studyStreak.
  ///
  /// In en, this message translates to:
  /// **'Study Streak'**
  String get studyStreak;

  /// No description provided for @streakDays.
  ///
  /// In en, this message translates to:
  /// **'Streak Days'**
  String get streakDays;

  /// No description provided for @weeklyProgress.
  ///
  /// In en, this message translates to:
  /// **'Weekly Progress'**
  String get weeklyProgress;

  /// No description provided for @yourProgress.
  ///
  /// In en, this message translates to:
  /// **'Your Progress'**
  String get yourProgress;

  /// No description provided for @continueStudying.
  ///
  /// In en, this message translates to:
  /// **'Continue Studying'**
  String get continueStudying;

  /// No description provided for @quickActions.
  ///
  /// In en, this message translates to:
  /// **'Quick Actions'**
  String get quickActions;

  /// No description provided for @todayCurrentAffairs.
  ///
  /// In en, this message translates to:
  /// **'Today Current Affairs'**
  String get todayCurrentAffairs;

  /// No description provided for @weakSubjects.
  ///
  /// In en, this message translates to:
  /// **'Weak Subjects'**
  String get weakSubjects;

  /// No description provided for @practiceMore.
  ///
  /// In en, this message translates to:
  /// **'Practice More'**
  String get practiceMore;

  /// No description provided for @homeTab.
  ///
  /// In en, this message translates to:
  /// **'Home Tab'**
  String get homeTab;

  /// No description provided for @testsTab.
  ///
  /// In en, this message translates to:
  /// **'Tests Tab'**
  String get testsTab;

  /// No description provided for @materialsTab.
  ///
  /// In en, this message translates to:
  /// **'Materials Tab'**
  String get materialsTab;

  /// No description provided for @analyticsTab.
  ///
  /// In en, this message translates to:
  /// **'Analytics Tab'**
  String get analyticsTab;

  /// No description provided for @profileTab.
  ///
  /// In en, this message translates to:
  /// **'Profile Tab'**
  String get profileTab;

  /// No description provided for @mockTests.
  ///
  /// In en, this message translates to:
  /// **'Mock Tests'**
  String get mockTests;

  /// No description provided for @startTest.
  ///
  /// In en, this message translates to:
  /// **'Start Test'**
  String get startTest;

  /// No description provided for @fullMock.
  ///
  /// In en, this message translates to:
  /// **'Full Mock'**
  String get fullMock;

  /// No description provided for @subjectTest.
  ///
  /// In en, this message translates to:
  /// **'Subject Test'**
  String get subjectTest;

  /// No description provided for @chapterTest.
  ///
  /// In en, this message translates to:
  /// **'Chapter Test'**
  String get chapterTest;

  /// No description provided for @dailyChallenge.
  ///
  /// In en, this message translates to:
  /// **'Daily Challenge'**
  String get dailyChallenge;

  /// No description provided for @testInstructions.
  ///
  /// In en, this message translates to:
  /// **'Test Instructions'**
  String get testInstructions;

  /// No description provided for @questionsCount.
  ///
  /// In en, this message translates to:
  /// **'Questions Count'**
  String get questionsCount;

  /// No description provided for @duration.
  ///
  /// In en, this message translates to:
  /// **'Duration'**
  String get duration;

  /// No description provided for @difficulty.
  ///
  /// In en, this message translates to:
  /// **'Difficulty'**
  String get difficulty;

  /// No description provided for @startNow.
  ///
  /// In en, this message translates to:
  /// **'Start Now'**
  String get startNow;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @previous.
  ///
  /// In en, this message translates to:
  /// **'Previous'**
  String get previous;

  /// No description provided for @submitTest.
  ///
  /// In en, this message translates to:
  /// **'Submit Test'**
  String get submitTest;

  /// No description provided for @confirmSubmit.
  ///
  /// In en, this message translates to:
  /// **'Confirm Submit'**
  String get confirmSubmit;

  /// No description provided for @markForReview.
  ///
  /// In en, this message translates to:
  /// **'Mark For Review'**
  String get markForReview;

  /// No description provided for @clearResponse.
  ///
  /// In en, this message translates to:
  /// **'Clear Response'**
  String get clearResponse;

  /// No description provided for @questionPalette.
  ///
  /// In en, this message translates to:
  /// **'Question Palette'**
  String get questionPalette;

  /// No description provided for @answered.
  ///
  /// In en, this message translates to:
  /// **'Answered'**
  String get answered;

  /// No description provided for @unanswered.
  ///
  /// In en, this message translates to:
  /// **'Unanswered'**
  String get unanswered;

  /// No description provided for @markedForReview.
  ///
  /// In en, this message translates to:
  /// **'Marked For Review'**
  String get markedForReview;

  /// No description provided for @timeLeft.
  ///
  /// In en, this message translates to:
  /// **'Time Left'**
  String get timeLeft;

  /// No description provided for @autoSubmit.
  ///
  /// In en, this message translates to:
  /// **'Auto Submit'**
  String get autoSubmit;

  /// No description provided for @testResult.
  ///
  /// In en, this message translates to:
  /// **'Test Result'**
  String get testResult;

  /// No description provided for @yourScore.
  ///
  /// In en, this message translates to:
  /// **'Your Score'**
  String get yourScore;

  /// No description provided for @correct.
  ///
  /// In en, this message translates to:
  /// **'Correct'**
  String get correct;

  /// No description provided for @wrong.
  ///
  /// In en, this message translates to:
  /// **'Wrong'**
  String get wrong;

  /// No description provided for @unattempted.
  ///
  /// In en, this message translates to:
  /// **'Unattempted'**
  String get unattempted;

  /// No description provided for @percentage.
  ///
  /// In en, this message translates to:
  /// **'Percentage'**
  String get percentage;

  /// No description provided for @viewSolutions.
  ///
  /// In en, this message translates to:
  /// **'View Solutions'**
  String get viewSolutions;

  /// No description provided for @retake.
  ///
  /// In en, this message translates to:
  /// **'Retake'**
  String get retake;

  /// No description provided for @nextTest.
  ///
  /// In en, this message translates to:
  /// **'Next Test'**
  String get nextTest;

  /// No description provided for @timeAnalysis.
  ///
  /// In en, this message translates to:
  /// **'Time Analysis'**
  String get timeAnalysis;

  /// No description provided for @avgTimePerQuestion.
  ///
  /// In en, this message translates to:
  /// **'Avg Time Per Question'**
  String get avgTimePerQuestion;

  /// No description provided for @strongSubjects.
  ///
  /// In en, this message translates to:
  /// **'Strong Subjects'**
  String get strongSubjects;

  /// No description provided for @weakSubjectsResult.
  ///
  /// In en, this message translates to:
  /// **'Weak Subjects Result'**
  String get weakSubjectsResult;

  /// No description provided for @explanation.
  ///
  /// In en, this message translates to:
  /// **'Explanation'**
  String get explanation;

  /// No description provided for @reportError.
  ///
  /// In en, this message translates to:
  /// **'Report Error'**
  String get reportError;

  /// No description provided for @correctAnswer.
  ///
  /// In en, this message translates to:
  /// **'Correct Answer'**
  String get correctAnswer;

  /// No description provided for @yourAnswer.
  ///
  /// In en, this message translates to:
  /// **'Your Answer'**
  String get yourAnswer;

  /// No description provided for @questionBank.
  ///
  /// In en, this message translates to:
  /// **'Question Bank'**
  String get questionBank;

  /// No description provided for @filter.
  ///
  /// In en, this message translates to:
  /// **'Filter'**
  String get filter;

  /// No description provided for @subject.
  ///
  /// In en, this message translates to:
  /// **'Subject'**
  String get subject;

  /// No description provided for @chapter.
  ///
  /// In en, this message translates to:
  /// **'Chapter'**
  String get chapter;

  /// No description provided for @topic.
  ///
  /// In en, this message translates to:
  /// **'Topic'**
  String get topic;

  /// No description provided for @difficultyLevel.
  ///
  /// In en, this message translates to:
  /// **'Difficulty Level'**
  String get difficultyLevel;

  /// No description provided for @easy.
  ///
  /// In en, this message translates to:
  /// **'Easy'**
  String get easy;

  /// No description provided for @medium.
  ///
  /// In en, this message translates to:
  /// **'Medium'**
  String get medium;

  /// No description provided for @hard.
  ///
  /// In en, this message translates to:
  /// **'Hard'**
  String get hard;

  /// No description provided for @searchQuestions.
  ///
  /// In en, this message translates to:
  /// **'Search Questions'**
  String get searchQuestions;

  /// No description provided for @bookmarkAdded.
  ///
  /// In en, this message translates to:
  /// **'Bookmark Added'**
  String get bookmarkAdded;

  /// No description provided for @bookmarkRemoved.
  ///
  /// In en, this message translates to:
  /// **'Bookmark Removed'**
  String get bookmarkRemoved;

  /// No description provided for @myBookmarks.
  ///
  /// In en, this message translates to:
  /// **'My Bookmarks'**
  String get myBookmarks;

  /// No description provided for @revealAnswer.
  ///
  /// In en, this message translates to:
  /// **'Reveal Answer'**
  String get revealAnswer;

  /// No description provided for @practiceSimilar.
  ///
  /// In en, this message translates to:
  /// **'Practice Similar'**
  String get practiceSimilar;

  /// No description provided for @noQuestionsFound.
  ///
  /// In en, this message translates to:
  /// **'No Questions Found'**
  String get noQuestionsFound;

  /// No description provided for @allSubjects.
  ///
  /// In en, this message translates to:
  /// **'All Subjects'**
  String get allSubjects;

  /// No description provided for @studyMaterials.
  ///
  /// In en, this message translates to:
  /// **'Study Materials'**
  String get studyMaterials;

  /// No description provided for @downloadPdf.
  ///
  /// In en, this message translates to:
  /// **'Download Pdf'**
  String get downloadPdf;

  /// No description provided for @pdfDownloaded.
  ///
  /// In en, this message translates to:
  /// **'Pdf Downloaded'**
  String get pdfDownloaded;

  /// No description provided for @openPdf.
  ///
  /// In en, this message translates to:
  /// **'Open Pdf'**
  String get openPdf;

  /// No description provided for @bookmarkPage.
  ///
  /// In en, this message translates to:
  /// **'Bookmark Page'**
  String get bookmarkPage;

  /// No description provided for @shareNote.
  ///
  /// In en, this message translates to:
  /// **'Share Note'**
  String get shareNote;

  /// No description provided for @downloadedMaterials.
  ///
  /// In en, this message translates to:
  /// **'Downloaded Materials'**
  String get downloadedMaterials;

  /// No description provided for @storageUsed.
  ///
  /// In en, this message translates to:
  /// **'Storage Used'**
  String get storageUsed;

  /// No description provided for @deleteDownload.
  ///
  /// In en, this message translates to:
  /// **'Delete Download'**
  String get deleteDownload;

  /// No description provided for @viewOnline.
  ///
  /// In en, this message translates to:
  /// **'View Online'**
  String get viewOnline;

  /// No description provided for @materialNotFound.
  ///
  /// In en, this message translates to:
  /// **'Material Not Found'**
  String get materialNotFound;

  /// No description provided for @currentAffairs.
  ///
  /// In en, this message translates to:
  /// **'Current Affairs'**
  String get currentAffairs;

  /// No description provided for @daily.
  ///
  /// In en, this message translates to:
  /// **'Daily'**
  String get daily;

  /// No description provided for @monthly.
  ///
  /// In en, this message translates to:
  /// **'Monthly'**
  String get monthly;

  /// No description provided for @weeklyQuiz.
  ///
  /// In en, this message translates to:
  /// **'Weekly Quiz'**
  String get weeklyQuiz;

  /// No description provided for @searchNews.
  ///
  /// In en, this message translates to:
  /// **'Search News'**
  String get searchNews;

  /// No description provided for @readMore.
  ///
  /// In en, this message translates to:
  /// **'Read More'**
  String get readMore;

  /// No description provided for @source.
  ///
  /// In en, this message translates to:
  /// **'Source'**
  String get source;

  /// No description provided for @publishedOn.
  ///
  /// In en, this message translates to:
  /// **'Published On'**
  String get publishedOn;

  /// No description provided for @quizStart.
  ///
  /// In en, this message translates to:
  /// **'Quiz Start'**
  String get quizStart;

  /// No description provided for @quizResult.
  ///
  /// In en, this message translates to:
  /// **'Quiz Result'**
  String get quizResult;

  /// No description provided for @noArticles.
  ///
  /// In en, this message translates to:
  /// **'No Articles'**
  String get noArticles;

  /// No description provided for @analytics.
  ///
  /// In en, this message translates to:
  /// **'Analytics'**
  String get analytics;

  /// No description provided for @overview.
  ///
  /// In en, this message translates to:
  /// **'Overview'**
  String get overview;

  /// No description provided for @subjectPerformance.
  ///
  /// In en, this message translates to:
  /// **'Subject Performance'**
  String get subjectPerformance;

  /// No description provided for @testHistory.
  ///
  /// In en, this message translates to:
  /// **'Test History'**
  String get testHistory;

  /// No description provided for @tips.
  ///
  /// In en, this message translates to:
  /// **'Tips'**
  String get tips;

  /// No description provided for @totalAttempted.
  ///
  /// In en, this message translates to:
  /// **'Total Attempted'**
  String get totalAttempted;

  /// No description provided for @avgAccuracy.
  ///
  /// In en, this message translates to:
  /// **'Avg Accuracy'**
  String get avgAccuracy;

  /// No description provided for @totalTime.
  ///
  /// In en, this message translates to:
  /// **'Total Time'**
  String get totalTime;

  /// No description provided for @bestScore.
  ///
  /// In en, this message translates to:
  /// **'Best Score'**
  String get bestScore;

  /// No description provided for @weakestSubject.
  ///
  /// In en, this message translates to:
  /// **'Weakest Subject'**
  String get weakestSubject;

  /// No description provided for @strongestSubject.
  ///
  /// In en, this message translates to:
  /// **'Strongest Subject'**
  String get strongestSubject;

  /// No description provided for @improvementTip.
  ///
  /// In en, this message translates to:
  /// **'Improvement Tip'**
  String get improvementTip;

  /// No description provided for @studyStreakLabel.
  ///
  /// In en, this message translates to:
  /// **'Study Streak Label'**
  String get studyStreakLabel;

  /// No description provided for @noDataYet.
  ///
  /// In en, this message translates to:
  /// **'No Data Yet'**
  String get noDataYet;

  /// No description provided for @loadingChart.
  ///
  /// In en, this message translates to:
  /// **'Loading Chart'**
  String get loadingChart;

  /// No description provided for @leaderboard.
  ///
  /// In en, this message translates to:
  /// **'Leaderboard'**
  String get leaderboard;

  /// No description provided for @stateRank.
  ///
  /// In en, this message translates to:
  /// **'State Rank'**
  String get stateRank;

  /// No description provided for @districtRank.
  ///
  /// In en, this message translates to:
  /// **'District Rank'**
  String get districtRank;

  /// No description provided for @friendsRank.
  ///
  /// In en, this message translates to:
  /// **'Friends Rank'**
  String get friendsRank;

  /// No description provided for @weeklyRank.
  ///
  /// In en, this message translates to:
  /// **'Weekly Rank'**
  String get weeklyRank;

  /// No description provided for @yourRank.
  ///
  /// In en, this message translates to:
  /// **'Your Rank'**
  String get yourRank;

  /// No description provided for @noLeaderboard.
  ///
  /// In en, this message translates to:
  /// **'No Leaderboard'**
  String get noLeaderboard;

  /// No description provided for @aiAssistant.
  ///
  /// In en, this message translates to:
  /// **'Ai Assistant'**
  String get aiAssistant;

  /// No description provided for @typeMessage.
  ///
  /// In en, this message translates to:
  /// **'Type Message'**
  String get typeMessage;

  /// No description provided for @askTnpsc.
  ///
  /// In en, this message translates to:
  /// **'Ask Tnpsc'**
  String get askTnpsc;

  /// No description provided for @suggestedQuestions.
  ///
  /// In en, this message translates to:
  /// **'Suggested Questions'**
  String get suggestedQuestions;

  /// No description provided for @thinking.
  ///
  /// In en, this message translates to:
  /// **'Thinking'**
  String get thinking;

  /// No description provided for @tapToAsk.
  ///
  /// In en, this message translates to:
  /// **'Tap To Ask'**
  String get tapToAsk;

  /// No description provided for @clearChat.
  ///
  /// In en, this message translates to:
  /// **'Clear Chat'**
  String get clearChat;

  /// No description provided for @profile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profile;

  /// No description provided for @editProfile.
  ///
  /// In en, this message translates to:
  /// **'Edit Profile'**
  String get editProfile;

  /// No description provided for @myAchievements.
  ///
  /// In en, this message translates to:
  /// **'My Achievements'**
  String get myAchievements;

  /// No description provided for @examReadiness.
  ///
  /// In en, this message translates to:
  /// **'Exam Readiness'**
  String get examReadiness;

  /// No description provided for @targetScoreLabel.
  ///
  /// In en, this message translates to:
  /// **'Target Score Label'**
  String get targetScoreLabel;

  /// No description provided for @studyProgress.
  ///
  /// In en, this message translates to:
  /// **'Study Progress'**
  String get studyProgress;

  /// No description provided for @allBadges.
  ///
  /// In en, this message translates to:
  /// **'All Badges'**
  String get allBadges;

  /// No description provided for @locked.
  ///
  /// In en, this message translates to:
  /// **'Locked'**
  String get locked;

  /// No description provided for @unlocked.
  ///
  /// In en, this message translates to:
  /// **'Unlocked'**
  String get unlocked;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @appLanguage.
  ///
  /// In en, this message translates to:
  /// **'App Language'**
  String get appLanguage;

  /// No description provided for @darkMode.
  ///
  /// In en, this message translates to:
  /// **'Dark Mode'**
  String get darkMode;

  /// No description provided for @notifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notifications;

  /// No description provided for @dailyReminder.
  ///
  /// In en, this message translates to:
  /// **'Daily Reminder'**
  String get dailyReminder;

  /// No description provided for @clearCache.
  ///
  /// In en, this message translates to:
  /// **'Clear Cache'**
  String get clearCache;

  /// No description provided for @privacyPolicy.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get privacyPolicy;

  /// No description provided for @terms.
  ///
  /// In en, this message translates to:
  /// **'Terms'**
  String get terms;

  /// No description provided for @deleteAccount.
  ///
  /// In en, this message translates to:
  /// **'Delete Account'**
  String get deleteAccount;

  /// No description provided for @version.
  ///
  /// In en, this message translates to:
  /// **'Version'**
  String get version;

  /// No description provided for @premiumBadge.
  ///
  /// In en, this message translates to:
  /// **'Premium Badge'**
  String get premiumBadge;

  /// No description provided for @subjectTamil.
  ///
  /// In en, this message translates to:
  /// **'Subject Tamil'**
  String get subjectTamil;

  /// No description provided for @subjectGS.
  ///
  /// In en, this message translates to:
  /// **'Subject Gs'**
  String get subjectGS;

  /// No description provided for @subjectAptitude.
  ///
  /// In en, this message translates to:
  /// **'Subject Aptitude'**
  String get subjectAptitude;

  /// No description provided for @fieldRequired.
  ///
  /// In en, this message translates to:
  /// **'Field Required'**
  String get fieldRequired;

  /// No description provided for @passwordTooShort.
  ///
  /// In en, this message translates to:
  /// **'Password Too Short'**
  String get passwordTooShort;

  /// No description provided for @passwordMismatch.
  ///
  /// In en, this message translates to:
  /// **'Password Mismatch'**
  String get passwordMismatch;

  /// No description provided for @downloadFailed.
  ///
  /// In en, this message translates to:
  /// **'Download Failed'**
  String get downloadFailed;

  /// No description provided for @uploadFailed.
  ///
  /// In en, this message translates to:
  /// **'Upload Failed'**
  String get uploadFailed;

  /// No description provided for @testLoadFailed.
  ///
  /// In en, this message translates to:
  /// **'Test Load Failed'**
  String get testLoadFailed;

  /// No description provided for @questionsFailed.
  ///
  /// In en, this message translates to:
  /// **'Questions Failed'**
  String get questionsFailed;

  /// No description provided for @sessionExpired.
  ///
  /// In en, this message translates to:
  /// **'Session Expired'**
  String get sessionExpired;

  /// No description provided for @noInternetMsg.
  ///
  /// In en, this message translates to:
  /// **'No Internet Msg'**
  String get noInternetMsg;

  /// No description provided for @serverError.
  ///
  /// In en, this message translates to:
  /// **'Server Error'**
  String get serverError;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'ta'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'ta':
      return AppLocalizationsTa();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
