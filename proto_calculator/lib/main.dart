import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:proto_calculator/login/login_page.dart';
import 'package:streaming_shared_preferences/streaming_shared_preferences.dart';

import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  StreamingSharedPreferences prefs = await StreamingSharedPreferences.instance;
  Get.put(prefs);
  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    title: 'Navigation Basics',
    home: LoginPage(),
  ));
}
