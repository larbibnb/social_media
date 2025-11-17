import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:social_media/features/auth/presentation/cubits/auth_cubit.dart';
import 'package:social_media/features/post/domain/entity/post.dart';
import 'package:social_media/features/post/presentation/components/post_card.dart';
import 'package:social_media/features/post/presentation/cubits/post_cubit/post_cubit.dart';
import 'package:social_media/features/post/presentation/cubits/post_cubit/post_state.dart';
import 'package:social_media/features/profile/domain/entities/profile_user.dart';
import 'package:social_media/features/profile/presentation/cubit/profile_cubite.dart';

class FeedView extends StatefulWidget {
  const FeedView({super.key});

  @override
  State<FeedView> createState() => _FeedViewState();
}

class _FeedViewState extends State<FeedView> {
  late final PostCubit postCubit;
  late final ProfileCubit profileCubit;
  late final AuthCubit authCubit;
  List<String> _following = [];

  // final List<Post> _feedPosts = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    postCubit = context.read<PostCubit>();
    profileCubit = context.read<ProfileCubit>();
    authCubit = context.read<AuthCubit>();
    profileCubit
        .getProfileUser(authCubit.currentUser!.uid, emitState: false)
        .then((user) {
          if (user != null) {
            _following = user.following;
            if (_following.isNotEmpty) {
              postCubit.fetchFeedPostsByUserIds(_following);
            }
          }
        })
        .catchError((e) {
          // ignore — PostCubit will remain in initial state; optionally show error
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocBuilder<PostCubit, PostState>(
        builder: (context, state) {
          if (state is PostsLoaded) {
            final posts = state.posts;
            if (posts.isEmpty) {
              return RefreshIndicator(
                onRefresh:
                    () => profileCubit
                        .getProfileUser(
                          authCubit.currentUser!.uid,
                          emitState: false,
                        )
                        .then((user) {
                          postCubit.fetchFeedPostsByUserIds(user!.following);
                        }),
                child: const _EmptyPostsIndicator(),
              );
            } else {
              return RefreshIndicator(
                onRefresh:
                    () => profileCubit
                        .getProfileUser(
                          authCubit.currentUser!.uid,
                          emitState: false,
                        )
                        .then((user) {
                          postCubit.fetchFeedPostsByUserIds(user!.following);
                        }),
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

class _PostCardWithAuthor extends StatefulWidget {
  final Post post;

  const _PostCardWithAuthor({required this.post});

  @override
  State<_PostCardWithAuthor> createState() => _PostCardWithAuthorState();
}

class _PostCardWithAuthorState extends State<_PostCardWithAuthor> {
  late final Future<ProfileUser?> _authorFuture;

  @override
  void initState() {
    super.initState();
    // Use emitState: false so fetching the author for a post does not
    // modify the global ProfileCubit's UI state (prevents profile view reload loops).
    _authorFuture = context.read<ProfileCubit>().getProfileUser(
      widget.post.ownerId,
      emitState: false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<ProfileUser?>(
      future: _authorFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const _PostCardSkeleton();
        }

        if (snapshot.hasError) {
          return Card(
            margin: const EdgeInsets.symmetric(vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                'Failed to load author information.',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
          );
        }

        final author =
            snapshot.data ??
            ProfileUser(
              uid: widget.post.ownerId,
              displayName: 'Unknown user',
              email: 'unknown@social.media',
              userName: 'unknown',
              gender: null,
              createdAt: '',
              profilePicUrl: null,
              bio: null,
              followers: [],
              following: [],
            );

        return PostCard(post: widget.post, author: author);
      },
    );
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
