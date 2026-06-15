/// Shared domain enums (see ARCHITECTURE.md §9).
library;

enum UserRole { passenger, driver }

/// Central ride state machine (synced via the ride repository).
enum RideStatus {
  idle,
  searching,
  driverAssigned,
  accepted,
  enRoute,
  arrived,
  inProgress,
  completed,
  paid,
  rated,
  cancelled,
}

enum DriverStatus { offline, online, onOrder }

/// Driver-side lifecycle of a single order (mirrors the passenger [RideStatus]
/// but framed from the driver's perspective; see docs/app_flows.md).
enum DriverOrderStage {
  incoming, // offer shown, awaiting accept/decline
  enRouteToPickup, // accepted, driving to the passenger
  arrived, // at pickup, boarding / verification
  inProgress, // trip underway A→B
  completed, // trip finished, earnings summary
}

enum VerificationStatus { unverified, pending, verified, rejected }

enum RideTier { economy, comfort, business }

enum PaymentType { card, cash, kaspi, multicard }

/// Bilingual labels + lifecycle helpers for the ride state machine.
/// Used by the fake order system and the ride screens (see docs/app_flows.md §7).
extension RideStatusX on RideStatus {
  /// Ride is live — somewhere between request and trip end.
  bool get isActive =>
      this == RideStatus.searching ||
      this == RideStatus.driverAssigned ||
      this == RideStatus.accepted ||
      this == RideStatus.enRoute ||
      this == RideStatus.arrived ||
      this == RideStatus.inProgress;

  /// Ride can no longer transition.
  bool get isTerminal =>
      this == RideStatus.rated || this == RideStatus.cancelled;

  String get labelRu => switch (this) {
        RideStatus.idle => 'Нет поездки',
        RideStatus.searching => 'Поиск водителя',
        RideStatus.driverAssigned => 'Водитель найден',
        RideStatus.accepted => 'Заказ принят',
        RideStatus.enRoute => 'Водитель в пути',
        RideStatus.arrived => 'Водитель подан',
        RideStatus.inProgress => 'В поездке',
        RideStatus.completed => 'Поездка завершена',
        RideStatus.paid => 'Оплачено',
        RideStatus.rated => 'Оценено',
        RideStatus.cancelled => 'Отменено',
      };

  String get labelKk => switch (this) {
        RideStatus.idle => 'Сапар жоқ',
        RideStatus.searching => 'Жүргізушіні іздеу',
        RideStatus.driverAssigned => 'Жүргізуші табылды',
        RideStatus.accepted => 'Тапсырыс қабылданды',
        RideStatus.enRoute => 'Жүргізуші жолда',
        RideStatus.arrived => 'Жүргізуші келді',
        RideStatus.inProgress => 'Сапар үстінде',
        RideStatus.completed => 'Сапар аяқталды',
        RideStatus.paid => 'Төленді',
        RideStatus.rated => 'Бағаланды',
        RideStatus.cancelled => 'Бас тартылды',
      };
}

extension PaymentTypeX on PaymentType {
  String get labelRu => switch (this) {
        PaymentType.card => 'Карта',
        PaymentType.cash => 'Наличные',
        PaymentType.kaspi => 'Kaspi',
        PaymentType.multicard => 'Multicard',
      };
}
