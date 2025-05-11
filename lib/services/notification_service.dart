import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import 'dart:async';

class NotificationService {
  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

  // Initialize notification channels and settings
  Future<void> initialize(Function(String?) onNotificationTap) async {
    // Request permission for iOS
    if (Platform.isIOS) {
      await _firebaseMessaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );
    }

    // Configure local notifications
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    final DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
      onDidReceiveLocalNotification: (id, title, body, payload) async {
        // Handle iOS foreground notification
        debugPrint('Received iOS notification in foreground: $payload');
      },
    );

    final InitializationSettings initializationSettings =
        InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );

    await _flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse details) {
        onNotificationTap(details.payload);
      },
    );

    // Handle notifications when app is in background or terminated
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      debugPrint('Notification tapped in background state!');
      final payload = message.data['route'];
      onNotificationTap(payload);
    });

    // Handle notifications when app is in foreground
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      debugPrint('Got a message whilst in the foreground!');
      _showLocalNotification(message);
    });

    // Check if app was opened from a notification
    final initialMessage = await FirebaseMessaging.instance.getInitialMessage();
    if (initialMessage != null) {
      debugPrint('App opened from terminated state via notification!');
      final payload = initialMessage.data['route'];
      onNotificationTap(payload);
    }
  }

  // Subscribe to a topic (e.g., for promotions, order updates)
  Future<void> subscribeToTopic(String topic) async {
    await _firebaseMessaging.subscribeToTopic(topic);
  }

  // Unsubscribe from a topic
  Future<void> unsubscribeFromTopic(String topic) async {
    await _firebaseMessaging.unsubscribeFromTopic(topic);
  }

  // Get the FCM token for this device
  Future<String?> getToken() async {
    return await _firebaseMessaging.getToken();
  }

  // Show a local notification
  Future<void> _showLocalNotification(RemoteMessage message) async {
    final RemoteNotification? notification = message.notification;
    final AndroidNotification? android = message.notification?.android;

    if (notification != null && android != null) {
      await _flutterLocalNotificationsPlugin.show(
        notification.hashCode,
        notification.title,
        notification.body,
        NotificationDetails(
          android: AndroidNotificationDetails(
            'default_channel',
            'Default Channel',
            importance: Importance.high,
            priority: Priority.high,
            icon: android.smallIcon,
          ),
          iOS: const DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
          ),
        ),
        payload: message.data['route'],
      );
    }
  }

  // Send a local notification
  Future<void> showNotification({
    required String title,
    required String body,
    String? payload,
  }) async {
    await _flutterLocalNotificationsPlugin.show(
      0,
      title,
      body,
      NotificationDetails(
        android: const AndroidNotificationDetails(
          'default_channel',
          'Default Channel',
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: const DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
      payload: payload,
    );
  }
}
