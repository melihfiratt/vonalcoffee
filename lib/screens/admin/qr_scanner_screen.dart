import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../../theme/app_theme.dart';
import '../../services/firestore_service.dart';
import '../../models/user_profile.dart';

class QRScannerScreen extends StatefulWidget {
  const QRScannerScreen({super.key});

  @override
  State<QRScannerScreen> createState() => _QRScannerScreenState();
}

class _QRScannerScreenState extends State<QRScannerScreen> {
  final _firestoreService = FirestoreService();
  final MobileScannerController _scannerController = MobileScannerController();
  bool _isProcessing = false;

  @override
  void dispose() {
    _scannerController.dispose();
    super.dispose();
  }

  Future<void> _handleBarcode(BarcodeCapture capture) async {
    if (_isProcessing) return;
    final barcode = capture.barcodes.firstOrNull;
    if (barcode == null || barcode.rawValue == null) return;

    setState(() => _isProcessing = true);
    _scannerController.stop();

    final rawValue = barcode.rawValue!;
    // Parse UID from QR: "vonal-coffee://loyalty/{uid}"
    String? uid;
    if (rawValue.startsWith('vonal-coffee://loyalty/')) {
      uid = rawValue.replaceFirst('vonal-coffee://loyalty/', '');
    }

    if (uid == null || uid.isEmpty) {
      _showError('Geçersiz QR kodu');
      _resetScanner();
      return;
    }

    // Single read — fetch customer data
    final user = await _firestoreService.getUserByUid(uid);
    if (user == null) {
      _showError('Kullanıcı bulunamadı');
      _resetScanner();
      return;
    }

    if (mounted) {
      _showStampSheet(user);
    }
  }

  void _resetScanner() {
    setState(() => _isProcessing = false);
    _scannerController.start();
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.error,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  void _showStampSheet(UserProfile user) {
    int selectedStamps = 1;

    showModalBottomSheet(
      context: context,
      backgroundColor: AdminColors.card,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return Padding(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Handle
                  Container(
                    width: 40, height: 4,
                    decoration: BoxDecoration(
                      color: AdminColors.divider,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Customer info
                  CircleAvatar(
                    radius: 32,
                    backgroundColor: AdminColors.accent.withValues(alpha: 0.15),
                    child: Text(
                      user.firstName.isNotEmpty ? user.firstName[0].toUpperCase() : '?',
                      style: AppTextStyles.heading1.copyWith(
                        color: AdminColors.accent,
                        fontSize: 28,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    user.fullName,
                    style: AppTextStyles.heading3.copyWith(color: AdminColors.textPrimary),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Mevcut Stamp: ${user.stamps} / ${user.totalStamps}',
                    style: AppTextStyles.body2.copyWith(color: AdminColors.textSecondary),
                  ),
                  const SizedBox(height: 24),

                  // Stamp selection
                  Text(
                    'Kaç stamp eklenecek?',
                    style: AppTextStyles.subtitle2.copyWith(color: AdminColors.textSecondary),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [1, 2, 3].map((count) {
                      final isSelected = selectedStamps == count;
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 6),
                        child: GestureDetector(
                          onTap: () => setSheetState(() => selectedStamps = count),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            width: 64, height: 64,
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? AdminColors.accent
                                  : AdminColors.surface,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: isSelected
                                    ? AdminColors.accent
                                    : AdminColors.divider,
                                width: 2,
                              ),
                            ),
                            child: Center(
                              child: Text(
                                '+$count',
                                style: AppTextStyles.heading3.copyWith(
                                  color: isSelected
                                      ? Colors.white
                                      : AdminColors.textSecondary,
                                  fontSize: 20,
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 24),

                  // Approve button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () async {
                        Navigator.pop(ctx);
                        try {
                          await _firestoreService.addStamps(user.id, selectedStamps);
                          if (mounted) {
                            ScaffoldMessenger.of(this.context).showSnackBar(
                              SnackBar(
                                content: Text('✅ ${user.firstName}\'e $selectedStamps stamp eklendi!'),
                                backgroundColor: AdminColors.accent,
                                behavior: SnackBarBehavior.floating,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              ),
                            );
                          }
                        } catch (e) {
                          _showError('Stamp eklenemedi: $e');
                        }
                        _resetScanner();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AdminColors.accent,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                      child: Text(
                        'Onayla (+$selectedStamps Stamp)',
                        style: AppTextStyles.button,
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    ).whenComplete(() {
      if (!_isProcessing) return;
      _resetScanner();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: AppTheme.darkTheme,
      child: Scaffold(
        backgroundColor: AdminColors.background,
        appBar: AppBar(
          backgroundColor: AdminColors.background,
          title: Text(
            'QR Tarayıcı',
            style: AppTextStyles.heading3.copyWith(color: AdminColors.textPrimary),
          ),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_rounded, color: AdminColors.textPrimary),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: Column(
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                child: Stack(
                  children: [
                    MobileScanner(
                      controller: _scannerController,
                      onDetect: _handleBarcode,
                    ),
                    // Scan overlay
                    Center(
                      child: Container(
                        width: 250, height: 250,
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: AdminColors.accent.withValues(alpha: 0.7),
                            width: 3,
                          ),
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Bottom info
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              color: AdminColors.background,
              child: Column(
                children: [
                  Icon(
                    _isProcessing ? Icons.hourglass_top_rounded : Icons.qr_code_scanner_rounded,
                    color: AdminColors.accent,
                    size: 32,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _isProcessing ? 'İşleniyor...' : 'Müşterinin QR kodunu taratın',
                    style: AppTextStyles.subtitle1.copyWith(color: AdminColors.textPrimary),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Wallet ekranındaki QR kodu kameraya gösterin',
                    style: AppTextStyles.caption.copyWith(color: AdminColors.textSecondary),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
