import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../models/social_post.dart';

class SocialPostCard extends StatelessWidget {
  final SocialPost post;

  const SocialPostCard({super.key, required this.post});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // User row
          Row(
            children: [
              _buildAvatar(),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          post.userName,
                          style: AppTextStyles.subtitle1.copyWith(fontSize: 14),
                        ),
                        if (post.isCheckedIn) ...[
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.location_on_rounded,
                                  size: 10,
                                  color: AppColors.primary,
                                ),
                                const SizedBox(width: 2),
                                Text(
                                  'Here',
                                  style: AppTextStyles.label.copyWith(
                                    color: AppColors.primary,
                                    fontSize: 9,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      post.timeAgo,
                      style: AppTextStyles.caption.copyWith(fontSize: 11),
                    ),
                  ],
                ),
              ),
              if (post.mood != null)
                Text(post.mood!, style: const TextStyle(fontSize: 22)),
            ],
          ),
          const SizedBox(height: 12),
          // Message
          Text(
            post.message,
            style: AppTextStyles.body1.copyWith(fontSize: 14, height: 1.4),
          ),
          const SizedBox(height: 12),
          // Action row
          Row(
            children: [
              _buildActionChip(Icons.favorite_border_rounded, '${post.likes}'),
              const SizedBox(width: 16),
              _buildActionChip(Icons.chat_bubble_outline_rounded, 'Reply'),
              const Spacer(),
              Icon(
                Icons.more_horiz_rounded,
                size: 20,
                color: AppColors.textTertiary,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAvatar() {
    // Generate a color from username
    final colorIndex = post.userName.hashCode % _avatarColors.length;
    final bgColor = _avatarColors[colorIndex.abs()];
    final initials = post.userName.split(' ').map((n) => n[0]).take(2).join();

    return Container(
      width: 42,
      height: 42,
      decoration: BoxDecoration(
        color: bgColor,
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Text(
          initials,
          style: AppTextStyles.subtitle1.copyWith(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _buildActionChip(IconData icon, String label) {
    return Row(
      children: [
        Icon(icon, size: 18, color: AppColors.textTertiary),
        const SizedBox(width: 4),
        Text(
          label,
          style: AppTextStyles.caption.copyWith(fontSize: 12),
        ),
      ],
    );
  }

  static const _avatarColors = [
    Color(0xFF5C6BC0),
    Color(0xFF26A69A),
    Color(0xFFEF5350),
    Color(0xFFAB47BC),
    Color(0xFF42A5F5),
    Color(0xFFFF7043),
    Color(0xFF66BB6A),
    Color(0xFFEC407A),
  ];
}
