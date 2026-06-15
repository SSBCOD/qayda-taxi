import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';

import '../../../app/router/routes.dart';
import '../../../core/extensions/context_ext.dart';
import '../../../core/theme/app_radii.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/widgets.dart';
import '../../../data/models/address.dart';
import '../../../data/models/enums.dart';
import '../../../data/models/tariff.dart';
import '../../payment/application/payment_controller.dart';
import '../../ride/application/ride_controller.dart';
import '../../ride/map/map_controller.dart';
import '../address_search/application/address_providers.dart';
import 'application/trip_quote_provider.dart';
import 'tariff_providers.dart';

/// Route overview + trip request (the "passenger map screen").
///
/// Map background with the planned route, a floating duration/distance badge
/// and the trip‑request bottom sheet: horizontally scrollable [TariffCard]s,
/// a payment row and the "Заказать …" CTA which creates the Ride and pushes
/// the wait screen.
class RouteTariffScreen extends ConsumerStatefulWidget {
  const RouteTariffScreen({super.key});

  @override
  ConsumerState<RouteTariffScreen> createState() => _RouteTariffScreenState();
}

class _RouteTariffScreenState extends ConsumerState<RouteTariffScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _drawRoute());
  }

  void _drawRoute() {
    final origin = _originForTrip();
    final dest = _destinationForTrip();
    ref.read(mapControllerProvider.notifier).setRoute(
          origin: LatLng(origin.lat, origin.lng),
          destination: LatLng(dest.lat, dest.lng),
        );
  }

  Address _originForTrip() {
    final selected = ref.read(selectedOriginProvider);
    if (selected != null) return selected;

    final map = ref.read(mapControllerProvider);
    final pickup = map.userPosition ?? map.center;
    final origin = pickupAddressFromCoordinates(
      lat: pickup.latitude,
      lng: pickup.longitude,
    );
    ref.read(selectedOriginProvider.notifier).state = origin;
    return origin;
  }

  Address _destinationForTrip() {
    return ref.read(selectedDestinationProvider) ?? kMockDestination;
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(selectedDestinationProvider, (prev, next) {
      if (prev != next) _drawRoute();
    });
    ref.listen(selectedOriginProvider, (prev, next) {
      if (prev != next) _drawRoute();
    });

    final topInset = MediaQuery.paddingOf(context).top;
    final tariffs = ref.watch(tariffsProvider);
    final selectedTier = ref.watch(selectedTierProvider);
    final payment = ref.watch(paymentControllerProvider);
    final quoteAsync = ref.watch(tripQuoteProvider);
    final badgeText = quoteAsync.when(
      data: (q) => q.badgeText,
      loading: () => TripQuote.fallback.badgeText,
      error: (_, __) => TripQuote.fallback.badgeText,
    );

    return Scaffold(
      body: Stack(
        children: [
          const Positioned.fill(child: QaydaMap()),

          // Planned-route badge.
          Positioned(
            top: topInset + 64,
            left: 0,
            right: 0,
            child: Center(child: _RouteBadge(text: badgeText)),
          ),

          // Back control.
          Positioned(
            top: topInset + 8,
            left: AppSpacing.page,
            child: GlassFloatingButton(
              icon: Icons.arrow_back,
              size: 48,
              onPressed: () => _close(context),
            ),
          ),

          // Map controls (zoom + my-location).
          Positioned(
            top: topInset + 72,
            right: AppSpacing.page,
            child: MapControls(
              onZoomIn: () {},
              onZoomOut: () {},
              onMyLocation: () =>
                  ref.read(mapControllerProvider.notifier).locateUser(),
            ),
          ),

          // Trip request sheet.
          Align(
            alignment: Alignment.bottomCenter,
            child: _TripRequestSheet(
              tariffs: tariffs,
              selectedTier: selectedTier,
              paymentLabel: payment.selected.displayLabelRu,
              onSelect: (tier) =>
                  ref.read(selectedTierProvider.notifier).state = tier,
              onPaymentTap: () => context.push(Routes.payment),
              onConfirm: () => _order(context),
            ),
          ),
        ],
      ),
    );
  }

  void _close(BuildContext context) {
    if (context.canPop()) {
      context.pop();
    } else {
      context.go(Routes.pHome);
    }
  }

  Future<void> _order(BuildContext context) async {
    final tier = ref.read(selectedTierProvider);
    final tariff = ref.read(tariffsProvider).firstWhere((t) => t.tier == tier);

    final origin = _originForTrip();
    final destination = _destinationForTrip();
    final selectedPayment = ref.read(paymentControllerProvider).selected;
    final quote = await _quoteForTrip();
    if (!context.mounted) return;

    await ref.read(rideControllerProvider.notifier).createOrder(
          origin: origin,
          destination: destination,
          tier: tier,
          priceTenge: tariff.priceTenge,
          distanceKm: quote.distanceKm,
          durationMin: quote.durationMin,
          paymentLabel: selectedPayment.displayLabelRu,
          paymentType: selectedPayment.paymentType,
        );

    if (!context.mounted) return;
    context.push(Routes.pRideWait);
  }

  Future<TripQuote> _quoteForTrip() async {
    try {
      return await ref.read(tripQuoteProvider.future);
    } catch (_) {
      return TripQuote.fallback;
    }
  }
}

// ─────────────────────────────────────────────────────────────────────────────
class _RouteBadge extends StatelessWidget {
  final String text;
  const _RouteBadge({required this.text});

  @override
  Widget build(BuildContext context) {
    final scheme = context.colors;
    return Container(
      constraints: BoxConstraints(
        maxWidth: MediaQuery.sizeOf(context).width - (AppSpacing.page * 2),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: scheme.surface.withValues(alpha: 0.88),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: scheme.outlineVariant.withValues(alpha: 0.5),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.navigation, size: 18, color: scheme.primary),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              text,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTypography.labelMd.copyWith(color: scheme.primary),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
class _TripRequestSheet extends StatelessWidget {
  final List<Tariff> tariffs;
  final RideTier selectedTier;
  final String paymentLabel;
  final ValueChanged<RideTier> onSelect;
  final VoidCallback onPaymentTap;
  final VoidCallback onConfirm;

  const _TripRequestSheet({
    required this.tariffs,
    required this.selectedTier,
    required this.paymentLabel,
    required this.onSelect,
    required this.onPaymentTap,
    required this.onConfirm,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = context.colors;

    final maxHeight = MediaQuery.sizeOf(context).height * 0.64;
    return ConstrainedBox(
      constraints: BoxConstraints(maxHeight: maxHeight),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: scheme.surfaceContainerLowest,
          borderRadius: AppRadii.sheetRadius,
          border: Border(
            top:
                BorderSide(color: scheme.outlineVariant.withValues(alpha: 0.3)),
          ),
          boxShadow: const [
            BoxShadow(
              color: Color(0x14000000),
              blurRadius: 30,
              offset: Offset(0, -8),
            ),
          ],
        ),
        child: SafeArea(
          top: false,
          child: SingleChildScrollView(
            physics: const ClampingScrollPhysics(),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const DragHandle(),
                // Tariff cards (horizontal).
                SizedBox(
                  height: 148,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.page,
                      vertical: AppSpacing.sm,
                    ),
                    itemCount: tariffs.length,
                    separatorBuilder: (_, __) =>
                        const SizedBox(width: AppSpacing.gutter),
                    itemBuilder: (context, i) {
                      final t = tariffs[i];
                      final selected = t.tier == selectedTier;
                      return Align(
                        alignment: Alignment.bottomCenter,
                        child: TariffCard(
                          title: t.titleRu,
                          priceTenge: t.priceTenge,
                          etaMinutes: t.etaPickupMin,
                          selected: selected,
                          onTap: () => onSelect(t.tier),
                        ),
                      );
                    },
                  ),
                ),
                // Payment row.
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.page,
                    AppSpacing.sm,
                    AppSpacing.page,
                    AppSpacing.md,
                  ),
                  child: _PaymentRow(label: paymentLabel, onTap: onPaymentTap),
                ),
                // CTA.
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.page,
                    0,
                    AppSpacing.page,
                    AppSpacing.md,
                  ),
                  child: PrimaryActionButton(
                    label: 'Заказать ${selectedTier.orderFormRu}',
                    labelSecondary: '${selectedTier.orderFormKk} тапсырыс беру',
                    onPressed: onConfirm,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _PaymentRow extends StatelessWidget {
  final String label;
  final VoidCallback? onTap;
  const _PaymentRow({required this.label, this.onTap});

  @override
  Widget build(BuildContext context) {
    final scheme = context.colors;
    return Material(
      color: scheme.surfaceContainerLow,
      borderRadius: BorderRadius.circular(AppRadii.button),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadii.button),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: scheme.surfaceContainerLowest,
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.credit_card, size: 20, color: scheme.primary),
              ),
              const SizedBox(width: AppSpacing.gutter),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.bodyMd.copyWith(
                        color: scheme.primary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Метод оплаты • Төлем тәсілі',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.labelMd
                          .copyWith(color: scheme.onSurfaceVariant),
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
