import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_signin_button/flutter_signin_button.dart';
import 'package:proto_calculator/calculate/calculate.dart';
import 'package:proto_calculator/login/cubit/login_cubit.dart';

class LoginForm extends StatelessWidget {
  const LoginForm({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return BlocListener<LoginCubit, LoginState>(
        listener: (context, state) {},
        child: Scaffold(
            body:
                Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Center(
              child: SignInButton(Buttons.Google, onPressed: () {
            context.read<LoginCubit>().logInWithGoogle();
          })),
          Platform.isIOS
              ? Center(
                  child: SignInButton(Buttons.Apple, onPressed: () {
                  context.read<LoginCubit>().logInWithApple();
                }))
              : Column(),
          Center(
              child: TextButton(
            onPressed: () {
              context.read<LoginCubit>().loginInAnon();
              Navigator.push(context, MaterialPageRoute(builder: (context) {
                return const CalculatorPage();
              }));
            },
            child: const Text("Sign in anonymously"),
          )),
        ])));
  }
}
