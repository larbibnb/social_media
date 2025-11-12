import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:social_media/features/auth/domain/entities/app_user.dart';
import 'package:social_media/features/auth/domain/repositories/auth_repo.dart';

class FirebaseAuthRepo implements AuthRepo {
  FirebaseAuth firebaseAuth = FirebaseAuth.instance;
  FirebaseFirestore firebaseFirestore = FirebaseFirestore.instance;

  @override
  Future<AppUser?> getCurrentUser() async {
    try {
      final user = firebaseAuth.currentUser;

      if (user != null) {
        final userDoc =
            await firebaseFirestore.collection('users').doc(user.uid).get();
        final userData = userDoc.data();
        final displayName = userData?['displayName'];
        final userName = userData?['userName'];
        final gender = userData?['gender'];

        return AppUser(
          email: user.email!,
          uid: user.uid,
          displayName: displayName,
          userName: userName,
          gender: gender != null ? Gender.values.byName(gender) : null,
        );
      } else {
        return null;
      }
    } on FirebaseAuthException catch (e) {
      throw Exception(e.message);
    } on Exception catch (e) {
      throw Exception(e.toString());
    }
  }

  @override
  Future<AppUser?> registerWithEmailAndPassword({
    String? name,
    required String email,
    required String password,
  }) async {
    try {
      UserCredential userCredential = await firebaseAuth
          .createUserWithEmailAndPassword(email: email, password: password);

      // store only the yyyy-MM-dd string
      final String createdAt =
          DateTime.now().toIso8601String().split('T').first;

      AppUser user = AppUser(
        uid: userCredential.user!.uid,
        email: email,
        createdAt: createdAt,
      );

      await firebaseFirestore.collection('users').doc(user.uid).set({
        'uid': user.uid,
        'email': user.email,
        'createdAt': createdAt, // stored as string
      });

      return user;
    } catch (e) {
      throw Exception('Register failed: ${e.toString()}');
    }
  }

  @override
  Future<AppUser?> loginWithEmailAndPassword(
    String email,
    String password,
  ) async {
    try {
      UserCredential userCredential = await firebaseAuth
          .signInWithEmailAndPassword(email: email, password: password);

      final userDoc =
          await firebaseFirestore
              .collection('users')
              .doc(userCredential.user!.uid)
              .get();

      final userData = userDoc.data();
      if (userData == null) return null;

      final String? displayName = userData['displayName'];
      final String? userName = userData['userName'];
      final Gender? gender =
          userData['gender'] != null
              ? Gender.values.byName(userData['gender'])
              : null;
      final String createdAt = userData['createdAt'] ?? '';

      final AppUser user = AppUser(
        uid: userCredential.user!.uid,
        displayName: displayName,
        email: email,
        createdAt: createdAt,
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
}
