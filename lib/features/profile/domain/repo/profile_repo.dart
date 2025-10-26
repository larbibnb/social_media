import 'package:file_picker/file_picker.dart';
import 'package:social_media/features/profile/domain/entities/profile_user.dart';

abstract class ProfileRepo {
  Future<ProfileUser?> getProfileUser(String uid);
  Future<void> updateProfileUser(ProfileUser user, PlatformFile? pickedFile);
  Future<void> toggleFollowUser(String myUid, String uid);
}
