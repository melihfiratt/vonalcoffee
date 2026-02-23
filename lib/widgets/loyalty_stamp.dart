import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class LoyaltyStamp extends StatelessWidget {
  final bool isFilled;
  final int index;
  final int total;

  const LoyaltyStamp({
    super.key,
    required this.isFilled,
    required this.index,
    required this.total,
  });

  @override
  Widget build(BuildContext context) {
    final isLast = index == total - 1;

    return Column(
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: isFilled
                ? AppColors.primary
                : isLast
                    ? AppColors.gold.withValues(alpha: 0.12)
                    : AppColors.surface,
            shape: BoxShape.circle,
            border: Border.all(
              color: isFilled
                  ? AppColors.primary
                  : isLast
                      ? AppColors.gold
                      : AppColors.divider,
              width: isLast && !isFilled ? 1.5 : 1,
            ),
            boxShadow: isFilled
                ? [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.2),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : [],
          ),
          child: Icon(
            isLast && !isFilled
                ? Icons.card_giftcard_rounded
                : Icons.local_cafe_rounded,
            size: 18,
            color: isFilled
                ? Colors.white
                : isLast
                    ? AppColors.gold
                    : AppColors.textTertiary,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          '${index + 1}',
          style: AppTextStyles.caption.copyWith(
            fontSize: 10,
            fontWeight: isFilled ? FontWeight.w600 : FontWeight.w400,
            color: isFilled ? AppColors.primary : AppColors.textTertiary,
          ),
        ),
      ],
    );
  }
}
