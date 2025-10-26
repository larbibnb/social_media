import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart' as intl;
import 'package:social_media/features/auth/presentation/cubits/auth_cubit.dart';
import 'package:social_media/features/post/domain/entity/comment.dart';
import 'package:social_media/features/post/domain/entity/post.dart';
import 'package:social_media/features/post/presentation/cubits/post_cubit/post_cubit.dart';
import 'package:social_media/features/profile/domain/entities/profile_user.dart';
import 'package:social_media/features/profile/presentation/cubit/profile_cubite.dart';
import 'package:social_media/features/profile/presentation/cubit/profile_state.dart';

class PostCard extends StatefulWidget {
  final Post post;
  final ProfileUser author;
  final VoidCallback? onShare;
  final VoidCallback? onMenuTap;

  const PostCard({
    super.key,
    required this.post,
    required this.author,
    this.onShare,
    this.onMenuTap,
  });

  @override
  State<PostCard> createState() => _PostCardState();
}

class _PostCardState extends State<PostCard>
    with AutomaticKeepAliveClientMixin<PostCard> {
  static const int _compactCommentCount = 2;
  bool _showAllComments = false;
  final TextEditingController _commentController = TextEditingController();

  AuthCubit get _authCubit => context.read<AuthCubit>();
  PostCubit get _postCubit => context.read<PostCubit>();
  ProfileCubit get _profileCubit => context.read<ProfileCubit>();
  String get _currentUserId => _authCubit.currentUser?.uid ?? '';

  @override
  bool get wantKeepAlive => true;

  void _toggleComments() {
    setState(() => _showAllComments = !_showAllComments);
    if (_showAllComments) {
      _showCommentsSheet();
    }
  }

  void _onLike() {
    if (!widget.post.likes.contains(_currentUserId)) {
      _postCubit.likePost(widget.post.id, _currentUserId);
    } else {
      _postCubit.unlikePost(widget.post.id, _currentUserId);
    }
  }

  void _onComment() {
    final currentUser = _authCubit.currentUser;
    if (currentUser != null) {
      final comment = _commentController.text.trim();
      if (comment.isNotEmpty) {
        _postCubit.commentPost(
          widget.post.id,
          currentUser.uid,
          currentUser.name,
          comment,
        );
        _commentController.clear();
        setState(() => _showAllComments = false);
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('You must be logged in to comment.')),
      );
    }
  }

  void _showLikesSheet() {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        if (widget.post.likes.isEmpty) {
          return Padding(
            padding: EdgeInsets.only(
              left: 16,
              right: 16,
              bottom: MediaQuery.of(context).viewInsets.bottom + 16,
              top: 24,
            ),
            child: const _EmptyState(message: 'No likes yet'),
          );
        }
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.favorite, color: Colors.redAccent),
                  const SizedBox(width: 8),
                  Text(
                    'Liked by ${widget.post.likes.length} people',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Flexible(
                child: ListView.separated(
                  shrinkWrap: true,
                  itemCount: widget.post.likes.length,
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final likerId = widget.post.likes[index];
                    return BlocProvider.value(
                      value: _profileCubit,
                      child: _UserTile(userId: likerId),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showCommentsSheet() {
    final comments = widget.post.comments;
    if (!_showAllComments && comments.length <= _compactCommentCount) {
      return;
    }
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        if (widget.post.comments.isEmpty) {
          return Padding(
            padding: EdgeInsets.only(
              left: 16,
              right: 16,
              bottom: MediaQuery.of(context).viewInsets.bottom + 16,
              top: 24,
            ),
            child: const _EmptyState(message: 'No comments yet'),
          );
        }
        return Padding(
          padding: EdgeInsets.only(
            left: 16,
            right: 16,
            bottom: MediaQuery.of(context).viewInsets.bottom + 16,
            top: 24,
          ),
          child: _CommentsList(comments: comments),
        );
      },
    ).then((value) {
      setState(() => _showAllComments = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final theme = Theme.of(context);
    final post = widget.post;
    final author = widget.author;

    return Card(
      clipBehavior: Clip.hardEdge,
      margin: const EdgeInsets.symmetric(vertical: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      elevation: 6,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _PostHeader(
            author: author,
            timestamp: post.timestamp,
            onMenuTap: widget.onMenuTap,
          ),
          if (post.description.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Text(post.description, style: theme.textTheme.bodyLarge),
            ),
          if (post.images.isNotEmpty) _PostImageCarousel(images: post.images),
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16,
            ).copyWith(bottom: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _PostActions(
                  onLike: _onLike,
                  isLiked: post.likes.contains(_currentUserId),
                  likeCount: post.likes.length,
                  commentCount: post.comments.length,
                  showComments: _toggleComments,
                  onShare: widget.onShare,
                  onLikesTap: _showLikesSheet,
                ),
                const SizedBox(height: 8),
                if (post.likes.isNotEmpty)
                  GestureDetector(
                    onTap: _showLikesSheet,
                    child: Text(
                      _buildLikesLabel(post.likes.length),
                      style: theme.textTheme.labelLarge?.copyWith(
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                const SizedBox(height: 8),
                _buildCommentsSection(post.comments, _onComment, theme),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCommentsSection(
    List<Comment> comments,
    VoidCallback onComment,
    ThemeData theme,
  ) {
    final visibleComments = comments.take(_compactCommentCount).toList();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: _commentController,
          decoration: InputDecoration(
            border: OutlineInputBorder(borderSide: BorderSide.none),
            hintText: 'Add a comment...',
            suffixIcon: IconButton(
              icon: const Icon(Icons.add_comment_outlined),
              onPressed: onComment,
            ),
          ),
        ),
        const Divider(height: 16),
        ...visibleComments.map(
          (comment) => Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: BlocProvider.value(
              value: _profileCubit,
              child: _CommentTile(comment: comment),
            ),
          ),
        ),
        if (comments.length > _compactCommentCount)
          TextButton(
            onPressed:
                comments.isEmpty
                    ? null
                    : (_showAllComments ? _toggleComments : _showCommentsSheet),
            child: Text(
              _showAllComments
                  ? 'Show fewer comments'
                  : 'View all ${comments.length} comments',
              style: theme.textTheme.labelLarge,
            ),
          ),
      ],
    );
  }

  String _buildLikesLabel(int likeCount) {
    if (likeCount == 1) return 'Liked by 1 person';
    if (likeCount < 1000) return 'Liked by $likeCount people';
    final formatter = intl.NumberFormat.compact();
    return 'Liked by ${formatter.format(likeCount)} people';
  }
}

class _PostHeader extends StatelessWidget {
  final ProfileUser author;
  final DateTime timestamp;
  final VoidCallback? onMenuTap;

  const _PostHeader({
    required this.author,
    required this.timestamp,
    this.onMenuTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final formattedDate = intl.DateFormat('MMM d • h:mm a').format(timestamp);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: theme.colorScheme.surfaceContainerHighest,
            backgroundImage:
                author.profilePicUrl != null
                    ? CachedNetworkImageProvider(author.profilePicUrl!)
                    : null,
            child:
                author.profilePicUrl == null
                    ? Text(author.name.characters.first.toUpperCase())
                    : null,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  author.name,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  formattedDate,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          IconButton(icon: const Icon(Icons.more_vert), onPressed: onMenuTap),
        ],
      ),
    );
  }
}

class _PostActions extends StatelessWidget {
  final bool isLiked;
  final int likeCount;
  final int commentCount;
  final VoidCallback? onLike;
  final VoidCallback? showComments;
  final VoidCallback? onShare;
  final VoidCallback? onLikesTap;

  const _PostActions({
    required this.isLiked,
    required this.likeCount,
    required this.commentCount,
    this.onLike,
    this.showComments,
    this.onShare,
    this.onLikesTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        IconButton(
          icon: Icon(
            isLiked ? Icons.favorite : Icons.favorite_border,
            color: isLiked ? Colors.redAccent : theme.iconTheme.color,
          ),
          onPressed: onLike,
        ),
        GestureDetector(
          onTap: onLikesTap,
          child: Text(
            intl.NumberFormat.compact().format(likeCount),
            style: theme.textTheme.labelLarge,
          ),
        ),
        const SizedBox(width: 16),
        IconButton(
          icon: const Icon(Icons.chat_bubble_outline),
          onPressed: showComments,
        ),
        Text(
          intl.NumberFormat.compact().format(commentCount),
          style: theme.textTheme.labelLarge,
        ),
        const SizedBox(width: 16),
        IconButton(icon: const Icon(Icons.share_outlined), onPressed: onShare),
      ],
    );
  }
}

class _PostImageCarousel extends StatefulWidget {
  final List<String> images;
  const _PostImageCarousel({required this.images});

  @override
  State<_PostImageCarousel> createState() => _PostImageCarouselState();
}

class _PostImageCarouselState extends State<_PostImageCarousel> {
  late final PageController _controller;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _controller = PageController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final images = widget.images;
    return Column(
      children: [
        SizedBox(
          height: 300,
          width: double.infinity,
          child: PageView.builder(
            controller: _controller,
            itemCount: images.length,
            onPageChanged: (page) => setState(() => _currentPage = page),
            itemBuilder: (context, index) {
              final imageUrl = images[index];
              return CachedNetworkImage(
                imageUrl: imageUrl,
                fit: BoxFit.cover,
                placeholder:
                    (context, url) =>
                        const Center(child: CircularProgressIndicator()),
                errorWidget:
                    (context, url, error) =>
                        const Center(child: Icon(Icons.broken_image, size: 48)),
              );
            },
          ),
        ),
        if (images.length > 1)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: _CarouselIndicators(
              length: images.length,
              activeIndex: _currentPage,
            ),
          ),
      ],
    );
  }
}

class _CarouselIndicators extends StatelessWidget {
  final int length;
  final int activeIndex;

  const _CarouselIndicators({required this.length, required this.activeIndex});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(length, (index) {
        final isActive = index == activeIndex;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: isActive ? 10 : 8,
          height: isActive ? 10 : 8,
          decoration: BoxDecoration(
            color: isActive ? Colors.blueAccent : Colors.grey.shade400,
            shape: BoxShape.circle,
          ),
        );
      }),
    );
  }
}

class _CommentTile extends StatefulWidget {
  final Comment comment;
  const _CommentTile({required this.comment});

  @override
  State<_CommentTile> createState() => _CommentTileState();
}

class _CommentTileState extends State<_CommentTile> {
  late final Future<ProfileUser?> _userFuture;

  @override
  void initState() {
    super.initState();
    _userFuture = context.read<ProfileCubit>().getProfileUser(
      widget.comment.ownerId,
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<ProfileUser?>(
      future: _userFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const _CommentSkeleton();
        }
        final user = snapshot.data;
        return _CommentContent(
          username: user?.name ?? 'Unknown User',
          profilePicUrl: user?.profilePicUrl,
          description: widget.comment.description,
          timeStamp: widget.comment.timestamp,
        );
      },
    );
  }
}

class _CommentContent extends StatelessWidget {
  final String username;
  final String? profilePicUrl;
  final String description;
  final DateTime timeStamp;

  const _CommentContent({
    required this.username,
    required this.profilePicUrl,
    required this.description,
    required this.timeStamp,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CircleAvatar(
          radius: 16,
          backgroundImage:
              profilePicUrl != null
                  ? CachedNetworkImageProvider(profilePicUrl!)
                  : null,
          child:
              profilePicUrl == null
                  ? Text(username.characters.first.toUpperCase())
                  : null,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                username,
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              Text(description, style: theme.textTheme.bodyMedium),
              const SizedBox(height: 8),
              Text(
                intl.DateFormat('MMM d • h:mm a').format(timeStamp),
                style: theme.textTheme.bodySmall,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _CommentSkeleton extends StatelessWidget {
  const _CommentSkeleton();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const CircleAvatar(radius: 16, backgroundColor: Colors.grey),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: 12,
                width: 100,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
              const SizedBox(height: 6),
              Container(
                height: 12,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _CommentsList extends StatelessWidget {
  final List<Comment> comments;
  const _CommentsList({required this.comments});

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      shrinkWrap: true,
      itemCount: comments.length,
      separatorBuilder: (_, __) => const Divider(height: 16),
      itemBuilder: (context, index) {
        final comment = comments[index];
        return BlocProvider.value(
          value: context.read<ProfileCubit>(),
          child: _CommentTile(comment: comment),
        );
      },
    );
  }
}

class _EmptyState extends StatelessWidget {
  final String message;
  const _EmptyState({required this.message});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.inbox_outlined, size: 48, color: theme.disabledColor),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                message,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _UserTile extends StatefulWidget {
  final String userId;
  const _UserTile({required this.userId});

  @override
  State<_UserTile> createState() => _UserTileState();
}

class _UserTileState extends State<_UserTile> {
  late final Future<ProfileUser?> _userFuture;

  @override
  void initState() {
    super.initState();
    _userFuture = context.read<ProfileCubit>().getProfileUser(widget.userId);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<ProfileUser?>(
      future: _userFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const ListTile(
            leading: CircleAvatar(backgroundColor: Colors.grey),
            title: SizedBox(
              height: 12,
              child: DecoratedBox(
                decoration: BoxDecoration(color: Colors.grey),
              ),
            ),
          );
        }

        final profileUser = snapshot.data;
        if (profileUser == null || snapshot.hasError) {
          return const ListTile(
            leading: CircleAvatar(child: Icon(Icons.error)),
            title: Text('Unknown user'),
            subtitle: Text('Could not load user details'),
          );
        }

        return ListTile(
          leading: CircleAvatar(
            backgroundImage:
                profileUser.profilePicUrl != null
                    ? CachedNetworkImageProvider(profileUser.profilePicUrl!)
                    : null,
            child:
                profileUser.profilePicUrl == null
                    ? Text(profileUser.name.characters.first.toUpperCase())
                    : null,
          ),
          title: Text(profileUser.name),
          subtitle: Text(profileUser.email),
        );
      },
    );
  }
}
