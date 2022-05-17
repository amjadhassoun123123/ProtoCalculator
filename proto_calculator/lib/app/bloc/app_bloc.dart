import 'dart:async';

import 'package:authentication_repository/authentication_repository.dart';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:streaming_shared_preferences/streaming_shared_preferences.dart';
import 'package:very_good_analysis/very_good_analysis.dart';

part 'app_event.dart';
part 'app_state.dart';

class AppBloc extends Bloc<AppEvent, AppState> {
  AppBloc({required AuthenticationRepository authenticationRepository, required StreamingSharedPreferences prefs})
      : _authenticationRepository = authenticationRepository,
      _prefs = prefs,
        super(
          authenticationRepository.currentUser.isNotEmpty
              ? AppState.freshOpen(authenticationRepository.currentUser)
              : const AppState.unauthenticated(),
        ) {
    on<AppUserChanged>(_onUserChanged);
    on<AppLogoutRequested>(_onLogoutRequested);
    _userSubscription = _authenticationRepository.user.listen(
      (user) => add(AppUserChanged(user)),
    );
  }

  final AuthenticationRepository _authenticationRepository;
  final StreamingSharedPreferences _prefs;
  late final StreamSubscription<User> _userSubscription;

  void _onUserChanged(AppUserChanged event, Emitter<AppState> emit) {
    emit(
      event.user.isNotEmpty
          ? AppState.authenticated(event.user)
          : const AppState.unauthenticated(),
    );
    _prefs.setString("uid", "");
  }

  void _onLogoutRequested(AppLogoutRequested event, Emitter<AppState> emit) {
    unawaited(_authenticationRepository.logOut());
    _prefs.setString("uid", "");
  }

  @override
  Future<void> close() {
    _userSubscription.cancel();
    return super.close();
  }
}
