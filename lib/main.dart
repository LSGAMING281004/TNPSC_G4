import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:google_fonts/google_fonts.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'core/providers/app_providers.dart';
import 'firebase_options.dart';
import 'core/services/audio_handler.dart';
import 'shared/providers/app_providers.dart' as shared_providers;

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
}

void main() async {
  final widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

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
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
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

  FlutterNativeSplash.remove();

  runApp(
    ProviderScope(
      overrides: [
        shared_providers.audioHandlerProvider.overrideWithValue(audioHandler),
      ],
      child: const ThiralApp(),
    ),
  );
}

Future<void> _openHiveBoxes() async {
  await Hive.openBox('user_box');
  await Hive.openBox('settings');
  await Hive.openBox('cached_questions');
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

    return MaterialApp.router(
      title: 'Thiral — TNPSC Group 4',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode,
      routerConfig: router,
      localizationsDelegates: const [
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
