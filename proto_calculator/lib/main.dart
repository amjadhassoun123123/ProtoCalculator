// ignore_for_file: prefer_const_constructors

import 'package:authentication_repository/authentication_repository.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_storage/get_storage.dart';
import 'app/view/app.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(bob(await runPython(
      "def add(args):\n    try:\n        return sum([int(x) for x in args])\n    except Exception as e:\n        return 'error'\n")));
  return;
  await GetStorage.init();
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  final FirebaseFirestore db = FirebaseFirestore.instance;
  db.settings = const Settings(persistenceEnabled: true);
  await db.waitForPendingWrites();
  const prefs = FlutterSecureStorage();
  final authenticationRepository = AuthenticationRepository();
  await authenticationRepository.user.first;

  runApp(App(authenticationRepository: authenticationRepository, prefs: prefs));
}

Future<String> runPython(String code) async {
  const channel = MethodChannel('co.spurry.calculator.fluttersignin/code');
  return await channel.invokeMethod("runPython", {"code": code});
}

MaterialApp bob(String code) {
  return MaterialApp(
      home: Scaffold(
          backgroundColor: Colors.white,
          body: Center(
              child: Stack(children: [
            SizedBox(
              height: 50,
            ),
            Text("code output is:" + code, style: TextStyle(color: Colors.red))
          ]))));
}
