import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:social_media/features/profile/domain/entities/profile_user.dart';
import 'package:social_media/features/profile/domain/repo/profile_repo.dart';
import 'package:social_media/features/storage/data/firebase_storage_repo.dart';

class FirebaseProfileRepo implements ProfileRepo {
  final FirebaseFirestore firebaseFirestore;
  final storageRepo = FirebaseStorageRepo();
  FirebaseProfileRepo(this.firebaseFirestore);

  @override
  Future<ProfileUser?> getProfileUser(String uid) async {
    try {
      final userDoc =
          await firebaseFirestore.collection('users').doc(uid).get();
      final userData = userDoc.data();
      if (userData != null) {
        return ProfileUser.fromJson(userData);
      } else {
        return null;
      }
    } catch (e) {
      throw Exception('Get profile user failed: ${e.toString()}');
    }
  }

  @override
  Future<void> updateProfileUser(
    ProfileUser user,
    PlatformFile? pickedFile,
  ) async {
    String? profilePicUrl = user.profilePicUrl;
    if (pickedFile != null) {
      profilePicUrl = await storageRepo.uploadProfileImage(
        pickedFile.path!,
        '${user.uid}_profile.jpg',
      );
    }
    final updatedUser = user.copyWith(profilePicUrl: profilePicUrl);
    await firebaseFirestore
        .collection('users')
        .doc(user.uid)
        .update(updatedUser.toJson());
  }

  @override
  Future<void> toggleFollowUser(String myUid, String uid) async {
    try {
      final myUserDoc =
          await firebaseFirestore.collection('users').doc(myUid).get();
      final userDoc =
          await firebaseFirestore.collection('users').doc(uid).get();
      final myUserData = myUserDoc.data();
      final userData = userDoc.data();
      if (myUserData != null && userData != null) {
        final myUser = ProfileUser.fromJson(myUserData);
        final user = ProfileUser.fromJson(userData);
        if (myUser.following.contains(uid)) {
          myUser.following.remove(uid);
          user.followers.remove(myUid);
          await firebaseFirestore
              .collection('users')
              .doc(myUid)
              .update(myUser.toJson());
          await firebaseFirestore
              .collection('users')
              .doc(uid)
              .update(user.toJson());
        } else {
          myUser.following.add(uid);
          await firebaseFirestore
              .collection('users')
              .doc(myUid)
              .update(myUser.toJson());
          user.followers.add(myUid);
          await firebaseFirestore
              .collection('users')
              .doc(uid)
              .update(user.toJson());
        }
      } else {
        throw Exception('User not found');
      }
    } catch (e) {
      throw Exception('Toggle follow user failed: ${e.toString()}');
    }
  }
}
