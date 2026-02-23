// lib/core/database/app_database.dart
import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'tables/bills_table.dart';
import 'tables/bill_items_table.dart';
import 'tables/catalog_items_table.dart';
import 'tables/customers_table.dart';
import 'tables/payments_table.dart';
import 'tables/shop_profile_table.dart';

part 'app_database.g.dart';

@DriftDatabase(
    tables: [Bills, BillItems, CatalogItems, Customers, Payments, ShopProfiles])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 4;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (m) async {
          await m.createAll();
        },
        onUpgrade: (m, from, to) async {
          if (from < 2) {
            await m.createTable(billItems);
          }
          if (from < 3) {
            await m.createTable(shopProfiles);
          }
          if (from < 4) {
            await m.addColumn(bills, bills.customerPhone);
            await m.addColumn(bills, bills.amountPaid);
            await m.addColumn(bills, bills.amountRemaining);
            await m.createTable(payments);
          }
        },
      );

  // ── Bills ────────────────────────────────────────────────
  Future<List<Bill>> getAllBills() => select(bills).get();

  Stream<List<Bill>> watchAllBills() => select(bills).watch();

  Stream<List<Bill>> watchRecentBills({int limit = 5}) {
    return (select(bills)
          ..orderBy([(t) => OrderingTerm.desc(t.createdAt)])
          ..limit(limit))
        .watch();
  }

  Future<int> insertBill(BillsCompanion entry) => into(bills).insert(entry);

  Future<bool> updateBill(Bill entry) => update(bills).replace(entry);

  Future<void> deleteBill(int id) async {
    // Delete items first
    await (delete(billItems)..where((t) => t.billId.equals(id))).go();
    // Delete bill
    await (delete(bills)..where((t) => t.id.equals(id))).go();
  }

  /// Deletes all bills and payments for a customer by phone.
  Future<void> deleteCustomerAndHistoryByPhone(String phone) async {
    transaction(() async {
      final customerBills = await getBillsByPhone(phone);
      for (final b in customerBills) {
        await deleteBill(b.id);
      }
      await (delete(payments)..where((t) => t.customerPhone.equals(phone)))
          .go();
    });
  }

  /// Deletes all bills and payments for a customer by name.
  Future<void> deleteCustomerAndHistoryByName(String name) async {
    transaction(() async {
      final customerBills = await getBillsByName(name);
      for (final b in customerBills) {
        await deleteBill(b.id);
      }
      await (delete(payments)
            ..where((t) => t.customerName.lower().equals(name.toLowerCase())))
          .go();
    });
  }

  // ── Bill Items ───────────────────────────────────────────
  Future<List<BillItem>> getBillItems(int billId) {
    return (select(billItems)..where((t) => t.billId.equals(billId))).get();
  }

  Future<int> insertBillItem(BillItemsCompanion entry) =>
      into(billItems).insert(entry);

  Future<void> replaceBillItems(
      int billId, List<BillItemsCompanion> items) async {
    await (delete(billItems)..where((t) => t.billId.equals(billId))).go();
    for (final item in items) {
      await into(billItems).insert(item);
    }
  }

  // ── Catalog ──────────────────────────────────────────────
  Stream<List<CatalogItem>> watchCatalog() => select(catalogItems).watch();

  Future<List<CatalogItem>> searchCatalog(String query) {
    return (select(catalogItems)
          ..where((t) => t.normalizedName.contains(query.toLowerCase())))
        .get();
  }

  Future<int> upsertCatalogItem(CatalogItemsCompanion entry) =>
      into(catalogItems).insertOnConflictUpdate(entry);

  // ── Customers ────────────────────────────────────────────
  Future<List<Customer>> getAllCustomers() => select(customers).get();

  Future<int> insertCustomer(CustomersCompanion entry) =>
      into(customers).insert(entry);

  // ── Customer Ledger Queries ───────────────────────────────

  /// Watch ALL bills ordered by date desc — for computing customer summaries.
  Stream<List<Bill>> watchAllBillsForLedger() {
    return (select(bills)..orderBy([(t) => OrderingTerm.desc(t.createdAt)]))
        .watch();
  }

  /// Bills by customer phone number.
  Future<List<Bill>> getBillsByPhone(String phone) {
    return (select(bills)
          ..where((t) => t.customerPhone.equals(phone))
          ..orderBy([(t) => OrderingTerm.desc(t.createdAt)]))
        .get();
  }

  /// Bills by customer name (exact, case-insensitive) — used when no phone.
  Future<List<Bill>> getBillsByName(String name) {
    return (select(bills)
          ..where((t) => t.customerName.lower().equals(name.toLowerCase()))
          ..orderBy([(t) => OrderingTerm.desc(t.createdAt)]))
        .get();
  }

  /// Attempts to find a phone number for a customer by searching bills/payments.
  Future<String?> getPhoneByName(String name) async {
    // Try bills first
    final billsWithMatch = await (select(bills)
          ..where((t) => t.customerName.lower().equals(name.toLowerCase()))
          ..where((t) => t.customerPhone.isNotNull()))
        .get();

    for (final b in billsWithMatch) {
      if (b.customerPhone != null && b.customerPhone!.isNotEmpty) {
        return b.customerPhone;
      }
    }

    // Try payments
    final pmtsWithMatch = await (select(payments)
          ..where((t) => t.customerName.lower().equals(name.toLowerCase()))
          ..where((t) => t.customerPhone.isNotNull()))
        .get();

    for (final p in pmtsWithMatch) {
      if (p.customerPhone != null && p.customerPhone!.isNotEmpty) {
        return p.customerPhone;
      }
    }

    return null;
  }

  // ── Payments ──────────────────────────────────────────────

  Stream<List<Payment>> watchPaymentsByPhone(String phone) {
    return (select(payments)
          ..where((t) => t.customerPhone.equals(phone))
          ..orderBy([(t) => OrderingTerm.desc(t.paidAt)]))
        .watch();
  }

  Future<List<Payment>> getPaymentsByPhone(String phone) {
    return (select(payments)
          ..where((t) => t.customerPhone.equals(phone))
          ..orderBy([(t) => OrderingTerm.desc(t.paidAt)]))
        .get();
  }

  /// Payments by customer name (cases-insensitive) — used when no phone.
  Future<List<Payment>> getPaymentsByName(String name) {
    return (select(payments)
          ..where((t) => t.customerName.lower().equals(name.toLowerCase()))
          ..orderBy([(t) => OrderingTerm.desc(t.paidAt)]))
        .get();
  }

  Stream<List<Payment>> watchAllPayments() {
    return (select(payments)..orderBy([(t) => OrderingTerm.desc(t.paidAt)]))
        .watch();
  }

  Future<int> insertPayment(PaymentsCompanion entry) =>
      into(payments).insert(entry);

  Future<bool> updatePayment(Payment entry) => update(payments).replace(entry);

  Future<int> deletePayment(int id) =>
      (delete(payments)..where((t) => t.id.equals(id))).go();

  // ── Shop Profile ─────────────────────────────────────────
  Future<ShopProfile?> getShopProfile() => (select(shopProfiles)
        ..orderBy([(t) => OrderingTerm.desc(t.updatedAt)])
        ..limit(1))
      .getSingleOrNull();

  Future<void> upsertShopProfile(ShopProfilesCompanion entry) async {
    final existing = await (select(shopProfiles)
          ..orderBy([(t) => OrderingTerm.desc(t.updatedAt)])
          ..limit(1))
        .getSingleOrNull();
    if (existing != null) {
      await (update(shopProfiles)..where((t) => t.id.equals(existing.id)))
          .write(entry);
    } else {
      await into(shopProfiles).insert(entry);
    }
  }

  // ── Sync helpers ─────────────────────────────────────────
  Future<List<Bill>> getUnsyncedBills() =>
      (select(bills)..where((t) => t.isSynced.equals(false))).get();

  Future<List<CatalogItem>> getUnsyncedCatalogItems() =>
      (select(catalogItems)..where((t) => t.isSynced.equals(false))).get();
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'snap_khata.db'));
    return NativeDatabase.createInBackground(file);
  });
}
