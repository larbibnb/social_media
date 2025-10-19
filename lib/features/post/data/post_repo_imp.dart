import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:social_media/features/post/domain/entity/comment.dart';
import 'package:social_media/features/post/domain/entity/post.dart';
import 'package:social_media/features/post/domain/repo/post_repo.dart';

class PostRepoImp extends CommentRepo {
  final FirebaseFirestore _firestore;

  PostRepoImp({required FirebaseFirestore firestore})
      : _firestore = firestore;

  @override
  Future<List<Post>> getPosts() async {
    final postsCollection = _firestore.collection('posts');
    final postsSnapshot = await postsCollection.get();
    final postsList = postsSnapshot.docs.map((doc) {
      final data = doc.data();
      final postId = doc.id;
      return Post(
        id: postId,
        ownerId: data['ownerId'],
        description: data['description'],
        images: List<String>.from(data['images']),
        timestamp: (data['timestamp'] as Timestamp).toDate(),
      );
    }).toList();
    return postsList;
  }

  @override
  Future<Post> getPost(String postId) async {
    final postDoc = await _firestore.collection('posts').doc(postId).get();
    final postData = postDoc.data();
    if (postData == null) {
      throw Exception('Post not found');
    }
    return Post(
      id: postId,
      ownerId: postData['ownerId'],
      description: postData['description'],
      images: List<String>.from(postData['images']),
      timestamp: (postData['timestamp'] as Timestamp).toDate(),
    );
  }

  @override
  Future<void> createPost(
    String ownerId,
    String description,
    List<String> images,
  ) async {
    final postDoc = await _firestore.collection('posts').add({
      'ownerId': ownerId,
      'description': description,
      'images': images,
      'likes': [],
      'comments': [],
    });
    final postId = postDoc.id;
    await _firestore.collection('posts').doc(postId).update({
      'id': postId,
    });
  }

  @override
  Future<void> updatePost(
    String postId,
    String description,
    List<String> images,
  ) async {
    await _firestore.collection('posts').doc(postId).update({
      'description': description,
      'images': images,
    });
  }

  @override
  Future<void> deletePost(String postId) async {
    await _firestore.collection('posts').doc(postId).delete();
  }

  @override
  Future<void> likePost(String postId, String userId) async {
    final postRef = _firestore.collection('posts').doc(postId);
    await postRef.update({
      'likes': FieldValue.arrayUnion([userId]),
    });
  }

  @override
  Future<void> unlikePost(String postId, String userId) async {
    final postRef = _firestore.collection('posts').doc(postId);
    await postRef.update({
      'likes': FieldValue.arrayRemove([userId]),
    });
  }

  @override
  Future<List<String>> getLikes(String postId) async {
    final postDoc = await _firestore.collection('posts').doc(postId).get();
    final data = postDoc.data();
    if (data == null) {
      return [];
    }
    return List<String>.from(data['likes'] ?? []);
  }

  @override
  Future<List<Comment>> getComments(String postId) async {
    final commentsSnapshot = await _firestore
        .collection('posts')
        .doc(postId)
        .collection('comments')
        .get();
    return commentsSnapshot.docs.map((doc) {
      final data = doc.data();
      return Comment(
        id: doc.id,
        postId: postId,
        ownerId: data['ownerId'],
        description: data['description'],
      );
    }).toList();
  }

  @override
  Future<void> addComment(String postId, Comment comment) async {
    final commentsCollection =
        _firestore.collection('posts').doc(postId).collection('comments');
    final commentDoc = await commentsCollection.add({
      'ownerId': comment.ownerId,
      'postId': comment.postId,
      'description': comment.description,
    });
    await commentsCollection.doc(commentDoc.id).update({
      'id': commentDoc.id,
      'createdAt': Timestamp.now(),
    });
  }

  @override
  Future<void> deleteComment(String postId, String commentId) async {
    await _firestore
        .collection('posts')
        .doc(postId)
        .collection('comments')
        .doc(commentId)
        .delete();
  }
}