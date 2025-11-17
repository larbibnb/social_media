import 'dart:developer';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:social_media/features/post/domain/entity/comment.dart';
import 'package:social_media/features/post/domain/entity/post.dart';
import 'package:social_media/features/post/domain/repo/post_repo.dart';
import 'package:social_media/features/post/presentation/cubits/post_cubit/post_state.dart';
import 'package:social_media/features/storage/domain/storage_repo.dart';

class PostCubit extends Cubit<PostState> {
  final PostRepo _postRepo;
  final StorageRepo _storageRepo;
  PostCubit(this._postRepo, this._storageRepo) : super(PostInitial());

  Future<List<Post>> fetchPostsByUserId(String userId) async {
    emit(PostLoading());
    try {
      final userPosts = await _postRepo.fetchPostsByUserId(userId);
      emit(PostsLoaded(userPosts));
      return userPosts;
    } catch (e) {
      emit(PostError(e.toString()));
      return <Post>[];
    }
  }

  Future<List<Post>> fetchFeedPostsByUserIds(List<String> userIds) async {
    emit(PostLoading());
    try {
      final feedPosts = await _postRepo.fetchFeedPostsByUserIds(userIds);
      emit(PostsLoaded(feedPosts));
      return feedPosts;
    } catch (e) {
      emit(PostError(e.toString()));
      return <Post>[];
    }
  }

  Future<void> createOrUpdatePost(Post post, {List<String>? pathImages}) async {
    try {
      final uploadedUrls = <String>[];
      if (pathImages != null && pathImages.isNotEmpty) {
        for (var i = 0; i < pathImages.length; i++) {
          final img = pathImages[i];
          final uniqueFileName = '${post.id}_$i';
          final url = await _storageRepo.uploadPostImage(img, uniqueFileName);
          uploadedUrls.add(url);
        }
        post.images.addAll(uploadedUrls);
        log(post.images.toString());
      }
      _postRepo.createOrUpdatePost(post);
    } catch (e) {
      emit(PostError(e.toString()));
    }
  }

  Future<void> deletePost(String postId) async {
    try {
      await _postRepo.deletePost(postId);
    } catch (e) {
      emit(PostError(e.toString()));
    }
  }

  Future<void> toggleLikePost(String postId, String userId) async {
    try {
      await _postRepo.toggleLikePost(postId, userId);
    } catch (e) {
      emit(PostError(e.toString()));
    }
  }

  Future<void> commentPost(
    String postId,
    String ownerId,
    String ownerName,
    String description,
  ) async {
    final currentState = state;
    if (currentState is! PostsLoaded) return;

    final newComment = Comment(
      id: '',
      ownerId: ownerId,
      ownerName: ownerName,
      postId: postId,
      description: description,
      timestamp: DateTime.now(),
    );

    // Optimistic UI update
    final updatedPosts =
        currentState.posts.map((post) {
          if (post.id == postId) {
            final updatedComments = List<Comment>.from(post.comments)
              ..add(newComment);
            return post.copyWith(comments: updatedComments);
          }
          return post;
        }).toList();
    emit(PostsLoaded(updatedPosts));

    try {
      await _postRepo.commentPost(postId, ownerId, ownerName, description);
    } catch (e) {
      // Revert on error
      emit(currentState); // Re-emit the original state
      emit(PostError('Failed to post comment: ${e.toString()}'));
    }
  }

  Future<void> deleteCommentPost(String postId, String commentId) async {
    final currentState = state;
    if (currentState is! PostsLoaded) return;
    final updatedPosts =
        currentState.posts.map((post) {
          if (post.id == postId) {
            final updatedComments =
                post.comments
                    .where((comment) => comment.id != commentId)
                    .toList();
            return post.copyWith(comments: updatedComments);
          }
          return post;
        }).toList();
    emit(PostsLoaded(updatedPosts));
    try {
      await _postRepo.deleteCommentPost(postId, commentId);
    } catch (e) {
      // Revert on error
      emit(currentState); // Re-emit the original state
      emit(PostError('Failed to delete comment: ${e.toString()}'));
    }
  }
}
