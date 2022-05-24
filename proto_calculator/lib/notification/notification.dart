// ignore_for_file: avoid_function_literals_in_foreach_calls

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:rxdart/rxdart.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificationAPI {
  static final _notifications = FlutterLocalNotificationsPlugin();
  static final onNotifications = BehaviorSubject<String?>();

  static Future _notificationsDetails() async {
    return const NotificationDetails(
      android: AndroidNotificationDetails('channel id', "channel name",
          importance: Importance.max),
      iOS: IOSNotificationDetails(),
    );
  }

  static Future init({bool initScheduled = false}) async {
    const android = AndroidInitializationSettings('@mipmap/ic_)launcher');
    const iOS = IOSInitializationSettings();
    const settings = InitializationSettings(android: android, iOS: iOS);
    await _notifications.initialize(
      settings,
      onSelectNotification: (payload) async {
        onNotifications.add(payload);
      },
    );
    tz.initializeTimeZones();
  }

  static Future showNotification(
          {int id = 0, String? title, String? body, String? payload}) async =>
      _notifications.show(
        id,
        title,
        body,
        await _notificationsDetails(),
        payload: payload,
      );

  static Future showScheduledNotification(
      {required int id,
      String? title,
      String? body,
      String? payload,
      required DateTime scheduledDate,
      required List<String> days}) async {
    const storage = FlutterSecureStorage();
    var db = FirebaseFirestore.instance;
    db.settings = const Settings(persistenceEnabled: true);
    final dbEntry = db.collection("Users").doc(await storage.read(key: "uid"));
    final info = await dbEntry.get();
    final data = info.data();

    days.forEach((day) async {
      if (data![day]["id"] != null) {
        cancel(id);
      }
      await db.collection("Users").doc(await storage.read(key: "uid")).set({
        day: {"id": id, "time": scheduledDate}
      }, SetOptions(merge: true));
    });
    _notifications.zonedSchedule(
        id,
        title,
        body,
        tz.TZDateTime.from(scheduledDate, tz.local),
        await _notificationsDetails(),
        payload: payload,
        androidAllowWhileIdle: true,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime);
  }

  static void cancel(int id) => _notifications.cancel(id);
}
