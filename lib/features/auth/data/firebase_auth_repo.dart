import 'package:firebase_auth/firebase_auth.dart';
import 'package:social_media/features/auth/domain/app_user.dart';
import 'package:social_media/features/auth/domain/repositories/auth_repo.dart';

class FirebaseAuthRepo implements AuthRepo {
  FirebaseAuth firebaseAuth = FirebaseAuth.instance;

  @override
  Future<AppUser> getCurrentUser() async{
    try {
      final user = firebaseAuth.currentUser;
      if (user != null) {
        return AppUser(
          email: user.email!,
          uid: user.uid,
          name: user.displayName!,
        );
      } else {
        throw Exception("No user is logged in");
      }
    } on FirebaseAuthException catch (e) {
      throw Exception(e.message);
    } on Exception catch (e) {
      throw Exception(e.toString());
    }
  }

  @override
  Future<AppUser> loginWithEmailAndPassword(String email, String password) async{
    try {
      UserCredential userCredential = await firebaseAuth.signInWithEmailAndPassword(email: email, password: password);
      AppUser user = AppUser(
        uid: userCredential.user!.uid,
        email: email,
        name: '',
      );
      return user;
    } catch (e) {
      throw Exception('Login failed: ${e.toString()}');
    }
  }
 
  @override
  Future<void> logout() {
    try {
      return firebaseAuth.signOut();
    } catch (e) {
      throw Exception('Logout failed: ${e.toString()}');
    }
  }

  @override
  Future<AppUser> registerWithEmailAndPassword(String email, String password) async{
   try {
      UserCredential userCredential = await firebaseAuth.createUserWithEmailAndPassword(email: email, password: password);
      AppUser user = AppUser(
        uid: userCredential.user!.uid,
        email: email,
        name: '',
      );
      return user;
    } catch (e) {
      throw Exception('Register failed: ${e.toString()}');
    }
  }

}