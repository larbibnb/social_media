import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:social_media/features/post/domain/entity/post.dart';
import 'package:social_media/features/post/domain/repo/post_repo.dart';

class PostRepoImp extends CommentRepo {
  final FirebaseFirestore _firestore;

  PostRepoImp({required FirebaseFirestore firestore})
      : _firestore = firestore;
  final postsCollection = FirebaseFirestore.instance.collection('posts');

  @override
  Future<List<Post>> fetchPosts() async {
    try {
  final postsSnapshot = await postsCollection.orderBy('timestamp', descending: true).get();
  final postsdocsList = postsSnapshot.docs;
  final postsList = postsdocsList
  .map((doc) => Post.fromJson(doc.data()))
  .toList();
  return postsList;
  } catch (e) {
  throw Exception('error fetching posts $e');
  }
  }

  @override
  Future<List<Post>> fetchPostByUserId(String userId) async {
    try {
  final postSnapShot = await postsCollection.where('userId', isEqualTo: userId).get();
  final userpostsdocs = postSnapShot.docs;
     final userposts = userpostsdocs.map((doc) => Post.fromJson(doc.data())).toList();
  return userposts;
} on Exception catch (e) {
    throw Exception('error fetching posts by user id $e');
}
  }

  @override
  Future<void> createOrUpdatePost(
  Post post
  ) async {
    try {
  await postsCollection.doc(post.id).set(post.toJson());
} catch (e) {
  log('$e');
  }
  }

  @override
  Future<void> deletePost(String postId) async {
    await postsCollection.doc(postId).delete();
  }

}