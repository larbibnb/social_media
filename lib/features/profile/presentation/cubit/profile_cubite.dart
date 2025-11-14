import 'package:file_picker/file_picker.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:social_media/features/profile/domain/entities/profile_user.dart';
import 'package:social_media/features/profile/domain/repo/profile_repo.dart';
import 'package:social_media/features/profile/presentation/cubit/profile_state.dart';

class ProfileCubit extends Cubit<ProfileState> {
  ProfileRepo profileRepo;

  ProfileCubit(this.profileRepo) : super(ProfileInitial());

  /// Fetch a profile user. If [emitState] is true (default) the cubit will
  /// emit loading/loaded/error states. Set to false when you need a one-off
  /// lookup (for example when loading post authors) so the global profile
  /// UI state isn't disturbed.
  Future<ProfileUser?> getProfileUser(
    String uid, {
    bool emitState = true,
  }) async {
    try {
      if (emitState) emit(ProfileLoading());
      final profileUser = await profileRepo.getProfileUser(uid);
      if (profileUser != null && emitState) {
        emit(ProfileLoaded(profileUser));
      }
      return profileUser;
    } catch (e) {
      if (emitState)
        emit(ProfileError('Cubit Get profile user failed: ${e.toString()}'));
      return null;
    }
  }

  Future<void> updateProfileUser(
    ProfileUser updatedprofileUser, {
    PlatformFile? pickedFile,
  }) async {
    try {
      emit(ProfileLoading());
      await profileRepo.updateProfileUser(updatedprofileUser, pickedFile);
      await getProfileUser(updatedprofileUser.uid);
    } catch (e) {
      emit(ProfileError('Failed to update profile: ${e.toString()}'));
    }
  }

  Future<void> toggleFollowUser(String myUid, String uid) async {
    try {
      final currentState = state;
      if (currentState is ProfileLoaded) {
        final originalUser = currentState.profileUser;
        final isFollowing = originalUser.followers.contains(myUid);

        // Optimistically update the UI
        final List<String> newFollowers = List.from(originalUser.followers);
        if (isFollowing) {
          newFollowers.remove(myUid);
        } else {
          newFollowers.add(myUid);
        }
        final updatedUser = originalUser.copyWith(followers: newFollowers);
        emit(ProfileLoaded(updatedUser));

        // Perform the actual repository call
        await profileRepo.toggleFollowUser(myUid, uid);
      }
    } catch (e) {
      // If something goes wrong, revert to the original state
      final currentState = state;
      if (currentState is ProfileLoaded)
        getProfileUser(currentState.profileUser.uid);
      emit(ProfileError('Failed to toggle follow: ${e.toString()}'));
    }
  }
}
