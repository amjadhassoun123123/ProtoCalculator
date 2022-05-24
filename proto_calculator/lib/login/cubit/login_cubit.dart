import 'package:authentication_repository/authentication_repository.dart';
import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:form_inputs/form_inputs.dart';
import 'package:formz/formz.dart';
import 'package:get_storage/get_storage.dart';
part 'login_state.dart';

class LoginCubit extends Cubit<LoginState> {
  LoginCubit(this._authenticationRepository) : super(const LoginState());

  final AuthenticationRepository _authenticationRepository;
  final storage = const FlutterSecureStorage();
  Future<void> logInWithGoogle() async {
    emit(state.copyWith(status: FormzStatus.submissionInProgress));
    try {
      await _authenticationRepository.logInWithGoogle();
      emit(state.copyWith(status: FormzStatus.submissionSuccess));
      await storage.write(
          key: "uid", value: _authenticationRepository.currentUser.id);
      final uid = await storage.read(key: "uid");
      if (uid != null) {
        await setupDatabase(uid);
      }
      await getPreference();
    } on LogInWithGoogleFailure catch (e) {
      emit(
        state.copyWith(
          errorMessage: e.message,
          status: FormzStatus.submissionFailure,
        ),
      );
    } catch (_) {
      emit(state.copyWith(status: FormzStatus.submissionFailure));
    }
  }

  Future<void> logInWithApple() async {
    emit(state.copyWith(status: FormzStatus.submissionInProgress));
    try {
      await _authenticationRepository.signInWithApple();
      await storage.write(
          key: "uid", value: _authenticationRepository.currentUser.id);
      final uid = await storage.read(key: "uid");
      if (uid != null) {
        await setupDatabase(uid);
      }
      await getPreference();
      emit(state.copyWith(status: FormzStatus.submissionSuccess));
    } on Error catch (e) {
      emit(
        state.copyWith(
          errorMessage: e.toString(),
          status: FormzStatus.submissionFailure,
        ),
      );
    } catch (_) {
      emit(state.copyWith(status: FormzStatus.submissionFailure));
    }
  }

  Future<void> loginInAnon() async {
    emit(state.copyWith(status: FormzStatus.submissionInProgress));
    await _authenticationRepository.loginInAnon();
    await storage.write(key: "uid", value: await storage.read(key: "uidAnon"));
    final uid = await storage.read(key: "uid");
    if (uid != null) {
      setupDatabase(uid);
    }
    await getPreference();
    emit(state.copyWith(status: FormzStatus.submissionSuccess));
  }

  Future<void> syncData() async {
    FlutterSecureStorage storage = const FlutterSecureStorage();
    final anonUID = await storage.read(key: "uidAnon");
    final FirebaseFirestore db = FirebaseFirestore.instance;
    db.settings = const Settings(persistenceEnabled: true);
    final anonData = db.collection("Users").doc(anonUID).collection("profile");
    final userData = db
        .collection("Users")
        .doc(await storage.read(key: "uid"))
        .collection("profile");

    await anonData.doc("calculations").get().then((value) async {
      var data = value.data();
      if (data != null || data!.isNotEmpty) {
        await userData.doc("calculations").get();
        await userData.doc("calculations").set(data, SetOptions(merge: true));
      }
    });

    await anonData.doc("settings").get().then((value) async {
      var data = value.data();
      if (data != null || data!.isNotEmpty) {
        await userData.doc("settings").get();
        await userData.doc("settings").set(data, SetOptions(merge: true));
      }
    });

    await db
        .collection("Users")
        .doc(anonUID)
        .collection("profile")
        .doc("calculations")
        .set({});
  }

  Future<void> setupDatabase(String uid) async {
    var db = FirebaseFirestore.instance;
    db.settings = const Settings(persistenceEnabled: true);
    final data = db.collection("Users").doc(uid);
    await data.get().then((value) {
      if (!value.exists) {
        data.set({});
        data.collection("profile").doc("calculations").set({});
        data.collection("profile").doc("settings").set({
          "light_mode" : false
        });
        data.set(
          {
            "days" : ["Mon", "Wed", "Sun"],
            "reminders" : true,
            "time" : "9:00"
          },
        );
        syncData();
      }
    });
  }

  Future<void> getPreference() async {
    final FirebaseFirestore db = FirebaseFirestore.instance;
    db.settings = const Settings(persistenceEnabled: true);
    GetStorage box = GetStorage();
    var a = await db
        .collection("Users")
        .doc(await storage.read(key: "uid"))
        .collection("profile")
        .doc("settings")
        .get();
    await box.write("light", a.data()!["light_mode"]);
  }
}
