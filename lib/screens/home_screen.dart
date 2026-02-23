import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../theme/app_theme.dart';
import '../services/firestore_service.dart';
import '../models/user_profile.dart';
import '../models/treat_item.dart';
import '../models/campaign.dart';
import '../widgets/quick_action_button.dart';
import '../widgets/treat_card.dart';
import '../widgets/section_header.dart';
import 'settings_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _firestoreService = FirestoreService();
  String get _uid => FirebaseAuth.instance.currentUser?.uid ?? '';

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning';
    if (hour < 17) return 'Good afternoon';
    return 'Good evening';
  }

  void _showSnackBar(String message) {
    HapticFeedback.lightImpact();
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_uid.isEmpty) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 8),
              // ── Header (Stream) ──
              StreamBuilder<UserProfile?>(
                stream: _firestoreService.getUserProfile(_uid),
                builder: (context, snapshot) {
                  final name = snapshot.data?.firstName ?? 'Guest';
                  return _buildHeader(context, name);
                },
              ),
              const SizedBox(height: 24),

              // ── Quick Actions ──
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    QuickActionButton(
                      icon: Icons.delivery_dining_rounded,
                      label: 'Paket\nServis',
                      onTap: () => _showSnackBar('🛵 Paket Servis coming soon!'),
                    ),
                    const SizedBox(width: 14),
                    QuickActionButton(
                      icon: Icons.coffee_rounded,
                      label: 'Evde\nKahve',
                      onTap: () => _showSnackBar('☕ Evde Kahve coming soon!'),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 28),

              // ── Exclusive Treats (Stream) ──
              SectionHeader(
                title: 'Exclusive Treats',
                actionText: 'See All',
                onActionTap: () => _showSnackBar('All treats coming soon!'),
              ),
              const SizedBox(height: 14),
              SizedBox(
                height: 210,
                child: StreamBuilder<List<TreatItem>>(
                  stream: _firestoreService.getTreats(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    final treats = snapshot.data!;
                    if (treats.isEmpty) {
                      return const Center(child: Text('No treats available.'));
                    }
                    return ListView.builder(
                      scrollDirection: Axis.horizontal,
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.only(left: 20, right: 4),
                      itemCount: treats.length,
                      itemBuilder: (context, index) {
                        return TreatCard(
                          treat: treats[index],
                          onTap: () => _showSnackBar('${treats[index].title} — details coming soon!'),
                        );
                      },
                    );
                  },
                ),
              ),
              const SizedBox(height: 28),

              // ── Refer a Friend Banner ──
              _buildReferBanner(),
              const SizedBox(height: 20),

              // ── Campaigns from Firestore (single read) ──
              FutureBuilder<List<Campaign>>(
                future: _firestoreService.getActiveCampaigns(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const SizedBox.shrink();
                  }
                  final campaigns = snapshot.data!;
                  return Column(
                    children: campaigns.map((campaign) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 14),
                        child: _buildInfoBanner(
                          emoji: '🎯',
                          title: campaign.title,
                          subtitle: campaign.description,
                          gradient: [
                            const Color(0xFF0F7A1E).withValues(alpha: 0.08),
                            const Color(0xFF2E9E3E).withValues(alpha: 0.12),
                          ],
                          onTap: () => _showSnackBar('📢 ${campaign.title}'),
                        ),
                      );
                    }).toList(),
                  );
                },
              ),

              // ── Static Banners ──
              _buildInfoBanner(
                emoji: '🌿',
                title: 'Our Coffee Beans',
                subtitle:
                    'Ethically sourced from the best farms in South America',
                gradient: [
                  const Color(0xFF2E7D32).withValues(alpha: 0.08),
                  const Color(0xFF66BB6A).withValues(alpha: 0.12),
                ],
                onTap: () => _showSnackBar('🌿 Learn more about our beans — coming soon!'),
              ),
              const SizedBox(height: 14),
              _buildInfoBanner(
                emoji: '🎉',
                title: 'Happy Hour',
                subtitle: 'Every Friday 3-5 PM — Buy 1 Get 1 Free!',
                gradient: [
                  const Color(0xFFFF8F00).withValues(alpha: 0.08),
                  const Color(0xFFFFCA28).withValues(alpha: 0.12),
                ],
                onTap: () => _showSnackBar('🎉 Happy Hour details — coming soon!'),
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, String firstName) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${_getGreeting()},',
                style: AppTextStyles.body2.copyWith(fontSize: 14),
              ),
              const SizedBox(height: 2),
              Text(
                firstName,
                style: AppTextStyles.heading1.copyWith(fontSize: 26),
              ),
            ],
          ),
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const SettingsScreen(),
                ),
              );
            },
            child: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.person_rounded,
                color: AppColors.primary,
                size: 26,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReferBanner() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: GestureDetector(
        onTap: () => _showSnackBar('🎁 Referral link copied! Share with friends.'),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppColors.primary,
                AppColors.primaryLight,
              ],
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.3),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(
                  Icons.card_giftcard_rounded,
                  color: Colors.white,
                  size: 26,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Arkadaşını Davet Et',
                      style: AppTextStyles.subtitle1.copyWith(
                        color: Colors.white,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Invite a friend & both earn a free coffee!',
                      style: AppTextStyles.body2.copyWith(
                        color: Colors.white.withValues(alpha: 0.85),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.arrow_forward_ios_rounded,
                color: Colors.white,
                size: 18,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoBanner({
    required String emoji,
    required String title,
    required String subtitle,
    required List<Color> gradient,
    VoidCallback? onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: gradient,
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: AppColors.divider.withValues(alpha: 0.5),
              width: 1,
            ),
          ),
          child: Row(
            children: [
              Text(emoji, style: const TextStyle(fontSize: 36)),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: AppTextStyles.subtitle1.copyWith(fontSize: 15)),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: AppTextStyles.body2.copyWith(fontSize: 12),
                      maxLines: 2,
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.arrow_forward_ios_rounded,
                color: AppColors.textTertiary,
                size: 16,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
