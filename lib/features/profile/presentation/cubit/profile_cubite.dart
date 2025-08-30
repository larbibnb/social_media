import 'package:file_picker/file_picker.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:social_media/features/profile/domain/entities/profile_user.dart';
import 'package:social_media/features/profile/domain/repo/profile_repo.dart';
import 'package:social_media/features/profile/presentation/cubit/profile_state.dart';

class ProfileCubit extends Cubit<ProfileState> {
  ProfileRepo profileRepo;
  ProfileCubit(this.profileRepo) : super(ProfileInitial());

  void getProfileUser(String uid) async {
    try {
      emit(ProfileLoading());
      final profileUser = await profileRepo.getProfileUser(uid);
      if (profileUser != null) {
        emit(ProfileLoaded(profileUser));
      }
    } catch (e) {
      emit(ProfileError('Cubit Get profile user failed: ${e.toString() }'));
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
}
