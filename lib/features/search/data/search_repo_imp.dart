import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:social_media/features/profile/domain/entities/profile_user.dart';
import 'package:social_media/features/search/domain/search_repo.dart';

class SearchRepoImpl implements SearchRepo {
  final FirebaseFirestore _firestore;

  SearchRepoImpl({required FirebaseFirestore firestore})
    : _firestore = firestore;

  @override
  Future<List<ProfileUser>> searchUsers(String query) async {
    final collectionRef = _firestore.collection('users');
    final querySnapshot =
        await collectionRef
            .where('displayName', isGreaterThanOrEqualTo: query)
            .where('displayName', isLessThanOrEqualTo: '$query\u{f8ff}')
            .get();

    final results = <ProfileUser>[];
    for (final doc in querySnapshot.docs) {
      final user = ProfileUser.fromJson(doc.data());
      results.add(user);
    }
    return results;
  }
}
