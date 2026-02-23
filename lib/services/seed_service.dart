import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/dummy_data.dart';

class SeedService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  /// Call this ONCE to populate Firestore with dummy data
  Future<void> seedDatabase() async {
    final batch = _db.batch();

    // 1. Seed Stores
    for (var store in DummyData.stores) {
      final docRef = _db.collection('stores').doc(store.id);
      batch.set(docRef, {
        'name': store.name,
        'address': store.address,
        'city': store.city,
        'latitude': store.latitude,
        'longitude': store.longitude,
        'openingHours': store.openingHours,
        'closingHours': store.closingHours,
        'distance': store.distance,
        'phoneNumber': store.phoneNumber,
        'isOpen': store.isOpen,
        'amenities': store.amenities,
      });
    }

    // 2. Seed Treats
    for (var treat in DummyData.treats) {
      final docRef = _db.collection('treats').doc(treat.id);
      batch.set(docRef, {
        'title': treat.title,
        'subtitle': treat.subtitle,
        'imageEmoji': treat.imageEmoji,
        'promoText': treat.promoText,
      });
    }

    // 3. Seed Social Posts
    for (var post in DummyData.socialPosts) {
      final docRef = _db.collection('posts').doc(post.id);
      batch.set(docRef, {
        'userName': post.userName,
        'userAvatar': post.userAvatar,
        'message': post.message,
        'timestamp': Timestamp.fromDate(post.timestamp),
        'branchName': post.branchName,
        'likes': post.likes,
        'isCheckedIn': post.isCheckedIn,
        'mood': post.mood,
      });
    }

    await batch.commit();
    print('✅ Database Seeded Successfully');
  }

  /// Optional: Seed dummy transactions for a specific user
  Future<void> seedUserTransactions(String uid) async {
    final batch = _db.batch();
    
    for (var tx in DummyData.transactions) {
      final docRef = _db.collection('users').doc(uid).collection('transactions').doc(tx.id);
      batch.set(docRef, {
        'date': Timestamp.fromDate(tx.date),
        'locationName': tx.locationName,
        'itemName': tx.itemName,
        'price': tx.price,
        'currency': tx.currency,
        'stampsEarned': tx.stampsEarned,
      });
    }
    
    // Update user's stamps
    batch.update(_db.collection('users').doc(uid), {
      'stamps': 6,
    });
    
    await batch.commit();
    print('✅ User Transactions Seeded Successfully');
  }
}
