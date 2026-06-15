import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../app/router/routes.dart';
import '../../core/extensions/context_ext.dart';
import '../../core/theme/app_radii.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';
import '../../core/widgets/widgets.dart';
import 'application/faq_data.dart';

/// FAQ / Help Center hub (Stitch `faq_help_center_bilingual`).
///
/// Main entry for `/support` — search, category grid, accordion FAQ, chat CTA.
/// Content adapted for KZ (₸, Kaspi — no Apple Pay).
class FaqHelpCenterScreen extends StatefulWidget {
  const FaqHelpCenterScreen({super.key});

  @override
  State<FaqHelpCenterScreen> createState() => _FaqHelpCenterScreenState();
}

class _FaqHelpCenterScreenState extends State<FaqHelpCenterScreen> {
  final _searchCtrl = TextEditingController();
  String? _categoryFilter;
  String? _expandedId;

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  List<FaqItem> get _filtered {
    final q = _searchCtrl.text.trim();
    return kFaqItems.where((item) {
      if (_categoryFilter != null && item.categoryId != _categoryFilter) {
        return false;
      }
      return item.matchesQuery(q);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = context.colors;
    final items = _filtered;
    final compact = MediaQuery.sizeOf(context).width < 360;

    return Scaffold(
      backgroundColor: scheme.surfaceContainerLowest,
      appBar: QaydaAppBar(
        title: 'FAQ / Жиі қойылатын сұрақтар',
        glass: false,
        onBack: () => context.pop(),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.page,
          AppSpacing.lg,
          AppSpacing.page,
          120,
        ),
        children: [
          SearchField(
            hint: 'Поиск по вопросам / Сұрақтар бойынша іздеу',
            controller: _searchCtrl,
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: AppSpacing.lg),

          // Category bento grid.
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: AppSpacing.gutter,
            crossAxisSpacing: AppSpacing.gutter,
            childAspectRatio: compact ? 1.12 : 1.4,
            children: kFaqCategories.map((cat) {
              final selected = _categoryFilter == cat.id;
              return Material(
                color: selected
                    ? scheme.primaryContainer
                    : scheme.surfaceContainer,
                borderRadius: AppRadii.cardRadius,
                child: InkWell(
                  borderRadius: AppRadii.cardRadius,
                  onTap: () => setState(() {
                    _categoryFilter = selected ? null : cat.id;
                  }),
                  child: Container(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    decoration: BoxDecoration(
                      borderRadius: AppRadii.cardRadius,
                      border: Border.all(
                        color: selected
                            ? scheme.primary
                            : scheme.outlineVariant.withValues(alpha: 0.2),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(cat.icon,
                            size: 28,
                            color: selected
                                ? scheme.onPrimaryContainer
                                : scheme.primary),
                        const Spacer(),
                        Text(
                          '${cat.labelRu} / ${cat.labelKk}',
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: AppTypography.labelMd.copyWith(
                            color: selected
                                ? scheme.onPrimaryContainer
                                : scheme.onSurface,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: AppSpacing.lg),

          const Text('Популярное / Танымал',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTypography.headlineMd),
          const SizedBox(height: AppSpacing.md),

          if (items.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
              child: Text(
                'Ничего не найдено / Ештеңе табылмады',
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: AppTypography.bodyMd
                    .copyWith(color: scheme.onSurfaceVariant),
              ),
            )
          else
            ...items.map((item) => Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                  child: _FaqAccordion(
                    item: item,
                    expanded: _expandedId == item.id,
                    onTap: () => setState(() {
                      _expandedId = _expandedId == item.id ? null : item.id;
                    }),
                  ),
                )),

          const SizedBox(height: AppSpacing.lg),

          // Help CTA card.
          Container(
            padding: const EdgeInsets.all(AppSpacing.lg),
            decoration: BoxDecoration(
              color: scheme.primary,
              borderRadius: BorderRadius.circular(AppRadii.card),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Нужна помощь? / Көмек керек пе?',
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: AppTypography.headlineMd
                            .copyWith(color: scheme.onPrimary),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Наша команда 24/7 / Біздің команда 24/7',
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: AppTypography.bodyMd.copyWith(
                          color: scheme.onPrimary.withValues(alpha: 0.8),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                FilledButton(
                  style: FilledButton.styleFrom(
                    backgroundColor: scheme.onPrimary,
                    foregroundColor: scheme.primary,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 12,
                    ),
                  ),
                  onPressed: () => context.push(Routes.supportChat),
                  child: const Text('Чат / Чат'),
                ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        top: false,
        minimum: const EdgeInsets.fromLTRB(
          AppSpacing.page,
          AppSpacing.md,
          AppSpacing.page,
          AppSpacing.page,
        ),
        child: PrimaryActionButton(
          label: 'Связаться с нами',
          labelSecondary: 'Бізбен байланысу',
          onPressed: () => context.push(Routes.supportChat),
        ),
      ),
    );
  }
}

class _FaqAccordion extends StatelessWidget {
  final FaqItem item;
  final bool expanded;
  final VoidCallback onTap;

  const _FaqAccordion({
    required this.item,
    required this.expanded,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = context.colors;
    return Material(
      color: scheme.surfaceContainerLow,
      borderRadius: BorderRadius.circular(AppRadii.button),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          InkWell(
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      '${item.questionRu} / ${item.questionKk}',
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.bodyLg,
                    ),
                  ),
                  AnimatedRotation(
                    turns: expanded ? 0.5 : 0,
                    duration: const Duration(milliseconds: 200),
                    child:
                        Icon(Icons.expand_more, color: scheme.onSurfaceVariant),
                  ),
                ],
              ),
            ),
          ),
          AnimatedCrossFade(
            firstChild: const SizedBox.shrink(),
            secondChild: Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.md,
                0,
                AppSpacing.md,
                AppSpacing.md,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.answerRu,
                    style: AppTypography.bodyMd,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    item.answerKk,
                    style: AppTypography.bodyMd
                        .copyWith(color: scheme.onSurfaceVariant),
                  ),
                ],
              ),
            ),
            crossFadeState:
                expanded ? CrossFadeState.showSecond : CrossFadeState.showFirst,
            duration: const Duration(milliseconds: 200),
          ),
        ],
      ),
    );
  }
}
