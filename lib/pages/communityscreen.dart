import 'package:flutter/material.dart';

class CommunityScreen extends StatefulWidget {
  const CommunityScreen({Key? key}) : super(key: key);

  @override
  State<CommunityScreen> createState() => _CommunityScreenState();
}

class _CommunityScreenState extends State<CommunityScreen> {
  final List<Map<String, dynamic>> communityPosts = [
    {
      'id': '1',
      'username': 'Alex_Manga',
      'timeAgo': '2h ago',
      'avatar': 'AM',
      'avatarColor': Color(0xFFEF4444),
      'content':
          'Just finished Attack on Titan! What an emotional rollercoaster 😭 The ending was perfect',
      'likes': 24,
      'replies': 8,
      'reposts': 3,
    },
    {
      'id': '2',
      'username': 'MangaQueen',
      'timeAgo': '4h ago',
      'avatar': 'MQ',
      'avatarColor': Color(0xFFA855F7),
      'content':
          'Looking for romance manga recommendations! Something similar to Horimiya 🥰',
      'likes': 15,
      'replies': 12,
      'reposts': 2,
    },
    {
      'id': '3',
      'username': 'NovelReader92',
      'timeAgo': '6h ago',
      'avatar': 'NR',
      'avatarColor': Color(0xFF3B82F6),
      'content':
          'Just started reading Jujutsu Kaisen and I\'m already hooked! Why didn\'t anyone tell me about this masterpiece sooner? 🔥',
      'likes': 42,
      'replies': 18,
      'reposts': 7,
    },
    {
      'id': '4',
      'username': 'MangArtist',
      'timeAgo': '8h ago',
      'avatar': 'MA',
      'avatarColor': Color(0xFFEC4899),
      'content':
          'Just shared my fan art of Tanjiro! Check it out and let me know what you think 🎨',
      'likes': 89,
      'replies': 25,
      'reposts': 12,
    },
    {
      'id': '5',
      'username': 'AnimeDaily',
      'timeAgo': '10h ago',
      'avatar': 'AD',
      'avatarColor': Color(0xFFF97316),
      'content':
          'New manga series alert! The latest chapters are absolutely insane. The plot twist caught everyone off guard 🤯',
      'likes': 156,
      'replies': 45,
      'reposts': 34,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A1A),
      body: CustomScrollView(
        slivers: [
          // App bar
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
            actions: [
              IconButton(
                icon: const Icon(
                  Icons.notifications_outlined,
                  color: Colors.white70,
                ),
                onPressed: () {},
              ),
            ],
          ),

          // Community posts
          SliverList(
            delegate: SliverChildBuilderDelegate((context, index) {
              final post = communityPosts[index];
              return _buildPostCard(context, post);
            }, childCount: communityPosts.length),
          ),

          SliverToBoxAdapter(
            child: SizedBox(height: MediaQuery.of(context).padding.bottom + 16),
          ),
        ],
      ),
    );
  }

  Widget _buildPostCard(BuildContext context, Map<String, dynamic> post) {
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
            // Post header (avatar, username, time)
            Row(
              children: [
                // Avatar
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [
                        post['avatarColor'],
                        post['avatarColor'].withOpacity(0.7),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      post['avatar'],
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),

                // Username and time
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        post['username'],
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        post['timeAgo'],
                        style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                      ),
                    ],
                  ),
                ),

                // More options button
                IconButton(
                  icon: Icon(Icons.more_horiz, color: Colors.grey[600]),
                  onPressed: () {},
                  constraints: const BoxConstraints(),
                  padding: EdgeInsets.zero,
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Post content
            Text(
              post['content'],
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
                  _buildEngagementStat('${post['likes']}', 'Likes'),
                  _buildEngagementStat('${post['replies']}', 'Replies'),
                  _buildEngagementStat('${post['reposts']}', 'Reposts'),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Action buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildActionButton(Icons.favorite_border, 'Like'),
                _buildActionButton(Icons.chat_bubble_outline, 'Reply'),
                _buildActionButton(Icons.repeat, 'Repost'),
                _buildActionButton(Icons.share_outlined, 'Share'),
              ],
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

  Widget _buildActionButton(IconData icon, String label) {
    return GestureDetector(
      onTap: () {},
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 20, color: Colors.grey[500]),
          const SizedBox(height: 4),
          Text(label, style: TextStyle(fontSize: 11, color: Colors.grey[500])),
        ],
      ),
    );
  }
}
