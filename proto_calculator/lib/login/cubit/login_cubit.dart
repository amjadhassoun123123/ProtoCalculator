import 'dart:convert';

import 'package:authentication_repository/authentication_repository.dart';
import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:form_inputs/form_inputs.dart';
import 'package:formz/formz.dart';

part 'login_state.dart';

class LoginCubit extends Cubit<LoginState> {
  LoginCubit(this._authenticationRepository) : super(const LoginState());

  final AuthenticationRepository _authenticationRepository;
  final FlutterSecureStorage _prefs = const FlutterSecureStorage();
  final storage = const FlutterSecureStorage();
  Future<void> logInWithGoogle() async {
    emit(state.copyWith(status: FormzStatus.submissionInProgress));
    try {
      await _authenticationRepository.logInWithGoogle();
      emit(state.copyWith(status: FormzStatus.submissionSuccess));
      await _prefs.write(
          key: "uid", value: _authenticationRepository.currentUser.id);
      final uid = await storage.read(key: "uid");
      if (uid != null) {
        setupDatabase(uid);
      }
      syncData();
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
      emit(state.copyWith(status: FormzStatus.submissionSuccess));
      await _prefs.write(
          key: "uid", value: _authenticationRepository.currentUser.id);
      final uid = await storage.read(key: "uid");
      if (uid != null) {
        setupDatabase(uid);
      }
      syncData();
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
    await _prefs.write(key: "uid", value: await _prefs.read(key: "uidAnon"));
    final uid = await storage.read(key: "uid");
    if (uid != null) {
      setupDatabase(uid);
    }
    emit(state.copyWith(status: FormzStatus.submissionSuccess));
  }

  void syncData() async {
    FlutterSecureStorage storage = const FlutterSecureStorage();
    final anonUID = await storage.read(key: "uidAnon");

    final FirebaseFirestore db = FirebaseFirestore.instance;
    db.settings = const Settings(persistenceEnabled: true);
    final docRef = db.collection("Users").doc(anonUID).collection("profile").doc("calculations");

    docRef.get().then((value) async {
      var data = value.data();
      if (data == null) {
        return;
      }
      db
          .collection("Users")
          .doc(await storage.read(key: "uid")).collection("profile").doc("calculations")
          .set(data, SetOptions(merge: true));
      db.collection("Users").doc(await storage.read(key: "uidAnon")).collection("profile").doc("calculations").set({});
    });
  }

  void setupDatabase(String uid) async {
    var db = FirebaseFirestore.instance;
    db.settings = const Settings(persistenceEnabled: true);
    final data = db.collection("Users").doc(uid);
    await data.get().then((value) {
      if (!value.exists) {
        data.set({});
        data.collection("profile").doc("calculations").set({});
        data.collection("profile").doc("settings").set({});
      }
    });
  }
}
