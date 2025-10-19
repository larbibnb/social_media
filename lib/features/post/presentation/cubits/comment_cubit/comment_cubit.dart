import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:social_media/features/post/domain/entity/comment.dart';
import 'package:social_media/features/post/domain/repo/comment_repo.dart';

import 'comment_state.dart';

class CommentCubit extends Cubit<CommentState> {
  CommentCubit({required CommentRepo commentRepo})
      : _commentRepo = commentRepo,
        super(const CommentState.initial());

  final CommentRepo _commentRepo;

  Future<void> loadComments(String postId) async {
    emit(state.copyWith(status: CommentStatus.loading));
    try {
      final comments = await _commentRepo.getComments(postId);
      emit(state.copyWith(status: CommentStatus.loaded, comments: comments));
    } catch (error) {
      emit(state.copyWith(status: CommentStatus.error, errorMessage: error.toString()));
    }
  }

  Future<void> addComment({
    required String postId,
    required Comment comment,
  }) async {
    final updatedComments = List<Comment>.from(state.comments)..add(comment);
    emit(state.copyWith(comments: updatedComments));
    try {
      await _commentRepo.createComment(postId, comment.ownerId, comment.description);
    } catch (error) {
      updatedComments.remove(comment);
      emit(state.copyWith(comments: updatedComments, errorMessage: error.toString()));
    }
  }

  Future<void> deleteComment({
    required String postId,
    required String commentId,
  }) async {
    final updatedComments =
        state.comments.where((comment) => comment.id != commentId).toList();
    emit(state.copyWith(comments: updatedComments));
    try {
      await _commentRepo.deleteComment(postId, commentId);
    } catch (error) {
      emit(state.copyWith(status: CommentStatus.error, errorMessage: error.toString()));
    }
  }
}