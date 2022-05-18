import 'dart:convert';

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
          //get local data

          //update local data
          String? stringofitems = await storage.read(key: 'data');
          List<dynamic> prev = <String>[""];
          if (stringofitems != null && stringofitems.isNotEmpty) {
            prev = json.decode(stringofitems);
          }
          DateTime now = DateTime.now();

          prev.add(now.toLocal().toString().split('.')[0] +
              "|" +
              state +
              " " +
              "=" +
              " " +
              answer);

          await storage.write(key: 'data', value: jsonEncode(prev));

          //Animate scrolling of list
          // _scrollController.animateTo(
          //     _scrollController.position.maxScrollExtent,
          //     duration: const Duration(milliseconds: 500),
          //     curve: Curves.fastOutSlowIn);
          //update database
          if (await storage.read(key: 'uidAnon') == null) {
            var db = FirebaseFirestore.instance;
            db.settings = const Settings(persistenceEnabled: true);

            final calculation = <String, dynamic>{
              now.toLocal().toString().split('.')[0]:
                  state + " " + "=" + " " + answer,
            };

            db
                .collection("Users")
                .doc(await storage.read(key: "uid"))
                .set(calculation, SetOptions(merge: true));
          }
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
