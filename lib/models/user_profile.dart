class UserProfile {
  final String id;
  final String firstName;
  final String lastName;
  final String email;
  final String avatarUrl;
  final int stamps;
  final int totalStamps;
  final String memberSince;
  final String loyaltyTier;

  const UserProfile({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.avatarUrl,
    required this.stamps,
    this.totalStamps = 9,
    required this.memberSince,
    this.loyaltyTier = 'Gold',
  });

  String get fullName => '$firstName $lastName';
  bool get hasFreeCoffee => stamps >= totalStamps;
  int get stampsRemaining => totalStamps - stamps;
}
