import 'dart:math';

import 'package:authentication_repository/authentication_repository.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_storage/get_storage.dart';
import 'package:day_picker/day_picker.dart';
import 'package:intl/intl.dart';
import 'package:proto_calculator/calculate/cubit/calculator_cubit.dart';
import 'package:proto_calculator/notification/notification.dart';

// ignore: must_be_immutable
class CalculatorView extends StatefulWidget {
  const CalculatorView({Key? key, required this.title}) : super(key: key);

  final String title;
  @override
  State<StatefulWidget> createState() {
    return _MyStatefulWidgetState();
  }
}

@override
class _MyStatefulWidgetState extends State<CalculatorView> {
  final GetStorage storage = GetStorage();
  bool select = false;
  List<String> selectedDays = [];
  DateTime selectedTime = DateTime.now();
  var stateSwitch = false;
  var fltrNotification = FlutterLocalNotificationsPlugin();
  List<String> icons = [
    "7",
    "8",
    "9",
    "*",
    "4",
    "5",
    "6",
    "/",
    "1",
    "2",
    "3",
    "-",
    "CLEAR",
    "0",
    "=",
    "+"
  ];
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
    NotificationAPI.init();
    getPreference();

    // listenNotifications();
  }
// void listenNotifications () => NotificationAPI().onNotifications.stream.listen(onClickedNotification);

// void onClickedNotification(String? payload) =>
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: const Text("Online Calculator")),
        body: Column(children: [
          Expanded(
            child: ListView(
              shrinkWrap: true,
              children: [
                BlocBuilder<CalculateCubit, String>(builder: (context, state) {
                  if (state.isNotEmpty) {
                    return Text(state,
                        style: const TextStyle(
                            fontSize: 45, color: Colors.deepPurpleAccent));
                  }
                  return const Text("0.0",
                      style: TextStyle(
                          fontSize: 45, color: Colors.deepPurpleAccent));
                }),
                GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: 4,
                  childAspectRatio: 2,
                  children: icons.map((icon) {
                    return TextButton(
                      onPressed: () {
                        context.read<CalculateCubit>().calculate(icon);
                      },
                      child: Text(
                        icon,
                        style: const TextStyle(
                          color: Colors.black,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    );
                  }).toList(),
                ),
                CupertinoSwitch(
                    value: stateSwitch,
                    onChanged: (value) {
                      setState(() {
                        stateSwitch = value;
                        GetStorage().write("light", value);
                        context
                            .read<CalculateCubit>()
                            .updateSettings(lightMode: stateSwitch);
                      });
                    }),
                Column(
                  children: [
                    TextButton(
                        onPressed: () {
                          //context.read<AppBloc>().add(AppLogoutRequested());
                          Navigator.pop(context);
                          context.read<AuthenticationRepository>().logOut();
                        },
                        child: const Text("Signout")),
                  ],
                ),
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
                      if (values.isNotEmpty) {
                        select = true;
                        selectedDays.clear();
                        selectedDays.addAll(values);
                      }
                    });
                  },
                ),
                select
                    ? Column(
                        children: [
                          SizedBox(
                              height: 200,
                              child: CupertinoDatePicker(
                                mode: CupertinoDatePickerMode.time,
                                onDateTimeChanged: (value) {
                                  setState(() {
                                    selectedTime = value;
                                  });
                                },
                                initialDateTime: DateTime.now(),
                              )),
                          TextButton(
                              onPressed: (() {
                                Random random =  Random();
                                int randomNumber = random.nextInt(100000);
                                //create notification for all selected days at that time
                                NotificationAPI.showNotification(
                                  title: "Reminder Set",
                                  body:
                                      "Your weekly reminder for ${selectedDays.toString()} at ${DateFormat("h:mma").format(selectedTime)} is set",
                                  payload: "idek",
                                );
                                NotificationAPI.showScheduledNotification(
                                    id: randomNumber,
                                    title: "Time to get calculating ",
                                    body:
                                        "Here's your daily reminder to do math, woohoo!",
                                    payload: "idek",
                                    scheduledDate: selectedTime,
                                    days: selectedDays);
                                setState(() {
                                  select = false;
                                  for (var element in _days) {
                                    element.isSelected = false;
                                  }
                                });
                                //update db
                              }),
                              child: const Text("Set time to remind me"))
                        ],
                      )
                    : Column(),
              ],
            ),
            // This trailing comma makes auto-formatting nicer for build methods.
          )
        ]));
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
    setState(() {
      stateSwitch = box.read("light");
    });
  }
}
