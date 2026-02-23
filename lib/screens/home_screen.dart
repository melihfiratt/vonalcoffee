import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../theme/app_theme.dart';
import '../services/firestore_service.dart';
import '../models/user_profile.dart';
import '../models/treat_item.dart';
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
  final String _uid = FirebaseAuth.instance.currentUser!.uid;

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning';
    if (hour < 17) return 'Good afternoon';
    return 'Good evening';
  }

  @override
  Widget build(BuildContext context) {
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
                      onTap: () {},
                    ),
                    const SizedBox(width: 14),
                    QuickActionButton(
                      icon: Icons.coffee_rounded,
                      label: 'Evde\nKahve',
                      onTap: () {},
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 28),

              // ── Exclusive Treats (Stream) ──
              const SectionHeader(
                title: 'Exclusive Treats',
                actionText: 'See All',
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
                        return TreatCard(treat: treats[index]);
                      },
                    );
                  },
                ),
              ),
              const SizedBox(height: 28),

              // ── Refer a Friend Banner ──
              _buildReferBanner(),
              const SizedBox(height: 20),

              // ── News / Info Banners ──
              _buildInfoBanner(
                emoji: '🌿',
                title: 'Our Coffee Beans',
                subtitle:
                    'Ethically sourced from the best farms in South America',
                gradient: [
                  const Color(0xFF2E7D32).withValues(alpha: 0.08),
                  const Color(0xFF66BB6A).withValues(alpha: 0.12),
                ],
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
    );
  }

  Widget _buildInfoBanner({
    required String emoji,
    required String title,
    required String subtitle,
    required List<Color> gradient,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
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
    );
  }
}
