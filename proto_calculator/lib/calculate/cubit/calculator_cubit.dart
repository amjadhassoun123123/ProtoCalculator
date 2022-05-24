import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:function_tree/function_tree.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

/// {@template calculate_cubit}
/// A [Cubit] which manages an [String] as its state.
/// {@endtemplate}
class CalculateCubit extends Cubit<String> {
  CalculateCubit() : super("");
  bool reset = false;
  var db = FirebaseFirestore.instance;
  FlutterSecureStorage storage = const FlutterSecureStorage();

  Future<void> calculate(String icon) async {
    List<String> list = ["+", "-", "/", "*"];
    if (icon == "=") {
      try {
        //convert equation to number if possible
        String answer = state.interpret().roundToDouble().toString();

        if (!state.isNum) {
          DateTime now = DateTime.now();

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

  Future<void> updateSettings({bool? lightMode, String? name}) async {
    db.settings = const Settings(persistenceEnabled: true);
    GetStorage box = GetStorage();
    db
        .collection("Users")
        .doc(await storage.read(key: "uid"))
        .collection("profile")
        .doc("settings")
        .set({"light_mode": lightMode});
    box.write("light", lightMode);
  }

  Future<bool> getMode() async {
    db.settings = const Settings(persistenceEnabled: true);
    await db
        .collection("Users")
        .doc(await storage.read(key: "uid"))
        .collection("profile")
        .doc("settings")
        .get()
        .then((value) {
      if (value.data() != null) {
        return value.data()!["light_mode"];
      }
    });
    return false;
  }
}
