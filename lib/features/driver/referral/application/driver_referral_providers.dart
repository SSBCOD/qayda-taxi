import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Lifecycle of an invited driver in the partner program.
enum ReferralStatus { active, pending, completed }

/// A perk tile shown in the horizontal carousel.
class ReferralPerk {
  final String titleRu;
  final String titleKk;
  final String subtitleRu;
  final String subtitleKk;
  final bool highlighted;

  const ReferralPerk({
    required this.titleRu,
    required this.titleKk,
    required this.subtitleRu,
    required this.subtitleKk,
    this.highlighted = false,
  });
}

/// One referred driver row.
class ReferralEntry {
  final String id;
  final String nameRu;
  final String nameKk;
  final ReferralStatus status;
  final int completedOrders;
  final int targetOrders;
  final num rewardTenge;
  final String? statusLabelRu;
  final String? statusLabelKk;

  const ReferralEntry({
    required this.id,
    required this.nameRu,
    required this.nameKk,
    required this.status,
    required this.completedOrders,
    required this.targetOrders,
    required this.rewardTenge,
    this.statusLabelRu,
    this.statusLabelKk,
  });
}

class DriverReferralState {
  final String promoCode;
  final num totalEarningsTenge;
  final String eliteLabelRu;
  final String eliteLabelKk;
  final List<ReferralPerk> perks;
  final List<ReferralEntry> referrals;

  const DriverReferralState({
    required this.promoCode,
    required this.totalEarningsTenge,
    required this.eliteLabelRu,
    required this.eliteLabelKk,
    required this.perks,
    required this.referrals,
  });

  String get shareLink => 'qayda://referral/$promoCode';
}

/// Mock driver referral program — promo code, perks and active referrals (₸).
final driverReferralProvider = Provider<DriverReferralState>((ref) {
  return const DriverReferralState(
    promoCode: 'QAYDA777',
    totalEarningsTenge: 45000,
    eliteLabelRu: 'Executive Elite Status',
    eliteLabelKk: 'Executive Elite Status',
    perks: [
      ReferralPerk(
        titleRu: '5 000 ₸ за каждого друга',
        titleKk: 'Әр дос үшін 5 000 ₸',
        subtitleRu: 'После первой поездки приглашённого',
        subtitleKk: 'Әр дос үшін 5 000 ₸ төленеді',
        highlighted: true,
      ),
      ReferralPerk(
        titleRu: 'Бонус за активность',
        titleKk: 'Белсенділік бонусы',
        subtitleRu: 'Когда друг выполнит 50 заказов',
        subtitleKk: 'Досыңыз 50 тапсырыс орындағанда',
      ),
    ],
    referrals: [
      ReferralEntry(
        id: 'ref_1',
        nameRu: 'Данияр С.',
        nameKk: 'Данияр С.',
        status: ReferralStatus.active,
        completedOrders: 12,
        targetOrders: 50,
        rewardTenge: 5000,
        statusLabelRu: 'Ожидается',
        statusLabelKk: 'Күтілуде',
      ),
      ReferralEntry(
        id: 'ref_2',
        nameRu: 'Арман М.',
        nameKk: 'Арман М.',
        status: ReferralStatus.pending,
        completedOrders: 0,
        targetOrders: 50,
        rewardTenge: 5000,
        statusLabelRu: 'В обработке',
        statusLabelKk: 'Өңделуде',
      ),
      ReferralEntry(
        id: 'ref_3',
        nameRu: 'Тимур К.',
        nameKk: 'Тимур К.',
        status: ReferralStatus.completed,
        completedOrders: 50,
        targetOrders: 50,
        rewardTenge: 5000,
      ),
    ],
  );
});
