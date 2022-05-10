import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../calculate.dart';

// ignore: must_be_immutable
class CalculatorView extends StatelessWidget {
  CalculatorView({Key? key, required this.title}) : super(key: key);
  final String title;

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
      body: Column(
        children: [
          BlocBuilder<CalculateCubit, String>(builder: (context, state) {
            return Text(state,
                style: const TextStyle(
                    fontSize: 45, color: Colors.deepPurpleAccent));
          }),
          Expanded(
            child: GridView.count(
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
          ),
        ],
      ),
      // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
