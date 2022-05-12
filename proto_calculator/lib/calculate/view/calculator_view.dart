import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_instance/get_instance.dart';
import 'package:proto_calculator/login/login_controller.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../calculate.dart';

// ignore: must_be_immutable
class CalculatorView extends StatefulWidget {
  CalculatorView({Key? key, required this.title}) : super(key: key);

  final String title;



    @override
  State<StatefulWidget> createState() {
   return _MyStatefulWidgetState();
  }
}
class _MyStatefulWidgetState extends State<CalculatorView>{
    final LoginController controller = Get.find();
  List<String> calculations = [
    "",
  ];
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
          BlocBuilder<CalculateCubit, String>(builder: (context, state) {
            return Text("");
            // var prefs = getLocalData();
            // return FutureBuilder<List<String>>(
            //   future: prefs,
            //   builder: (context, snapshot) {
            //     if (snapshot.hasData) {
            //       return StreamBuilder(
            //           stream: Stream.periodic(const Duration(seconds: 2)),
            //           builder: (BuildContext context, AsyncSnapshot<List<String>> snapshot) { {
            //             return Column(
            //               children: <Widget>[
            //                 ListView.builder(
            //                   shrinkWrap: true,
            //                   itemCount: prefs.,
            //                   itemBuilder: (context, index) {
            //                     return Text(bob[index]);
            //                   },
            //                 )
            //               ],
            //             );
            //           });
            //     }
            //     return CircularProgressIndicator(); // or some other widget
            //   },
            // );
          }),
          Text(controller.name),
          Text(controller.email),
          TextButton(
              onPressed: () {
                Navigator.pop(context);
                controller.signOut();
              },
              child: const Text("Signout")),
        ],
      ),
      // This trailing comma makes auto-formatting nicer for build methods.
    );
  }

  Future<List<String>?> getLocalData() async {
    final prefs = await SharedPreferences.getInstance();
    if (prefs.getStringList("data") == null) {
      return null;
    }
    return prefs.getStringList("data");
  }

}



