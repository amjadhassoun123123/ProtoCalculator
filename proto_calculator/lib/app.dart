import 'package:flutter/material.dart';

import 'calculate/calculate.dart';

/// {@template counter_app}
/// A [MaterialApp] which sets the `home` to [CalculatorPage].
/// {@endtemplate}
class CalculatorApp extends MaterialApp {
  /// {@macro counter_app}
  const CalculatorApp({Key? key}) : super(key: key, home: const CalculatorPage());
}