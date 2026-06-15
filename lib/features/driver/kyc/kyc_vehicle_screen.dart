import 'package:flutter/material.dart';
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

/// Driver KYC · step 1 of 2 — vehicle details
/// (Stitch `driver_onboarding_vehicle_details`).
///
/// Brand/model, year, KZ plate and colour are pre-filled with demo defaults and
/// editable via lightweight sheets/dialogs. Confirming advances to the identity
/// step. An auto-detection card derives the available tariff from the vehicle.
class KycVehicleScreen extends ConsumerWidget {
  const KycVehicleScreen({super.key});

  Future<void> _editBrandModel(BuildContext context, WidgetRef ref) async {
    final value = await _promptText(
      context,
      titleRu: 'Марка и модель',
      titleKk: 'Марка және модель',
      initial: ref.read(kycControllerProvider).brandModel,
    );
    if (value != null && value.isNotEmpty) {
      ref.read(kycControllerProvider.notifier).setBrandModel(value);
    }
  }

  Future<void> _editYear(BuildContext context, WidgetRef ref) async {
    final value = await _promptText(
      context,
      titleRu: 'Год выпуска',
      titleKk: 'Шығарылған жылы',
      initial: ref.read(kycControllerProvider).year.toString(),
      keyboardType: TextInputType.number,
      maxLength: 4,
    );
    final year = int.tryParse(value ?? '');
    if (year != null && year > 1950 && year <= DateTime.now().year + 1) {
      ref.read(kycControllerProvider.notifier).setYear(year);
    }
  }

  Future<void> _editPlate(BuildContext context, WidgetRef ref) async {
    final value = await _promptText(
      context,
      titleRu: 'Госномер РК',
      titleKk: 'МНӨ (мемлекеттік нөмір)',
      initial: ref.read(kycControllerProvider).plate,
      maxLength: 10,
    );
    if (value != null && value.isNotEmpty) {
      ref.read(kycControllerProvider.notifier).setPlate(value);
    }
  }

  Future<void> _editColor(BuildContext context, WidgetRef ref) async {
    final current = ref.read(kycControllerProvider).colorRu;
    final color = await showModalBottomSheet<VehicleColor>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => _ColorSheet(currentRu: current),
    );
    if (color != null) {
      ref.read(kycControllerProvider.notifier).setColor(color);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheme = context.colors;
    final kyc = ref.watch(kycControllerProvider);

    return Scaffold(
      appBar: const QaydaAppBar(
        title: 'Данные авто',
        subtitle: 'Автомобиль деректері',
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
                ru: 'Шаг 1 из 2',
                kk: '1-қадам 2-ден',
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            const Text(
              'Укажите данные машины',
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: AppTypography.headlineMobile,
            ),
            const SizedBox(height: 2),
            Text(
              'Көлік деректерін көрсетіңіз',
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style:
                  AppTypography.bodyMd.copyWith(color: scheme.onSurfaceVariant),
            ),
            const SizedBox(height: AppSpacing.lg),
            _FieldTile(
              labelRu: 'Марка и модель',
              labelKk: 'Марка және модель',
              value: kyc.brandModel,
              onTap: () => _editBrandModel(context, ref),
            ),
            const SizedBox(height: AppSpacing.sm),
            _FieldTile(
              labelRu: 'Год выпуска',
              labelKk: 'Шығарылған жылы',
              value: kyc.year.toString(),
              onTap: () => _editYear(context, ref),
            ),
            const SizedBox(height: AppSpacing.sm),
            _PlateTile(plate: kyc.plate, onTap: () => _editPlate(context, ref)),
            const SizedBox(height: AppSpacing.sm),
            _FieldTile(
              labelRu: 'Цвет',
              labelKk: 'Түсі',
              value: '${kyc.colorRu} / ${kyc.colorKk}',
              leading: Container(
                width: 16,
                height: 16,
                decoration: BoxDecoration(
                  color: kyc.colorSwatch,
                  shape: BoxShape.circle,
                  border: Border.all(color: scheme.outlineVariant),
                ),
              ),
              onTap: () => _editColor(context, ref),
            ),
            const SizedBox(height: AppSpacing.lg),
            _TariffDetectionCard(
              tierRu: kyc.tierLabelRu,
              tierKk: kyc.tierLabelKk,
            ),
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
            label: 'Подтвердить',
            labelSecondary: 'Растау',
            onPressed: () => context.go(Routes.kycIdentity),
          ),
        ),
      ),
    );
  }
}

/// Text prompt dialog returning the trimmed entered value (or null on cancel).
Future<String?> _promptText(
  BuildContext context, {
  required String titleRu,
  required String titleKk,
  required String initial,
  TextInputType keyboardType = TextInputType.text,
  int? maxLength,
}) async {
  final controller = TextEditingController(text: initial);
  try {
    return await showDialog<String>(
      context: context,
      builder: (context) {
        final scheme = Theme.of(context).colorScheme;
        return AlertDialog(
          backgroundColor: scheme.surfaceContainerLowest,
          title: BilingualText(
            primary: titleRu,
            secondary: titleKk,
            textAlign: TextAlign.start,
            primaryStyle: AppTypography.headlineMd,
          ),
          content: TextField(
            controller: controller,
            autofocus: true,
            keyboardType: keyboardType,
            maxLength: maxLength,
            textCapitalization: TextCapitalization.characters,
            style: AppTypography.bodyLg,
            decoration: const InputDecoration(counterText: ''),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Отмена / Бас тарту'),
            ),
            FilledButton(
              onPressed: () =>
                  Navigator.of(context).pop(controller.text.trim()),
              child: const Text('Готово / Дайын'),
            ),
          ],
        );
      },
    );
  } finally {
    controller.dispose();
  }
}

/// Generic editable form row: label + value + chevron, on a low-surface card.
class _FieldTile extends StatelessWidget {
  final String labelRu;
  final String labelKk;
  final String value;
  final Widget? leading;
  final VoidCallback onTap;

  const _FieldTile({
    required this.labelRu,
    required this.labelKk,
    required this.value,
    required this.onTap,
    this.leading,
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
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '$labelRu / $labelKk',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.labelMd
                          .copyWith(color: scheme.onSurfaceVariant),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        if (leading != null) ...[
                          leading!,
                          const SizedBox(width: AppSpacing.sm),
                        ],
                        Flexible(
                          child: Text(value,
                              style: AppTypography.bodyLg,
                              overflow: TextOverflow.ellipsis),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right, color: scheme.onSurfaceVariant),
            ],
          ),
        ),
      ),
    );
  }
}

/// KZ license-plate field: realistic plate rendering + KZ flag block.
class _PlateTile extends StatelessWidget {
  final String plate;
  final VoidCallback onTap;

  const _PlateTile({required this.plate, required this.onTap});

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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Госномер РК / МНӨ',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTypography.labelMd
                    .copyWith(color: scheme.onSurfaceVariant),
              ),
              const SizedBox(height: AppSpacing.sm),
              Container(
                height: 40,
                constraints: const BoxConstraints(maxWidth: 220),
                decoration: BoxDecoration(
                  color: scheme.surfaceContainerLowest,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: scheme.outlineVariant),
                ),
                clipBehavior: Clip.antiAlias,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Flexible(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 14),
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            plate,
                            maxLines: 1,
                            style: AppTypography.priceDisplay.copyWith(
                              letterSpacing: 2,
                              color: scheme.onSurface,
                            ),
                          ),
                        ),
                      ),
                    ),
                    Container(width: 1, color: scheme.outlineVariant),
                    Container(
                      width: 36,
                      alignment: Alignment.center,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 18,
                            height: 12,
                            decoration: BoxDecoration(
                              color: const Color(0xFF00B0F0),
                              borderRadius: BorderRadius.circular(1),
                            ),
                            alignment: Alignment.center,
                            child: Container(
                              width: 6,
                              height: 6,
                              decoration: const BoxDecoration(
                                color: Color(0xFFFCE300),
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),
                          const SizedBox(height: 1),
                          Text(
                            'KZ',
                            style: TextStyle(
                              fontSize: 9,
                              height: 1,
                              fontWeight: FontWeight.w700,
                              color: scheme.onSurface,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Auto-detection result: 3D-render placeholder + available tariff + check.
class _TariffDetectionCard extends StatelessWidget {
  final String tierRu;
  final String tierKk;

  const _TariffDetectionCard({required this.tierRu, required this.tierKk});

  @override
  Widget build(BuildContext context) {
    final scheme = context.colors;
    return QaydaCard(
      child: Row(
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: scheme.surfaceContainerLow,
              borderRadius: BorderRadius.circular(AppRadii.input),
              border: Border.all(
                  color: scheme.outlineVariant.withValues(alpha: 0.5)),
            ),
            child: Icon(Icons.directions_car,
                size: 36, color: scheme.onSurfaceVariant),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Доступный тариф: $tierRu',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.labelMd
                      .copyWith(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 4),
                Text(
                  'Қолжетімді тариф: $tierKk',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.bodyMd
                      .copyWith(color: scheme.onSurfaceVariant),
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          const Icon(Icons.check_circle, color: Color(0xFF34C759), size: 28),
        ],
      ),
    );
  }
}

/// Bottom sheet for picking a vehicle colour from [kVehicleColors].
class _ColorSheet extends StatelessWidget {
  final String currentRu;
  const _ColorSheet({required this.currentRu});

  @override
  Widget build(BuildContext context) {
    final scheme = context.colors;
    return Container(
      decoration: BoxDecoration(
        color: scheme.surfaceContainerLowest,
        borderRadius: AppRadii.sheetRadius,
      ),
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.page,
        AppSpacing.sm,
        AppSpacing.page,
        AppSpacing.lg,
      ),
      child: SafeArea(
        top: false,
        child: SingleChildScrollView(
          physics: const ClampingScrollPhysics(),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Center(child: DragHandle()),
              const SizedBox(height: AppSpacing.md),
              const Text(
                'Цвет автомобиля',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTypography.headlineMd,
              ),
              const SizedBox(height: 2),
              Text('Көлік түсі',
                  style: AppTypography.bodyMd
                      .copyWith(color: scheme.onSurfaceVariant)),
              const SizedBox(height: AppSpacing.md),
              for (final color in kVehicleColors)
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  onTap: () => Navigator.of(context).pop(color),
                  leading: Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: color.value,
                      shape: BoxShape.circle,
                      border: Border.all(color: scheme.outlineVariant),
                    ),
                  ),
                  title: Text(
                    '${color.ru} / ${color.kk}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTypography.bodyLg,
                  ),
                  trailing: color.ru == currentRu
                      ? Icon(Icons.check, color: scheme.primary)
                      : null,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
