import 'package:bloc/bloc.dart';
import 'package:function_tree/function_tree.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// {@template calculate_cubit}
/// A [Cubit] which manages an [String] as its state.
/// {@endtemplate}
class CalculateCubit extends Cubit<String> {
  /// {@macro counter_cubit}
  CalculateCubit() : super("");
  bool reset = false;

  Future<void> calculate(String icon) async {
    List<String> list = ["+", "-", "/", "*"];
    if (icon == "=") {
      try {
        emit(state.interpret().toString());
        final prefs = await SharedPreferences.getInstance();
        List<String>? prev = prefs.getStringList("data");
        if (prev != null) {
          prev.add(state);
          await prefs.setStringList('data', prev);
        } else {
          await prefs.setStringList('data', <String>[state]);
        }
        reset = true;
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
