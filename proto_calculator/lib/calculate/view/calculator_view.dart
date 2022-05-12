import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_instance/get_instance.dart';
import 'package:proto_calculator/login/login_controller.dart';
import 'package:streaming_shared_preferences/streaming_shared_preferences.dart';

import '../calculate.dart';

// ignore: must_be_immutable
class CalculatorView extends StatefulWidget {
  const CalculatorView({Key? key, required this.title}) : super(key: key);

  final String title;
  @override
  State<StatefulWidget> createState() {
    return _MyStatefulWidgetState();
  }
}

class _MyStatefulWidgetState extends State<CalculatorView> {
  final ScrollController _scrollController = Get.put(ScrollController());
  final LoginController _loginController = Get.find();
  final StreamingSharedPreferences prefs = Get.find();
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
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Online Calculator")),
      body: Column(
        children: [
          SizedBox(
              height: MediaQuery.of(context).size.height / 12,
              child: BlocBuilder<CalculateCubit, String>(
                  builder: (context, state) {
                return Text(state,
                    style: const TextStyle(
                        fontSize: 45, color: Colors.deepPurpleAccent));
              })),
          SizedBox(
              height: MediaQuery.of(context).size.height / 3,
              child: Expanded(
                  child: GridView.count(
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
              ))),
          BlocBuilder<CalculateCubit, String>(builder: (context, state) {
            return PreferenceBuilder<List<String>>(
                preference:
                    prefs.getStringList("data", defaultValue: <String>[""]),
                builder: (BuildContext context, List<String> calculations) {
                  return SizedBox(
                      height: MediaQuery.of(context).size.height / 4,
                      child: ListView.builder(
                        controller: _scrollController,
                        itemExtent: 15,
                        shrinkWrap: true,
                        itemCount: calculations.length,
                        itemBuilder: (context, index) {
                          return Text(calculations[index], style: const TextStyle(fontSize: 10, fontStyle: FontStyle.italic),);
                        },
                      ));
                });
          }),
          // return FutureBuilder<List<String>>(
          //   future: prefs,
          //   builder: (context, snapshot) {
          //     if (snapshot.hasData) {

          //               ],
          //             );
          //           });
          //     }
          //     return CircularProgressIndicator(); // or some other widget
          //   },
          // );
          SizedBox(
              height: MediaQuery.of(context).size.height / 5,
              child: Column(
                children: [
                  Text(_loginController.name),
                  Text(_loginController.email),
                  TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                        _loginController.signOut();
                      },
                      child: const Text("Signout")),
                ],
              ))
        ],
      ),
      // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
