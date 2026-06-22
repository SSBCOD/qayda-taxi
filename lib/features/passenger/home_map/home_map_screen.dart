import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router/routes.dart';
import '../../../core/navigation/app_menu_config.dart';
import '../../../core/navigation/qayda_nav_drawer.dart';
import '../../../core/extensions/context_ext.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radii.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/widgets.dart';
import '../../ride/map/map_controller.dart';

/// Passenger home — the live map hub.
///
/// Reproduces the Stitch "Main Map" composition:
///   • full-screen [QaydaGoogleMap] background
///   • glass top bar (menu · Qayda wordmark · language)
///   • floating ETA badge + pulsing user pin + my-location control
///   • bottom search sheet with quick-address chips and a promo card
///
/// Lives inside [PassengerShell], so the BottomNav is supplied by the shell.
class HomeMapScreen extends ConsumerStatefulWidget {
  const HomeMapScreen({super.key});

  @override
  ConsumerState<HomeMapScreen> createState() => _HomeMapScreenState();
}

class _HomeMapScreenState extends ConsumerState<HomeMapScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(mapControllerProvider.notifier).locateUser();
    });
  }

  @override
  Widget build(BuildContext context) {
    final topInset = MediaQuery.paddingOf(context).top;
    final hasUserPin = ref.watch(
      mapControllerProvider.select((s) => s.userPosition != null),
    );

    return Scaffold(
      extendBodyBehindAppBar: true,
      drawer: const _HomeDrawer(),
      body: Stack(
        children: [
          // ── Map background ──────────────────────────────────────────
          const Positioned.fill(child: QaydaMap()),

          // Decorative pulse only until GPS pin is available.
          if (!hasUserPin)
            const Positioned.fill(
              child: IgnorePointer(
                child: Center(child: PulseMarker(size: 18)),
              ),
            ),

          // ── Floating ETA badge ──────────────────────────────────────
          Positioned(
            top: topInset + 64 + 12,
            left: 0,
            right: 0,
            child: const Center(child: _EtaBadge(minutes: 2)),
          ),

          // ── Glass top bar ───────────────────────────────────────────
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: _GlassHeader(topInset: topInset),
          ),

          // ── My-location control + bottom search sheet ───────────────
          Align(
            alignment: Alignment.bottomCenter,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.page,
                    0,
                    AppSpacing.page,
                    AppSpacing.gutter,
                  ),
                  child: Row(
                    children: [
                      const Spacer(),
                      GlassFloatingButton(
                        icon: Icons.my_location,
                        size: 48,
                        onPressed: () => ref
                            .read(mapControllerProvider.notifier)
                            .locateUser(),
                      ),
                    ],
                  ),
                ),
                const _SearchSheet(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Glass top bar: menu · centered "Qayda" wordmark · language switcher.
// ─────────────────────────────────────────────────────────────────────────────
class _GlassHeader extends StatelessWidget {
  final double topInset;
  const _GlassHeader({required this.topInset});

  @override
  Widget build(BuildContext context) {
    final scheme = context.colors;
    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
        child: Container(
          padding: EdgeInsets.only(top: topInset),
          decoration: BoxDecoration(
            color: scheme.surface.withValues(alpha: 0.7),
            border: Border(
              bottom: BorderSide(
                color: scheme.outlineVariant.withValues(alpha: 0.3),
              ),
            ),
          ),
          child: SizedBox(
            height: 64,
            child: Stack(
              alignment: Alignment.center,
              children: [
                Text(
                  'Qayda',
                  style:
                      AppTypography.displayLg.copyWith(color: scheme.primary),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.page - 8,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Builder(
                        builder: (context) => IconButton(
                          onPressed: () => Scaffold.of(context).openDrawer(),
                          icon: const Icon(Icons.menu),
                          color: scheme.primary,
                          tooltip: MaterialLocalizations.of(context)
                              .openAppDrawerTooltip,
                        ),
                      ),
                      const LanguageSwitcher(),
                    ],
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

// ─────────────────────────────────────────────────────────────────────────────
// Floating glass pill: pulsing dot + "Подача: N мин".
// ─────────────────────────────────────────────────────────────────────────────
class _EtaBadge extends StatelessWidget {
  final int minutes;
  const _EtaBadge({required this.minutes});

  @override
  Widget build(BuildContext context) {
    final scheme = context.colors;
    return ClipRRect(
      borderRadius: BorderRadius.circular(AppRadii.card),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.7),
            borderRadius: BorderRadius.circular(999),
            border: Border.all(
              color: scheme.outlineVariant.withValues(alpha: 0.5),
            ),
            boxShadow: const [
              BoxShadow(
                color: Color(0x0D000000),
                blurRadius: 2,
                offset: Offset(0, 1),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(
                width: 18,
                height: 18,
                child: Center(
                  child: PulseMarker(size: 7, color: AppColors.locationBlue),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                context.l10n.homeEtaPickup(minutes),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTypography.labelMd.copyWith(color: scheme.onSurface),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Bottom sheet: search field + quick-address chips + promo card.
// ─────────────────────────────────────────────────────────────────────────────
class _SearchSheet extends StatelessWidget {
  const _SearchSheet();

  @override
  Widget build(BuildContext context) {
    final scheme = context.colors;
    final l10n = context.l10n;

    // Opens the address-search flow (search → pick place / map → route/tariff).
    void openSearch() => context.push(Routes.pSearch);

    final maxHeight = MediaQuery.sizeOf(context).height * 0.48;
    return ConstrainedBox(
      constraints: BoxConstraints(maxHeight: maxHeight),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: scheme.surface,
          borderRadius: AppRadii.sheetRadius,
          border: Border(
            top:
                BorderSide(color: scheme.outlineVariant.withValues(alpha: 0.5)),
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
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.page,
                0,
                AppSpacing.page,
                AppSpacing.md,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const DragHandle(),
                  SearchField(
                    hint: l10n.homeSearchHint,
                    readOnly: true,
                    onTap: openSearch,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  SizedBox(
                    height: 40,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      children: [
                        _QuickChip(
                          icon: Icons.home_outlined,
                          label: l10n.homeChipHome,
                          onTap: openSearch,
                        ),
                        const SizedBox(width: AppSpacing.gutter),
                        _QuickChip(
                          icon: Icons.work_outline,
                          label: l10n.homeChipWork,
                          onTap: openSearch,
                        ),
                        const SizedBox(width: AppSpacing.gutter),
                        _QuickChip(
                          icon: Icons.local_mall_outlined,
                          label: 'Dostyk Plaza',
                          onTap: openSearch,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.gutter),
                  _PromoCard(
                    title: l10n.homePromoTitle,
                    subtitle: l10n.homePromoSubtitle,
                    onTap: openSearch,
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

class _QuickChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback? onTap;

  const _QuickChip({required this.icon, required this.label, this.onTap});

  @override
  Widget build(BuildContext context) {
    final scheme = context.colors;
    return Material(
      color: scheme.surfaceContainerLowest,
      borderRadius: BorderRadius.circular(AppRadii.button),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadii.button),
        child: Container(
          constraints: BoxConstraints(
            maxWidth: MediaQuery.sizeOf(context).width * 0.62,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppRadii.button),
            border: Border.all(
              color: scheme.outlineVariant.withValues(alpha: 0.3),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 20, color: scheme.onSurface),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style:
                      AppTypography.labelMd.copyWith(color: scheme.onSurface),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PromoCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final VoidCallback? onTap;

  const _PromoCard({
    required this.title,
    required this.subtitle,
    this.onTap,
  });

  static const Color _blue = Color(0xFF3B82F6);

  @override
  Widget build(BuildContext context) {
    final scheme = context.colors;
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(AppRadii.card),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadii.card),
        child: Ink(
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF1E1235), Color(0xFF12122A)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(AppRadii.card),
            border: Border.all(color: const Color(0xFF3D3D6A)),
          ),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: const Color(0xFF2A1060),
                  borderRadius: BorderRadius.circular(AppRadii.button - 4),
                ),
                child: const Icon(Icons.bolt, color: Color(0xFF8B5CF6)),
              ),
              const SizedBox(width: AppSpacing.gutter),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.labelMd.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.bodyMd.copyWith(
                        color: const Color(0xFF9CA3AF),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.all(4),
                decoration: const BoxDecoration(
                  color: Color(0xFF2A1060),
                  shape: BoxShape.circle,
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x0D000000),
                      blurRadius: 2,
                      offset: Offset(0, 1),
                    ),
                  ],
                ),
                child: const Icon(Icons.chevron_right, color: _blue, size: 20),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Drawer opened by the header menu button.
// ─────────────────────────────────────────────────────────────────────────────
class _HomeDrawer extends StatelessWidget {
  const _HomeDrawer();

  @override
  Widget build(BuildContext context) {
    return const QaydaNavDrawer(
      header: QaydaDrawerHeader(),
      entries: kPassengerDrawerEntries,
    );
  }
}
