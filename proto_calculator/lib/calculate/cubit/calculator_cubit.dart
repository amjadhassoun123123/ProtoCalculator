import 'package:bloc/bloc.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:function_tree/function_tree.dart';
import 'package:get/get.dart';
import 'package:proto_calculator/login/login_controller.dart';
import 'package:streaming_shared_preferences/streaming_shared_preferences.dart';

/// {@template calculate_cubit}
/// A [Cubit] which manages an [String] as its state.
/// {@endtemplate}
class CalculateCubit extends Cubit<String> {
  final ScrollController _scrollController = Get.find();
  final LoginController _loginController = Get.find();

  /// {@macro counter_cubit}
  CalculateCubit() : super("");
  bool reset = false;

  Future<void> calculate(String icon) async {
    List<String> list = ["+", "-", "/", "*"];
    if (icon == "=") {
      try {
        //convert equation to number if possible
        String answer = state.interpret().roundToDouble().toString();
        if (!state.isNum) {
          //get local data
          StreamingSharedPreferences preferences =
              await StreamingSharedPreferences.instance;

          //update local data
          List<String>? prev = preferences
              .getStringList("data", defaultValue: <String>[""]).getValue();
          DateTime now = DateTime.now();
          print(now.toLocal().toString().split('.')[0]);
          prev.add(now.toLocal().toString().split('.')[0] +
              " " +
              state +
              " " +
              "=" +
              " " +
              answer);
          preferences.setStringList("data", prev);

          //Animate scrolling of list
          _scrollController.animateTo(
              _scrollController.position.maxScrollExtent,
              duration: const Duration(milliseconds: 500),
              curve: Curves.fastOutSlowIn);

          //update database
          DatabaseReference ref = FirebaseDatabase.instance.ref("Users");
          DatabaseReference calculations = ref.child(_loginController.uid);
          calculations
              .update({now.toLocal().toString().split('.')[0]: state +
              " " +
              "=" +
              " " +
              answer});
        }
        reset = true;
        emit(answer);
      } catch (e) {
        emit("");
      }
    } else if (icon == "CLEAR") {
      emit("");
    } else if (!reset) {
      emit(state + icon);
    } else if (list.contains(icon)) {
      emit(state + icon);
      reset = false;
    } else {
      emit(icon);
      reset = false;
    }
  }
}
