import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:proto_calculator/login/login_controller.dart';
import 'package:flutter_signin_button/flutter_signin_button.dart';
import 'dart:io' show Platform;

class LoginPage extends StatelessWidget {
  LoginPage({Key? key}) : super(key: key);
  final controller = Get.put(LoginController());
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        home: Scaffold(
            appBar: AppBar(title: const Text("Online Calculator")),
            body:
                Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              Center(
                  child: SignInButton(Buttons.Google, onPressed: () {
                controller.signInWithGoogle(context);
              })),
              Platform.isIOS? Center(
                  child: SignInButton(Buttons.Apple, onPressed: () {
                controller.signInWithApple(context);
              })) : Column(),
              // Center(
              //     child: SignInButton(Buttons.Apple, onPressed: () {
              //   controller.signInWithApple(context);
              // }))
            ])));
  }
}
