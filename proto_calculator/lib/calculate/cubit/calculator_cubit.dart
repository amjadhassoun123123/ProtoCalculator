import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:function_tree/function_tree.dart';
import 'package:get/get.dart';

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
        FlutterSecureStorage storage = const FlutterSecureStorage();
        if (!state.isNum) {
          DateTime now = DateTime.now();

          var db = FirebaseFirestore.instance;
          db.settings = const Settings(persistenceEnabled: true);

          final calculation = <String, dynamic>{
            now.toLocal().toString().split('.')[0]:
                state + " " + "=" + " " + answer,
          };

          db
              .collection("Users")
              .doc(await storage.read(key: "uid"))
              .collection("profile")
              .doc("calculations")
              .set(calculation, SetOptions(merge: true));
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
