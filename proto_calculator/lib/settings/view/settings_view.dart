// ignore_for_file: avoid_function_literals_in_foreach_calls

import 'dart:io';
import 'package:intl/date_symbol_data_local.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:proto_calculator/settings/cubit/settings_cubit.dart';
import 'package:provider/provider.dart';
import 'package:authentication_repository/authentication_repository.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_storage/get_storage.dart';
import 'package:day_picker/day_picker.dart';
import 'package:proto_calculator/notification/notification.dart';

// ignore: must_be_immutable
class SettingsView extends StatefulWidget {
  const SettingsView({
    Key? key,
  }) : super(key: key);
  @override
  State<StatefulWidget> createState() {
    return _MyStatefulWidgetState();
  }
}

@override
class _MyStatefulWidgetState extends State<SettingsView> {
  final GetStorage storage = GetStorage();
  List<dynamic> selectedDays = [];
  DateTime selectedTime = DateTime.now();
  var lightSwitch = false;
  var reminderSwitch = false;
  var fltrNotification = FlutterLocalNotificationsPlugin();
  final List<DayInWeek> _days = [
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

  @override
  void initState() {
    super.initState();
    initializeDateFormatting('en', null);
    tz.initializeTimeZones();
    NotificationAPI.init();
    getPreference();
    // listenNotifications();
  }
// void listenNotifications () => NotificationAPI().onNotifications.stream.listen(onClickedNotification);

// void onClickedNotification(String? payload) =>
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: const Text("Settings")),
        body: Column(children: [
          Expanded(
            child: ListView(
              shrinkWrap: true,
              children: [
                const SizedBox(
                  height: 20,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      "Light mode",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    lightMode(),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      "Reminders",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    reminders(),
                  ],
                ),
                const SizedBox(
                  height: 20,
                ),
                reminderSwitch
                    ? Column(
                        children: [
                          SelectWeekDays(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            days: _days,
                            border: false,
                            boxDecoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(30.0),
                              gradient: const LinearGradient(
                                begin: Alignment.topLeft,
                                colors: [Color(0xFFE55CE4), Color(0xFFBB75FB)],
                                tileMode: TileMode
                                    .repeated, // repeats the gradient over the canvas
                              ),
                            ),
                            onSelect: (values) {
                              // <== Callback to handle the selected days
                              setState(() {
                                if (values.isEmpty) {
                                  reminderSwitch = false;
                                }
                                selectedDays.clear();
                                selectedDays.addAll(values);
                                setReminders();
                                // NotificationAPI.showPending();
                              });
                            },
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text(
                                "Time",
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              CupertinoButton(
                                  onPressed: () => _showDialog(
                                        CupertinoDatePicker(
                                          mode: CupertinoDatePickerMode.time,
                                          initialDateTime: DateTime.now(),
                                          use24hFormat: true,
                                          onDateTimeChanged:
                                              (DateTime newTime) {
                                            setState(() {
                                              selectedTime = newTime;
                                              setReminders();
                                            });
                                          },
                                        ),
                                      ),
                                  child: Text(
                                    "${selectedTime.hour}:${selectedTime.minute}",
                                  )),
                            ],
                          ),
                        ],
                      )
                    : Column(),
                const SizedBox(
                  height: 20,
                ),
                TextButton(
                    onPressed: () {
                      //context.read<AppBloc>().add(AppLogoutRequested());
                      Navigator.pop(context);
                      context.read<AuthenticationRepository>().logOut();
                    },
                    child: const Text("Signout")),
              ],
            ),
            // This trailing comma makes auto-formatting nicer for build methods.
          )
        ]));
  }

  Future<void> setReminders() async {
    final FirebaseFirestore db = FirebaseFirestore.instance;
    db.settings = const Settings(persistenceEnabled: true);
    FlutterSecureStorage storage = const FlutterSecureStorage();
    await db.collection("Users").doc(await storage.read(key: "uid")).set({
      "days": selectedDays,
      "reminders": reminderSwitch,
      "time": "${selectedTime.hour}:${selectedTime.minute}"
    });
    NotificationAPI.cancelAll();
    selectedDays.forEach((element) {
      DateTime date = getNextDate(element, selectedTime);

      NotificationAPI.showScheduledNotification(
        id: getDay(element),
        scheduledDate: date,
        payload: date.toString(),
      );
    });
  }

  Future<void> getPreference() async {
    final FirebaseFirestore db = FirebaseFirestore.instance;
    db.settings = const Settings(persistenceEnabled: true);
    GetStorage box = GetStorage();
    FlutterSecureStorage storage = const FlutterSecureStorage();
    var a = await db
        .collection("Users")
        .doc(await storage.read(key: "uid"))
        .collection("profile")
        .doc("settings")
        .get();
    await box.write("light", a.data()!["light_mode"]);
    a = await db.collection("Users").doc(await storage.read(key: "uid")).get();
    await box.write("reminders", a.data()!["reminders"]);
    setState(() {
      lightSwitch = box.read("light");
      reminderSwitch = box.read("reminders");
      List<dynamic> days = a.data()!["days"];

      selectedTime = DateTime(
          DateTime.now().year,
          DateTime.now().month,
          DateTime.now().day,
          int.parse(a.data()!["time"].split(":")[0]),
          int.parse(a.data()!["time"].split(":")[1]));
      selectedDays.addAll(days);
      _days.forEach((element) {
        if (days.contains(element.dayName)) {
          element.isSelected = true;
        }
      });
    });
    setReminders();
  }

  Widget lightMode() {
    return Platform.isIOS
        ? CupertinoSwitch(
            value: lightSwitch,
            onChanged: (value) {
              setState(() {
                lightSwitch = value;
                SettingsCubit.updateSettings(lightMode: lightSwitch);
              });
            })
        : Switch(
            value: lightSwitch,
            onChanged: ((value) {
              setState(() {
                lightSwitch = value;
                SettingsCubit.updateSettings(lightMode: lightSwitch);
              });
            }));
  }

  Widget reminders() {
    return Platform.isIOS
        ? CupertinoSwitch(
            value: reminderSwitch,
            onChanged: (value) {
              setState(() {
                reminderSwitch = value;
                SettingsCubit.updateSettings(reminder: reminderSwitch);
              });
            })
        : Switch(
            value: reminderSwitch,
            onChanged: ((value) {
              setState(() {
                reminderSwitch = value;
                SettingsCubit.updateSettings(reminder: reminderSwitch);
              });
            }));
  }

  void _showDialog(Widget child) {
    showCupertinoModalPopup<void>(
        context: context,
        builder: (BuildContext context) => Container(
              height: 216,
              padding: const EdgeInsets.only(top: 6.0),
              // The Bottom margin is provided to align the popup above the system navigation bar.
              margin: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
              ),
              // Provide a background color for the popup.
              color: CupertinoColors.systemBackground.resolveFrom(context),
              // Use a SafeArea widget to avoid system overlaps.
              child: SafeArea(
                top: false,
                child: child,
              ),
            ));
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
