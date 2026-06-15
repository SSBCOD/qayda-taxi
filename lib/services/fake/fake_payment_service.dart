import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/enums.dart';

/// Outcome of a fake charge.
class PaymentResult {
  final bool success;
  final String receiptId;
  final num amount;
  final PaymentType method;
  const PaymentResult({
    required this.success,
    required this.receiptId,
    required this.amount,
    required this.method,
  });
}

/// Fake payment processor for the MVP demo. Always succeeds after a short
/// "processing" delay and returns a receipt id. No real gateway, no card data
/// — see docs/backend.md (payments are mocked).
class FakePaymentService {
  const FakePaymentService();

  Future<PaymentResult> charge({
    required num amount,
    required PaymentType method,
    Duration delay = const Duration(milliseconds: 1500),
  }) async {
    await Future.delayed(delay);
    final stamp =
        DateTime.now().millisecondsSinceEpoch.toRadixString(36).toUpperCase();
    return PaymentResult(
      success: true,
      receiptId: 'QR-$stamp',
      amount: amount,
      method: method,
    );
  }
}

final paymentServiceProvider =
    Provider<FakePaymentService>((_) => const FakePaymentService());
