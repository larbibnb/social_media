import 'package:equatable/equatable.dart';
import 'package:social_media/features/post/domain/entity/comment.dart';

enum CommentStatus { initial, loading, loaded, error }

class CommentState extends Equatable {
  const CommentState({
    required this.status,
    required this.comments,
    this.errorMessage,
  });

  const CommentState.initial()
      : status = CommentStatus.initial,
        comments = const <Comment>[],
        errorMessage = null;

  final CommentStatus status;
  final List<Comment> comments;
  final String? errorMessage;

  CommentState copyWith({
    CommentStatus? status,
    List<Comment>? comments,
    String? errorMessage,
  }) {
    return CommentState(
      status: status ?? this.status,
      comments: comments ?? this.comments,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, comments, errorMessage];
}