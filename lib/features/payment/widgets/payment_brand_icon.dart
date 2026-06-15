import 'package:flutter/material.dart';

import '../../../core/theme/app_radii.dart';
import '../../../core/theme/app_typography.dart';
import '../../../data/models/payment_method.dart';

/// Coloured brand badge for a KZ payment method (Kaspi / Freedom / Halyk / cash).
class PaymentBrandIcon extends StatelessWidget {
  final PaymentMethod method;
  final double size;

  const PaymentBrandIcon({
    super.key,
    required this.method,
    this.size = 40,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isCash = method.kind == PaymentMethodKind.cash;

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: isCash ? scheme.surfaceContainerLow : method.brandColor,
        borderRadius:
            BorderRadius.circular(isCash ? size / 2 : AppRadii.button),
        border: isCash
            ? null
            : Border.all(color: scheme.outlineVariant.withValues(alpha: 0.3)),
      ),
      alignment: Alignment.center,
      child: isCash
          ? Icon(Icons.payments_outlined,
              size: size * 0.5, color: scheme.primary)
          : Text(
              method.brandShort,
              style: AppTypography.labelMd.copyWith(
                color: Colors.white,
                fontSize: method.brandShort.length > 5 ? 8 : 10,
                fontWeight: FontWeight.w700,
              ),
              textAlign: TextAlign.center,
            ),
    );
  }
}
