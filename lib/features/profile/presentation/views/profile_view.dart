import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:social_media/features/auth/presentation/cubits/auth_cubit.dart';
import 'package:social_media/features/post/domain/entity/post.dart';
import 'package:social_media/features/post/presentation/components/post_card.dart';
import 'package:social_media/features/post/presentation/cubits/post_cubit/post_cubit.dart';
import 'package:social_media/features/post/presentation/cubits/post_cubit/post_state.dart';
import 'package:social_media/features/profile/domain/entities/profile_user.dart';
import 'package:social_media/features/profile/presentation/cubit/profile_cubite.dart';
import 'package:social_media/features/profile/presentation/cubit/profile_state.dart';
import 'package:social_media/features/profile/presentation/views/edit_profile_view.dart';

class ProfileView extends StatefulWidget {
  final String uid;
  const ProfileView({super.key, required this.uid});

  @override
  State<ProfileView> createState() => _ProfileViewState();
}

class _ProfileViewState extends State<ProfileView>
    with SingleTickerProviderStateMixin {
  late TabController tabBarController;
  late final AuthCubit authCubit;
  late final ProfileCubit profileCubit;
  late final PostCubit postCubit;
  List<Post> _profilePosts = [];

  @override
  void initState() {
    super.initState();
    authCubit = context.read<AuthCubit>();
    profileCubit = context.read<ProfileCubit>();
    postCubit = context.read<PostCubit>();
    profileCubit.getProfileUser(widget.uid);
    // Fetch profile posts without mutating the global PostCubit's state
    postCubit.fetchPostsByUserId(widget.uid).then((posts) {
      setState(() {
        _profilePosts = posts;
      });
    });
    tabBarController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    tabBarController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProfileCubit, ProfileState>(
      builder: (context, state) {
        if (state is ProfileLoading || state is ProfileInitial) {
          return Scaffold(body: Center(child: CircularProgressIndicator()));
        } else if (state is ProfileError) {
          return Scaffold(body: Center(child: Text(state.error)));
        } else if (state is ProfileLoaded) {
          final currentUser = authCubit.currentUser;
          final profileUser = state.profileUser;
          final isCurrentUser = profileUser.uid == currentUser!.uid;
          bool isFollowing = profileUser.followers.contains(currentUser.uid);
          return Scaffold(
            body: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 25),
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      _ProfileHeader(profileUser: profileUser),
                      _ActionButton(
                        isCurrentUser: isCurrentUser,
                        isFollowing: isFollowing,
                        onTap: () {
                          if (isCurrentUser) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder:
                                    (context) =>
                                        EditProfileView(user: profileUser),
                              ),
                            );
                          } else {
                            context.read<ProfileCubit>().toggleFollowUser(
                              currentUser.uid,
                              profileUser.uid,
                            );
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  isFollowing
                                      ? 'Unfollowing ${profileUser.displayName}'
                                      : 'Following ${profileUser.displayName}',
                                ),
                              ),
                            );
                          }
                        },
                      ),
                      SizedBox(height: 20),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Bio',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      SizedBox(height: 10),
                      SizedBox(
                        child:
                            isCurrentUser
                                ? Align(
                                  alignment: Alignment.centerLeft,
                                  child: Text(
                                    profileUser.bio ??
                                        'what best describes you  ...',
                                  ),
                                )
                                : Text(
                                  profileUser.bio ?? '',
                                  overflow: TextOverflow.fade,
                                ),
                      ),
                      SizedBox(height: 20),
                      Wrap(
                        spacing: 10,
                        runSpacing: 10,
                        children: [
                          ...profileUser.interests.map(
                            (interest) => _InfoChip(
                              label: interest,
                              icon: Icons.favorite,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 20),
                      BlocBuilder<PostCubit, PostState>(
                        builder: (context, postState) {
                          final profilePosts = _profilePosts;
                          return Column(
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  _StatCard(
                                    profileUser: profileUser,
                                    postsCount: profilePosts.length,
                                    label: 'Following',
                                  ),
                                  _StatCard(
                                    profileUser: profileUser,
                                    postsCount: profilePosts.length,
                                    label: 'Followers',
                                  ),
                                  _StatCard(
                                    profileUser: profileUser,
                                    postsCount: profilePosts.length,
                                    label: 'Posts',
                                  ),
                                ],
                              ),
                              SizedBox(height: 20),
                              TabBar(
                                controller: tabBarController,
                                tabs: [
                                  Tab(text: 'Posts'),
                                  Tab(text: 'Collections'),
                                ],
                              ),
                              SizedBox(height: 20),
                              SizedBox(
                                height: 800,
                                child: TabBarView(
                                  physics: const NeverScrollableScrollPhysics(),
                                  controller: tabBarController,
                                  children: [
                                    ListView.builder(
                                      shrinkWrap: true,
                                      // Allow the list to scroll within the SingleChildScrollView
                                      physics: const BouncingScrollPhysics(),
                                      itemBuilder:
                                          (context, index) => PostCard(
                                            author: profileUser,
                                            post: profilePosts[index],
                                          ),
                                      itemCount: profilePosts.length,
                                    ),
                                    Center(child: Text('Collections')),
                                  ],
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        } else {
          return Scaffold(body: Center(child: Text('Something went wrong.')));
        }
      },
    );
  }
}

// -- Reusable private widgets for a softer/profile UI --

class _ProfileHeader extends StatelessWidget {
  final ProfileUser profileUser;
  const _ProfileHeader({required this.profileUser});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child:
                profileUser.profilePicUrl != null
                    ? CachedNetworkImage(
                      imageUrl: profileUser.profilePicUrl!,
                      width: 120,
                      height: 120,
                      fit: BoxFit.cover,
                      placeholder:
                          (c, u) => SizedBox(
                            width: 120,
                            height: 120,
                            child: Center(child: CircularProgressIndicator()),
                          ),
                      errorWidget:
                          (c, u, e) => Container(
                            width: 120,
                            height: 120,
                            color: Colors.grey.shade200,
                            child: Icon(Icons.error),
                          ),
                    )
                    : Container(
                      width: 120,
                      height: 120,
                      color: Colors.grey.shade200,
                      child: Center(
                        child: Text(
                          profileUser.displayName!.characters.first
                              .toUpperCase(),
                          style: TextStyle(fontSize: 36),
                        ),
                      ),
                    ),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  profileUser.displayName!,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  profileUser.email,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Joined in ${profileUser.createdAt}',
                  style: theme.textTheme.bodySmall,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final bool isCurrentUser;
  final bool isFollowing;
  final VoidCallback? onTap;
  const _ActionButton({
    required this.isCurrentUser,
    required this.isFollowing,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 52,
        width: double.infinity,
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color:
              isCurrentUser
                  ? Theme.of(context).colorScheme.primary
                  : Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 8,
              offset: Offset(0, 6),
            ),
          ],
          border: Border.all(color: Colors.transparent),
        ),
        child: Center(
          child: Text(
            isCurrentUser
                ? 'Edit Profile'
                : (isFollowing ? 'Unfollow' : 'Follow'),
            style: TextStyle(
              color:
                  isCurrentUser
                      ? Colors.white
                      : Theme.of(context).colorScheme.primary,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final String label;
  final IconData icon;
  const _InfoChip({required this.label, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 46,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18, color: Theme.of(context).colorScheme.primary),
          const SizedBox(width: 8),
          Text(label, style: Theme.of(context).textTheme.bodyMedium),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final ProfileUser profileUser;
  final int postsCount;
  final String label;
  const _StatCard({
    required this.profileUser,
    required this.postsCount,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        height: 100,
        margin: const EdgeInsets.symmetric(horizontal: 6),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 8,
              offset: Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextButton(
              onPressed: () {},
              child: Text(
                label == 'Following'
                    ? profileUser.following.length.toString()
                    : label == 'Followers'
                    ? profileUser.followers.length.toString()
                    : postsCount.toString(),
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 6),
            Text(label, style: Theme.of(context).textTheme.bodySmall),
          ],
        ),
      ),
    );
  }
}
