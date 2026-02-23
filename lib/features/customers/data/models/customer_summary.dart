// lib/features/customers/data/models/customer_summary.dart

/// Computed summary of a customer's ledger — built in-memory from
/// Bills + Payments to avoid stale derived data.
class CustomerSummary {
  final String displayName; // most frequent / latest name
  final String? phone; // null for name-only groups
  final double totalBilled; // sum of all bill.totalAmount
  final double totalPaid; // sum of bill.amountPaid + manual Payments
  final double
      pendingAmount; // totalBilled - totalPaid (can be negative = overpaid)
  final DateTime lastActivity; // latest bill or payment date
  final int billCount;

  const CustomerSummary({
    required this.displayName,
    this.phone,
    required this.totalBilled,
    required this.totalPaid,
    required this.pendingAmount,
    required this.lastActivity,
    required this.billCount,
  });

  bool get isSettled => pendingAmount <= 0;
}

/// A single ledger entry — either a Bill or a Payment — for the timeline.
class LedgerEntry {
  final LedgerEntryType type;
  final DateTime date;
  final double amount;
  final String label; // bill invoice or payment note
  final int? billId; // non-null for bill entries
  final int? paymentId; // non-null for payment entries
  final String? imagePath; // bill image for navigation
  final String? paymentNote;

  const LedgerEntry({
    required this.type,
    required this.date,
    required this.amount,
    required this.label,
    this.billId,
    this.paymentId,
    this.imagePath,
    this.paymentNote,
  });
}

enum LedgerEntryType { bill, payment }
