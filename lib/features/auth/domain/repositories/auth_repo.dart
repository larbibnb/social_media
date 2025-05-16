import 'package:social_media/features/auth/domain/app_user.dart';

abstract class AuthRepo {
  Future<AppUser> loginWithEmailAndPassword(String email, String password);
  Future<AppUser> registerWithEmailAndPassword(String email, String password);
  Future<void> logout();
  Future<AppUser> getCurrentUser();
}
