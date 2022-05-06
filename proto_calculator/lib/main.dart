import 'package:bloc/bloc.dart';
import 'package:flutter/widgets.dart';

import 'app.dart';
import 'input_observer.dart';

void main() {
  BlocOverrides.runZoned(
    () => runApp(const CalculatorApp()),
    blocObserver:   InputObserver(),
  );
}