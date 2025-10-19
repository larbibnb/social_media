import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:social_media/features/post/domain/repo/likes_repo.dart';

part 'likes_state.dart';

class LikesCubit extends Cubit<LikesState> {
  LikesCubit({required LikesRepo likesRepo})
      : _likesRepo = likesRepo,
        super(const LikesState.initial());

  final LikesRepo _likesRepo;

  Future<void> loadLikes(String postId) async {
    emit(state.copyWith(status: LikesStatus.loading));
    try {
      final likes = await _likesRepo.getLikes(postId);
      emit(state.copyWith(status: LikesStatus.loaded, likes: likes.map((like) => like.uid).toList()));
    } catch (error) {
      emit(state.copyWith(status: LikesStatus.error, errorMessage: error.toString()));
    }
  }

  Future<void> toggleLike({required String postId, required String userId}) async {
    final currentState = state;

    if (currentState.status != LikesStatus.loaded) {
      await loadLikes(postId);
      return;
    }

    final isLiked = currentState.likes.contains(userId);
    final updatedLikes = List<String>.from(currentState.likes);

    if (isLiked) {
      updatedLikes.remove(userId);
      emit(currentState.copyWith(likes: updatedLikes));
      try {
        await _likesRepo.unlikePost(postId, userId);
      } catch (error) {
        updatedLikes.add(userId);
        emit(currentState.copyWith(likes: updatedLikes, errorMessage: error.toString()));
      }
    } else {
      updatedLikes.add(userId);
      emit(currentState.copyWith(likes: updatedLikes));
      try {
        await _likesRepo.likePost(postId, userId);
      } catch (error) {
        updatedLikes.remove(userId);
        emit(currentState.copyWith(likes: updatedLikes, errorMessage: error.toString()));
      }
    }
  }
}