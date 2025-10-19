part of 'likes_cubit.dart';

enum LikesStatus { initial, loading, loaded, error }

class LikesState {
  const LikesState({
    required this.status,
    required this.likes,
    this.errorMessage,
  });

  const LikesState.initial()
      : status = LikesStatus.initial,
        likes = const <String>[],
        errorMessage = null;

  final LikesStatus status;
  final List<String> likes;
  final String? errorMessage;

  LikesState copyWith({
    LikesStatus? status,
    List<String>? likes,
    String? errorMessage,
  }) {
    return LikesState(
      status: status ?? this.status,
      likes: likes ?? this.likes,
      errorMessage: errorMessage,
    );
  }
}