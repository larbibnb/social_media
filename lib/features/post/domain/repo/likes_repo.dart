import 'package:social_media/features/post/domain/entity/likes.dart';

abstract class LikesRepo {
  Future<List<Likes>> getLikes(String postId);
  Future<void> likePost(String postId, String uid);
  Future<void> unlikePost(String postId, String uid);
}
