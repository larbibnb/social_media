import 'package:social_media/features/auth/domain/entities/app_user.dart';

abstract class AuthRepo {
  Future<AppUser?> loginWithEmailAndPassword(String email, String password);
  Future<AppUser?> registerWithEmailAndPassword({
    required String email,
    required String password,
    String? name,
  });
  Future<void> logout();
  Future<AppUser?> getCurrentUser();
}
