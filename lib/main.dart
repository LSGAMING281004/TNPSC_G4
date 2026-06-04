import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:google_fonts/google_fonts.dart';
import 'firebase_options.dart';
import 'core/constants/app_constants.dart';
import 'core/theme/app_theme.dart';
import 'core/router/app_router.dart';
import 'core/language/language.dart';
import 'core/services/audio_handler.dart';
import 'core/services/push_notification_service.dart';
import 'shared/providers/app_providers.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  // Register background FCM handler before anything else
  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);


  await Supabase.initialize(
    url: AppConstants.supabaseUrl,
    anonKey: AppConstants.supabaseAnonKey,
  );

  await Hive.initFlutter();
  await _openHiveBoxes();

  // Initialize audio service for background playback
  final audioHandler = await initAudioService();

  // Pre-load Noto Sans Tamil so Tamil mode renders immediately
  await GoogleFonts.pendingFonts([GoogleFonts.notoSansTamil()]);

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: Colors.white,
    ),
  );

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Request push notification permissions and subscribe to topics
  await PushNotificationService.initialize();

  runApp(
    ProviderScope(
      overrides: [
        audioHandlerProvider.overrideWithValue(audioHandler),
      ],
      child: const TNPSCApp(),
    ),
  );
}

Future<void> _openHiveBoxes() async {
  await Hive.openBox(AppConstants.userBox);
  await Hive.openBox(AppConstants.settingsBox);
  await Hive.openBox(AppConstants.bookmarksBox);
  await Hive.openBox(AppConstants.downloadedMaterialsBox);
  await Hive.openBox(AppConstants.readingProgressBox);
  await Hive.openBox(AppConstants.quotesBox);
  await Hive.openBox(AppConstants.cacheBox);
  await Hive.openBox(AppConstants.testResultsBox);
  await Hive.openBox(AppConstants.notificationsBox);
}

class TNPSCApp extends ConsumerWidget {
  const TNPSCApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    final isDarkMode = ref.watch(isDarkModeProvider);
    final langMode = ref.watch(languageNotifierProvider);
    final locale = ref.watch(appLocaleProvider);

    // Use fontFamily instead of replacing textTheme to avoid
    // "Failed to interpolate TextStyles with different inherit values"
    final tamilFontFamily = GoogleFonts.notoSansTamil().fontFamily;
    final fontFamily = langMode == LanguageMode.tamil ? tamilFontFamily : null;

    return MaterialApp.router(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme.copyWith(
        textTheme: AppTheme.lightTheme.textTheme.apply(fontFamily: fontFamily),
      ),
      darkTheme: AppTheme.darkTheme.copyWith(
        textTheme: AppTheme.darkTheme.textTheme.apply(fontFamily: fontFamily),
      ),
      themeMode: isDarkMode ? ThemeMode.dark : ThemeMode.light,
      locale: locale,
      supportedLocales: const [
        Locale('en', 'US'),
        Locale('ta', 'IN'),
      ],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      routerConfig: router,
    );
  }
}
