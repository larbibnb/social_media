import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:social_media/features/profile/domain/entities/profile_user.dart';
import 'package:social_media/features/profile/domain/repo/profile_repo.dart';

/// ProfileCacheCubit maintains an in-memory cache of ProfileUser objects keyed by uid.
///
/// State: Map<String, ProfileUser> where keys are user UIDs and values are cached profiles.
///
/// Features:
/// - No loading or error states; only emits updated map.
/// - Ephemeral cache (resets on app restart; no persistence).
/// - Synchronous cache reads via state[uid].
/// - Asynchronous load(uid) that fetches and caches missing users.
/// - One fetch per unseen uid; subsequent calls return cached instantly.
///
/// Usage:
/// 1. Prefetch all known user UIDs (e.g., post owners, commenters) in initState.
/// 2. Read from cache synchronously: final user = cacheCubit.state[uid];
/// 3. For missing users, call cacheCubit.load(uid).then((_) { setState(() {}); });
class ProfileCacheCubit extends Cubit<Map<String, ProfileUser>> {
  final ProfileRepo _profileRepo;

  ProfileCacheCubit(this._profileRepo) : super({});

  /// Load a profile by uid.
  ///
  /// If [uid] is already cached, returns immediately (no fetch).
  /// Otherwise, fetches from repository, caches, and returns the ProfileUser.
  /// Throws if fetch fails.
  Future<ProfileUser> load(String uid) async {
    // Return cached user if available
    if (state.containsKey(uid)) {
      return state[uid]!;
    }

    // Fetch from repository
    final user = await _profileRepo.getProfileUser(uid);

    if (user != null) {
      // Update cache: emit new map with fetched user
      emit({...state, uid: user});
      return user;
    } else {
      throw Exception('Profile not found for uid: $uid');
    }
  }

  /// Prefetch multiple user profiles.
  ///
  /// Fetches all missing uids in parallel and updates the cache once.
  /// Returns immediately if all are already cached.
  Future<void> loadBatch(List<String> uids) async {
    final missingUids = uids.where((uid) => !state.containsKey(uid)).toList();

    if (missingUids.isEmpty) return;

    try {
      final fetched = await Future.wait(
        missingUids.map((uid) => _profileRepo.getProfileUser(uid)),
      );

      final newUsers = <String, ProfileUser>{};
      for (int i = 0; i < missingUids.length; i++) {
        if (fetched[i] != null) {
          newUsers[missingUids[i]] = fetched[i]!;
        }
      }

      if (newUsers.isNotEmpty) {
        emit({...state, ...newUsers});
      }
    } catch (e) {
      // Silently fail batch prefetch; individual loads will retry
    }
  }

  /// Clear the cache.
  void clear() {
    emit({});
  }
}
