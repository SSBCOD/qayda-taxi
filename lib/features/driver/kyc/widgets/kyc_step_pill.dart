import 'package:flutter/material.dart';

import '../../../../core/extensions/context_ext.dart';
import '../../../../core/theme/app_typography.dart';

/// Small rounded "Шаг N из M / N-қадам M-ден" indicator used across the KYC
/// onboarding steps (matches the Stitch sub-header pill).
class KycStepPill extends StatelessWidget {
  final String ru;
  final String kk;

  const KycStepPill({super.key, required this.ru, required this.kk});

  @override
  Widget build(BuildContext context) {
    final scheme = context.colors;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        '$ru / $kk',
        style: AppTypography.labelMd.copyWith(color: scheme.onSurfaceVariant),
      ),
    );
  }
}
