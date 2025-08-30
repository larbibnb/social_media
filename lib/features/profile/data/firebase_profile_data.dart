import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:social_media/features/profile/domain/entities/profile_user.dart';
import 'package:social_media/features/profile/domain/repo/profile_repo.dart';
import 'package:social_media/features/storage/data/firebase_storage_repo.dart';

class FirebaseProfileRepo implements ProfileRepo {
  FirebaseFirestore firebaseFirestore = FirebaseFirestore.instance;
  final storageRepo = FirebaseStorageRepo();

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
      profilePicUrl = await storageRepo.uploadImage(
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
}
