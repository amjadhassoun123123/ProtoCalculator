import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_storage/get_storage.dart';

class SettingsCubit {
  static Future<void> updateSettings(
      {bool? lightMode, String? name, bool? reminder}) async {
    GetStorage().write("light", lightMode);
    var db = FirebaseFirestore.instance;
    FlutterSecureStorage storage = const FlutterSecureStorage();
    db.settings = const Settings(persistenceEnabled: true);
    GetStorage box = GetStorage();
    if (lightMode != null) {
      db
          .collection("Users")
          .doc(await storage.read(key: "uid"))
          .collection("profile")
          .doc("settings")
          .set({"light_mode": lightMode}, SetOptions(merge: true));
    }
    if (reminder != null) {
      db
          .collection("Users")
          .doc(await storage.read(key: "uid"))
          .set({"reminders": reminder}, SetOptions(merge: true));
      box.write("light", lightMode);
    }
  }
}
