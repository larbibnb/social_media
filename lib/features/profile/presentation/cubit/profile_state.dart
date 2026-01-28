import 'package:social_media/features/post/domain/entity/post.dart';
import 'package:social_media/features/profile/domain/entities/profile_user.dart';

abstract class ProfileState {}

class ProfileInitial extends ProfileState {}

class ProfileLoading extends ProfileState {}

class ProfileLoaded extends ProfileState {
  final ProfileUser profileUser;
  final List<Post> posts;
  ProfileLoaded(this.profileUser,this.posts);
}
class ProfileError extends ProfileState {
  final String error;

  ProfileError(this.error);
}
