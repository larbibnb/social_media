import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:social_media/features/post/domain/entity/likes.dart';
import 'package:social_media/features/post/domain/repo/likes_repo.dart';

class LikesRepoImp extends LikesRepo {
  final FirebaseFirestore _firestore;

  LikesRepoImp({required FirebaseFirestore firestore})
      : _firestore = firestore;

  @override
  Future<List<Likes>> getLikes(String postId) async {
    final likesSnapShot = await _firestore.collection('posts').doc(postId).collection('likes').get();
    final likesList = likesSnapShot.docs.map((doc) {
      final data = doc.data();
      return Likes(postId: postId, ownerId: data['ownerId'], uid: data['uid'],);
    }).toList();
    return likesList;
  }

  @override
  Future<void> likePost(String postId, String ownerId) async {
    final likesCollection=await _firestore.collection('posts').doc(postId).collection('likes');
    final likesDoc=await likesCollection.add({'ownerId': ownerId,});
    likesCollection.doc(likesDoc.id).update({'uid':likesDoc.id ,});
  }


  @override
  Future<void> unlikePost(String postId, String uid) async {
    final likesCollection= _firestore.collection('posts').doc(postId).collection('likes');
    await likesCollection.doc(uid).delete();
  }
}