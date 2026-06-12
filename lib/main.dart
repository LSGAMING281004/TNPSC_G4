import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:thiral_app/l10n/app_localizations.dart';
import 'package:google_fonts/google_fonts.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'core/providers/app_providers.dart';
import 'core/language/language_provider.dart';
import 'core/language/language_mode.dart';
import 'firebase_options.dart';
import 'core/services/audio_handler.dart';
import 'features/notifications/services/notification_service.dart';

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  if (Firebase.apps.isEmpty) {
    await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  }
}

void main() async {
  final widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

  // Load environment variables from .env (must happen before any secret access)
  await dotenv.load(fileName: '.env');

  // Lock orientation to portrait
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Status bar style
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ),
  );

  // Firebase
  if (Firebase.apps.isEmpty) {
    await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  }
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  // Hive offline cache
  await Hive.initFlutter();
  await _openHiveBoxes();

  // Local notifications channel
  await _initLocalNotifications();

  // Initialize audio service for background playback
  final audioHandler = await initAudioService();

  // Pre-load Noto Sans Tamil so Tamil mode renders immediately
  await GoogleFonts.pendingFonts([GoogleFonts.notoSansTamil()]);

  // Initialize unified Notification Service (FCM & Local)
  await NotificationService().init();

  FlutterNativeSplash.remove();

  runApp(
    ProviderScope(
      overrides: [
        audioHandlerProvider.overrideWithValue(audioHandler),
      ],
      child: const ThiralApp(),
    ),
  );
}

Future<void> _openHiveBoxes() async {
  await Hive.openBox('user_box');
  await Hive.openBox('settings');
  await Hive.openBox('settings_box');
  await Hive.openBox('cached_questions');
  await Hive.openBox('bookmarks');
  await Hive.openBox('bookmarks_box');
  await Hive.openBox('test_progress');
  await Hive.openBox('user_prefs');
  await Hive.openBox('downloaded_materials_box');
  await Hive.openBox('reading_progress_box');
  await Hive.openBox('quotes_box');
  await Hive.openBox('cache_box');
  await Hive.openBox('test_results_box');
  await Hive.openBox('notifications_box');
}

Future<void> _initLocalNotifications() async {
  final flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
  const androidSettings = AndroidInitializationSettings('@mipmap/launcher_icon');
  const iosSettings = DarwinInitializationSettings(
    requestAlertPermission: true,
    requestBadgePermission: true,
    requestSoundPermission: true,
  );
  const initSettings = InitializationSettings(android: androidSettings, iOS: iosSettings);
  await flutterLocalNotificationsPlugin.initialize(initSettings);

  // Create high-importance notification channel for Android
  const AndroidNotificationChannel channel = AndroidNotificationChannel(
    'thiral_important',
    'Thiral Notifications',
    description: 'Daily study reminders and exam updates',
    importance: Importance.high,
  );
  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(channel);
}

class ThiralApp extends ConsumerWidget {
  const ThiralApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // using routerProvider from app_router.dart
    final router = ref.watch(routerProvider);
    final themeMode = ref.watch(themeModeProvider);
    final langMode = ref.watch(languageNotifierProvider);

    Locale appLocale = const Locale('en', 'IN');
    if (langMode == LanguageMode.tamil || langMode == LanguageMode.both) {
      appLocale = const Locale('ta', 'IN');
    }

    return MaterialApp.router(
      title: 'Thiral — TNPSC Group 4',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode,
      routerConfig: router,
      locale: appLocale,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en', 'IN'),
        Locale('ta', 'IN'), // Tamil
      ],
    );
  }
}
