import 'enums.dart';

/// A ride category (Эконом / Комфорт / Бизнес) with pricing inputs.
///
/// Conceptual schema in `docs/models.md`. For the MVP the prices are seeded
/// locally (mock); with Firebase they come from `/tariffs/{tier}`.
class Tariff {
  final RideTier tier;
  final String titleRu;
  final String titleKk;
  final num priceTenge;
  final int etaPickupMin;
  final String? carAssetPath;

  const Tariff({
    required this.tier,
    required this.titleRu,
    required this.titleKk,
    required this.priceTenge,
    required this.etaPickupMin,
    this.carAssetPath,
  });
}

extension RideTierX on RideTier {
  String get titleRu => switch (this) {
        RideTier.economy => 'Эконом',
        RideTier.comfort => 'Комфорт',
        RideTier.business => 'Бизнес',
      };

  String get titleKk => switch (this) {
        RideTier.economy => 'Эконом',
        RideTier.comfort => 'Комфорт',
        RideTier.business => 'Бизнес',
      };

  /// Accusative form used in the "Заказать …" CTA (RU).
  String get orderFormRu => switch (this) {
        RideTier.economy => 'Эконом',
        RideTier.comfort => 'Комфорт',
        RideTier.business => 'Бизнес',
      };

  /// Dative form used in the "Заказать …" CTA (KK).
  String get orderFormKk => switch (this) {
        RideTier.economy => 'Экономға',
        RideTier.comfort => 'Комфортқа',
        RideTier.business => 'Бизнеске',
      };

  /// Bilingual label for menus and history rows.
  String get bilingualLabel => '$titleRu / $titleKk';

  /// Premium class label on the driver post-ride rating screen (Stitch mock).
  String get driverClassLabel => switch (this) {
        RideTier.business => 'Executive Class',
        RideTier.comfort => 'Комфорт',
        RideTier.economy => 'Эконом',
      };
}
