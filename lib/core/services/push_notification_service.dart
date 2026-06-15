import 'dart:io';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';

class PushNotificationService {
  static final FirebaseMessaging _fcm = FirebaseMessaging.instance;

  static Future<void> initialize() async {
    // Only run on mobile/web where supported
    if (kIsWeb || Platform.isAndroid || Platform.isIOS) {
      try {
        // 1. Request Permission
        NotificationSettings settings = await _fcm.requestPermission(
          alert: true,
          badge: true,
          sound: true,
          provisional: false,
        );

        if (settings.authorizationStatus == AuthorizationStatus.authorized) {
          debugPrint('User granted permission for notifications');
          
          // 2. Subscribe to topics
          // The backend sends notifications to 'all_users' by default
          if (!kIsWeb) {
            await _fcm.subscribeToTopic('all_users');
            debugPrint('Subscribed to all_users topic');
          }

          // 3. Handle foreground messages
          FirebaseMessaging.onMessage.listen((RemoteMessage message) {
            debugPrint('Received foreground message: \${message.notification?.title}');
            // Foreground notifications are handled by the stream in the app already,
            // but we could show a local notification here if needed.
          });
          
        } else {
          debugPrint('User declined or has not accepted permission');
        }
      } catch (e) {
        debugPrint('Error initializing FCM: $e');
      }
    }
  }

  static Future<void> subscribeToTopic(String topic) async {
    if (kIsWeb || Platform.isAndroid || Platform.isIOS) {
      try {
        await _fcm.subscribeToTopic(topic);
        debugPrint('Subscribed to topic: $topic');
      } catch (e) {
        debugPrint('Error subscribing to topic $topic: $e');
      }
    }
  }

  static Future<void> unsubscribeFromTopic(String topic) async {
    if (kIsWeb || Platform.isAndroid || Platform.isIOS) {
      try {
        await _fcm.unsubscribeFromTopic(topic);
        debugPrint('Unsubscribed from topic: $topic');
      } catch (e) {
        debugPrint('Error unsubscribing from topic $topic: $e');
      }
    }
  }
}

// Background handler must be a top-level function
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  debugPrint("Handling a background message: \${message.messageId}");
}
