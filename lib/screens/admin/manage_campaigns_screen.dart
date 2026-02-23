import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../theme/app_theme.dart';
import '../../services/firestore_service.dart';
import '../../models/campaign.dart';

class ManageCampaignsScreen extends StatefulWidget {
  const ManageCampaignsScreen({super.key});

  @override
  State<ManageCampaignsScreen> createState() => _ManageCampaignsScreenState();
}

class _ManageCampaignsScreenState extends State<ManageCampaignsScreen> {
  final _firestoreService = FirestoreService();

  void _showSnackBar(String message, {bool isError = false}) {
    HapticFeedback.lightImpact();
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        backgroundColor: isError ? AppColors.error : AdminColors.accent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _showAddCampaignDialog() {
    final titleController = TextEditingController();
    final descController = TextEditingController();
    final imageUrlController = TextEditingController();
    DateTime selectedDate = DateTime.now().add(const Duration(days: 7));

    showModalBottomSheet(
      context: context,
      backgroundColor: AdminColors.card,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return Padding(
              padding: EdgeInsets.fromLTRB(
                  24, 16, 24, MediaQuery.of(ctx).viewInsets.bottom + 24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Handle
                  Center(
                    child: Container(
                      width: 40, height: 4,
                      decoration: BoxDecoration(
                        color: AdminColors.divider,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Yeni Kampanya',
                    style: AppTextStyles.heading3.copyWith(color: AdminColors.textPrimary),
                  ),
                  const SizedBox(height: 20),

                  // Title
                  TextField(
                    controller: titleController,
                    style: TextStyle(color: AdminColors.textPrimary),
                    decoration: InputDecoration(
                      hintText: 'Kampanya Başlığı',
                      hintStyle: TextStyle(color: AdminColors.textTertiary),
                      filled: true,
                      fillColor: AdminColors.surface,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Description
                  TextField(
                    controller: descController,
                    style: TextStyle(color: AdminColors.textPrimary),
                    maxLines: 3,
                    decoration: InputDecoration(
                      hintText: 'Açıklama',
                      hintStyle: TextStyle(color: AdminColors.textTertiary),
                      filled: true,
                      fillColor: AdminColors.surface,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Image URL
                  TextField(
                    controller: imageUrlController,
                    style: TextStyle(color: AdminColors.textPrimary),
                    decoration: InputDecoration(
                      hintText: 'Resim URL (opsiyonel)',
                      hintStyle: TextStyle(color: AdminColors.textTertiary),
                      filled: true,
                      fillColor: AdminColors.surface,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // End Date
                  GestureDetector(
                    onTap: () async {
                      final pickedDate = await showDatePicker(
                        context: context,
                        initialDate: selectedDate,
                        firstDate: DateTime.now(),
                        lastDate: DateTime.now().add(const Duration(days: 365)),
                        builder: (context, child) {
                          return Theme(
                            data: ThemeData.dark().copyWith(
                              colorScheme: const ColorScheme.dark(
                                primary: AdminColors.accent,
                                surface: AdminColors.card,
                              ),
                            ),
                            child: child!,
                          );
                        },
                      );
                      if (pickedDate != null) {
                        setSheetState(() => selectedDate = pickedDate);
                      }
                    },
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      decoration: BoxDecoration(
                        color: AdminColors.surface,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.calendar_today_rounded,
                              color: AdminColors.textSecondary, size: 20),
                          const SizedBox(width: 12),
                          Text(
                            'Bitiş: ${selectedDate.day}/${selectedDate.month}/${selectedDate.year}',
                            style: AppTextStyles.body1.copyWith(color: AdminColors.textPrimary),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Save button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () async {
                        if (titleController.text.trim().isEmpty) {
                          _showSnackBar('Başlık gerekli', isError: true);
                          return;
                        }
                        Navigator.pop(ctx);
                        try {
                          await _firestoreService.createCampaign(
                            title: titleController.text.trim(),
                            description: descController.text.trim(),
                            endDate: selectedDate,
                            imageUrl: imageUrlController.text.trim(),
                          );
                          _showSnackBar('✅ Kampanya oluşturuldu');
                        } catch (e) {
                          _showSnackBar('Hata: $e', isError: true);
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AdminColors.accent,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                      child: const Text('Kampanya Oluştur'),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
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
            'Kampanya Yönetimi',
            style: AppTextStyles.heading3.copyWith(color: AdminColors.textPrimary),
          ),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_rounded, color: AdminColors.textPrimary),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: _showAddCampaignDialog,
          backgroundColor: AdminColors.accent,
          child: const Icon(Icons.add_rounded, color: Colors.white),
        ),
        body: StreamBuilder<List<Campaign>>(
          stream: _firestoreService.getCampaigns(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            final campaigns = snapshot.data ?? [];
            if (campaigns.isEmpty) {
              return Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.campaign_outlined,
                        color: AdminColors.textTertiary, size: 64),
                    const SizedBox(height: 16),
                    Text(
                      'Henüz kampanya yok',
                      style: AppTextStyles.subtitle1.copyWith(
                          color: AdminColors.textSecondary),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '+ butonuyla yeni kampanya ekleyin',
                      style: AppTextStyles.body2.copyWith(
                          color: AdminColors.textTertiary),
                    ),
                  ],
                ),
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.all(20),
              itemCount: campaigns.length,
              itemBuilder: (context, index) {
                final campaign = campaigns[index];
                return _buildCampaignCard(campaign);
              },
            );
          },
        ),
      ),
    );
  }

  Widget _buildCampaignCard(Campaign campaign) {
    final isExpired = campaign.isExpired;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AdminColors.card,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AdminColors.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  campaign.title,
                  style: AppTextStyles.subtitle1.copyWith(
                    color: AdminColors.textPrimary,
                  ),
                ),
              ),
              if (isExpired)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.error.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text('Süresi Doldu',
                      style: AppTextStyles.caption.copyWith(
                          color: AppColors.error, fontSize: 10)),
                )
              else
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AdminColors.accent.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text('Aktif',
                      style: AppTextStyles.caption.copyWith(
                          color: AdminColors.accent, fontSize: 10)),
                ),
            ],
          ),
          if (campaign.description.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              campaign.description,
              style: AppTextStyles.body2.copyWith(color: AdminColors.textSecondary),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
          if (campaign.endDate != null) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.calendar_today_rounded,
                    color: AdminColors.textTertiary, size: 14),
                const SizedBox(width: 6),
                Text(
                  'Bitiş: ${campaign.endDate!.day}/${campaign.endDate!.month}/${campaign.endDate!.year}',
                  style: AppTextStyles.caption.copyWith(color: AdminColors.textTertiary),
                ),
                const Spacer(),
                GestureDetector(
                  onTap: () async {
                    try {
                      await _firestoreService.deleteCampaign(campaign.id);
                      _showSnackBar('🗑️ Kampanya silindi');
                    } catch (e) {
                      _showSnackBar('Silinemedi', isError: true);
                    }
                  },
                  child: const Icon(Icons.delete_outline_rounded,
                      color: AppColors.error, size: 20),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
