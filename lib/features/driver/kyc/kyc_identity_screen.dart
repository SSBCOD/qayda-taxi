import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router/routes.dart';
import '../../../core/extensions/context_ext.dart';
import '../../../core/theme/app_radii.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/widgets.dart';
import 'application/kyc_controller.dart';
import 'widgets/kyc_step_pill.dart';

/// Driver KYC · step 2 of 2 — identity verification
/// (Stitch `driver_onboarding_identity_verification`).
///
/// Collects the IIN and three document scans (ID front/back + driving licence).
/// Photo capture is faked: tapping a document tile toggles an "uploaded" state.
/// Submitting moves the application to review and opens the pending screen.
class KycIdentityScreen extends ConsumerStatefulWidget {
  const KycIdentityScreen({super.key});

  @override
  ConsumerState<KycIdentityScreen> createState() => _KycIdentityScreenState();
}

class _KycIdentityScreenState extends ConsumerState<KycIdentityScreen> {
  late final TextEditingController _iinController;
  bool _submitting = false;

  bool get _hasValidIinInput =>
      _iinController.text.replaceAll(RegExp(r'\D'), '').length == 12;

  @override
  void initState() {
    super.initState();
    _iinController = TextEditingController(
      text: ref.read(kycControllerProvider).iin,
    );
  }

  @override
  void dispose() {
    _iinController.dispose();
    super.dispose();
  }

  Future<void> _editIin(BuildContext context) async {
    final currentIin = ref.read(kycControllerProvider).iin;
    if (_iinController.text != currentIin) {
      _iinController.value = TextEditingValue(
        text: currentIin,
        selection: TextSelection.collapsed(offset: currentIin.length),
      );
    }

    final value = await showDialog<String>(
      context: context,
      builder: (context) {
        final scheme = Theme.of(context).colorScheme;
        return AlertDialog(
          backgroundColor: scheme.surfaceContainerLowest,
          title: const BilingualText(
            primary: 'Ваш ИИН',
            secondary: 'Сіздің ЖСН',
            textAlign: TextAlign.start,
            primaryStyle: AppTypography.headlineMd,
          ),
          content: TextField(
            controller: _iinController,
            autofocus: true,
            keyboardType: TextInputType.number,
            textInputAction: TextInputAction.done,
            maxLength: 12,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            onSubmitted: (value) => Navigator.of(context).pop(value.trim()),
            style: AppTypography.bodyLg,
            decoration: const InputDecoration(
              counterText: '',
              hintText: '12 цифр / 12 сан',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Отмена / Бас тарту'),
            ),
            FilledButton(
              onPressed: () =>
                  Navigator.of(context).pop(_iinController.text.trim()),
              child: const Text('Готово / Дайын'),
            ),
          ],
        );
      },
    );
    if (!mounted) return;
    if (value != null) {
      ref.read(kycControllerProvider.notifier).setIin(value);
    }
  }

  void _submit(BuildContext context) {
    if (_submitting) return;
    FocusScope.of(context).unfocus();
    setState(() => _submitting = true);
    ref.read(kycControllerProvider.notifier).setIin(_iinController.text);
    ref.read(kycControllerProvider.notifier).submitForReview();
    HapticFeedback.mediumImpact();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.go(Routes.kycPending);
    });
  }

  @override
  Widget build(BuildContext context) {
    final scheme = context.colors;
    final kyc = ref.watch(kycControllerProvider);
    final notifier = ref.read(kycControllerProvider.notifier);
    final documentsComplete =
        kyc.idFrontUploaded && kyc.idBackUploaded && kyc.licenseUploaded;
    final canSubmit = !_submitting &&
        documentsComplete &&
        (kyc.hasValidIin || _hasValidIinInput);

    return Scaffold(
      appBar: QaydaAppBar(
        title: 'Личные данные',
        subtitle: 'Жеке деректер',
        onBack: () => context.go(Routes.kycVehicle),
      ),
      body: SafeArea(
        top: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.page,
            AppSpacing.md,
            AppSpacing.page,
            AppSpacing.lg,
          ),
          children: [
            const Center(
              child: KycStepPill(
                ru: 'Шаг 2 из 2',
                kk: '2-қадам 2-ден',
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            const Text(
              'Укажите ИИН и документы',
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: AppTypography.headlineMobile,
            ),
            const SizedBox(height: 2),
            Text(
              'ЖСН және құжаттарды көрсетіңіз',
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style:
                  AppTypography.bodyMd.copyWith(color: scheme.onSurfaceVariant),
            ),
            const SizedBox(height: AppSpacing.lg),
            // IIN.
            Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: _submitting ? null : () => _editIin(context),
                borderRadius: BorderRadius.circular(AppRadii.input),
                child: Ink(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  decoration: BoxDecoration(
                    color: scheme.surfaceContainerLow,
                    borderRadius: BorderRadius.circular(AppRadii.input),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Ваш ИИН / Сіздің ЖСН',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: AppTypography.labelMd
                                  .copyWith(color: scheme.onSurfaceVariant),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              kyc.maskedIin,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: AppTypography.headlineMd
                                  .copyWith(letterSpacing: 3),
                            ),
                          ],
                        ),
                      ),
                      Icon(Icons.chevron_right, color: scheme.onSurfaceVariant),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            _DocTile(
              icon: Icons.badge_outlined,
              labelRu: 'Удостоверение личности (лицевая сторона)',
              labelKk: 'Жеке куәлік (алдыңғы жағы)',
              uploaded: kyc.idFrontUploaded,
              onTap: () => notifier.setIdFront(!kyc.idFrontUploaded),
            ),
            const SizedBox(height: AppSpacing.gutter),
            _DocTile(
              icon: Icons.badge_outlined,
              labelRu: 'Удостоверение личности (обратная сторона)',
              labelKk: 'Жеке куәлік (артқы жағы)',
              uploaded: kyc.idBackUploaded,
              onTap: () => notifier.setIdBack(!kyc.idBackUploaded),
            ),
            const SizedBox(height: AppSpacing.gutter),
            _DocTile(
              icon: Icons.card_membership_outlined,
              labelRu: 'Водительское удостоверение',
              labelKk: 'Жүргізуші куәлігі',
              uploaded: kyc.licenseUploaded,
              onTap: () => notifier.setLicense(!kyc.licenseUploaded),
            ),
            const SizedBox(height: AppSpacing.lg),
            _ReviewNoticeCard(),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.page,
            0,
            AppSpacing.page,
            AppSpacing.md,
          ),
          child: PrimaryActionButton(
            label: 'Отправить на проверку',
            labelSecondary: 'Тексеруге жіберу',
            onPressed: canSubmit ? () => _submit(context) : null,
          ),
        ),
      ),
    );
  }
}

/// Document upload row: icon + bilingual label + capture/uploaded affordance.
class _DocTile extends StatelessWidget {
  final IconData icon;
  final String labelRu;
  final String labelKk;
  final bool uploaded;
  final VoidCallback onTap;

  const _DocTile({
    required this.icon,
    required this.labelRu,
    required this.labelKk,
    required this.uploaded,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = context.colors;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadii.input),
        child: Ink(
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: scheme.surfaceContainerLow,
            borderRadius: BorderRadius.circular(AppRadii.input),
          ),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: scheme.surfaceContainerLowest,
                  borderRadius: BorderRadius.circular(AppRadii.input - 4),
                ),
                child: Icon(icon, color: scheme.onSurfaceVariant),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      labelRu,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.bodyLg,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      labelKk,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.bodyMd
                          .copyWith(color: scheme.onSurfaceVariant),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Icon(
                uploaded ? Icons.check_circle : Icons.add_a_photo_outlined,
                color: uploaded
                    ? const Color(0xFF34C759)
                    : scheme.onSurfaceVariant,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Bordered notice explaining the 24h security review.
class _ReviewNoticeCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final scheme = context.colors;
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppRadii.input),
        border: Border.all(color: scheme.outlineVariant),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: scheme.surfaceContainerHigh,
              borderRadius: BorderRadius.circular(AppRadii.input - 4),
            ),
            child: Icon(Icons.shield_outlined, color: scheme.onSurfaceVariant),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Expanded(
                      child: Text(
                        'Проверка документов',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTypography.headlineMd,
                      ),
                    ),
                    Icon(Icons.schedule, color: scheme.onSurfaceVariant),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  'Ваши данные будут проверены службой безопасности в течение '
                  '24 часов. / Деректеріңіз қауіпсіздік қызметімен 24 сағат '
                  'ішінде тексеріледі.',
                  maxLines: 6,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.bodyMd
                      .copyWith(color: scheme.onSurfaceVariant),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
