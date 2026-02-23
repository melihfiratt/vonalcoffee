import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../theme/app_theme.dart';
import '../../services/firestore_service.dart';

class ManageAdminsScreen extends StatefulWidget {
  const ManageAdminsScreen({super.key});

  @override
  State<ManageAdminsScreen> createState() => _ManageAdminsScreenState();
}

class _ManageAdminsScreenState extends State<ManageAdminsScreen> {
  final _emailController = TextEditingController();
  final _firestoreService = FirestoreService();
  bool _isLoading = false;
  String? _resultMessage;
  bool _isError = false;

  @override
  void dispose() {
    _emailController.dispose();
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

  Future<void> _searchAndMakeAdmin() async {
    final email = _emailController.text.trim();
    if (email.isEmpty) {
      _showSnackBar('Email adresi girin', isError: true);
      return;
    }

    setState(() {
      _isLoading = true;
      _resultMessage = null;
    });

    try {
      // Single read
      final user = await _firestoreService.getUserByEmail(email);
      if (user == null) {
        setState(() {
          _resultMessage = 'Kullanıcı bulunamadı: $email';
          _isError = true;
        });
        return;
      }

      if (user.isAdmin) {
        setState(() {
          _resultMessage = '${user.fullName} zaten admin.';
          _isError = false;
        });
        return;
      }

      // Single write
      await _firestoreService.updateUserRole(user.id, 'admin');
      setState(() {
        _resultMessage = '✅ ${user.fullName} admin olarak atandı!';
        _isError = false;
      });
      _emailController.clear();
    } catch (e) {
      setState(() {
        _resultMessage = 'Hata: $e';
        _isError = true;
      });
    } finally {
      if (mounted) setState(() => _isLoading = false);
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
            'Admin Yönetimi',
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
              // Info
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF9B59B6).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: const Color(0xFF9B59B6).withValues(alpha: 0.2),
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.admin_panel_settings_rounded,
                        color: Color(0xFF9B59B6), size: 22),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Email adresi ile kayıtlı bir kullanıcıyı admin olarak atayabilirsiniz.',
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

              // Email input
              Text(
                'Kullanıcı Email',
                style: AppTextStyles.subtitle2.copyWith(color: AdminColors.textSecondary),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                style: TextStyle(color: AdminColors.textPrimary),
                decoration: InputDecoration(
                  hintText: 'ornek@email.com',
                  hintStyle: TextStyle(color: AdminColors.textTertiary),
                  filled: true,
                  fillColor: AdminColors.surface,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide.none,
                  ),
                  prefixIcon: const Icon(Icons.email_outlined,
                      color: AdminColors.textTertiary),
                ),
              ),
              const SizedBox(height: 20),

              // Search & assign button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _searchAndMakeAdmin,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF9B59B6),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          height: 20, width: 20,
                          child: CircularProgressIndicator(
                              color: Colors.white, strokeWidth: 2))
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.person_add_rounded, size: 20),
                            const SizedBox(width: 8),
                            Text('Admin Olarak Ata',
                                style: AppTextStyles.button),
                          ],
                        ),
                ),
              ),

              // Result message
              if (_resultMessage != null) ...[
                const SizedBox(height: 20),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: _isError
                        ? AppColors.error.withValues(alpha: 0.1)
                        : AdminColors.accent.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: _isError
                          ? AppColors.error.withValues(alpha: 0.2)
                          : AdminColors.accent.withValues(alpha: 0.2),
                    ),
                  ),
                  child: Text(
                    _resultMessage!,
                    style: AppTextStyles.body1.copyWith(
                      color: _isError ? AppColors.error : AdminColors.accent,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
