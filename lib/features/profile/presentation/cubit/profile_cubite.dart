import 'package:file_picker/file_picker.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:social_media/features/post/domain/entity/post.dart';
import 'package:social_media/features/profile/domain/entities/profile_user.dart';
import 'package:social_media/features/profile/domain/repo/profile_repo.dart';
import 'package:social_media/features/profile/presentation/cubit/profile_state.dart';

class ProfileCubit extends Cubit<ProfileState> {
  ProfileRepo profileRepo;

  ProfileCubit(this.profileRepo) : super(ProfileInitial());

  /// Fetch a profile user and emit loading/loaded/error states.
  ///
  /// This method is intended for full-profile UI flows (Profile page,
  /// Onboarding) where emitting global profile state is desired. For
  /// lightweight, feed-side lookups prefer `ProfileCacheCubit` to avoid
  /// mutating the global profile UI state.
  Future<ProfileUser?> getProfileUser(String uid) async {
    try {
      emit(ProfileLoading());
      final profileUser = await profileRepo.getProfileUser(uid);
      if (profileUser != null) {
        emit(ProfileLoaded(profileUser, []));
      } else {
        emit(ProfileError('Profile not found for uid: $uid'));
      }
      return profileUser;
    } catch (e) {
      emit(ProfileError('Cubit Get profile user failed: ${e.toString()}'));
      return null;
    }
  }
    Future<List<Post>> fetchPostsByUserId(String userId) async {
    emit(ProfileLoading());
    final profileUser = await getProfileUser(userId);
    if (profileUser == null) {
      return <Post>[];
    }
    try {
      final userPosts = await profileRepo.fetchPostsByUserId(userId);
      emit(ProfileLoaded(profileUser, userPosts));
      return userPosts;
    } catch (e) {
      emit(ProfileError(e.toString()));
      return <Post>[];
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
        emit(ProfileLoaded(updatedUser,[]));

        // Perform the actual repository call
        await profileRepo.toggleFollowUser(myUid, uid);
      }
    } catch (e) {
      // If something goes wrong, revert to the original state
      final currentState = state;
      if (currentState is ProfileLoaded) {
        getProfileUser(currentState.profileUser.uid);
      }
      emit(ProfileError('Failed to toggle follow: ${e.toString()}'));
    }
  }
}
