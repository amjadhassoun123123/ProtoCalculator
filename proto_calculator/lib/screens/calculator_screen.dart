import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:proto_calculator/providers/input_provider.dart';

// ignore: must_be_immutable
class CalculatorPage extends StatelessWidget {
  CalculatorPage({Key? key, required this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

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
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      body: Column(
        children: [
          const Input(),
          Expanded(
            child: GridView.count(
              crossAxisCount: 4,
              childAspectRatio: 3,
              children: icons.map((icon) {
                return TextButton(
                  onPressed: () {
                    context.read<Inputter>().addText(icon);
                  },
                  child: Text(
                    icon,
                    style: const TextStyle(
                      color: Colors.black,
                      fontSize: 25,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                );
              }).toList(),
            ),
          )
        ],
      ),
      // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}

class Input extends StatelessWidget {
  const Input({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Text(context.watch<Inputter>().input,
        style: const TextStyle(fontSize: 50, color: Colors.deepPurpleAccent));
  }
}
