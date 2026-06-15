import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router/routes.dart';
import '../../../core/extensions/context_ext.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/widgets.dart';
import '../../../data/models/enums.dart';
import '../../../data/models/ride.dart';
import '../../ride/application/ride_controller.dart';
import '../../ride/map/map_controller.dart';

/// Driver-search / wait screen.
///
/// While `searching` it shows the search progress; once a driver is assigned
/// (`enRoute` / `arrived`) it shows the driver card, ETA and Call · Chat ·
/// Cancel actions. Navigation is driven entirely by the shared [RideStatus]:
/// when the ride moves to `inProgress` the active-ride screen takes over.
class RideWaitScreen extends ConsumerWidget {
  const RideWaitScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen<Ride?>(rideControllerProvider, (prev, next) {
      if (next == null) return;
      if (prev?.status != RideStatus.inProgress &&
          next.status == RideStatus.inProgress) {
        context.go(Routes.pRideActive);
      }
      if (prev?.status != RideStatus.completed &&
          next.status == RideStatus.completed) {
        context.go(Routes.paymentBinding);
      }
    });

    final ride = ref.watch(rideControllerProvider);

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: QaydaAppBar(
        title: 'Водитель приедет',
        subtitle: 'Жүргізуші келеді',
        onBack: () => _confirmCancel(context, ref),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.more_vert),
          ),
        ],
      ),
      body: Stack(
        children: [
          const Positioned.fill(child: QaydaMap()),
          Align(
            alignment: Alignment.bottomCenter,
            // Inline condition allows Dart to narrow `ride` to non-null
            // in the false branch, eliminating the need for `!`.
            child: (ride == null ||
                    ride.status == RideStatus.searching ||
                    ride.status == RideStatus.driverAssigned)
                ? _SearchingSheet(onCancel: () => _confirmCancel(context, ref))
                : _DriverSheet(
                    ride: ride,
                    onCancel: () => _confirmCancel(context, ref),
                  ),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmCancel(BuildContext context, WidgetRef ref) async {
    final ok = await showQaydaDialog(
      context: context,
      title: 'Отменить поездку?',
      message: 'Сапарды болдырмайсыз ба?',
      confirmLabel: 'Отменить',
      cancelLabel: 'Назад',
      destructive: true,
    );
    if (ok != true) return;
    ref.read(rideControllerProvider.notifier).cancelTrip();
    ref.read(rideControllerProvider.notifier).reset();
    if (context.mounted) context.go(Routes.pHome);
  }
}

// ─────────────────────────────────────────────────────────────────────────────
class _Sheet extends StatelessWidget {
  final Widget child;
  const _Sheet({required this.child});

  @override
  Widget build(BuildContext context) {
    final scheme = context.colors;
    final maxHeight = MediaQuery.sizeOf(context).height * 0.62;
    return ConstrainedBox(
      constraints: BoxConstraints(maxHeight: maxHeight),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: scheme.surfaceContainerLowest,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
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
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.page,
                0,
                AppSpacing.page,
                AppSpacing.md,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [const DragHandle(), child],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _SearchingSheet extends StatelessWidget {
  final VoidCallback onCancel;
  const _SearchingSheet({required this.onCancel});

  @override
  Widget build(BuildContext context) {
    final scheme = context.colors;
    return _Sheet(
      child: Column(
        children: [
          const SizedBox(height: AppSpacing.sm),
          const AppLoader(size: 32),
          const SizedBox(height: AppSpacing.md),
          const Text(
            'Идёт поиск водителя',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTypography.headlineMd,
          ),
          const SizedBox(height: 2),
          Text(
            'Жүргізушіні іздеудеміз…',
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style:
                AppTypography.bodyMd.copyWith(color: scheme.onSurfaceVariant),
          ),
          const SizedBox(height: AppSpacing.lg),
          SecondaryButton(
            label: 'Отмена / Бас тарту',
            icon: Icons.close,
            onPressed: onCancel,
          ),
        ],
      ),
    );
  }
}

class _DriverSheet extends ConsumerWidget {
  final Ride ride;
  final VoidCallback onCancel;
  const _DriverSheet({required this.ride, required this.onCancel});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheme = context.colors;
    final arrived = ride.status == RideStatus.arrived;
    final accepted = ride.status == RideStatus.accepted;
    final enRoute = ride.status == RideStatus.enRoute;
    final driver = ride.driver;
    if (driver == null) return const _Sheet(child: AppLoader(size: 32));
    final map = ref.watch(mapControllerProvider);
    final etaMin =
        enRoute && map.isSimulating ? map.remainingEtaMin : ride.driverEtaMin;

    final statusText = arrived
        ? 'ПОДАН / КЕЛДІ'
        : accepted
            ? 'ПРИНЯТ / ҚАБЫЛДАНДЫ'
            : 'В ПУТИ / ЖОЛДА';
    final etaText = arrived
        ? 'Водитель ждёт вас / Жүргізуші күтуде'
        : accepted
            ? 'Водитель едет к вам / Жүргізуші сізге барады'
            : 'через $etaMin мин / $etaMin мин ішінде';

    return _Sheet(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: StatusPill(text: statusText),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            etaText,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            style: AppTypography.headlineMobile,
          ),
          const SizedBox(height: AppSpacing.lg),
          DriverCard(
            name: driver.name,
            rating: driver.rating,
            vehicle: driver.vehicleLineRu,
            plate: driver.plate,
          ),
          const SizedBox(height: AppSpacing.lg),
          Row(
            children: [
              Expanded(
                child: _CircleAction(
                  icon: Icons.call,
                  label: 'Звонок',
                  color: const Color(0xFF16A34A),
                  background: const Color(0xFFF0FDF4),
                  onTap: () {},
                ),
              ),
              Expanded(
                child: _CircleAction(
                  icon: Icons.chat_bubble_outline,
                  label: 'Чат',
                  color: scheme.primary,
                  background: scheme.surfaceContainerHigh,
                  onTap: () {},
                ),
              ),
              Expanded(
                child: _CircleAction(
                  icon: Icons.close,
                  label: 'Отмена',
                  color: const Color(0xFFDC2626),
                  background: const Color(0xFFFEF2F2),
                  onTap: onCancel,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _CircleAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final Color background;
  final VoidCallback onTap;

  const _CircleAction({
    required this.icon,
    required this.label,
    required this.color,
    required this.background,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(999),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 56,
            height: 56,
            decoration:
                BoxDecoration(color: background, shape: BoxShape.circle),
            child: Icon(icon, color: color),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTypography.labelMd.copyWith(color: color),
          ),
        ],
      ),
    );
  }
}
