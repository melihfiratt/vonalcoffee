import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Stream of auth state changes
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Get current user
  User? get currentUser => _auth.currentUser;

  // Sign In
  Future<UserCredential> signIn(String email, String password) async {
    return await _auth.signInWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
  }

  // Sign Up & Create Profile
  Future<UserCredential> signUp(
    String firstName,
    String lastName,
    String email,
    String password,
  ) async {
    // 1. Create Firebase Auth user
    UserCredential cred = await _auth.createUserWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );

    // 2. Create the Firestore profile
    if (cred.user != null) {
      await _db.collection('users').doc(cred.user!.uid).set({
        'firstName': firstName.trim(),
        'lastName': lastName.trim(),
        'email': email.trim(),
        'avatarUrl': '',
        'stamps': 0,
        'totalStamps': 9,
        'memberSince': _getFormattedDate(),
        'loyaltyTier': 'Member',
        'createdAt': FieldValue.serverTimestamp(),
      });
    }

    return cred;
  }

  // Sign Out
  Future<void> signOut() async {
    await _auth.signOut();
  }

  // Helper for memberSince date
  String _getFormattedDate() {
    final now = DateTime.now();
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${months[now.month - 1]} ${now.year}';
  }
}
