import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:proto_calculator/login/login_page.dart';



Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
    runApp( MaterialApp(
    title: 'Navigation Basics',
    home: LoginPage(),
  ));
}
