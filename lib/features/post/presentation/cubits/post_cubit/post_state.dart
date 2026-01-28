// lib/features/post/presentation/cubit/post_state.dart
import 'package:social_media/features/post/domain/entity/post.dart';

sealed class PostState {}

abstract class PostsCollectionState extends PostState {
  List<Post> get posts;
}
class PostInitial extends PostState {}

class PostLoading extends PostState {}

class FeedPostsLoaded extends PostsCollectionState {
  @override
  final List<Post> posts;
  FeedPostsLoaded(this.posts);
}
class ProfilePostsLoaded extends PostsCollectionState {
  @override
  final List<Post> posts;
  ProfilePostsLoaded(this.posts);
}

class PostError extends PostState {
  final String message;

   PostError(this.message);
}
