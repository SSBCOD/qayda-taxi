import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/pricing/kz_taxi_pricing.dart';
import '../../../../data/models/enums.dart';
import '../../../../services/accounts/account_session.dart';

enum WalletTxType { ride, payout }

/// A wallet ledger entry (trip credit or Kaspi payout).
class WalletTransaction {
  final String id;
  final WalletTxType type;
  final String titleRu;
  final String titleKk;
  final String dateRu;
  final String dateKk;
  final num amountTenge;
  final String? statusRu;
  final String? statusKk;

  const WalletTransaction({
    required this.id,
    required this.type,
    required this.titleRu,
    required this.titleKk,
    required this.dateRu,
    required this.dateKk,
    required this.amountTenge,
    this.statusRu,
    this.statusKk,
  });

  bool get isCredit => amountTenge > 0;
}

class DriverWalletState {
  final num balanceTenge;
  final String payoutLabelRu;
  final String payoutLabelKk;
  final String payoutLastFour;
  final List<WalletTransaction> transactions;

  const DriverWalletState({
    required this.balanceTenge,
    required this.payoutLabelRu,
    required this.payoutLabelKk,
    required this.payoutLastFour,
    required this.transactions,
  });
}

/// Mock driver wallet — balance + Kaspi payout method + transaction history (₸).
final driverWalletProvider = Provider<DriverWalletState>((ref) {
  final balance = ref.read(driverWalletBalanceProvider);
  final comfortFare = KzTaxiPricing.fareTenge(
    RideTier.comfort,
    distanceKm: 4.2,
    durationMin: 12,
  );
  final comfortIncome = comfortFare +
      KzTaxiPricing.driverBonusTenge(comfortFare, RideTier.comfort);
  final businessFare = KzTaxiPricing.fareTenge(
    RideTier.business,
    distanceKm: 6.5,
    durationMin: 18,
  );
  final businessIncome = businessFare +
      KzTaxiPricing.driverBonusTenge(businessFare, RideTier.business);

  return DriverWalletState(
    balanceTenge: balance,
    payoutLabelRu: 'Kaspi Gold',
    payoutLabelKk: 'Kaspi Gold',
    payoutLastFour: '4422',
    transactions: [
      WalletTransaction(
        id: 'tx_8824',
        type: WalletTxType.ride,
        titleRu: 'Поездка #8824',
        titleKk: 'Сапар #8824',
        dateRu: 'Сегодня, 14:20',
        dateKk: 'Бүгін, 14:20',
        amountTenge: comfortIncome,
        statusRu: 'Зачислено',
        statusKk: 'Есептелді',
      ),
      const WalletTransaction(
        id: 'tx_payout_1',
        type: WalletTxType.payout,
        titleRu: 'Вывод средств',
        titleKk: 'Қаражатты шығару',
        dateRu: 'Вчера, 18:05',
        dateKk: 'Кеше, 18:05',
        amountTenge: -15000,
        statusRu: 'Kaspi Gold • 4422',
        statusKk: 'Kaspi Gold • 4422',
      ),
      WalletTransaction(
        id: 'tx_8819',
        type: WalletTxType.ride,
        titleRu: 'Поездка #8819',
        titleKk: 'Сапар #8819',
        dateRu: 'Вчера, 16:45',
        dateKk: 'Кеше, 16:45',
        amountTenge: businessIncome - 500,
        statusRu: 'Зачислено',
        statusKk: 'Есептелді',
      ),
      WalletTransaction(
        id: 'tx_8812',
        type: WalletTxType.ride,
        titleRu: 'Поездка #8812',
        titleKk: 'Сапар #8812',
        dateRu: '12 окт, 12:10',
        dateKk: '12 қазан, 12:10',
        amountTenge: businessIncome,
        statusRu: 'Зачислено',
        statusKk: 'Есептелді',
      ),
    ],
  );
});

/// Processes a fake Kaspi payout (demo only).
class DriverWalletController extends Notifier<num> {
  @override
  num build() => 45200;

  void restore(num balance) => state = balance;

  void reset() => state = 45200;

  Future<bool> withdraw({required num amount}) async {
    if (amount <= 0 || amount > state) return false;
    await Future.delayed(const Duration(milliseconds: 1200));
    state -= amount;
    AccountSession.save(ref);
    return true;
  }
}

final driverWalletBalanceProvider =
    NotifierProvider<DriverWalletController, num>(DriverWalletController.new);
