import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../app/router/routes.dart';
import '../../../core/extensions/context_ext.dart';
import '../../../core/extensions/num_ext.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radii.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/widgets.dart';
import 'application/driver_referral_providers.dart';

/// Driver referral partner program (Stitch
/// `driver_referral_partner_program_bilingual`).
///
/// Total referral earnings in ₸, personal promo code, perk carousel and
/// active referrals list with share/copy actions.
class DriverReferralScreen extends ConsumerWidget {
  const DriverReferralScreen({super.key});

  void _copyText(BuildContext context, String text, String message) {
    HapticFeedback.selectionClick();
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          behavior: SnackBarBehavior.floating,
        ),
      );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheme = context.colors;
    final referral = ref.watch(driverReferralProvider);

    return Scaffold(
      backgroundColor: scheme.surface,
      appBar: QaydaAppBar(
        title: 'Пригласить друга / Досыңды шақыр',
        glass: false,
        onBack: () => context.popOrGo(Routes.dDashboard),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.page,
          AppSpacing.lg,
          AppSpacing.page,
          120,
        ),
        children: [
          // Total earnings card.
          QaydaCard(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              children: [
                Text(
                  'Заработано на рефералах / Рефералдардан тапқан табыс',
                  textAlign: TextAlign.center,
                  style: AppTypography.labelMd
                      .copyWith(color: scheme.onSurfaceVariant),
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  referral.totalEarningsTenge.tenge,
                  style: AppTypography.displayLg,
                ),
                const SizedBox(height: AppSpacing.md),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.stars, size: 18, color: scheme.primary),
                    const SizedBox(width: 4),
                    Text(
                      '${referral.eliteLabelRu} / ${referral.eliteLabelKk}',
                      style: AppTypography.labelMd,
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.lg),

          const _SectionLabel(
            text: 'Ваш промокод / Сіздің промокодыңыз',
          ),
          const SizedBox(height: AppSpacing.sm),
          Material(
            color: scheme.surfaceContainerLow,
            borderRadius: AppRadii.cardRadius,
            child: InkWell(
              onTap: () => _copyText(
                context,
                referral.promoCode,
                'Скопировано / Көшірілді',
              ),
              borderRadius: AppRadii.cardRadius,
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        referral.promoCode,
                        style: AppTypography.headlineMobile.copyWith(
                          letterSpacing: 4,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: scheme.surfaceContainerLowest,
                        borderRadius: BorderRadius.circular(AppRadii.button),
                        border: Border.all(
                          color: scheme.outlineVariant.withValues(alpha: 0.5),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.content_copy,
                              size: 16, color: scheme.primary),
                          const SizedBox(width: 4),
                          const Text(
                            'Копировать / Көшіру',
                            style: AppTypography.labelMd,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),

          const _SectionLabel(text: 'Привилегии / Артықшылықтар'),
          const SizedBox(height: AppSpacing.sm),
          SizedBox(
            height: 140,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: referral.perks.length,
              separatorBuilder: (_, __) => const SizedBox(width: AppSpacing.md),
              itemBuilder: (context, i) => _PerkCard(perk: referral.perks[i]),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const _SectionLabel(
                text: 'Активные рефералы / Белсенді рефералдар',
                padding: EdgeInsets.zero,
              ),
              Text(
                'Всего: ${referral.referrals.length} / Барлығы: ${referral.referrals.length}',
                style: AppTypography.labelMd,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          ...referral.referrals.map(
            (e) => Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.sm),
              child: _ReferralRow(entry: e),
            ),
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.fromLTRB(
          AppSpacing.page,
          AppSpacing.sm,
          AppSpacing.page,
          AppSpacing.md,
        ),
        child: PrimaryActionButton(
          label: 'Поделиться ссылкой',
          labelSecondary: 'Сілтемемен бөлісу',
          onPressed: () => _copyText(
            context,
            referral.shareLink,
            'Ссылка скопирована / Сілтеме көшірілді',
          ),
        ),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String text;
  final EdgeInsetsGeometry padding;

  const _SectionLabel({
    required this.text,
    this.padding = const EdgeInsets.symmetric(horizontal: 4),
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: padding,
      child: Text(
        text,
        style: AppTypography.labelMd.copyWith(
          color: scheme.onSurfaceVariant,
          letterSpacing: 1.2,
        ),
      ),
    );
  }
}

class _PerkCard extends StatelessWidget {
  final ReferralPerk perk;

  const _PerkCard({required this.perk});

  @override
  Widget build(BuildContext context) {
    final scheme = context.colors;
    final highlighted = perk.highlighted;

    return Container(
      width: 256,
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: highlighted ? scheme.primary : scheme.surfaceContainerLowest,
        borderRadius: AppRadii.cardRadius,
        border: highlighted
            ? null
            : Border.all(color: scheme.outlineVariant.withValues(alpha: 0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            highlighted ? Icons.payments_outlined : Icons.verified_outlined,
            size: 32,
            color: highlighted ? scheme.onPrimary : scheme.primary,
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            '${perk.titleRu} / ${perk.titleKk}',
            style: AppTypography.bodyLg.copyWith(
              fontWeight: FontWeight.w700,
              color: highlighted ? scheme.onPrimary : scheme.primary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '${perk.subtitleRu} / ${perk.subtitleKk}',
            style: AppTypography.bodyMd.copyWith(
              color: highlighted
                  ? scheme.onPrimary.withValues(alpha: 0.8)
                  : scheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

class _ReferralRow extends StatelessWidget {
  final ReferralEntry entry;

  const _ReferralRow({required this.entry});

  @override
  Widget build(BuildContext context) {
    final scheme = context.colors;
    final completed = entry.status == ReferralStatus.completed;

    return Opacity(
      opacity: completed ? 0.6 : 1,
      child: QaydaCard(
        bordered: !completed,
        color: completed ? scheme.surfaceContainerLow : null,
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Row(
          children: [
            CircleAvatar(
              radius: 24,
              backgroundColor: scheme.surfaceContainerHigh,
              child: completed
                  ? Icon(Icons.person, color: scheme.secondary)
                  : Text(
                      entry.nameRu[0],
                      style: AppTypography.headlineMd,
                    ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${entry.nameRu} / ${entry.nameKk}',
                    style: AppTypography.bodyLg.copyWith(
                      fontWeight: FontWeight.w600,
                      color: completed ? scheme.secondary : scheme.primary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  if (completed)
                    Text(
                      'Завершено / Аяқталды',
                      style: AppTypography.labelMd.copyWith(
                        color: scheme.onSurfaceVariant,
                        fontSize: 11,
                      ),
                    )
                  else
                    Row(
                      children: [
                        Container(
                          width: 6,
                          height: 6,
                          decoration: BoxDecoration(
                            color: entry.status == ReferralStatus.active
                                ? AppColors.online
                                : const Color(0xFFF59E0B),
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Flexible(
                          child: Text(
                            _statusLine(entry),
                            style: AppTypography.labelMd.copyWith(
                              color: scheme.onSurfaceVariant,
                              fontSize: 11,
                            ),
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                if (completed)
                  Text(
                    'Зачислено / Енгізілді',
                    style: AppTypography.priceDisplay
                        .copyWith(color: scheme.secondary),
                  )
                else
                  Text(
                    entry.rewardTenge.tenge,
                    style: AppTypography.priceDisplay,
                  ),
                const SizedBox(height: 2),
                if (completed)
                  const Icon(Icons.check_circle,
                      size: 18, color: AppColors.online)
                else if (entry.statusLabelRu != null)
                  Text(
                    '${entry.statusLabelRu} / ${entry.statusLabelKk}',
                    style: AppTypography.labelMd.copyWith(
                      color: scheme.onSurfaceVariant,
                      fontSize: 10,
                      letterSpacing: 0.5,
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _statusLine(ReferralEntry entry) {
    final orders = '${entry.completedOrders}/${entry.targetOrders} тапсырыс';
    return switch (entry.status) {
      ReferralStatus.active => 'Активен • $orders / Белсенді • $orders',
      ReferralStatus.pending => 'В ожидании • $orders / Күтуде • $orders',
      ReferralStatus.completed => '',
    };
  }
}
