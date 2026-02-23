class Campaign {
  final String id;
  final String title;
  final String description;
  final String imageUrl;
  final DateTime? endDate;
  final DateTime? createdAt;
  final bool isActive;

  const Campaign({
    required this.id,
    required this.title,
    required this.description,
    this.imageUrl = '',
    this.endDate,
    this.createdAt,
    this.isActive = true,
  });

  bool get isExpired =>
      endDate != null && endDate!.isBefore(DateTime.now());
}
