class SocialPost {
  final String id;
  final String userName;
  final String userAvatar;
  final String message;
  final DateTime timestamp;
  final String branchName;
  final int likes;
  final bool isCheckedIn;
  final String? mood;

  const SocialPost({
    required this.id,
    required this.userName,
    required this.userAvatar,
    required this.message,
    required this.timestamp,
    required this.branchName,
    this.likes = 0,
    this.isCheckedIn = true,
    this.mood,
  });

  String get timeAgo {
    final now = DateTime.now();
    final diff = now.difference(timestamp);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }
}
