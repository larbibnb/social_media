import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:social_media/features/auth/presentation/cubits/auth_cubit.dart';
import 'package:social_media/features/post/domain/entity/post.dart';
import 'package:social_media/features/post/presentation/components/post_card.dart';
import 'package:social_media/features/post/presentation/cubits/post_cubit/post_cubit.dart';
import 'package:social_media/features/post/presentation/cubits/post_cubit/post_state.dart';
import 'package:social_media/features/profile/presentation/cubit/profile_cache_cubit.dart';

class FeedView extends StatefulWidget {
  const FeedView({super.key});

  @override
  State<FeedView> createState() => _FeedViewState();
}

class _FeedViewState extends State<FeedView> {
  late final PostCubit postCubit;
  late final AuthCubit authCubit;
  late final ProfileCacheCubit cacheCubit;
  List<String> _following = [];

  @override
  void initState() {
    super.initState();
    postCubit = context.read<PostCubit>();
    authCubit = context.read<AuthCubit>();
    cacheCubit = context.read<ProfileCacheCubit>();
    _loadAndFetchFeed();
  }

  Future<void> _loadAndFetchFeed() async {
    log('Fetching feed data for ${authCubit.currentUser!.uid}');
      final user = await cacheCubit.load(authCubit.currentUser!.uid);
      _following = user.following;
      await postCubit.fetchFeedPostsByUserIds(_following);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocBuilder<PostCubit, PostState>(
        builder: (context, state) {
          if (state is ProfilePostsLoaded){
              _loadAndFetchFeed();
          }
          if (state is FeedPostsLoaded) {
            final posts = state.posts;
            final authorIds = posts.map((p) => p.ownerId).toSet().toList();
            cacheCubit.loadBatch(authorIds);
            if (posts.isEmpty) {
              return RefreshIndicator(
                onRefresh: () async {
                  final user = await cacheCubit.load(
                    authCubit.currentUser!.uid,
                  );
                  await postCubit.fetchFeedPostsByUserIds(user.following);
                },
                child: const _EmptyPostsIndicator(),
              );
            } else {
              return RefreshIndicator(
                onRefresh: () async {
                  final user = await cacheCubit.load(
                    authCubit.currentUser!.uid,
                  );
                  await postCubit.fetchFeedPostsByUserIds(user.following);
                },
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  physics: const AlwaysScrollableScrollPhysics(),
                  itemCount: posts.length,
                  itemBuilder: (context, index) {
                    final post = posts[index];
                    return _PostCardWithAuthor(post: post);
                  },
                ),
              );
            }
          } else if (state is PostError) {
            return Center(child: Text(state.message));
          } else {
            return const Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
  }
}

class _PostCardWithAuthor extends StatelessWidget {
  final Post post;

  const _PostCardWithAuthor({required this.post});

  @override
  Widget build(BuildContext context) {
    final cache = context.watch<ProfileCacheCubit>();
    final author = cache.state[post.ownerId];

    if (author == null) {
      return const _PostCardSkeleton();
    }

    return PostCard(post: post, author: author);
  }
}

class _PostCardSkeleton extends StatelessWidget {
  const _PostCardSkeleton();

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: const SizedBox(
        height: 320,
        child: Center(child: CircularProgressIndicator()),
      ),
    );
  }
}

class _EmptyPostsIndicator extends StatelessWidget {
  const _EmptyPostsIndicator();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.post_add_outlined,
              size: 64,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 16),
            Text(
              'No posts yet. Pull down to refresh or create your first post!',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }
}
