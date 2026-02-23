class Transaction {
  final String id;
  final DateTime date;
  final String locationName;
  final String itemName;
  final double price;
  final String currency;
  final int stampsEarned;
  final TransactionType type;

  const Transaction({
    required this.id,
    required this.date,
    required this.locationName,
    required this.itemName,
    required this.price,
    this.currency = '₺',
    this.stampsEarned = 1,
    this.type = TransactionType.purchase,
  });

  String get formattedPrice => '$currency${price.toStringAsFixed(2)}';

  String get formattedDate {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }
}

enum TransactionType {
  purchase,
  reward,
  refund,
}
