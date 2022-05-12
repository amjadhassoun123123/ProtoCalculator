import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:function_tree/function_tree.dart';
import 'package:get/get.dart';
import 'package:streaming_shared_preferences/streaming_shared_preferences.dart';

/// {@template calculate_cubit}
/// A [Cubit] which manages an [String] as its state.
/// {@endtemplate}
class CalculateCubit extends Cubit<String> {
  final ScrollController _scrollController = Get.find();

  /// {@macro counter_cubit}
  CalculateCubit() : super("");
  bool reset = false;

  Future<void> calculate(String icon) async {
    List<String> list = ["+", "-", "/", "*"];
    if (icon == "=") {
      try {
        String answer = state.interpret().toString();
        if (!state.isNum) {

          //get local data
          StreamingSharedPreferences preferences =
              await StreamingSharedPreferences.instance;

          //update local data
          List<String>? prev = preferences
              .getStringList("data", defaultValue: <String>[""]).getValue();
          prev.add(state + " " + "=" + " " + answer);
          preferences.setStringList("data", prev);


          //Animate scrolling of list
          _scrollController.animateTo(
              _scrollController.position.maxScrollExtent,
              duration: const Duration(milliseconds: 500),
              curve: Curves.fastOutSlowIn);
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
