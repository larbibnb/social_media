import 'package:social_media/features/post/domain/entity/post.dart';

abstract class PostRepo {
  Future<List<Post>> fetchPosts();
  Future<List<Post>> fetchPostsByUserId(String userId);
  Future<List<Post>> fetchFeedPostsByUserIds(List<String> userIds);
  Future<void> createOrUpdatePost(Post post);
  Future<void> deletePost(String postId);
  Future<void> toggleLikePost(String postId, String userId);
  Future<void> commentPost(
    String postId,
    String ownerId,
    String ownerName,
    String description,
  );
  Future<void> deleteCommentPost(String postId, String commentId);
}
