import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../theme/app_theme.dart';
import '../../services/notification_service.dart';

class SendNotificationScreen extends StatefulWidget {
  const SendNotificationScreen({super.key});

  @override
  State<SendNotificationScreen> createState() => _SendNotificationScreenState();
}

class _SendNotificationScreenState extends State<SendNotificationScreen> {
  final _titleController = TextEditingController();
  final _messageController = TextEditingController();
  bool _isSending = false;

  @override
  void dispose() {
    _titleController.dispose();
    _messageController.dispose();
    super.dispose();
  }

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

  Future<void> _sendNotification() async {
    if (_titleController.text.trim().isEmpty ||
        _messageController.text.trim().isEmpty) {
      _showSnackBar('Başlık ve mesaj gerekli', isError: true);
      return;
    }

    setState(() => _isSending = true);

    try {
      final success = await NotificationService.sendPushNotification(
        title: _titleController.text.trim(),
        message: _messageController.text.trim(),
      );

      if (success) {
        _showSnackBar('✅ Bildirim gönderildi!');
        _titleController.clear();
        _messageController.clear();
      } else {
        _showSnackBar('Bildirim gönderilemedi', isError: true);
      }
    } catch (e) {
      _showSnackBar('Hata: $e', isError: true);
    } finally {
      if (mounted) setState(() => _isSending = false);
    }
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
            'Bildirim Gönder',
            style: AppTextStyles.heading3.copyWith(color: AdminColors.textPrimary),
          ),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_rounded, color: AdminColors.textPrimary),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Info card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFE74C3C).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: const Color(0xFFE74C3C).withValues(alpha: 0.2),
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.info_outline_rounded,
                        color: Color(0xFFE74C3C), size: 22),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Bu bildirim tüm kayıtlı kullanıcılara gönderilecektir.',
                        style: AppTextStyles.body2.copyWith(
                          color: AdminColors.textSecondary,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Title
              Text(
                'Bildirim Başlığı',
                style: AppTextStyles.subtitle2.copyWith(color: AdminColors.textSecondary),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _titleController,
                style: TextStyle(color: AdminColors.textPrimary),
                decoration: InputDecoration(
                  hintText: 'Örn: Bugüne Özel İndirim!',
                  hintStyle: TextStyle(color: AdminColors.textTertiary),
                  filled: true,
                  fillColor: AdminColors.surface,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide.none,
                  ),
                  prefixIcon: const Icon(Icons.title_rounded,
                      color: AdminColors.textTertiary),
                ),
              ),
              const SizedBox(height: 20),

              // Message
              Text(
                'Bildirim Mesajı',
                style: AppTextStyles.subtitle2.copyWith(color: AdminColors.textSecondary),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _messageController,
                style: TextStyle(color: AdminColors.textPrimary),
                maxLines: 4,
                decoration: InputDecoration(
                  hintText: 'Bildirim içeriğini buraya yazın...',
                  hintStyle: TextStyle(color: AdminColors.textTertiary),
                  filled: true,
                  fillColor: AdminColors.surface,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 32),

              // Send button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isSending ? null : _sendNotification,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFE74C3C),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                  ),
                  child: _isSending
                      ? const SizedBox(
                          height: 24, width: 24,
                          child: CircularProgressIndicator(
                              color: Colors.white, strokeWidth: 2.5))
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.send_rounded, size: 20),
                            const SizedBox(width: 8),
                            Text('Bildirimi Gönder',
                                style: AppTextStyles.button),
                          ],
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
