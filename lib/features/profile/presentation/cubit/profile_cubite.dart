import 'package:file_picker/file_picker.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:social_media/features/profile/domain/entities/profile_user.dart';
import 'package:social_media/features/profile/domain/repo/profile_repo.dart';
import 'package:social_media/features/profile/presentation/cubit/profile_state.dart';

class ProfileCubit extends Cubit<ProfileState> {
  ProfileRepo profileRepo;

  ProfileCubit(this.profileRepo) : super(ProfileInitial());

  Future<ProfileUser?> getProfileUser(String uid) async {
    try {
      emit(ProfileLoading());
      final profileUser = await profileRepo.getProfileUser(uid);
      if (profileUser != null) {
        emit(ProfileLoaded(profileUser));
      }
      return profileUser;
    } catch (e) {
      emit(ProfileError('Cubit Get profile user failed: ${e.toString()}'));
      return null;
    }
  }

  void updateProfileUser(
    ProfileUser updatedprofileUser,
    PlatformFile? pickedFile,
  ) async {
    try {
      emit(ProfileLoading());
      await profileRepo.updateProfileUser(updatedprofileUser, pickedFile);
      getProfileUser(updatedprofileUser.uid);
      emit(ProfileLoaded(updatedprofileUser));
    } catch (e) {
      emit(ProfileError(e.toString()));
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
      if (currentState is ProfileLoaded) {
        getProfileUser(currentState.profileUser.uid);
        emit(ProfileLoaded(currentState.profileUser));
      }
      await profileRepo.toggleFollowUser(myUid, uid);
      emit(ProfileError(e.toString()));
    }
  }
}
