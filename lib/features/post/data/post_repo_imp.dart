import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:social_media/features/post/domain/entity/comment.dart';
import 'package:social_media/features/post/domain/entity/post.dart';
import 'package:social_media/features/post/domain/repo/post_repo.dart';

class PostRepoImp extends PostRepo {
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
        likes: List<String>.from(data['likes']),
        comments: List<Comment>.from(data['comments']),
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
        likes: List<String>.from(postData['likes']),
        comments: List<Comment>.from(postData['comments']),
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
}