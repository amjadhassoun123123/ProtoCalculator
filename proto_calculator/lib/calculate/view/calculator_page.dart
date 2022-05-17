import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../calculate.dart';
import 'calculator_view.dart';

/// {@template calculate_page}
/// A [StatelessWidget] which is responsible for providing a
/// [CalculateCubit] instance to the [CalculatorView].
/// {@endtemplate}
class CalculatorPage extends StatelessWidget {
  /// {@macro counter_page}
  const CalculatorPage({Key? key}) : super(key: key);
  static Page page() => const MaterialPage<void>(child: CalculatorPage());

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => CalculateCubit(),
      child: const CalculatorView(title: '',),
    );
  }
}