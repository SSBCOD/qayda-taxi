import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radii.dart';
import '../../../core/theme/app_typography.dart';
import '../common/bilingual_text.dart';

/// Purple-gradient primary CTA button matching the Midnight design system.
class PrimaryActionButton extends StatelessWidget {
  final String label;
  final String? labelSecondary;
  final VoidCallback? onPressed;

  const PrimaryActionButton({
    super.key,
    required this.label,
    this.labelSecondary,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final enabled = onPressed != null;
    return AnimatedOpacity(
      duration: const Duration(milliseconds: 200),
      opacity: enabled ? 1.0 : 0.45,
      child: Container(
        height: 56,
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: enabled
              ? const LinearGradient(
                  colors: [Color(0xFFA78BFA), AppColors.purple, AppColors.purpleDark],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
              : const LinearGradient(
                  colors: [AppColors.outline, AppColors.outline],
                ),
          borderRadius: AppRadii.buttonRadius,
          boxShadow: enabled
              ? [
                  BoxShadow(
                    color: AppColors.purple.withValues(alpha: 0.35),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ]
              : null,
        ),
        child: Material(
          type: MaterialType.transparency,
          child: InkWell(
            onTap: enabled
                ? () {
                    HapticFeedback.mediumImpact();
                    onPressed!();
                  }
                : null,
            borderRadius: AppRadii.buttonRadius,
            splashColor: Colors.white.withValues(alpha: 0.15),
            child: Center(
              child: labelSecondary == null
                  ? Text(
                      label,
                      style: AppTypography.headlineMd.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                    )
                  : BilingualText(
                      primary: label,
                      secondary: labelSecondary!,
                      primaryMaxLines: 1,
                      secondaryMaxLines: 1,
                      primaryStyle: AppTypography.headlineMd.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                      secondaryStyle: AppTypography.bodyMd.copyWith(
                        color: Colors.white.withValues(alpha: 0.75),
                      ),
                    ),
            ),
          ),
        ),
      ),
    );
  }
}
