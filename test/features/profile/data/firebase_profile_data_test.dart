import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:social_media/features/profile/data/firebase_profile_data.dart';
import 'package:social_media/features/profile/domain/entities/profile_user.dart';

void main() {
  late FakeFirebaseFirestore fakeFirestore;
  late FirebaseProfileRepo profileRepo;

  // Sample users for testing
  final myUser = ProfileUser(
    uid: 'my_uid',
    name: 'My User',
    email: 'my@test.com',
    createdAt: DateTime.now().toIso8601String(),
    followers: [],
    following: [],
  );

  final otherUser = ProfileUser(
    uid: 'other_uid',
    displayName: 'Other User',
    email: 'other@test.com',
    createdAt: DateTime.now().toIso8601String(),
    followers: [],
    following: [],
  );

  setUp(() async {
    fakeFirestore = FakeFirebaseFirestore();
    // Pre-populate the fake database with our test users
    await fakeFirestore
        .collection('users')
        .doc(myUser.uid)
        .set(myUser.toJson());
    await fakeFirestore
        .collection('users')
        .doc(otherUser.uid)
        .set(otherUser.toJson());

    // Inject the fake instance via the constructor
    profileRepo = FirebaseProfileRepo(fakeFirestore);
  });

  group('toggleFollowUser', () {
    test('should allow a user to follow another user successfully', () async {
      // ACT: myUser follows otherUser
      await profileRepo.toggleFollowUser(myUser.uid, otherUser.uid);

      // ASSERT
      // 1. Check myUser's document
      final myUserDoc =
          await fakeFirestore.collection('users').doc(myUser.uid).get();
      final updatedMyUser = ProfileUser.fromJson(myUserDoc.data()!);
      expect(updatedMyUser.following, contains(otherUser.uid));

      // 2. Check otherUser's document
      final otherUserDoc =
          await fakeFirestore.collection('users').doc(otherUser.uid).get();
      final updatedOtherUser = ProfileUser.fromJson(otherUserDoc.data()!);
      expect(updatedOtherUser.followers, contains(myUser.uid));
    });

    test('should allow a user to unfollow another user successfully', () async {
      // ARRANGE: First, make myUser follow otherUser
      // Since fake_cloud_firestore doesn't support FieldValue.arrayUnion,
      // we manually set the state by creating new user objects and setting them.
      final myUserFollowing = myUser.copyWith(following: [otherUser.uid]);
      final otherUserWithFollower = otherUser.copyWith(followers: [myUser.uid]);
      await fakeFirestore
          .collection('users')
          .doc(myUser.uid)
          .set(myUserFollowing.toJson());
      await fakeFirestore
          .collection('users')
          .doc(otherUser.uid)
          .set(otherUserWithFollower.toJson());

      // ACT: myUser unfollows otherUser
      await profileRepo.toggleFollowUser(myUser.uid, otherUser.uid);

      // ASSERT
      // 1. Check myUser's document
      final myUserDoc =
          await fakeFirestore.collection('users').doc(myUser.uid).get();
      final updatedMyUser = ProfileUser.fromJson(myUserDoc.data()!);
      expect(updatedMyUser.following, isNot(contains(otherUser.uid)));

      // 2. Check otherUser's document
      final otherUserDoc =
          await fakeFirestore.collection('users').doc(otherUser.uid).get();
      final updatedOtherUser = ProfileUser.fromJson(otherUserDoc.data()!);
      expect(updatedOtherUser.followers, isNot(contains(myUser.uid)));
    });

    test('should throw an exception if myUser is not found', () async {
      // ARRANGE: A non-existent user ID
      const nonExistentUid = 'non_existent_uid';

      // ACT & ASSERT
      expect(
        () => profileRepo.toggleFollowUser(nonExistentUid, otherUser.uid),
        throwsA(
          isA<Exception>().having(
            (e) => e.toString(),
            'message',
            contains('User not found'),
          ),
        ),
      );
    });

    test(
      'should throw an exception if the user to follow is not found',
      () async {
        // ARRANGE: A non-existent user ID
        const nonExistentUid = 'non_existent_uid';

        // ACT & ASSERT
        expect(
          () => profileRepo.toggleFollowUser(myUser.uid, nonExistentUid),
          throwsA(
            isA<Exception>().having(
              (e) => e.toString(),
              'message',
              contains('User not found'),
            ),
          ),
        );
      },
    );

    test(
      'should correctly update following list when following and followers list when unfollowing',
      () async {
        // ARRANGE: Start with no followers/following

        // ACT 1: Follow
        await profileRepo.toggleFollowUser(myUser.uid, otherUser.uid);

        // ASSERT 1: Check state after following
        var myUserDoc =
            await fakeFirestore.collection('users').doc(myUser.uid).get();
        var otherUserDoc =
            await fakeFirestore.collection('users').doc(otherUser.uid).get();
        expect(ProfileUser.fromJson(myUserDoc.data()!).following, [
          otherUser.uid,
        ]);
        expect(ProfileUser.fromJson(otherUserDoc.data()!).followers, [
          myUser.uid,
        ]);

        // ACT 2: Unfollow
        await profileRepo.toggleFollowUser(myUser.uid, otherUser.uid);

        // ASSERT 2: Check state after unfollowing
        myUserDoc =
            await fakeFirestore.collection('users').doc(myUser.uid).get();
        otherUserDoc =
            await fakeFirestore.collection('users').doc(otherUser.uid).get();
        expect(ProfileUser.fromJson(myUserDoc.data()!).following, isEmpty);
        expect(ProfileUser.fromJson(otherUserDoc.data()!).followers, isEmpty);
      },
    );
  });
}
