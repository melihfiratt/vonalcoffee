import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../services/firestore_service.dart';
import '../models/store_location.dart';
import '../widgets/store_card.dart';

class StoresScreen extends StatefulWidget {
  const StoresScreen({super.key});

  @override
  State<StoresScreen> createState() => _StoresScreenState();
}

class _StoresScreenState extends State<StoresScreen> {
  final _firestoreService = FirestoreService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 8),
            // Header / Search
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.divider),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.search_rounded,
                        color: AppColors.textTertiary),
                    const SizedBox(width: 12),
                    Text(
                      'Search location',
                      style: AppTextStyles.body2
                          .copyWith(color: AppColors.textTertiary),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Map Area (Placeholder)
            Expanded(
              child: Stack(
                children: [
                  Container(
                    width: double.infinity,
                    decoration: const BoxDecoration(
                      color: Color(0xFFE5E5EA), // Maps gray
                    ),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.map_rounded,
                              size: 48,
                              color: AppColors.primary.withValues(alpha: 0.3)),
                          const SizedBox(height: 8),
                          Text(
                            'Map Centered on Tatvan, Türkiye',
                            style: AppTextStyles.subtitle2.copyWith(
                                color:
                                    AppColors.primary.withValues(alpha: 0.5)),
                          ),
                        ],
                      ),
                    ),
                  ),
                  
                  // Dummy Pins
                  Positioned(
                    top: 150,
                    left: 100,
                    child: _buildMapPin(true), // Vonal 1
                  ),
                  Positioned(
                    top: 220,
                    right: 120,
                    child: _buildMapPin(false), // Vonal 2
                  ),

                  // Bottom Sheet with Stream
                  _buildBottomSheet(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMapPin(bool isSelected) {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: isSelected ? AppColors.primary : Colors.white,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(
          color: isSelected ? Colors.white : AppColors.primary,
          width: 2,
        ),
      ),
      child: Center(
        child: Text(
          '🦆',
          style: TextStyle(fontSize: 20),
        ),
      ),
    );
  }

  Widget _buildBottomSheet() {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Container(
        height: 320,
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 24,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: Column(
          children: [
            const SizedBox(height: 12),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.divider,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: StreamBuilder<List<StoreLocation>>(
                stream: _firestoreService.getStores(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  
                  final stores = snapshot.data ?? [];
                  if (stores.isEmpty) {
                    return const Center(child: Text('No stores found.'));
                  }

                  return ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    physics: const BouncingScrollPhysics(),
                    itemCount: stores.length,
                    separatorBuilder: (context, index) =>
                        const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      return StoreCard(store: stores[index]);
                    },
                  );
                },
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
