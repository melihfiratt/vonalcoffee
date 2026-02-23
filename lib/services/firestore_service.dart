import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../models/user_profile.dart';
import '../models/transaction.dart' as local_tx;
import '../models/store_location.dart';
import '../models/social_post.dart';
import '../models/treat_item.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // ── User Profile ──
  Stream<UserProfile?> getUserProfile(String uid) {
    return _db.collection('users').doc(uid).snapshots().map((snap) {
      if (!snap.exists) return null;
      final data = snap.data()!;
      return UserProfile(
        id: snap.id,
        firstName: data['firstName'] ?? '',
        lastName: data['lastName'] ?? '',
        email: data['email'] ?? '',
        avatarUrl: data['avatarUrl'] ?? '',
        stamps: data['stamps'] ?? 0,
        totalStamps: data['totalStamps'] ?? 9,
        memberSince: data['memberSince'] ?? '',
        loyaltyTier: data['loyaltyTier'] ?? 'Member',
        phoneNumber: data['phoneNumber'] ?? '',
        gender: data['gender'] ?? '',
        age: data['age'] ?? '',
      );
    }).handleError((e) {
      debugPrint('🔴 Firestore getUserProfile error: $e');
    });
  }

  // ── Update User Profile ──
  Future<void> updateUserProfile(String uid, Map<String, dynamic> data) async {
    try {
      await _db.collection('users').doc(uid).update(data);
    } catch (e) {
      debugPrint('🔴 Firestore updateUserProfile error: $e');
      rethrow;
    }
  }

  // ── Transactions ──
  Stream<List<local_tx.Transaction>> getTransactions(String uid) {
    return _db
        .collection('users')
        .doc(uid)
        .collection('transactions')
        .orderBy('date', descending: true)
        .snapshots()
        .map((snap) {
      return snap.docs.map((doc) {
        final data = doc.data();
        return local_tx.Transaction(
          id: doc.id,
          date: (data['date'] as Timestamp).toDate(),
          locationName: data['locationName'] ?? '',
          itemName: data['itemName'] ?? '',
          price: (data['price'] ?? 0).toDouble(),
          currency: data['currency'] ?? '₺',
          stampsEarned: data['stampsEarned'] ?? 1,
        );
      }).toList();
    }).handleError((e) {
      debugPrint('🔴 Firestore getTransactions error: $e');
    });
  }

  // ── Stores ──
  Stream<List<StoreLocation>> getStores() {
    return _db.collection('stores').snapshots().map((snap) {
      return snap.docs.map((doc) {
        final data = doc.data();
        return StoreLocation(
          id: doc.id,
          name: data['name'] ?? '',
          address: data['address'] ?? '',
          city: data['city'] ?? '',
          latitude: (data['latitude'] ?? 0).toDouble(),
          longitude: (data['longitude'] ?? 0).toDouble(),
          openingHours: data['openingHours'] ?? '',
          closingHours: data['closingHours'] ?? '',
          distance: data['distance'] ?? '',
          phoneNumber: data['phoneNumber'] ?? '',
          isOpen: data['isOpen'] ?? false,
          amenities: List<String>.from(data['amenities'] ?? []),
        );
      }).toList();
    }).handleError((e) {
      debugPrint('🔴 Firestore getStores error: $e');
    });
  }

  // ── Social Posts ──
  Stream<List<SocialPost>> getSocialPosts() {
    return _db
        .collection('posts')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snap) {
      return snap.docs.map((doc) {
        final data = doc.data();
        return SocialPost(
          id: doc.id,
          userName: data['userName'] ?? '',
          userAvatar: data['userAvatar'] ?? '',
          message: data['message'] ?? '',
          timestamp: (data['timestamp'] as Timestamp).toDate(),
          branchName: data['branchName'] ?? '',
          likes: data['likes'] ?? 0,
          isCheckedIn: data['isCheckedIn'] ?? false,
          mood: data['mood'],
        );
      }).toList();
    }).handleError((e) {
      debugPrint('🔴 Firestore getSocialPosts error: $e');
    });
  }

  // ── Create Social Post ──
  Future<void> createPost({
    required String userName,
    required String message,
    required String branchName,
    String? mood,
  }) async {
    try {
      await _db.collection('posts').add({
        'userName': userName,
        'userAvatar': '',
        'message': message,
        'timestamp': FieldValue.serverTimestamp(),
        'branchName': branchName,
        'likes': 0,
        'isCheckedIn': true,
        'mood': mood,
      });
    } catch (e) {
      debugPrint('🔴 Firestore createPost error: $e');
      rethrow;
    }
  }

  // ── Treats ──
  Stream<List<TreatItem>> getTreats() {
    return _db.collection('treats').snapshots().map((snap) {
      return snap.docs.map((doc) {
        final data = doc.data();
        return TreatItem(
          id: doc.id,
          title: data['title'] ?? '',
          subtitle: data['subtitle'] ?? '',
          imageEmoji: data['imageEmoji'] ?? '☕',
          promoText: data['promoText'],
        );
      }).toList();
    }).handleError((e) {
      debugPrint('🔴 Firestore getTreats error: $e');
    });
  }
}
