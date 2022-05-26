import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:day_picker/day_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:proto_calculator/notification/notification.dart';

class SettingsCubit extends ChangeNotifier {
  bool lightMode = false;
  bool reminderMode = false;
  List<dynamic> selectedDays = [];
  DateTime selectedTime = DateTime.now();

  final List<DayInWeek> daysInWeek = [
    DayInWeek(
      "Sun",
    ),
    DayInWeek(
      "Mon",
    ),
    DayInWeek(
      "Tue",
    ),
    DayInWeek(
      "Wed",
    ),
    DayInWeek(
      "Thu",
    ),
    DayInWeek(
      "Fri",
    ),
    DayInWeek(
      "Sat",
    ),
  ];

  Future<void> getPreference() async {
    final FirebaseFirestore db = FirebaseFirestore.instance;
    db.settings = const Settings(persistenceEnabled: true);
    FlutterSecureStorage storage = const FlutterSecureStorage();
    var a = await db
        .collection("Users")
        .doc(await storage.read(key: "uid"))
        .collection("profile")
        .doc("settings")
        .get();

    lightMode = await a.data()!["light_mode"];

    a = await db.collection("Users").doc(await storage.read(key: "uid")).get();

    reminderMode = await a.data()!["reminders"];

    List<dynamic> days = a.data()!["days"];

    selectedTime = DateTime(
        DateTime.now().year,
        DateTime.now().month,
        DateTime.now().day,
        int.parse(a.data()!["time"].split(":")[0]),
        int.parse(a.data()!["time"].split(":")[1]));
    selectedDays.addAll(days);
    for (var element in daysInWeek) {
      if (days.contains(element.dayName)) {
        element.isSelected = true;
      }
    }
    setReminders();
    notifyListeners();
  }

  Future<void> updateSettings(
      {bool? light,
      bool? reminder,
      List<dynamic>? days,
      DateTime? time}) async {
    var db = FirebaseFirestore.instance;
    FlutterSecureStorage storage = const FlutterSecureStorage();
    db.settings = const Settings(persistenceEnabled: true);
    if (light != null) {
      await db
          .collection("Users")
          .doc(await storage.read(key: "uid"))
          .collection("profile")
          .doc("settings")
          .set({"light_mode": light}, SetOptions(merge: true));
      lightMode = light;
    }
    if (reminder != null) {
      await db
          .collection("Users")
          .doc(await storage.read(key: "uid"))
          .set({"reminders": reminder}, SetOptions(merge: true));
      reminderMode = reminder;
    }
    if (days != null) {
      if (days.isEmpty) {
        await db
            .collection("Users")
            .doc(await storage.read(key: "uid"))
            .set({"reminders": false}, SetOptions(merge: true));
            reminderMode = false;
      }
      selectedDays.clear();
      selectedDays.addAll(days);
      await setReminders();
    }
    if (time != null) {
      selectedTime = time;
      await setReminders();
    }
    notifyListeners();
  }

  Future<void> setReminders() async {
    final FirebaseFirestore db = FirebaseFirestore.instance;
    db.settings = const Settings(persistenceEnabled: true);
    FlutterSecureStorage storage = const FlutterSecureStorage();
    await db.collection("Users").doc(await storage.read(key: "uid")).set({
      "days": selectedDays,
      "reminders": reminderMode,
      "time": "${selectedTime.hour}:${selectedTime.minute}"
    });
    for (var element in selectedDays) {
      DateTime date = getNextDate(element, selectedTime);

      NotificationAPI.showScheduledNotification(
        id: getDay(element),
        scheduledDate: date,
        payload: date.toString(),
      );
    }
  }

  int getDay(String day) {
    switch (day) {
      case "Mon":
        return 1;
      case "Tue":
        return 2;
      case "Wed":
        return 3;
      case "Thu":
        return 4;
      case "Fri":
        return 5;
      case "Sat":
        return 6;
      case "Sun":
        return 7;
    }
    return -1;
  }

  //return the next day, so if you pass monday, give me the next monday in DateTime
  DateTime getNextDate(String day, DateTime scheduledTime) {
    var currDay = getDay(day);

    while (scheduledTime.weekday != currDay) {
      scheduledTime = scheduledTime.add(const Duration(days: 1));
    }

    return scheduledTime;
  }
}
