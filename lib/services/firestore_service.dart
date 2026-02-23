import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../models/user_profile.dart';
import '../models/transaction.dart' as local_tx;
import '../models/store_location.dart';
import '../models/social_post.dart';
import '../models/treat_item.dart';
import '../models/campaign.dart';

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
        role: data['role'] ?? 'user',
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

  // ── Admin: Get user role (single read, no stream) ──
  Future<String> getUserRole(String uid) async {
    try {
      final doc = await _db.collection('users').doc(uid).get();
      if (!doc.exists) return 'user';
      return doc.data()?['role'] ?? 'user';
    } catch (e) {
      debugPrint('🔴 getUserRole error: $e');
      return 'user';
    }
  }

  // ── Admin: Get user by UID (single read for QR scan) ──
  Future<UserProfile?> getUserByUid(String uid) async {
    try {
      final doc = await _db.collection('users').doc(uid).get();
      if (!doc.exists) return null;
      final data = doc.data()!;
      return UserProfile(
        id: doc.id,
        firstName: data['firstName'] ?? '',
        lastName: data['lastName'] ?? '',
        email: data['email'] ?? '',
        avatarUrl: data['avatarUrl'] ?? '',
        stamps: data['stamps'] ?? 0,
        totalStamps: data['totalStamps'] ?? 9,
        memberSince: data['memberSince'] ?? '',
        loyaltyTier: data['loyaltyTier'] ?? 'Member',
        role: data['role'] ?? 'user',
      );
    } catch (e) {
      debugPrint('🔴 getUserByUid error: $e');
      return null;
    }
  }

  // ── Admin: Search user by email (single read) ──
  Future<UserProfile?> getUserByEmail(String email) async {
    try {
      final snap = await _db
          .collection('users')
          .where('email', isEqualTo: email.trim().toLowerCase())
          .limit(1)
          .get();
      if (snap.docs.isEmpty) return null;
      final doc = snap.docs.first;
      final data = doc.data();
      return UserProfile(
        id: doc.id,
        firstName: data['firstName'] ?? '',
        lastName: data['lastName'] ?? '',
        email: data['email'] ?? '',
        avatarUrl: data['avatarUrl'] ?? '',
        stamps: data['stamps'] ?? 0,
        totalStamps: data['totalStamps'] ?? 9,
        memberSince: data['memberSince'] ?? '',
        loyaltyTier: data['loyaltyTier'] ?? 'Member',
        role: data['role'] ?? 'user',
      );
    } catch (e) {
      debugPrint('🔴 getUserByEmail error: $e');
      return null;
    }
  }

  // ── Admin: Update user role ──
  Future<void> updateUserRole(String uid, String role) async {
    try {
      await _db.collection('users').doc(uid).update({'role': role});
    } catch (e) {
      debugPrint('🔴 updateUserRole error: $e');
      rethrow;
    }
  }

  // ── Admin: Add stamps to user ──
  Future<void> addStamps(String uid, int count) async {
    try {
      await _db.collection('users').doc(uid).update({
        'stamps': FieldValue.increment(count),
      });
      // Log the stamp addition (minimal write)
      await _db.collection('stamp_logs').add({
        'userId': uid,
        'stampsAdded': count,
        'timestamp': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      debugPrint('🔴 addStamps error: $e');
      rethrow;
    }
  }

  // ── Campaigns (single reads for admin, stream for home) ──
  Stream<List<Campaign>> getCampaigns() {
    return _db
        .collection('campaigns')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) {
      return snap.docs.map((doc) {
        final data = doc.data();
        return Campaign(
          id: doc.id,
          title: data['title'] ?? '',
          description: data['description'] ?? '',
          imageUrl: data['imageUrl'] ?? '',
          endDate: (data['endDate'] as Timestamp?)?.toDate(),
          createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
          isActive: data['isActive'] ?? true,
        );
      }).toList();
    }).handleError((e) {
      debugPrint('🔴 getCampaigns error: $e');
    });
  }

  // ── Admin: Get active campaigns only (for home screen, single read) ──
  Future<List<Campaign>> getActiveCampaigns() async {
    try {
      final snap = await _db
          .collection('campaigns')
          .where('isActive', isEqualTo: true)
          .orderBy('createdAt', descending: true)
          .limit(5)
          .get();
      return snap.docs.map((doc) {
        final data = doc.data();
        return Campaign(
          id: doc.id,
          title: data['title'] ?? '',
          description: data['description'] ?? '',
          imageUrl: data['imageUrl'] ?? '',
          endDate: (data['endDate'] as Timestamp?)?.toDate(),
          createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
          isActive: data['isActive'] ?? true,
        );
      }).toList();
    } catch (e) {
      debugPrint('🔴 getActiveCampaigns error: $e');
      return [];
    }
  }

  Future<void> createCampaign({
    required String title,
    required String description,
    required DateTime endDate,
    String imageUrl = '',
  }) async {
    try {
      await _db.collection('campaigns').add({
        'title': title,
        'description': description,
        'endDate': Timestamp.fromDate(endDate),
        'imageUrl': imageUrl,
        'isActive': true,
        'createdAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      debugPrint('🔴 createCampaign error: $e');
      rethrow;
    }
  }

  Future<void> deleteCampaign(String id) async {
    try {
      await _db.collection('campaigns').doc(id).delete();
    } catch (e) {
      debugPrint('🔴 deleteCampaign error: $e');
      rethrow;
    }
  }

  // ── Admin Analytics (single reads — Firebase-friendly) ──
  Future<int> getTotalUsersCount() async {
    try {
      final snap = await _db.collection('users').count().get();
      return snap.count ?? 0;
    } catch (e) {
      debugPrint('🔴 getTotalUsersCount error: $e');
      return 0;
    }
  }

  Future<int> getTodayStampsCount() async {
    try {
      final now = DateTime.now();
      final startOfDay = DateTime(now.year, now.month, now.day);
      final snap = await _db
          .collection('stamp_logs')
          .where('timestamp', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
          .count()
          .get();
      return snap.count ?? 0;
    } catch (e) {
      debugPrint('🔴 getTodayStampsCount error: $e');
      return 0;
    }
  }
}
