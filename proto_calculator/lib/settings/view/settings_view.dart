import 'dart:io';
import 'package:intl/date_symbol_data_local.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:proto_calculator/settings/cubit/settings_cubit.dart';
import 'package:provider/provider.dart';
import 'package:authentication_repository/authentication_repository.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
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
  var fltrNotification = FlutterLocalNotificationsPlugin();

  @override
  void initState() {
    super.initState();
    Provider.of<SettingsCubit>(context, listen: false).getPreference();
    initializeDateFormatting('en', null);
    tz.initializeTimeZones();
    NotificationAPI.init();
  }
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
                Provider.of<SettingsCubit>(context).reminderMode
                    ? Column(
                        children: [
                          SelectWeekDays(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            days:
                                Provider.of<SettingsCubit>(context).daysInWeek,
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
                              Provider.of<SettingsCubit>(context, listen: false)
                                  .updateSettings(days: values);
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
                                            Provider.of<SettingsCubit>(context,
                                                    listen: false)
                                                .updateSettings(time: newTime);
                                            Provider.of<SettingsCubit>(context,
                                                    listen: false)
                                                .setReminders();
                                          },
                                        ),
                                      ),
                                  child: Text(
                                    "${Provider.of<SettingsCubit>(context, listen: false).selectedTime.hour}:${Provider.of<SettingsCubit>(context, listen: false).selectedTime.minute.toString().padLeft(2, '0')}",
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

  Widget lightMode() {
    return Platform.isIOS
        ? CupertinoSwitch(
            value: Provider.of<SettingsCubit>(context).lightMode,
            onChanged: (value) {
              Provider.of<SettingsCubit>(context, listen: false)
                  .updateSettings(light: value);
            })
        : Switch(
            value: Provider.of<SettingsCubit>(context).lightMode,
            onChanged: ((value) {
              Provider.of<SettingsCubit>(context, listen: false)
                  .updateSettings(light: value);
            }));
  }

  Widget reminders() {
    return Platform.isIOS
        ? CupertinoSwitch(
            value: Provider.of<SettingsCubit>(context).reminderMode,
            onChanged: (value) {
              Provider.of<SettingsCubit>(context, listen: false)
                  .updateSettings(reminder: value);
            })
        : Switch(
            value: Provider.of<SettingsCubit>(context).reminderMode,
            onChanged: ((value) {
              Provider.of<SettingsCubit>(context, listen: false)
                  .updateSettings(reminder: value);
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
}
