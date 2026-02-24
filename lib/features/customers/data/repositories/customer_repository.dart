// lib/features/customers/data/repositories/customer_repository.dart
import 'package:drift/drift.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/database/app_database.dart';
import '../models/customer_summary.dart';

class CustomerRepository {
  final AppDatabase _db;
  final SupabaseClient _supabase;

  CustomerRepository(
      {required AppDatabase db, required SupabaseClient supabase})
      : _db = db,
        _supabase = supabase;

  // ── Customer Summaries ───────────────────────────────────────────────

  /// Stream of all CustomerSummaries, grouped by phone (or name if no phone).
  /// Reacts reactively to any bill or payment change.
  Stream<List<CustomerSummary>> watchCustomerSummaries() {
    // Combine bills + payments streams
    return _db.watchAllBillsForLedger().asyncMap((_) => _computeSummaries());
  }

  Future<List<CustomerSummary>> _computeSummaries() async {
    final allBills = await _db.getAllBills();
    final allPayments = await _db.watchAllPayments().first;

    // Group bills by phone (non-null) or by name (phone is null)
    final Map<String, List<Bill>> phoneGroups = {};
    final Map<String, List<Bill>> nameGroups = {};

    for (final bill in allBills) {
      final phone = bill.customerPhone;
      if (phone != null && phone.isNotEmpty) {
        phoneGroups.putIfAbsent(phone, () => []).add(bill);
      } else {
        final name = bill.customerName.trim().toLowerCase();
        if (name.isNotEmpty) {
          nameGroups.putIfAbsent(name, () => []).add(bill);
        }
      }
    }

    // Group payments by phone
    final Map<String, List<Payment>> paymentsByPhone = {};
    for (final p in allPayments) {
      final phone = p.customerPhone;
      if (phone != null && phone.isNotEmpty) {
        paymentsByPhone.putIfAbsent(phone, () => []).add(p);
      }
    }

    final summaries = <CustomerSummary>[];

    // Phone-grouped summaries
    for (final entry in phoneGroups.entries) {
      final phone = entry.key;
      final billList = entry.value;
      final pmtList = paymentsByPhone[phone] ?? [];
      summaries.add(_buildSummary(
        phone: phone,
        bills: billList,
        payments: pmtList,
      ));
    }

    // Name-only summaries (no phone)
    for (final entry in nameGroups.entries) {
      final name = entry.key;
      final billList = entry.value;

      // Also find payments for this name (where phone is null)
      final pmtList = allPayments
          .where((p) =>
              (p.customerPhone == null || p.customerPhone!.isEmpty) &&
              p.customerName.trim().toLowerCase() == name)
          .toList();

      summaries.add(_buildSummary(
        phone: null,
        bills: billList,
        payments: pmtList,
      ));
    }

    // Sort by highest pending first, then by last activity
    summaries.sort((a, b) {
      if (b.pendingAmount != a.pendingAmount) {
        return b.pendingAmount.compareTo(a.pendingAmount);
      }
      return b.lastActivity.compareTo(a.lastActivity);
    });

    return summaries;
  }

  CustomerSummary _buildSummary({
    required String? phone,
    required List<Bill> bills,
    required List<Payment> payments,
  }) {
    // Display name = most frequent name (the name that appears most across bills)
    final nameFrequency = <String, int>{};
    for (final b in bills) {
      final n = b.customerName.trim();
      if (n.isNotEmpty) nameFrequency[n] = (nameFrequency[n] ?? 0) + 1;
    }
    String displayName = 'Unknown Customer';
    if (nameFrequency.isNotEmpty) {
      displayName = nameFrequency.entries
          .reduce((a, b) => a.value >= b.value ? a : b)
          .key;
    }

    final totalBilled = bills.fold<double>(0, (sum, b) => sum + b.totalAmount);
    final totalPaidFromBills =
        bills.fold<double>(0, (sum, b) => sum + b.amountPaid);
    final totalManualPayments =
        payments.fold<double>(0, (sum, p) => sum + p.amount);
    final totalPaid = totalPaidFromBills + totalManualPayments;
    final pending = totalBilled - totalPaid;

    // Last activity = most recent bill or payment date
    DateTime lastActivity = bills.first.createdAt;
    for (final b in bills) {
      if (b.createdAt.isAfter(lastActivity)) lastActivity = b.createdAt;
    }
    for (final p in payments) {
      if (p.paidAt.isAfter(lastActivity)) lastActivity = p.paidAt;
    }

    return CustomerSummary(
      displayName: displayName,
      phone: phone,
      totalBilled: totalBilled,
      totalPaid: totalPaid,
      pendingAmount: pending,
      lastActivity: lastActivity,
      billCount: bills.length,
    );
  }

  // ── Customer Detail ──────────────────────────────────────────────────

  /// Builds a sorted, interleaved timeline of bill + payment entries.
  Future<List<LedgerEntry>> getLedgerEntries(
      {required String? phone, required String displayName}) async {
    final List<LedgerEntry> entries = [];

    // Bills
    final bills = phone != null && phone.isNotEmpty
        ? await _db.getBillsByPhone(phone)
        : await _db.getBillsByName(displayName);

    for (final b in bills) {
      entries.add(LedgerEntry(
        type: LedgerEntryType.bill,
        date: b.createdAt,
        amount: b.totalAmount,
        label: 'Bill — ₹${b.totalAmount.toStringAsFixed(0)}',
        billId: b.id,
        imagePath: b.rawImagePath,
      ));
    }

    // Manual payments
    if (phone != null && phone.isNotEmpty) {
      final pmts = await _db.getPaymentsByPhone(phone);
      for (final p in pmts) {
        entries.add(LedgerEntry(
          type: LedgerEntryType.payment,
          date: p.paidAt,
          amount: p.amount,
          label: 'Payment',
          paymentId: p.id,
          paymentNote: p.note,
        ));
      }
    } else {
      // Fetch by name if phone is null
      final pmts = await _db.getPaymentsByName(displayName);
      for (final p in pmts) {
        // Only add if it doesn't have a phone (to avoid duplicates if some payments have phone and others don't for same customer)
        // Actually, if we are in a name-only detail, we want all payments associated with this name.
        if (p.customerPhone == null || p.customerPhone!.isEmpty) {
          entries.add(LedgerEntry(
            type: LedgerEntryType.payment,
            date: p.paidAt,
            amount: p.amount,
            label: 'Payment',
            paymentId: p.id,
            paymentNote: p.note,
          ));
        }
      }
    }

    // Sort newest first
    entries.sort((a, b) => b.date.compareTo(a.date));
    return entries;
  }

  // ── Add Payment ──────────────────────────────────────────────────────

  Future<void> addPayment({
    required String? phone,
    required String customerName,
    required double amount,
    String? note,
    DateTime? paidAt,
  }) async {
    final now = paidAt ?? DateTime.now();

    // Save locally
    await _db.insertPayment(PaymentsCompanion(
      customerPhone: Value(phone),
      customerName: Value(customerName),
      amount: Value(amount),
      note: Value(note),
      paidAt: Value(now),
    ));

    // Sync to Supabase (best-effort)
    try {
      final user = _supabase.auth.currentUser;
      if (user != null) {
        await _supabase.from('payments').insert({
          'user_id': user.id,
          'customer_phone': phone,
          'customer_name': customerName,
          'amount': amount,
          'note': note,
          'paid_at': now.toIso8601String(),
        });
      }
    } catch (_) {
      // Silently fail — local data is source of truth
    }
  }

  /// Deletes a manual payment locally and from Supabase.
  Future<void> deletePayment(int localId) async {
    // 1. Fetch to get supabaseId
    final pmt = await (_db.select(_db.payments)
          ..where((t) => t.id.equals(localId)))
        .getSingleOrNull();

    // 2. Delete locally
    await (_db.delete(_db.payments)..where((t) => t.id.equals(localId))).go();

    // 3. Try Supabase
    if (pmt?.supabaseId != null) {
      try {
        await _supabase.from('payments').delete().eq('id', pmt!.supabaseId!);
      } catch (_) {}
    }
  }

  /// Deletes an entire customer Profile and their transaction history.
  Future<void> deleteCustomer(String? phone, String name) async {
    // 1. Local Wipe
    if (phone != null && phone.isNotEmpty) {
      await _db.deleteCustomerAndHistoryByPhone(phone);
    } else {
      await _db.deleteCustomerAndHistoryByName(name);
    }

    // 2. Supabase Wipe (Live Sync)
    try {
      final user = _supabase.auth.currentUser;
      if (user != null) {
        // Bills
        var billQuery = _supabase.from('bills').delete().eq('user_id', user.id);
        if (phone != null && phone.isNotEmpty) {
          billQuery = billQuery.eq('customer_phone', phone);
        } else {
          billQuery = billQuery.eq('customer_name', name);
        }
        await billQuery;

        // Payments
        var pmtQuery =
            _supabase.from('payments').delete().eq('user_id', user.id);
        if (phone != null && phone.isNotEmpty) {
          pmtQuery = pmtQuery.eq('customer_phone', phone);
        } else {
          pmtQuery = pmtQuery.eq('customer_name', name);
        }
        await pmtQuery;
      }
    } catch (_) {
      // Ignore live-sync failures
    }
  }

  /// Deletes multiple customers.
  Future<void> deleteCustomers(
      List<({String? phone, String name})> customers) async {
    for (final c in customers) {
      await deleteCustomer(c.phone, c.name);
    }
  }
}
