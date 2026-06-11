import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

import 'package:go_router/go_router.dart';
import '../../../core/router/app_router.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FirebaseMessaging _fcm = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifs = FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    // 1. Initialize timezone
    tz.initializeTimeZones();

    // 2. Request permissions
    await _fcm.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    // 3. Init Local Notifications for Foreground and Scheduled
    const androidInit = AndroidInitializationSettings('@mipmap/launcher_icon');
    const iosInit = DarwinInitializationSettings();
    const initSettings = InitializationSettings(android: androidInit, iOS: iosInit);
    
    await _localNotifs.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onLocalNotificationTap,
    );

    // 4. Save FCM Token to Firestore
    _fcm.getToken().then((token) => _saveToken(token));
    _fcm.onTokenRefresh.listen(_saveToken);

    // 5. Handle Foreground FCM Messages
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      _showLocalNotification(message);
    });

    // 6. Handle Background/Terminated FCM Taps
    FirebaseMessaging.onMessageOpenedApp.listen(_handleFCMTap);

    // 7. Schedule Daily Reminder
    await _scheduleDailyReminder();
  }

  Future<void> _saveToken(String? token) async {
    if (token == null) return;
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      await FirebaseFirestore.instance.collection('users').doc(user.uid).update({
        'fcmToken': token,
        'updatedAt': FieldValue.serverTimestamp(),
      }).catchError((_) {}); // Ignore if user doc doesn't exist yet
    }
  }

  Future<void> _showLocalNotification(RemoteMessage message) async {
    final notification = message.notification;
    final android = message.notification?.android;
    
    if (notification != null && android != null) {
      await _localNotifs.show(
        notification.hashCode,
        notification.title,
        notification.body,
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'thiral_important',
            'Thiral Notifications',
            channelDescription: 'Daily study reminders and exam updates',
            importance: Importance.high,
            priority: Priority.high,
          ),
          iOS: DarwinNotificationDetails(),
        ),
        payload: jsonEncode(message.data),
      );
    }
  }

  void _onLocalNotificationTap(NotificationResponse response) {
    if (response.payload != null) {
      try {
        final data = jsonDecode(response.payload!) as Map<String, dynamic>;
        _routeFromNotificationType(data['type'] ?? '');
      } catch (e) {
        // Fallback
      }
    }
  }

  void _handleFCMTap(RemoteMessage message) {
    _routeFromNotificationType(message.data['type'] ?? '');
  }

  void _routeFromNotificationType(String type) {
    final context = rootNavigatorKey.currentContext;
    if (context == null) return;
    
    switch (type) {
      case 'new_content':
        context.go('/study-materials');
        break;
      case 'current_affairs':
        context.go('/current-affairs');
        break;
      case 'test_reminder':
        context.go('/mock-tests');
        break;
      case 'achievement':
        context.go('/profile');
        break;
      default:
        context.go('/notifications');
        break;
    }
  }

  Future<void> _scheduleDailyReminder() async {
    final box = Hive.box('settings_box');
    final isEnabled = box.get('dailyReminder', defaultValue: true) as bool;
    
    await _localNotifs.cancel(1001); // Cancel existing daily reminder
    
    if (!isEnabled) return;

    final hour = box.get('reminderHour', defaultValue: 8) as int;
    final minute = box.get('reminderMinute', defaultValue: 0) as int;

    // Alternate message logic (we'll just pick Tamil or English based on day of year for simplicity)
    final isTamil = DateTime.now().day % 2 == 0;
    final title = isTamil ? "இன்றைய படிப்பு தொடங்குங்கள்! 📚" : "Time to study! 📚";
    final body = isTamil ? "உங்கள் இலக்கை அடையுங்கள்." : "You're one step closer to your goal.";

    await _localNotifs.zonedSchedule(
      1001,
      title,
      body,
      _nextInstanceOfTime(hour, minute),
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'thiral_daily',
          'Daily Reminder',
          channelDescription: 'Daily study reminder',
          importance: Importance.high,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  tz.TZDateTime _nextInstanceOfTime(int hour, int minute) {
    final tz.TZDateTime now = tz.TZDateTime.now(tz.local);
    tz.TZDateTime scheduledDate = tz.TZDateTime(tz.local, now.year, now.month, now.day, hour, minute);
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }
    return scheduledDate;
  }
}
