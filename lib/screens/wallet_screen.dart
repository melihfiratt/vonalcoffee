import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../theme/app_theme.dart';
import '../services/firestore_service.dart';
import '../models/user_profile.dart';
import '../widgets/loyalty_stamp.dart';

class WalletScreen extends StatelessWidget {
  const WalletScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    final firestoreService = FirestoreService();

    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            children: [
              const SizedBox(height: 16),
              // ── Title ──
              Text('My Wallet', style: AppTextStyles.heading2),
              const SizedBox(height: 24),

              StreamBuilder<UserProfile?>(
                stream: firestoreService.getUserProfile(uid),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final user = snapshot.data!;

                  return Column(
                    children: [
                      // ── QR Code Card ──
                      _buildQRCard(user.fullName, uid),
                      const SizedBox(height: 24),

                      // ── Loyalty Progress ──
                      _buildLoyaltySection(user.stamps, user.totalStamps),
                      const SizedBox(height: 24),
                    ],
                  );
                },
              ),

              // ── Action Buttons ──
              _buildActionButtons(),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQRCard(String name, String uid) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(28),
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.07),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          children: [
            // Mini header
            Text(
              'Scan to earn stamps',
              style: AppTextStyles.body2.copyWith(fontSize: 13),
            ),
            const SizedBox(height: 20),
            // QR Code
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                border: Border.all(
                  color: AppColors.primary.withValues(alpha: 0.15),
                  width: 3,
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: QrImageView(
                data: 'vonal-coffee://loyalty/$uid',
                version: QrVersions.auto,
                size: 180,
                eyeStyle: const QrEyeStyle(
                  eyeShape: QrEyeShape.circle,
                  color: AppColors.primary,
                ),
                dataModuleStyle: const QrDataModuleStyle(
                  dataModuleShape: QrDataModuleShape.circle,
                  color: AppColors.textPrimary,
                ),
                gapless: true,
              ),
            ),
            const SizedBox(height: 20),
            // Name
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(24),
              ),
              child: Text(
                name,
                style: AppTextStyles.subtitle1.copyWith(
                  color: AppColors.primary,
                  fontSize: 14,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoyaltySection(int stamps, int total) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(22),
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Loyalty Stamps', style: AppTextStyles.heading3.copyWith(fontSize: 16)),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.gold.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '$stamps / $total',
                    style: AppTextStyles.subtitle2.copyWith(
                      color: AppColors.gold,
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            // Stamps grid
            Wrap(
              spacing: 8,
              runSpacing: 10,
              children: List.generate(total, (index) {
                return LoyaltyStamp(
                  isFilled: index < stamps,
                  index: index,
                  total: total,
                );
              }),
            ),
            const SizedBox(height: 18),
            // Progress text
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.info_outline_rounded,
                    size: 16,
                    color: AppColors.textTertiary,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '$total stamps = 1 Free Coffee ☕',
                    style: AppTextStyles.body2.copyWith(fontSize: 13),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          Expanded(
            child: _buildActionBtn(
              icon: Icons.add_card_rounded,
              label: 'Add Loyalty Card',
              isPrimary: true,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: _buildActionBtn(
              icon: Icons.card_giftcard_rounded,
              label: 'View Rewards',
              isPrimary: false,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionBtn({
    required IconData icon,
    required String label,
    required bool isPrimary,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: isPrimary ? AppColors.primary : AppColors.background,
        borderRadius: BorderRadius.circular(14),
        border: isPrimary
            ? null
            : Border.all(color: AppColors.primary, width: 1.5),
        boxShadow: isPrimary
            ? [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.25),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ]
            : [],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 20,
            color: isPrimary ? Colors.white : AppColors.primary,
          ),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              label,
              style: AppTextStyles.buttonSmall.copyWith(
                color: isPrimary ? Colors.white : AppColors.primary,
                fontSize: 13,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
