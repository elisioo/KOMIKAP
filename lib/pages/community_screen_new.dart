import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:komikap/state/firebase_providers.dart';
import 'package:komikap/pages/comments_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CommunityScreenNew extends ConsumerStatefulWidget {
  const CommunityScreenNew({super.key});

  @override
  ConsumerState<CommunityScreenNew> createState() => _CommunityScreenNewState();
}

class _CommunityScreenNewState extends ConsumerState<CommunityScreenNew> {
  final _postController = TextEditingController();
  bool _isPostingLoading = false;

  @override
  void dispose() {
    _postController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authStateProvider);
    // Watch posts with auto-refresh every 3 seconds for real-time updates
    final postsAsync = ref.watch(postsProvider);

    return authState.when(
      loading: () => const Scaffold(
        backgroundColor: Color(0xFF1A1A1A),
        body: Center(
          child: CircularProgressIndicator(color: Color(0xFFA855F7)),
        ),
      ),
      error: (error, stack) => Scaffold(
        backgroundColor: const Color(0xFF1A1A1A),
        appBar: AppBar(
          backgroundColor: const Color(0xFF1A1A1A),
          title: const Text('Community'),
          elevation: 0,
        ),
        body: Center(
          child: Text('Error: $error', style: const TextStyle(color: Colors.white)),
        ),
      ),
      data: (user) {
        if (user == null) {
          return Scaffold(
            backgroundColor: const Color(0xFF1A1A1A),
            appBar: AppBar(
              backgroundColor: const Color(0xFF1A1A1A),
              title: const Text('Community'),
              elevation: 0,
            ),
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.login, size: 64, color: Colors.grey[600]),
                  const SizedBox(height: 16),
                  const Text(
                    'Please login to access community',
                    style: TextStyle(color: Colors.white70),
                  ),
                ],
              ),
            ),
          );
        }

        return Scaffold(
          backgroundColor: const Color(0xFF1A1A1A),
          body: CustomScrollView(
            slivers: [
              // App Bar
              SliverAppBar(
                automaticallyImplyLeading: false,
                backgroundColor: const Color(0xFF1A1A1A),
                floating: true,
                elevation: 0,
                title: const Text(
                  'Community',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),

              // Create Post Section
              SliverToBoxAdapter(
                child: _buildCreatePostSection(context, user),
              ),

              // Posts List
              postsAsync.when(
                loading: () => SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        const CircularProgressIndicator(color: Color(0xFFA855F7)),
                        const SizedBox(height: 16),
                        const Text(
                          'Loading posts...',
                          style: TextStyle(color: Colors.white70),
                        ),
                      ],
                    ),
                  ),
                ),
                error: (error, stack) => SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text(
                      'Error loading posts: $error',
                      style: const TextStyle(color: Colors.red),
                    ),
                  ),
                ),
                data: (posts) {
                  if (posts.isEmpty) {
                    return SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Center(
                          child: Column(
                            children: [
                              Icon(Icons.chat_bubble_outline, size: 64, color: Colors.grey[600]),
                              const SizedBox(height: 16),
                              const Text(
                                'No posts yet',
                                style: TextStyle(color: Colors.white70),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }

                  return SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final post = posts[index];
                        return _buildPostCard(context, post, user.uid, ref);
                      },
                      childCount: posts.length,
                    ),
                  );
                },
              ),

              SliverToBoxAdapter(
                child: SizedBox(height: MediaQuery.of(context).padding.bottom + 16),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCreatePostSection(BuildContext context, User user) {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[800]!),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // User info
          Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: const Color(0xFFA855F7),
                child: Text(
                  user.email?.substring(0, 1).toUpperCase() ?? 'U',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user.displayName ?? 'User',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      user.email ?? '',
                      style: const TextStyle(color: Colors.white54, fontSize: 12),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Text field
          TextField(
            controller: _postController,
            maxLines: 4,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              hintText: 'What manga are you reading? Share your thoughts...',
              hintStyle: const TextStyle(color: Colors.white54),
              filled: true,
              fillColor: Colors.black26,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Colors.grey[700]!),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Colors.grey[700]!),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Color(0xFFA855F7)),
              ),
            ),
          ),

          const SizedBox(height: 12),

          // Post button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _isPostingLoading
                  ? null
                  : () => _createPost(user.uid, user.displayName ?? 'User', ref),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFA855F7),
                disabledBackgroundColor: Colors.grey[700],
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: _isPostingLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : const Text(
                      'Post',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPostCard(BuildContext context, dynamic post, String currentUserId, WidgetRef ref) {
    final isLiked = (post.likedBy ?? []).contains(currentUserId);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 0, vertical: 8),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Colors.white.withOpacity(0.1), width: 1),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Post header
            Row(
              children: [
                CircleAvatar(
                  radius: 22,
                  backgroundColor: const Color(0xFFA855F7),
                  child: Text(
                    post.username.substring(0, 1).toUpperCase(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        post.username,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        _formatTime(post.createdAt),
                        style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                      ),
                    ],
                  ),
                ),
                if (post.uid == currentUserId)
                  PopupMenuButton(
                    itemBuilder: (context) => [
                      PopupMenuItem(
                        child: const Text('Delete'),
                        onTap: () => _deletePost(post.id, ref),
                      ),
                    ],
                  ),
              ],
            ),

            const SizedBox(height: 12),

            // Post content
            Text(
              post.content,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.white,
                height: 1.5,
              ),
            ),

            const SizedBox(height: 16),

            // Engagement metrics
            Container(
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(color: Colors.white.withOpacity(0.1)),
                  bottom: BorderSide(color: Colors.white.withOpacity(0.1)),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildEngagementStat('${post.likesCount}', 'Likes'),
                  _buildEngagementStat('${post.commentsCount}', 'Comments'),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Action buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildActionButton(
                  isLiked ? Icons.favorite : Icons.favorite_border,
                  'Like',
                  isLiked ? Colors.red : Colors.grey[500],
                  () => _toggleLike(post.id, currentUserId, isLiked, ref),
                ),
                _buildActionButton(
                  Icons.chat_bubble_outline,
                  'Comment',
                  Colors.grey[500],
                  () => _showCommentDialog(context, post.id, currentUserId, ref),
                ),
                _buildActionButton(
                  Icons.share_outlined,
                  'Share',
                  Colors.grey[500],
                  () {},
                ),
              ],
            ),

            // Comments section
            if ((post.commentsCount ?? 0) > 0)
              Padding(
                padding: const EdgeInsets.only(top: 16),
                child: GestureDetector(
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => CommentsScreen(
                        postId: post.id,
                        postTitle: 'Post',
                        postContent: post.content,
                        postAuthor: post.username,
                      ),
                    ),
                  ),
                  child: Text(
                    'View ${post.commentsCount} comments',
                    style: const TextStyle(
                      color: Color(0xFFA855F7),
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildEngagementStat(String count, String label) {
    return Column(
      children: [
        Text(
          count,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 2),
        Text(label, style: TextStyle(fontSize: 11, color: Colors.grey[500])),
      ],
    );
  }

  Widget _buildActionButton(
    IconData icon,
    String label,
    Color? color,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 20, color: color),
          const SizedBox(height: 4),
          Text(label, style: TextStyle(fontSize: 11, color: color)),
        ],
      ),
    );
  }

  void _createPost(String uid, String username, WidgetRef ref) async {
    if (_postController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please write something')),
      );
      return;
    }

    setState(() => _isPostingLoading = true);

    try {
      final postsNotifier = ref.read(postsNotifierProvider.notifier);
      await postsNotifier.createPost(
        uid: uid,
        username: username,
        content: _postController.text,
      );

      _postController.clear();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Post created successfully!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      setState(() => _isPostingLoading = false);
    }
  }

  void _toggleLike(String postId, String uid, bool isLiked, WidgetRef ref) async {
    try {
      final postsNotifier = ref.read(postsNotifierProvider.notifier);
      if (isLiked) {
        await postsNotifier.unlikePost(postId, uid);
      } else {
        await postsNotifier.likePost(postId, uid);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  void _deletePost(String postId, WidgetRef ref) async {
    try {
      final postsNotifier = ref.read(postsNotifierProvider.notifier);
      await postsNotifier.deletePost(postId);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Post deleted')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  void _showCommentDialog(BuildContext context, String postId, String uid, WidgetRef ref) {
    final commentController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: const Text('Add Comment', style: TextStyle(color: Colors.white)),
        content: TextField(
          controller: commentController,
          maxLines: 3,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: 'Write your comment...',
            hintStyle: const TextStyle(color: Colors.white54),
            filled: true,
            fillColor: Colors.black26,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey[700]!),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: Colors.white70)),
          ),
          TextButton(
            onPressed: () async {
              if (commentController.text.isEmpty) return;

              try {
                final commentsNotifier = ref.read(
                  commentsNotifierProvider(postId).notifier,
                );
                await commentsNotifier.addComment(
                  uid: uid,
                  username: 'User',
                  content: commentController.text,
                );

                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Comment added!')),
                );
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Error: $e')),
                );
              }
            },
            child: const Text('Post', style: TextStyle(color: Color(0xFFA855F7))),
          ),
        ],
      ),
    );
  }


  String _formatTime(DateTime? date) {
    if (date == null) return 'Now';
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inMinutes < 1) return 'Now';
    if (difference.inMinutes < 60) return '${difference.inMinutes}m ago';
    if (difference.inHours < 24) return '${difference.inHours}h ago';
    if (difference.inDays < 7) return '${difference.inDays}d ago';
    return '${(difference.inDays / 7).floor()}w ago';
  }
}
