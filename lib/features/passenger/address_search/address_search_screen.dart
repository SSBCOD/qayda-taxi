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

/// Address search (Stitch `address_search_2gis_style`).
///
/// Search input card with a "pick on map" shortcut, horizontally scrollable
/// saved-place chips and a search-history list. Selecting any place sets the
/// destination and continues into the route/tariff flow.
class AddressSearchScreen extends ConsumerStatefulWidget {
  const AddressSearchScreen({super.key});

  @override
  ConsumerState<AddressSearchScreen> createState() =>
      _AddressSearchScreenState();
}

class _AddressSearchScreenState extends ConsumerState<AddressSearchScreen> {
  final _controller = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _choose(Address address) {
    _syncPickupFromMap();
    ref.read(selectedDestinationProvider.notifier).state = address;
    context.push(Routes.pTariff);
  }

  void _syncPickupFromMap() {
    final map = ref.read(mapControllerProvider);
    final pickup = map.userPosition ?? map.center;
    ref.read(selectedOriginProvider.notifier).state =
        pickupAddressFromCoordinates(
      lat: pickup.latitude,
      lng: pickup.longitude,
    );
  }

  @override
  Widget build(BuildContext context) {
    final scheme = context.colors;

    final history = _query.isEmpty
        ? kSearchHistory
        : [...kSearchHistory, ...kSavedPlaces]
            .where((a) =>
                a.titleRu.toLowerCase().contains(_query.toLowerCase()) ||
                a.fullText.toLowerCase().contains(_query.toLowerCase()))
            .toList();

    return Scaffold(
      backgroundColor: scheme.surfaceContainerLowest,
      appBar: QaydaAppBar(
        title: 'Куда поедем?',
        subtitle: 'Қайда барамыз?',
        onBack: () => context.pop(),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.page,
          AppSpacing.lg,
          AppSpacing.page,
          AppSpacing.lg,
        ),
        children: [
          _SearchCard(
            controller: _controller,
            onChanged: (v) => setState(() => _query = v),
            onPickOnMap: () => context.push(Routes.pSetDestination),
          ),
          const SizedBox(height: AppSpacing.lg),
          _SavedPlacesRow(onTap: _choose),
          const SizedBox(height: AppSpacing.lg),
          Text(
            'История / Тарих',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTypography.headlineMd.copyWith(color: scheme.onSurface),
          ),
          const SizedBox(height: AppSpacing.md),
          for (final a in history)
            BoutiqueListTile(
              leadingIcon:
                  a.type == 'history' ? Icons.schedule : Icons.location_on,
              title: a.titleRu,
              subtitle: a.fullText,
              trailing: const SizedBox.shrink(),
              showDivider: a != history.last,
              onTap: () => _choose(a),
            ),
          if (history.isEmpty)
            Padding(
              padding: const EdgeInsets.only(top: AppSpacing.lg),
              child: Center(
                child: Text(
                  'Ничего не найдено / Ештеңе табылмады',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: AppTypography.bodyMd
                      .copyWith(color: scheme.onSurfaceVariant),
                ),
              ),
            ),
        ],
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: scheme.surfaceContainerLowest,
          border: Border(
            top: BorderSide(color: scheme.surfaceContainer),
          ),
          boxShadow: const [
            BoxShadow(
              color: Color(0x08000000),
              blurRadius: 10,
              offset: Offset(0, -4),
            ),
          ],
        ),
        child: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.page,
              AppSpacing.md,
              AppSpacing.page,
              AppSpacing.md,
            ),
            child: PrimaryActionButton(
              label: 'Далее',
              labelSecondary: 'Әрі қарай',
              onPressed: () {
                final dest = ref.read(selectedDestinationProvider);
                if (dest == null && kSearchHistory.isEmpty) return;
                _choose(dest ?? kSearchHistory.first);
              },
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Search input card: search row + "pick on map" shortcut.
// ─────────────────────────────────────────────────────────────────────────────
class _SearchCard extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final VoidCallback onPickOnMap;

  const _SearchCard({
    required this.controller,
    required this.onChanged,
    required this.onPickOnMap,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = context.colors;
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0D000000),
            blurRadius: 2,
            offset: Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(Icons.search, size: 24, color: scheme.secondary),
              const SizedBox(width: AppSpacing.gutter),
              Expanded(
                child: TextField(
                  controller: controller,
                  onChanged: onChanged,
                  autofocus: false,
                  cursorColor: AppColors.locationBlue,
                  style: AppTypography.bodyLg.copyWith(color: scheme.onSurface),
                  decoration: InputDecoration(
                    isDense: true,
                    border: InputBorder.none,
                    hintText: 'Поиск улицы или места / Іздеу',
                    hintStyle: AppTypography.bodyLg
                        .copyWith(color: scheme.onSurfaceVariant),
                  ),
                ),
              ),
            ],
          ),
          Divider(height: AppSpacing.md * 2, color: scheme.outlineVariant),
          InkWell(
            onTap: onPickOnMap,
            child: Row(
              children: [
                const Icon(Icons.location_on,
                    size: 24, color: AppColors.locationBlue),
                const SizedBox(width: AppSpacing.gutter),
                Expanded(
                  child: Text(
                    'Указать на карте / Картада көрсету',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTypography.bodyLg.copyWith(
                      color: AppColors.locationBlue,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Saved-place chips (horizontal scroll).
// ─────────────────────────────────────────────────────────────────────────────
class _SavedPlacesRow extends StatelessWidget {
  final ValueChanged<Address> onTap;
  const _SavedPlacesRow({required this.onTap});

  static const _emoji = {
    'home': '🏠',
    'work': '💼',
    'place': '📍',
    'airport': '✈️',
  };

  @override
  Widget build(BuildContext context) {
    final scheme = context.colors;
    return SizedBox(
      height: 40,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: kSavedPlaces.length,
        separatorBuilder: (_, __) => const SizedBox(width: AppSpacing.gutter),
        itemBuilder: (context, i) {
          final place = kSavedPlaces[i];
          return Material(
            color: scheme.surfaceContainerLow,
            borderRadius: BorderRadius.circular(16),
            child: InkWell(
              onTap: () => onTap(place),
              borderRadius: BorderRadius.circular(16),
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(_emoji[place.label] ?? '📍',
                        style: const TextStyle(fontSize: 18)),
                    const SizedBox(width: 8),
                    Text(
                      place.titleRu,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.labelMd
                          .copyWith(color: scheme.onSurface),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
