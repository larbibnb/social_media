import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:social_media/features/auth/domain/app_user.dart';
import 'package:social_media/features/auth/domain/repositories/auth_repo.dart';
import 'package:social_media/features/auth/presentation/cubits/auth_states.dart';

class AuthCubit extends Cubit<AuthState> {
  AuthRepo authRepo;
  AppUser? _currentUser;
  AuthCubit(this.authRepo) : super(AuthInitial());

  void chekAuth() async {
    try {
      emit(AuthLoading());
      _currentUser = await authRepo.getCurrentUser();
      if (_currentUser != null) {
        emit(Authenticated(_currentUser!));
      } else {
        emit(UnAuthenticated());
      }
    } on Exception catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  //get current user
  AppUser? get currentUser => _currentUser;

  // login with email and password
  Future<void> login({required String email, required String pw}) async {
    try {
      emit(AuthLoading());
      _currentUser = await authRepo.loginWithEmailAndPassword(email, pw);
      emit(Authenticated(_currentUser!));
    } catch (e) {
      emit(AuthError(e.toString()));
      emit(UnAuthenticated());
    }
  }

  // register with email and password
  Future<void> register({
    required String name,
    required String email,
    required String pw,
  }) async {
    try {
      emit(AuthLoading());
      _currentUser = await authRepo.registerWithEmailAndPassword(
        name: name,
        email: email,
        password: pw,
      );
      emit(Authenticated(_currentUser!));
    } catch (e) {
      emit(AuthError(e.toString()));
      emit(UnAuthenticated());
    }
  }

  // logout
  Future<void> logout() async {
    try {
      emit(AuthLoading());
      await authRepo.logout();
      emit(UnAuthenticated());
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }
}
