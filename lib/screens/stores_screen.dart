import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
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
  GoogleMapController? _mapController;

  // ── Tatvan center ──
  static const LatLng _tatvanCenter = LatLng(38.502, 42.289);

  // ── Branch coordinates ──
  static const LatLng _branch1Pos = LatLng(38.493621027314695, 42.29050119197776);
  static const LatLng _branch2Pos = LatLng(38.51117138892171, 42.2884348366541);

  late final Set<Marker> _markers;

  @override
  void initState() {
    super.initState();
    _markers = {
      Marker(
        markerId: const MarkerId('branch_1'),
        position: _branch1Pos,
        infoWindow: const InfoWindow(
          title: 'Vonal Coffee - Tatvan Sahil',
          snippet: 'Sahil Yolu Caddesi No:12',
        ),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
      ),
      Marker(
        markerId: const MarkerId('branch_2'),
        position: _branch2Pos,
        infoWindow: const InfoWindow(
          title: 'Vonal Coffee - Tatvan Merkez',
          snippet: 'Cumhuriyet Caddesi No:45',
        ),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
      ),
    };
  }

  @override
  void dispose() {
    _mapController?.dispose();
    super.dispose();
  }

  void _animateToMarker(LatLng position) {
    _mapController?.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(target: position, zoom: 16),
      ),
    );
  }

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
              child: GestureDetector(
                onTap: () {
                  HapticFeedback.lightImpact();
                  ScaffoldMessenger.of(context).hideCurrentSnackBar();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text('🔍 Search — coming soon!'),
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      duration: const Duration(seconds: 2),
                    ),
                  );
                },
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
            ),
            const SizedBox(height: 16),

            // Map Area with Google Maps
            Expanded(
              child: Stack(
                children: [
                  // ── Google Map ──
                  GoogleMap(
                    initialCameraPosition: const CameraPosition(
                      target: _tatvanCenter,
                      zoom: 13.5,
                    ),
                    markers: _markers,
                    onMapCreated: (controller) {
                      _mapController = controller;
                    },
                    myLocationButtonEnabled: false,
                    zoomControlsEnabled: false,
                    mapToolbarEnabled: false,
                    compassEnabled: false,
                    style: _mapStyle,
                  ),

                  // ── Zoom controls ──
                  Positioned(
                    top: 12,
                    right: 12,
                    child: Column(
                      children: [
                        _buildMapButton(
                          icon: Icons.add,
                          onTap: () => _mapController?.animateCamera(CameraUpdate.zoomIn()),
                        ),
                        const SizedBox(height: 8),
                        _buildMapButton(
                          icon: Icons.remove,
                          onTap: () => _mapController?.animateCamera(CameraUpdate.zoomOut()),
                        ),
                        const SizedBox(height: 8),
                        _buildMapButton(
                          icon: Icons.my_location_rounded,
                          onTap: () {
                            _mapController?.animateCamera(
                              CameraUpdate.newCameraPosition(
                                const CameraPosition(target: _tatvanCenter, zoom: 13.5),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),

                  // ── Bottom Sheet with Stores ──
                  _buildBottomSheet(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMapButton({required IconData icon, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.12),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Icon(icon, size: 20, color: AppColors.textPrimary),
      ),
    );
  }

  Widget _buildBottomSheet() {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Container(
        height: 280,
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
                  if (snapshot.hasError) {
                    debugPrint('🔴 Stores error: ${snapshot.error}');
                    return const Center(child: Text('Could not load stores.'));
                  }
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
                      return StoreCard(
                        store: stores[index],
                        onTap: () {
                          HapticFeedback.lightImpact();
                          _animateToMarker(
                            LatLng(stores[index].latitude, stores[index].longitude),
                          );
                        },
                      );
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

  // Subtle map style — you can extend this or remove it
  static const String _mapStyle = '';
}
