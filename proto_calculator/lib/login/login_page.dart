import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:proto_calculator/login/login_controller.dart';

import '../calculate/view/calculator_page.dart';
import '../calculate/view/calculator_view.dart';

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
                  label: Text("click me"),
                );
              } else {
                return calcBody();
              }
            })));
  }

  Widget calcBody() {
    return Scaffold(
        body: GridView.count(
          childAspectRatio: 3/2,
          physics: NeverScrollableScrollPhysics(),
          crossAxisCount: 1,
          mainAxisSpacing: 5,
            children: [
          const CalculatorPage(),
          
          TextButton(
            onPressed: () {
              controller.login();
            },
            child: Text("Signout"),
          ),Text("Signout"),
        ]));
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
