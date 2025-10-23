abstract class StorageRepo {
  Future<String> uploadProfileImage(String path, String fileName);
  Future<String> uploadPostImage(String path, String fileName);
}
