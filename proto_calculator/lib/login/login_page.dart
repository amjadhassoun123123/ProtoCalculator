import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:proto_calculator/login/login_controller.dart';

import '../calculate/view/calculator_page.dart';

class LoginPage extends StatelessWidget {
  LoginPage({Key? key}) : super(key: key);
  final controller = Get.put(LoginController());
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        home: Scaffold(
            appBar: AppBar(title: const Text("Online Calculator")),
            body: Obx(() {
              if (controller.googleAccount.value == null) {
                return FloatingActionButton.extended(
                  onPressed: () {
                    controller.login();
                    if (controller.googleAccount.value != null) {}
                  },
                  label: const Text("click me"),
                );
              } else {
                return calcBody(context);
              }
            })));
  }

  // TextButton(
  //   onPressed: () {
  //     controller.login();
  //   },
  //   child: Text("Signout"),
  // ),
  // Text("Signout"),
  Widget calcBody(context) {
 return Column(children: [
        const Flexible(
          child: CalculatorPage(),
        ),
        TextButton(
          onPressed: () {  
          },
          child: const Text(
            "Signout",
            style: TextStyle(fontSize: 30),
          ),
        ),
      ]);

  }
  void _navigateToNextScreen(BuildContext context) {
    Navigator.of(context).push(MaterialPageRoute(builder: (context) => LoginPage()));
  }

}
// Center(child: Obx(() {
//               if (controller.googleAccount.value == null) {
//                 return buildLoginButton();
//               } else {
//                 Navigator.push(
//                     context,
//                     MaterialPageRoute(
//                         builder: (context) => const CalculatorPage()));
//               }
//             }

