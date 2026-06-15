import 'package:flutter/material.dart';

import '../../app/router/routes.dart';

/// A single navigation destination for app drawers and settings hubs.
class AppMenuEntry {
  final IconData icon;
  final String labelRu;
  final String labelKk;
  final String route;

  const AppMenuEntry({
    required this.icon,
    required this.labelRu,
    required this.labelKk,
    required this.route,
  });

  String get bilingualLabel => '$labelRu / $labelKk';
}

/// Shared drawer destinations (payment, support, settings).
const kSharedMenuEntries = [
  AppMenuEntry(
    icon: Icons.payments_outlined,
    labelRu: 'Способы оплаты',
    labelKk: 'Төлем әдістері',
    route: Routes.payment,
  ),
  AppMenuEntry(
    icon: Icons.support_agent,
    labelRu: 'Поддержка',
    labelKk: 'Қолдау',
    route: Routes.support,
  ),
  AppMenuEntry(
    icon: Icons.settings_outlined,
    labelRu: 'Настройки',
    labelKk: 'Баптаулар',
    route: Routes.settings,
  ),
];

/// Driver-specific drawer items (before the shared settings block).
const kDriverDrawerEntries = [
  AppMenuEntry(
    icon: Icons.account_balance_wallet_outlined,
    labelRu: 'Кошелёк',
    labelKk: 'Әмиян',
    route: Routes.dWallet,
  ),
  AppMenuEntry(
    icon: Icons.bar_chart_outlined,
    labelRu: 'Статистика',
    labelKk: 'Статистика',
    route: Routes.dEarnings,
  ),
  AppMenuEntry(
    icon: Icons.directions_car_outlined,
    labelRu: 'Мои автомобили',
    labelKk: 'Менің көліктерім',
    route: Routes.dVehicles,
  ),
  AppMenuEntry(
    icon: Icons.route,
    labelRu: 'Мои поездки',
    labelKk: 'Менің сапарларым',
    route: Routes.dEarningsHistory,
  ),
  AppMenuEntry(
    icon: Icons.sell_outlined,
    labelRu: 'Промокоды',
    labelKk: 'Промокодтар',
    route: Routes.dReferral,
  ),
];

/// Driver drawer body: fleet items + shared payment/support/settings.
const kDriverFullDrawerEntries = [
  ...kDriverDrawerEntries,
  ...kSharedMenuEntries,
];

/// Passenger drawer destinations (profile + history + shared utilities).
const kPassengerDrawerEntries = [
  AppMenuEntry(
    icon: Icons.person_outline,
    labelRu: 'Профиль',
    labelKk: 'Профиль',
    route: Routes.pProfile,
  ),
  AppMenuEntry(
    icon: Icons.history,
    labelRu: 'История',
    labelKk: 'Тарих',
    route: Routes.pHistory,
  ),
  ...kSharedMenuEntries,
];
