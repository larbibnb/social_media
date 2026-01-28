import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:social_media/features/post/domain/entity/comment.dart';
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

      final postsList = <Post>[];
      for (final doc in postsdocsList) {
        final commentsSnapshot =
            await doc.reference
                .collection('comments')
                .orderBy('timestamp', descending: true)
                .get();
        final comments =
            commentsSnapshot.docs.map((commentDoc) {
              final data = commentDoc.data();
              return Comment.fromJson(data);
            }).toList();

        postsList.add(Post.fromJson(doc.data(), comments: comments));
      }
      return postsList;
    } catch (e) {
      throw Exception('error fetching posts $e');
    }
  }

  @override
  Future<List<Post>> fetchFeedPostsByUserIds(List<String> userIds) async {
    try {
      final postSnapShot =
          await postsCollection
              .orderBy('timestamp', descending: true)
              .where('ownerId', whereIn: userIds)
              .get();
      final userPostsDocs = postSnapShot.docs;

      final postsList = <Post>[];
      for (final doc in userPostsDocs) {
        final commentsSnapshot =
            await doc.reference
                .collection('comments')
                .orderBy('timestamp', descending: true)
                .get();
        final comments =
            commentsSnapshot.docs.map((commentDoc) {
              final data = commentDoc.data();
              return Comment.fromJson(data);
            }).toList();
        postsList.add(Post.fromJson(doc.data(), comments: comments));
      }
      return postsList;
    } on Exception catch (e) {
      throw Exception('error fetching posts $e');
    }
  }

  @override
  Future<void> deletePost(String postId) async {
    try {
      await postsCollection.doc(postId).delete();
    } catch (e) {
      throw Exception('error deleting post $e');
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
  Future<void> toggleLikePost(String postId, String userId) async {
    try {
      final postDoc = await postsCollection.doc(postId).get();
      if (postDoc.exists) {
        final post = Post.fromJson(postDoc.data()!);
        final isLiked = post.likes.contains(userId);
        if (isLiked) {
          post.likes.remove(userId);
        } else {
          post.likes.add(userId);
        }
        await postsCollection.doc(postId).set(post.toJson());
      } else {
        throw Exception('Post not found');
      }
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  @override
  Future<void> commentPost(
    String postId,
    String ownerId,
    String ownerName,
    String description,
  ) async {
    final commentDoc = await postsCollection
        .doc(postId)
        .collection('comments')
        .add({
          'id': '',
          'ownerId': ownerId,
          'ownerName': ownerName,
          'postId': postId,
          'description': description,
          'timestamp': FieldValue.serverTimestamp(),
        });
    await postsCollection
        .doc(postId)
        .collection('comments')
        .doc(commentDoc.id)
        .update({'id': commentDoc.id});
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
