import 'package:flutter/material.dart';
import '../models/post.dart';
import 'video_feed_player.dart';

class FeedPostItem extends StatelessWidget {
  final Post post;
  final bool isActive;

  const FeedPostItem({
    super.key,
    required this.post,
    required this.isActive,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        // Background
        const ColoredBox(color: Colors.black),

        // Media layer
        if (post.mediaType == 'video' && post.mediaUrl != null)
          VideoFeedPlayer(videoUrl: post.mediaUrl!, isActive: isActive)
        else if (post.mediaType == 'image' && post.mediaUrl != null)
          Image.network(
            post.mediaUrl!,
            fit: BoxFit.cover,
            width: double.infinity,
            height: double.infinity,
            errorBuilder: (_, __, ___) => const SizedBox.shrink(),
          )
        else if (post.content != null)
          Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Text(
                post.content!,
                style: const TextStyle(color: Colors.white, fontSize: 20),
                textAlign: TextAlign.center,
              ),
            ),
          ),

        // Gradient overlay at bottom
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: Container(
            height: 200,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.transparent, Colors.black54],
              ),
            ),
          ),
        ),

        // Author info (bottom left)
        Positioned(
          bottom: 80,
          left: 12,
          right: 80,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GestureDetector(
                onTap: () {
                  Navigator.pushNamed(
                    context,
                    '/staff-profile',
                    arguments: post.author.id,
                  );
                },
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 20,
                      backgroundColor: Colors.grey[700],
                      backgroundImage: post.author.avatarUrl != null
                          ? NetworkImage(post.author.avatarUrl!)
                          : null,
                      child: post.author.avatarUrl == null
                          ? Text(
                              post.author.name.isNotEmpty
                                  ? post.author.name[0].toUpperCase()
                                  : '?',
                              style: const TextStyle(color: Colors.white),
                            )
                          : null,
                    ),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        post.author.name,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              if (post.content != null && post.mediaUrl != null) ...[
                const SizedBox(height: 4),
                Text(
                  post.content!,
                  style: const TextStyle(color: Colors.white, fontSize: 13),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
              if (post.staffCategory != null) ...[
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.white24,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    post.staffCategory!,
                    style: const TextStyle(color: Colors.white, fontSize: 11),
                  ),
                ),
              ],
            ],
          ),
        ),

        // Action column (right side)
        Positioned(
          right: 8,
          bottom: 80,
          child: Column(
            children: [
              _ActionButton(
                icon: post.isLiked ? Icons.favorite : Icons.favorite_border,
                iconColor: post.isLiked ? Colors.red : Colors.white,
                label: '${post.likesCount}',
                onTap: () {}, // stub — FEED-03
              ),
              const SizedBox(height: 16),
              _ActionButton(
                icon: Icons.comment_outlined,
                label: '${post.commentsCount}',
                onTap: () {}, // stub — FEED-03
              ),
              const SizedBox(height: 16),
              _ActionButton(
                icon: Icons.share,
                label: '',
                onTap: () {}, // stub
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String label;
  final VoidCallback onTap;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
    this.iconColor = Colors.white,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Icon(icon, color: iconColor, size: 32),
          if (label.isNotEmpty)
            Text(
              label,
              style: const TextStyle(color: Colors.white, fontSize: 12),
            ),
        ],
      ),
    );
  }
}
