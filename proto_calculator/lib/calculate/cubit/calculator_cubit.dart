import 'package:bloc/bloc.dart';
import 'package:function_tree/function_tree.dart';

/// {@template calculate_cubit}
/// A [Cubit] which manages an [String] as its state.
/// {@endtemplate}
class CalculateCubit extends Cubit<String> {
  /// {@macro counter_cubit}
  CalculateCubit() : super("");
  bool reset = false;

  void calculate(String icon) {
    List<String> list = ["+", "-", "/", "*"];
    if (icon == "=") {
      try {
        emit(state.interpret().toString());
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
