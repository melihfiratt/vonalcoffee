class TreatItem {
  final String id;
  final String title;
  final String subtitle;
  final String imageEmoji;
  final String? promoText;

  const TreatItem({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.imageEmoji,
    this.promoText,
  });
}
