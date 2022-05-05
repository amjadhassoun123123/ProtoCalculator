import 'package:flutter/material.dart';
import 'package:function_tree/function_tree.dart';

class Input with ChangeNotifier {
  String _input = "";
  bool reset = false;
  String get input => _input;

  void addText(String icon) {
    List<String> list = ["+", "-", "/", "*"];
    if (icon == "=") {
      try {
        _input = _input.interpret().toString();
        reset = true;
      } catch (e) {
        _input = "";
      }
    } else if (icon == "CLEAR") {
      _input = "";
    } else if (!reset) {
      _input = _input + icon;
    } else if (list.contains(icon)) {
      _input = _input + icon;
      reset = false;
    } else {
      _input = icon;
      reset = false;
    }
    notifyListeners();
  }
}
