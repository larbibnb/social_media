import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:social_media/features/post/domain/entity/post.dart';
import 'package:social_media/features/post/domain/repo/post_repo.dart';

class PostRepoImp extends PostRepo {
  final postsCollection = FirebaseFirestore.instance.collection('posts');
  @override
  Future<List<Post>> fetchPosts() async {
    try {
      final postsSnapshot =
          await postsCollection.orderBy('timestamp', descending: true).get();
      final postsdocsList = postsSnapshot.docs;
      final postsList =
          postsdocsList.map((doc) => Post.fromJson(doc.data())).toList();
      return postsList;
    } catch (e) {
      throw Exception('error fetching posts $e');
    }
  }

  @override
  Future<List<Post>> fetchPostByUserId(String userId) async {
    try {
      final postSnapShot =
          await postsCollection.where('userId', isEqualTo: userId).get();
      final userpostsdocs = postSnapShot.docs;
      final userposts =
          userpostsdocs.map((doc) => Post.fromJson(doc.data())).toList();
      return userposts;
    } on Exception catch (e) {
      throw Exception('error fetching posts by user id $e');
    }
  }

  @override
  Future<void> createOrUpdatePost(Post post) async {
    try {
      await postsCollection.doc(post.id).set(post.toJson());
      log('${post.toJson()}');
    } catch (e) {
      log('$e');
    }
  }

  @override
  Future<void> deletePost(String postId) async {
    await postsCollection.doc(postId).delete();
  }

  @override
  Future<void> likePost(String postId, String userId) async {
    await postsCollection.doc(postId).update({
      'likes': FieldValue.arrayUnion([userId]),
    });
  }

  @override
  Future<void> unlikePost(String postId, String userId) async {
    await postsCollection.doc(postId).update({
      'likes': FieldValue.arrayRemove([userId]),
    });
  }

  @override
  Future<void> commentPost(
    String postId,
    String ownerId,
    String ownerName,
    String description,
  ) async {
    await postsCollection.doc(postId).collection('comments').add({
      'ownerId': ownerId,
      'ownerName': ownerName,
      'postId': postId,
      'description': description,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  @override
  Future<void> deleteCommentPost(String postId, String commentId) async {
    await postsCollection
        .doc(postId)
        .collection('comments')
        .doc(commentId)
        .delete();
  }
}
