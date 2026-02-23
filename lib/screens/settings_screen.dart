import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../theme/app_theme.dart';
import '../services/auth_service.dart';
import '../services/firestore_service.dart';
import '../services/seed_service.dart';
import '../models/user_profile.dart';
import 'manage_account_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
    final firestoreService = FirestoreService();

    void showComingSoon(String feature) {
      HapticFeedback.lightImpact();
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('$feature — coming soon!'),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          duration: const Duration(seconds: 2),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Settings', style: AppTextStyles.heading3),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          children: [
            const SizedBox(height: 24),
            // Profile Card (Stream)
            StreamBuilder<UserProfile?>(
              stream: firestoreService.getUserProfile(uid),
              builder: (context, snapshot) {
                final user = snapshot.data;
                return _buildProfileCard(
                  name: user?.fullName ?? 'Loading...',
                  email: user?.email ?? '',
                  memberSince: user?.memberSince ?? '',
                  tier: user?.loyaltyTier ?? '',
                );
              },
            ),
            const SizedBox(height: 24),

            // Seed Dev Tool (Hidden in production normally)
            _buildDevSeederButton(context, uid),

            // Settings Lists
            _buildSettingsGroup([
              _buildSettingItem(Icons.local_offer_outlined, 'Promo Codes', onTap: () => showComingSoon('Promo Codes')),
              _buildSettingItem(Icons.card_membership_rounded, 'Add Loyalty Card', onTap: () => showComingSoon('Add Loyalty Card')),
            ]),
            
            _buildSectionTitle('Account'),
            _buildSettingsGroup([
              _buildSettingItem(Icons.person_outline_rounded, 'Manage My Account', onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const ManageAccountScreen()),
                );
              }),
              _buildSettingItem(Icons.credit_card_rounded, 'Payment Methods', onTap: () => showComingSoon('Payment Methods')),
              _buildSettingItem(Icons.lock_outline_rounded, 'Passcode & Face ID', onTap: () => showComingSoon('Passcode & Face ID')),
              _buildSettingItem(Icons.notifications_none_rounded, 'Notifications', onTap: () => showComingSoon('Notification Settings')),
            ]),

            _buildSectionTitle('Support'),
            _buildSettingsGroup([
              _buildSettingItem(Icons.help_outline_rounded, 'Help Centre', onTap: () => showComingSoon('Help Centre')),
              _buildSettingItem(Icons.play_circle_outline_rounded, 'App Tutorial', onTap: () => showComingSoon('App Tutorial')),
            ]),

            _buildSectionTitle('Other'),
            _buildSettingsGroup([
              _buildSettingItem(Icons.star_border_rounded, 'Rate Our App', onTap: () => showComingSoon('Rate Our App')),
              _buildSettingItem(
                Icons.logout_rounded,
                'Log Out',
                isDestructive: true,
                onTap: () => AuthService().signOut(),
              ),
            ]),

            const SizedBox(height: 32),
            Text(
              'Vonal 1.0.0',
              style: AppTextStyles.caption.copyWith(color: AppColors.textTertiary),
            ),
            const SizedBox(height: 48),
          ],
        ),
      ),
    );
  }

  Widget _buildDevSeederButton(BuildContext context, String uid) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: ElevatedButton.icon(
        onPressed: () async {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Seeding database...')),
          );
          await SeedService().seedDatabase();
          await SeedService().seedUserTransactions(uid);
          
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Database seeded!')),
            );
          }
        },
        icon: const Icon(Icons.cloud_upload_rounded),
        label: const Text('Seed Dummy Data (Dev Tool)'),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.amber.shade700,
          foregroundColor: Colors.white,
        ),
      ),
    );
  }

  Widget _buildProfileCard({
    required String name,
    required String email,
    required String memberSince,
    required String tier,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.person_rounded,
                color: AppColors.primary,
                size: 32,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(name, style: AppTextStyles.heading3),
                  const SizedBox(height: 2),
                  Text(email, style: AppTextStyles.body2),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.gold.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          tier,
                          style: AppTextStyles.caption.copyWith(
                            color: AppColors.gold,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Member since $memberSince',
                        style: AppTextStyles.caption.copyWith(color: AppColors.textTertiary),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(28, 24, 20, 8),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          title.toUpperCase(),
          style: AppTextStyles.caption.copyWith(
            color: AppColors.textTertiary,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
      ),
    );
  }

  Widget _buildSettingsGroup(List<Widget> children) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.divider),
        ),
        child: Column(
          children: children,
        ),
      ),
    );
  }

  Widget _buildSettingItem(IconData icon, String title, {bool isDestructive = false, VoidCallback? onTap}) {
    final color = isDestructive ? AppColors.error : AppColors.textPrimary;
    return InkWell(
      onTap: onTap ?? () {},
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: Row(
          children: [
            Icon(icon, color: isDestructive ? color : AppColors.primary, size: 22),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: AppTextStyles.subtitle2.copyWith(color: color, fontSize: 15),
              ),
            ),
            Icon(
              Icons.arrow_forward_ios_rounded,
              color: AppColors.textTertiary,
              size: 16,
            ),
          ],
        ),
      ),
    );
  }
}
