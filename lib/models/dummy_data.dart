import 'user_profile.dart';
import 'transaction.dart';
import 'store_location.dart';
import 'social_post.dart';
import 'treat_item.dart';

class DummyData {
  // ── Current User ──
  static const currentUser = UserProfile(
    id: 'u001',
    firstName: 'Ahmet',
    lastName: 'Yılmaz',
    email: 'ahmet@vonalcoffee.com',
    avatarUrl: '',
    stamps: 5,
    totalStamps: 9,
    memberSince: 'Sep 2025',
    loyaltyTier: 'Gold',
  );

  // ── Store Locations ──
  static const stores = [
    StoreLocation(
      id: 's001',
      name: 'Vonal Coffee - Tatvan Sahil',
      address: 'Sahil Yolu Caddesi No:12',
      city: 'Tatvan, Bitlis',
      latitude: 38.5060,
      longitude: 42.2816,
      openingHours: '08:00',
      closingHours: '22:00',
      distance: '1.2 km',
      phoneNumber: '+90 434 827 1234',
      isOpen: true,
      amenities: ['Wi-Fi', 'Outdoor Seating', 'Power Outlets', 'Parking'],
    ),
    StoreLocation(
      id: 's002',
      name: 'Vonal Coffee - Tatvan Merkez',
      address: 'Cumhuriyet Caddesi No:45',
      city: 'Tatvan, Bitlis',
      latitude: 38.4980,
      longitude: 42.2850,
      openingHours: '07:30',
      closingHours: '23:00',
      distance: '3.5 km',
      phoneNumber: '+90 434 827 5678',
      isOpen: true,
      amenities: ['Wi-Fi', 'Indoor Seating', 'Power Outlets', 'Meeting Room'],
    ),
  ];

  // ── Transactions ──
  static final transactions = [
    Transaction(
      id: 't001',
      date: DateTime(2026, 1, 25),
      locationName: 'Vonal Coffee - Tatvan Sahil',
      itemName: 'Flat White',
      price: 170.00,
      stampsEarned: 1,
    ),
    Transaction(
      id: 't002',
      date: DateTime(2026, 1, 22),
      locationName: 'Vonal Coffee - Tatvan Merkez',
      itemName: 'Caramel Latte',
      price: 185.00,
      stampsEarned: 1,
    ),
    Transaction(
      id: 't003',
      date: DateTime(2026, 1, 18),
      locationName: 'Vonal Coffee - Tatvan Sahil',
      itemName: 'Espresso + Cheesecake',
      price: 290.00,
      stampsEarned: 2,
    ),
    Transaction(
      id: 't004',
      date: DateTime(2026, 1, 12),
      locationName: 'Vonal Coffee - Tatvan Sahil',
      itemName: 'Mocha',
      price: 175.00,
      stampsEarned: 1,
    ),
    Transaction(
      id: 't005',
      date: DateTime(2025, 12, 28),
      locationName: 'Vonal Coffee - Tatvan Merkez',
      itemName: 'Cappuccino',
      price: 160.00,
      stampsEarned: 1,
    ),
    Transaction(
      id: 't006',
      date: DateTime(2025, 12, 20),
      locationName: 'Vonal Coffee - Tatvan Sahil',
      itemName: 'Turkish Coffee + Baklava',
      price: 220.00,
      stampsEarned: 1,
      type: TransactionType.purchase,
    ),
  ];

  // ── Social Posts ──
  static final socialPosts = [
    SocialPost(
      id: 'p001',
      userName: 'Elif Kaya',
      userAvatar: '',
      message: 'Studying here for my finals! ☕📚 The atmosphere is perfect.',
      timestamp: DateTime.now().subtract(const Duration(minutes: 12)),
      branchName: 'Vonal Coffee - Tatvan Sahil',
      likes: 8,
      mood: '📚',
    ),
    SocialPost(
      id: 'p002',
      userName: 'Mehmet Demir',
      userAvatar: '',
      message: 'Anyone up for a chat? Sitting by the window 👋',
      timestamp: DateTime.now().subtract(const Duration(minutes: 35)),
      branchName: 'Vonal Coffee - Tatvan Sahil',
      likes: 3,
      mood: '💬',
    ),
    SocialPost(
      id: 'p003',
      userName: 'Zeynep Arslan',
      userAvatar: '',
      message: 'The new caramel latte is absolutely amazing! 🤤',
      timestamp: DateTime.now().subtract(const Duration(hours: 1)),
      branchName: 'Vonal Coffee - Tatvan Sahil',
      likes: 15,
      mood: '☕',
    ),
    SocialPost(
      id: 'p004',
      userName: 'Can Öztürk',
      userAvatar: '',
      message: 'Working remotely from Vonal today. Best WiFi in Tatvan!',
      timestamp: DateTime.now().subtract(const Duration(hours: 2)),
      branchName: 'Vonal Coffee - Tatvan Sahil',
      likes: 6,
      mood: '💻',
    ),
    SocialPost(
      id: 'p005',
      userName: 'Ayşe Yıldız',
      userAvatar: '',
      message: 'Catching up with old friends over Turkish coffee ❤️',
      timestamp: DateTime.now().subtract(const Duration(hours: 3)),
      branchName: 'Vonal Coffee - Tatvan Sahil',
      likes: 22,
      mood: '❤️',
    ),
  ];

  // ── Exclusive Treats ──
  static const treats = [
    TreatItem(
      id: 'tr001',
      title: 'Winter Mocha',
      subtitle: 'Rich cocoa meets bold espresso',
      imageEmoji: '☕',
      promoText: 'NEW',
    ),
    TreatItem(
      id: 'tr002',
      title: 'Caramel Crunch Latte',
      subtitle: 'Buttery caramel with crunchy bits',
      imageEmoji: '🍮',
      promoText: 'POPULAR',
    ),
    TreatItem(
      id: 'tr003',
      title: 'Matcha Mint Freeze',
      subtitle: 'Cooling matcha with fresh mint',
      imageEmoji: '🍵',
    ),
    TreatItem(
      id: 'tr004',
      title: 'Turkish Delight Latte',
      subtitle: 'Rose-flavored latte with lokum',
      imageEmoji: '🌹',
      promoText: 'LIMITED',
    ),
    TreatItem(
      id: 'tr005',
      title: 'Pistachio Flat White',
      subtitle: 'Creamy pistachio with double shot',
      imageEmoji: '🥜',
    ),
  ];
}
