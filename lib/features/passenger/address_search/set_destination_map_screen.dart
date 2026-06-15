import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router/routes.dart';
import '../../../core/extensions/context_ext.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/widgets.dart';
import '../../../data/models/address.dart';
import '../../ride/map/map_controller.dart';
import 'application/address_providers.dart';

/// Pick a destination by panning the map under a fixed centre pin
/// (Stitch `set_destination_on_map_2gis_style` / `confirm_destination_2gis_style`).
///
/// The map centre resolves to a (mock) address shown in the bottom sheet;
/// "Сюда" confirms it as the destination and continues into route/tariff.
class SetDestinationMapScreen extends ConsumerWidget {
  const SetDestinationMapScreen({super.key});

  // Mock "address under the pin" — no geocoding in the demo.
  static const Address _centerAddress = Address(
    id: 'park',
    titleRu: 'Парк Первого Президента',
    titleKk: 'Тұңғыш Президент саябағы',
    fullText: 'просп. Аль-Фараби',
    lat: 43.2010,
    lng: 76.8920,
    type: 'search',
  );

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final topInset = MediaQuery.paddingOf(context).top;

    void confirm() {
      final map = ref.read(mapControllerProvider);
      final pickup = map.userPosition ?? map.center;
      ref.read(selectedOriginProvider.notifier).state =
          pickupAddressFromCoordinates(
        lat: pickup.latitude,
        lng: pickup.longitude,
      );
      ref.read(selectedDestinationProvider.notifier).state = _centerAddress;
      context.push(Routes.pTariff);
    }

    return Scaffold(
      body: Stack(
        children: [
          const Positioned.fill(child: QaydaMap()),

          // Fixed centre destination pin (overlay, non-interactive).
          const Positioned.fill(
            child: IgnorePointer(child: Center(child: _BouncePin())),
          ),

          // Back button (top-left glass).
          Positioned(
            top: topInset + AppSpacing.sm,
            left: AppSpacing.page,
            child: GlassFloatingButton(
              icon: Icons.arrow_back,
              size: 56,
              onPressed: () => context.pop(),
            ),
          ),

          // My-location (above the sheet).
          Positioned(
            right: AppSpacing.page,
            bottom: 200,
            child: GlassFloatingButton(
              icon: Icons.my_location,
              size: 56,
              onPressed: () =>
                  ref.read(mapControllerProvider.notifier).locateUser(),
            ),
          ),

          // Confirm sheet.
          Align(
            alignment: Alignment.bottomCenter,
            child: _ConfirmSheet(
              address: _centerAddress,
              onConfirm: confirm,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Bouncing centre pin with soft shadow (matches the Stitch pin animation).
// ─────────────────────────────────────────────────────────────────────────────
class _BouncePin extends StatefulWidget {
  const _BouncePin();

  @override
  State<_BouncePin> createState() => _BouncePinState();
}

class _BouncePinState extends State<_BouncePin>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 2),
  )..repeat(reverse: true);

  late final Animation<double> _lift = Tween(begin: 0.0, end: -8.0).animate(
    CurvedAnimation(parent: _c, curve: Curves.easeInOut),
  );

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _c,
      builder: (context, _) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Transform.translate(
              offset: Offset(0, _lift.value - 24),
              child: const Icon(
                Icons.location_on,
                size: 48,
                color: AppColors.locationBlue,
                shadows: [
                  Shadow(
                      color: Color(0x33000000),
                      blurRadius: 8,
                      offset: Offset(0, 4)),
                ],
              ),
            ),
            Transform.translate(
              offset: const Offset(0, -20),
              child: Container(
                width: 16,
                height: 5,
                decoration: BoxDecoration(
                  color: Colors.black.withValues(
                    alpha: 0.2 + (_c.value * 0.15),
                  ),
                  borderRadius: BorderRadius.circular(100),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Bottom confirm sheet: address row + "Сюда" CTA.
// ─────────────────────────────────────────────────────────────────────────────
class _ConfirmSheet extends StatelessWidget {
  final Address address;
  final VoidCallback onConfirm;
  const _ConfirmSheet({required this.address, required this.onConfirm});

  @override
  Widget build(BuildContext context) {
    final scheme = context.colors;
    final maxHeight = MediaQuery.sizeOf(context).height * 0.42;
    return ConstrainedBox(
      constraints: BoxConstraints(maxHeight: maxHeight),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: scheme.surfaceContainerLowest,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          border: Border(
            top:
                BorderSide(color: scheme.outlineVariant.withValues(alpha: 0.3)),
          ),
          boxShadow: const [
            BoxShadow(
              color: Color(0x0D000000),
              blurRadius: 20,
              offset: Offset(0, -4),
            ),
          ],
        ),
        child: SafeArea(
          top: false,
          child: SingleChildScrollView(
            physics: const ClampingScrollPhysics(),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.page,
                AppSpacing.sm,
                AppSpacing.page,
                AppSpacing.md,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const DragHandle(),
                  Row(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: scheme.surfaceContainer,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(Icons.location_on, color: scheme.primary),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              address.titleRu,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: AppTypography.headlineMd
                                  .copyWith(color: scheme.onSurface),
                            ),
                            Text(
                              address.fullText,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: AppTypography.bodyMd
                                  .copyWith(color: scheme.onSurfaceVariant),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  PrimaryActionButton(
                    label: 'Сюда',
                    labelSecondary: 'Осында',
                    onPressed: onConfirm,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
