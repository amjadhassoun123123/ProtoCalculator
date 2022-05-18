import 'package:flutter/widgets.dart';
import 'package:proto_calculator/app/bloc/app_bloc.dart';
import 'package:proto_calculator/calculate/view/calculator_page.dart';
import 'package:proto_calculator/login/view/login_page.dart';

List<Page> onGenerateAppViewPages(AppStatus state, List<Page<dynamic>> pages) {
  switch (state) {
    case AppStatus.authenticated:
      return [CalculatorPage.page()];
    case AppStatus.unauthenticated:
      return [LoginPage.page()];
    case AppStatus.freshOpen:
      return [CalculatorPage.page()];
  }
}
