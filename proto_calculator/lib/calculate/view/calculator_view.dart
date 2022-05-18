import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'package:proto_calculator/app/app.dart';
import 'package:proto_calculator/calculate/cubit/calculator_cubit.dart';

// class Styles {
//   static ThemeData themeData(bool isDarkTheme, BuildContext context) {
//     return ThemeData(
//       primarySwatch: Colors.red,
//       primaryColor: isDarkTheme ? Colors.black : Colors.white,
//       backgroundColor: isDarkTheme ? Colors.black : Color(0xffF1F5FB),
//       indicatorColor: isDarkTheme ? Color(0xff0E1D36) : Color(0xffCBDCF8),
//       buttonColor: isDarkTheme ? Color(0xff3B3B3B) : Color(0xffF1F5FB),
//       hintColor: isDarkTheme ? Color(0xff280C0B) : Color(0xffEECED3),
//       highlightColor: isDarkTheme ? Color(0xff372901) : Color(0xffFCE192),
//       hoverColor: isDarkTheme ? Color(0xff3A3A3B) : Color(0xff4285F4),
//       focusColor: isDarkTheme ? Color(0xff0B2512) : Color(0xffA8DAB5),
//       disabledColor: Colors.grey,
//       cardColor: isDarkTheme ? Color(0xFF151515) : Colors.white,
//       canvasColor: isDarkTheme ? Colors.black : Colors.grey[50],
//       brightness: isDarkTheme ? Brightness.dark : Brightness.light,
//       buttonTheme: Theme.of(context).buttonTheme.copyWith(
//           colorScheme: isDarkTheme ? ColorScheme.dark() : ColorScheme.light()),
//       appBarTheme: AppBarTheme(
//         elevation: 0.0,
//       ),
//       textSelectionTheme: TextSelectionThemeData(
//           selectionColor: isDarkTheme ? Colors.white : Colors.black),
//     );
//   }
// }

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
  final FlutterSecureStorage storage = const FlutterSecureStorage();

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
  bool stateSwitch = false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Online Calculator")),
      body: Column(
        children: [
          BlocBuilder<CalculateCubit, String>(builder: (context, state) {
            if (state.isNotEmpty) {
              return Text(state,
                  style: const TextStyle(
                      fontSize: 45, color: Colors.deepPurpleAccent));
            }
            return const Text("0.0",
                style: TextStyle(fontSize: 45, color: Colors.deepPurpleAccent));
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
          FutureBuilder<bool>(
            future: context.read<CalculateCubit>().getMode(), // async work
            builder: (BuildContext context, AsyncSnapshot<bool> snapshot) {
              if (snapshot.hasData) {
              return CupertinoSwitch(
                value: snapshot.data!,
                onChanged: (v) => setState((() {
                  stateSwitch = v;
                  context
                      .read<CalculateCubit>()
                      .updateSettings(lightMode: stateSwitch);
                })),
              );}
              return Text("hi");
            },
          ),
          Column(
            children: [
              TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                    context.read<AppBloc>().add(AppLogoutRequested());
                  },
                  child: const Text("Signout")),
            ],
          )
        ],
      ),
      // This trailing comma makes auto-formatting nicer for build methods.
    );
  }

  Future<List<String>> getItems() async {
    String? stringofitems = await storage.read(key: 'data');

    if (stringofitems == null || stringofitems.isEmpty) {
      return <String>[""];
    }
    var prevData = json.decode(stringofitems);
    return prevData;
  }
}
