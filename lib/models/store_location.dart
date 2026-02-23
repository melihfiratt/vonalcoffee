class StoreLocation {
  final String id;
  final String name;
  final String address;
  final String city;
  final double latitude;
  final double longitude;
  final String openingHours;
  final String closingHours;
  final String distance;
  final String phoneNumber;
  final bool isOpen;
  final List<String> amenities;

  const StoreLocation({
    required this.id,
    required this.name,
    required this.address,
    required this.city,
    required this.latitude,
    required this.longitude,
    required this.openingHours,
    required this.closingHours,
    required this.distance,
    required this.phoneNumber,
    this.isOpen = true,
    this.amenities = const [],
  });

  String get hoursDisplay => '$openingHours - $closingHours';
  String get fullAddress => '$address, $city';
}
