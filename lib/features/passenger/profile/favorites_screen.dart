import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router/routes.dart';
import '../../../core/extensions/context_ext.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/widgets.dart';
import '../../../services/accounts/account_session.dart';
import 'application/favorites_controller.dart';

/// Favourite addresses (Stitch `favorite_addresses_bilingual`).
///
/// List of saved places with delete, plus an "add address" CTA. Persisted per
/// account via [AccountSession].
class FavoritesScreen extends ConsumerWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheme = context.colors;
    final items = ref.watch(favoritesControllerProvider);

    return Scaffold(
      backgroundColor: scheme.surfaceContainerLowest,
      appBar: QaydaAppBar(
        title: 'Избранные адреса',
        subtitle: 'Таңдаулы мекенжайлар',
        glass: false,
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
          Text(
            'Ваши частые поездки в одном месте / Жиі баратын орындарыңыз',
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            style: AppTypography.labelMd.copyWith(color: scheme.secondary),
          ),
          const SizedBox(height: AppSpacing.md),
          for (final item in items)
            _FavoriteRow(
              item: item,
              onDelete: () {
                ref.read(favoritesControllerProvider.notifier).remove(item);
                AccountSession.save(ref);
              },
            ),
          if (items.isEmpty)
            Padding(
              padding: const EdgeInsets.only(top: AppSpacing.lg),
              child: Center(
                child: Text(
                  'Список пуст / Тізім бос',
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
        color: scheme.surfaceContainerLowest,
        child: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.page,
              AppSpacing.md,
              AppSpacing.page,
              AppSpacing.md,
            ),
            child: FilledButton.icon(
              onPressed: () => context.push(Routes.pSetDestination),
              icon: const Icon(Icons.add),
              label: const Text(
                'Добавить адрес / Мекенжай қосу',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _FavoriteRow extends StatelessWidget {
  final FavoritePlace item;
  final VoidCallback onDelete;
  const _FavoriteRow({required this.item, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    final scheme = context.colors;
    return Container(
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: scheme.surfaceContainerHighest),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: scheme.surfaceContainerHigh,
                shape: BoxShape.circle,
              ),
              child: Icon(item.icon, color: scheme.primary),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${item.titleRu} / ${item.titleKk}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTypography.bodyLg
                        .copyWith(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    item.address,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style:
                        AppTypography.bodyMd.copyWith(color: scheme.secondary),
                  ),
                ],
              ),
            ),
            IconButton(
              onPressed: onDelete,
              icon: Icon(Icons.delete_outline, color: scheme.secondary),
            ),
          ],
        ),
      ),
    );
  }
}
