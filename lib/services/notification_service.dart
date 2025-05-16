import 'package:amber_road/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  static Future<void> initialize() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    await _notifications.initialize(
      const InitializationSettings(
        android: initializationSettingsAndroid,
      ),
    );

    final bool granted = (await _notifications
    .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>()
    ?.requestNotificationsPermission())!;

    if (!granted) {
      scaffoldMessengerKey.currentState?.showSnackBar(SnackBar(content: Text("Bruh")));
    }

    // Create notification channel
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'upload_channel',
      'Chapter Uploads',
      importance: Importance.high,
      description: 'Notifications for chapter upload progress',
    );

    await _notifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);
  }

  static Future<void> showUploadNotification({
    required int notificationId,
    required String title,
    required String content,
    int progress = 0,
    bool isComplete = false,
    bool isError = false,
  }) async {
    final AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
      'upload_channel',
      'Chapter Uploads',
      channelDescription: 'Notifications for chapter upload progress',
      importance: Importance.high,
      priority: Priority.high,
      showProgress: !isComplete && !isError,
      indeterminate: false,
      onlyAlertOnce: true,
      ongoing: !isComplete && !isError,
      progress: progress,
      maxProgress: 100,
      icon: '@mipmap/ic_launcher',
      ticker: 'Upload in progress',
    );

    await _notifications.show(
      notificationId,
      title,
      content,
      NotificationDetails(android: androidDetails),
    );
  }

  static Future<void> cancelNotification(int notificationId) async {
    await _notifications.cancel(notificationId);
  }
}