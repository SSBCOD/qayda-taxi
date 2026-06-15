import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/models/payment_method.dart';
import '../../../services/accounts/account_session.dart';

/// Holds the list of payment methods and the currently selected one.
///
/// Persisted per account via [AccountSession] (not global prefs).
class PaymentState {
  final List<PaymentMethod> methods;
  final String selectedId;

  const PaymentState({
    required this.methods,
    required this.selectedId,
  });

  PaymentMethod get selected => methods.firstWhere((m) => m.id == selectedId,
      orElse: () => methods.first);

  PaymentState copyWith({
    List<PaymentMethod>? methods,
    String? selectedId,
  }) {
    return PaymentState(
      methods: methods ?? this.methods,
      selectedId: selectedId ?? this.selectedId,
    );
  }
}

class PaymentController extends Notifier<PaymentState> {
  @override
  PaymentState build() {
    const methods = kDefaultPaymentMethods;
    return const PaymentState(methods: methods, selectedId: 'kaspi_1234');
  }

  void restore({
    required List<PaymentMethod> methods,
    required String selectedId,
  }) {
    final list = methods.isEmpty ? kDefaultPaymentMethods : methods;
    final id = list.any((m) => m.id == selectedId) ? selectedId : list.first.id;
    state = PaymentState(methods: list, selectedId: id);
  }

  void select(String id) {
    if (!state.methods.any((m) => m.id == id)) return;
    state = state.copyWith(selectedId: id);
    AccountSession.save(ref,
        paymentMethods: state.methods, selectedPaymentId: state.selectedId);
  }

  /// Fake card binding — detects issuer from BIN and appends to the list.
  void addCard(String cardNumber) {
    final method = PaymentMethod.fromCardNumber(cardNumber);
    final existing = state.methods.indexWhere((m) => m.id == method.id);
    final methods = List<PaymentMethod>.from(state.methods);
    if (existing >= 0) {
      methods[existing] = method;
    } else {
      methods.add(method);
    }
    state = state.copyWith(methods: methods, selectedId: method.id);
    AccountSession.save(ref,
        paymentMethods: state.methods, selectedPaymentId: state.selectedId);
  }
}

final paymentControllerProvider =
    NotifierProvider<PaymentController, PaymentState>(PaymentController.new);
