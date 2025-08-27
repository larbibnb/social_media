import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:social_media/features/storage/domain/storage_repo.dart';

class FirebaseStorageRepo implements StorageRepo {
  FirebaseStorage firebaseStorage = FirebaseStorage.instance;

  @override
  Future<String> uploadImage(String filePath, String fileName) async {
    try {
      final ref = firebaseStorage.ref().child('profile_images').child(fileName);
      await ref.putFile(File(filePath));
      final url = await ref.getDownloadURL();
      return url;
    } catch (e) {
      throw Exception('Upload image failed: ${e.toString()}');
    }
  }
}
