import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:hali_saha_bak/models/reservation.dart';
import 'package:http/http.dart' as http;
import 'package:timezone/timezone.dart' as timezone;

import 'package:timezone/data/latest.dart' as tz;

class NotificationService {
  Future<void> sendNotification({
    required String token,
    required String title,
    required String body,
  }) async {
    String url = 'https://fcm.googleapis.com/fcm/send';
    String key =
        'AAAAY4mm_eE:APA91bF99fLXs0K9tAiCVo2hSgpGNnSwp7pmj8dBTKf4PgzHMR1jwUH6FXlC2IYfYhqaqWAa8_GXQGsRD-lpuArlsgt2OieWujmdkeqp3nPObWNQX0plt94nBXRN-u6RHj_uSfalwo-v';

    Map<String, String>? headers = {
      'Content-Type': 'application/json',
      'Authorization': 'key=$key',
    };

    Map requestBody = {
      "to": token,
      "notification": {
        "title": title,
        "body": body,
        "mutable_content": true,
      },
      "data": {
        "title": title,
        "body": body,
      }
    };

    await http.post(
      Uri.parse(url),
      headers: headers,
      body: jsonEncode(requestBody),
    );
  }

  Future<void> showNotification() async {
    FlutterLocalNotificationsPlugin _flutterLocalNotifications = FlutterLocalNotificationsPlugin();
    AndroidInitializationSettings _initializationSettingsAndroid = const AndroidInitializationSettings('@mipmap/ic_launcher');
    IOSInitializationSettings _initializationSettingsIOS = const IOSInitializationSettings();
    InitializationSettings _initializationSettings = InitializationSettings(android: _initializationSettingsAndroid, iOS: _initializationSettingsIOS);
    await _flutterLocalNotifications.initialize(_initializationSettings);
    AndroidNotificationDetails androidPlatformChannelSpecifics = const AndroidNotificationDetails(
      'schedule-channel-id',
      'schedule',
      sound: RawResourceAndroidNotificationSound('notif'),
      playSound: true,
      importance: Importance.max,
      priority: Priority.high,
      icon: "@mipmap/ic_launcher",
      visibility: NotificationVisibility.public,
      // sound: RawResourceAndroidNotificationSound('notification'),
      enableVibration: true,
      ongoing: false,
    );
    IOSNotificationDetails iOSPlatformChannelSpecifics = const IOSNotificationDetails();
    NotificationDetails platformChannelSpecifics = NotificationDetails(android: androidPlatformChannelSpecifics, iOS: iOSPlatformChannelSpecifics);

    print('sho notif run');
    await _flutterLocalNotifications.show(12131, 'Test Notif', 'This is a test notification', platformChannelSpecifics);
  }

  Future<void> scheduleNotification({
    required DateTime dateTime,
    required String title,
    required String body,
    required Reservation reservation,
  }) async {
    FlutterLocalNotificationsPlugin _flutterLocalNotifications = FlutterLocalNotificationsPlugin();
    AndroidInitializationSettings _initializationSettingsAndroid = const AndroidInitializationSettings('@mipmap/ic_launcher');
    IOSInitializationSettings _initializationSettingsIOS = const IOSInitializationSettings();
    InitializationSettings _initializationSettings = InitializationSettings(android: _initializationSettingsAndroid, iOS: _initializationSettingsIOS);
    await _flutterLocalNotifications.initialize(_initializationSettings);
    AndroidNotificationDetails androidPlatformChannelSpecifics = const AndroidNotificationDetails(
      'schedule-channel-id',
      'schedule',
      sound: RawResourceAndroidNotificationSound('notif'),
      playSound: true,
      importance: Importance.max,
      priority: Priority.high,
      icon: "@mipmap/ic_launcher",
      visibility: NotificationVisibility.public,
      // sound: RawResourceAndroidNotificationSound('notification'),
      enableVibration: true,
      ongoing: false,
    );
    IOSNotificationDetails iOSPlatformChannelSpecifics = const IOSNotificationDetails();
    NotificationDetails platformChannelSpecifics = NotificationDetails(android: androidPlatformChannelSpecifics, iOS: iOSPlatformChannelSpecifics);

    tz.initializeTimeZones();

    String fullId = reservation.id.toString();
    String shortId = fullId.substring((fullId.length / 2).round(), fullId.length);
    int lastId = int.parse(shortId);

    try {
      await _flutterLocalNotifications.zonedSchedule(
        lastId,
        title,
        body,
        timezone.TZDateTime.parse(
          timezone.local,
          dateTime.toString(),
        ),
        platformChannelSpecifics,
        androidAllowWhileIdle: true,
        uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
      );
    } catch (e) {
      debugPrint('e catched: $e');
    }
  }
}
