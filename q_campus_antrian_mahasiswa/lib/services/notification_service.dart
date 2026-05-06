// lib/services/notification_service.dart

import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notifications = FlutterLocalNotificationsPlugin();

  static Future<void> init() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
    );

    await _notifications.initialize(settings: initializationSettings);
  }

  static Future<void> showCallNotification({
    required int id,
    required String nomorAntrian,
    required String layanan,
  }) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'queue_call_channel',
      'Panggilan Antrian',
      channelDescription: 'Notifikasi saat nomor antrian dipanggil',
      importance: Importance.max,
      priority: Priority.high,
      showWhen: true,
      enableVibration: true,
      playSound: true,
      fullScreenIntent: true, // Untuk pop up pop up yang menonjol
    );

    const NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
    );

    await _notifications.show(
      id: id,
      title: 'Antrian Anda Dipanggil! 🔔',
      body: 'Nomor $nomorAntrian segera menuju ke Loket $layanan.',
      notificationDetails: platformChannelSpecifics,
    );
  }
}
