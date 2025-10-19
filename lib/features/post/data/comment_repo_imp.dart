import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:social_media/features/post/domain/entity/comment.dart';
import 'package:social_media/features/post/domain/repo/comment_repo.dart';

class CommentRepoImp extends CommentRepo {
  final FirebaseFirestore _firestore;

  CommentRepoImp({required FirebaseFirestore fireStore})
      : _firestore = fireStore;

  @override
  Future<List<Comment>> getComments(String postId) async {
    final commentsCollection =
        _firestore.collection('posts').doc(postId).collection('comments');
    final commentsSnapshot = await commentsCollection.get();
    final commentsList = commentsSnapshot.docs.map((doc) {
      final data = doc.data();
      return Comment(
        id: doc.id,
        postId: postId,
        ownerId: data['ownerId'],
        description: data['description'],
      );
    }).toList();
    return commentsList;
  }

  @override
  Future<void> createComment(
      String postId,
      String ownerId,
      String description,
    ) async {
    final commentsCollection =
        _firestore.collection('posts').doc(postId).collection('comments');
    final commentDoc = await commentsCollection.add({
      'ownerId': ownerId,
      'postId': postId,
      'description': description,
    });
    final commentId = commentDoc.id;
    await commentsCollection.doc(commentId).update({
      'id': commentId,
    });
  }

  @override
  Future<void> deleteComment(String commentId, String postId) async {
    final commentsCollection =
        _firestore.collection('posts').doc(postId).collection('comments');
    await commentsCollection.doc(commentId).delete();
  }

  @override
  Future<void> updateComment(
      String commentId,
      String postId,
      String description,
    ) async {
    final commentsCollection =
        _firestore.collection('posts').doc(postId).collection('comments');
    await commentsCollection.doc(commentId).update({
      'description': description,
    });
  }
}