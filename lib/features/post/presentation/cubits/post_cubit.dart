import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:social_media/features/post/domain/entity/post.dart';
import 'package:social_media/features/post/domain/repo/post_repo.dart';
import 'package:social_media/features/post/presentation/cubits/post_cubit/post_state.dart';

class PostCubit extends Cubit<PostState> {
  final CommentRepo _postRepo;

  PostCubit(this._postRepo) : super(PostInitial());

    Future<Post> getPost(String postId) async {
    return await _postRepo.getPost(postId);
  }
  Future<void> fetchPosts() async {
    emit(PostLoading());
    try {
      final posts = await _postRepo.getPosts();
      emit(PostsLoaded(posts));
    } catch (e) {
      emit(PostError(e.toString()));
    }
  }
  Future<void> createPost(String ownerId, String description, List<String> images) async {
    try {
      emit(PostLoading());
      await _postRepo.createPost(ownerId, description, images);
      emit(PostInitial());
    } catch (e) {
      emit(PostError(e.toString()));
    }
  }
  Future<void> updatePost(String postId, String description, List<String> images) async {
    try {
      emit(PostLoading());
      await _postRepo.updatePost(postId, description, images);
      emit(PostInitial());
    } catch (e) {
      emit(PostError(e.toString()));
    }
  }
  Future<void> deletePost(String postId) async {
    try {
      emit(PostLoading());
      await _postRepo.deletePost(postId);
      emit(PostInitial());
    } catch (e) {
      emit(PostError(e.toString()));
    }
  }
}
