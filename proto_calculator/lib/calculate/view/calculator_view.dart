import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:proto_calculator/calculate/cubit/calculator_cubit.dart';
import 'package:proto_calculator/settings/cubit/settings_cubit.dart';
import 'package:proto_calculator/settings/view/settings_view.dart';
import 'package:provider/provider.dart';

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
                ElevatedButton(
                    onPressed: (() {
                      SettingsCubit settings =  SettingsCubit();
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (BuildContext context) => ListenableProvider(
                            create: (context) => settings,
                            builder: (context, child) => const SettingsView(),
                          ),
                        ),
                      );
                    }),
                    child: const Text("Settings"))
              ],
            ),
            // This trailing comma makes auto-formatting nicer for build methods.
          )
        ]));
  }
}
