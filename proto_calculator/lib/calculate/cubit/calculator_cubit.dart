import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:function_tree/function_tree.dart';
import 'package:get/get.dart';
import 'package:streaming_shared_preferences/streaming_shared_preferences.dart';

/// {@template calculate_cubit}
/// A [Cubit] which manages an [String] as its state.
/// {@endtemplate}
class CalculateCubit extends Cubit<String> {
  final ScrollController _scrollController = Get.find();

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
          var db = FirebaseFirestore.instance;

          final user = <String, dynamic>{
            now.toLocal().toString().split('.')[0]:
                state + " " + "=" + " " + answer,
          };
          db
              .collection("Users")
              .doc(preferences
                  .getString("uid", defaultValue: "Unknown User")
                  .getValue())
              .set(user, SetOptions(merge: true));

          // DatabaseReference ref = FirebaseDatabase.instance.ref("Users");
          // DatabaseReference calculations = ref.child(preferences
          //     .getString("uid", defaultValue: "Unknown User")
          //     .getValue());
          // calculations.update({
          //   now.toLocal().toString().split('.')[0]:
          //       state + " " + "=" + " " + answer
          // });
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
