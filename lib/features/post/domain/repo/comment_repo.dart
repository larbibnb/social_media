import 'package:social_media/features/post/domain/entity/comment.dart';

abstract class CommentRepo {
  Future<List<Comment>> getComments(String postId) async {
    throw UnimplementedError();
  }

  Future<void> createComment(String postId, String ownerId, String description) async {
    throw UnimplementedError();
  }

  Future<void> deleteComment(String commentId, String postId) async {
    throw UnimplementedError();
  }

  Future<void> updateComment(String commentId, String postId, String description) async {
    throw UnimplementedError();
  }
}
