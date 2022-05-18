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
      await _prefs.write(key: "uid", value: _authenticationRepository.currentUser.id);
      uploadLocal();
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
      await _prefs.write(key: "uid", value: _authenticationRepository.currentUser.id);
      uploadLocal();
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
    emit(state.copyWith(status: FormzStatus.submissionSuccess));
  }

  void uploadLocal() async {
    if (await storage.read(key: "uidAnon") != null) {
      FlutterSecureStorage storage = const FlutterSecureStorage();
      var db = FirebaseFirestore.instance;
      db.settings = const Settings(persistenceEnabled: true);
      String? stringofitems = await storage.read(key: 'data');
      if (stringofitems != null && stringofitems.isNotEmpty) {
        print(stringofitems);
        List<dynamic> prevData = json.decode(stringofitems!);

        for (var i = 0; i < prevData.length; i++) {
          var data = prevData[i];
          if (data.isNotEmpty) {
            var time = prevData[i].split("|")[0];
            var calc = prevData[i].split("|")[1];
            final calculation = <String, dynamic>{time: calc};
            db
                .collection("Users")
                .doc(await storage.read(key: "uid"))
                .set(calculation, SetOptions(merge: true));
          }
        }
        await storage.delete(key: "uidAnon");
      }
    }
  }
}
