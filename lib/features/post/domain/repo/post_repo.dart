import 'package:social_media/features/post/domain/entity/post.dart';

abstract class PostRepo {
  Future<List<Post>> fetchPosts();
  Future<List<Post>> fetchPostByUserId(String userId);
  Future<void> createOrUpdatePost(Post post);
  Future<void> deletePost(String postId);

}
