import 'package:social_media/features/post/domain/entity/post.dart';

abstract class PostRepo {
  Future<List<Post>> getPosts();
  Future<Post> getPost(String postId);
  Future<void> createPost(String ownerId, String description, List<String> images);
  Future<void> updatePost(String postId, String description, List<String> images);
  Future<void> deletePost(String postId);
}
