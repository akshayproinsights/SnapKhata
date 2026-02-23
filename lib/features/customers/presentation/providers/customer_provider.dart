// lib/features/customers/presentation/providers/customer_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../billing/presentation/providers/bill_provider.dart';
import '../../data/models/customer_summary.dart';
import '../../data/repositories/customer_repository.dart';

// ── Repository ─────────────────────────────────────────────────────────

final customerRepositoryProvider = Provider<CustomerRepository>((ref) {
  return CustomerRepository(
    db: ref.watch(appDatabaseProvider),
    supabase: Supabase.instance.client,
  );
});

// ── Customer Summaries (home list) ─────────────────────────────────────

final customerSummariesProvider = StreamProvider<List<CustomerSummary>>((ref) {
  return ref.watch(customerRepositoryProvider).watchCustomerSummaries();
});

// ── Customer Detail (ledger entries for one customer) ──────────────────

class CustomerDetailArgs {
  final String? phone;
  final String displayName;

  const CustomerDetailArgs({required this.phone, required this.displayName});

  @override
  bool operator ==(Object other) =>
      other is CustomerDetailArgs &&
      other.phone == phone &&
      other.displayName == displayName;

  @override
  int get hashCode => Object.hash(phone, displayName);
}

final customerDetailProvider =
    FutureProvider.family<List<LedgerEntry>, CustomerDetailArgs>(
        (ref, args) async {
  return ref.watch(customerRepositoryProvider).getLedgerEntries(
        phone: args.phone,
        displayName: args.displayName,
      );
});

// ── Add Payment ─────────────────────────────────────────────────────────

class AddPaymentState {
  final bool loading;
  final bool success;
  final String? error;

  const AddPaymentState({
    this.loading = false,
    this.success = false,
    this.error,
  });
}

class AddPaymentNotifier extends AutoDisposeNotifier<AddPaymentState> {
  @override
  AddPaymentState build() => const AddPaymentState();

  Future<void> addPayment({
    required String? phone,
    required String customerName,
    required double amount,
    String? note,
    DateTime? paidAt,
  }) async {
    state = const AddPaymentState(loading: true);
    try {
      await ref.read(customerRepositoryProvider).addPayment(
            phone: phone,
            customerName: customerName,
            amount: amount,
            note: note,
            paidAt: paidAt,
          );
      state = const AddPaymentState(success: true);
    } catch (e) {
      state = AddPaymentState(error: e.toString());
    }
  }

  void reset() => state = const AddPaymentState();
}

final addPaymentProvider =
    AutoDisposeNotifierProvider<AddPaymentNotifier, AddPaymentState>(
        AddPaymentNotifier.new);
