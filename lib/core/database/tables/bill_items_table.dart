// lib/core/database/tables/bill_items_table.dart
import 'package:drift/drift.dart';
import 'bills_table.dart';

/// Line items for a scanned bill — linked to [Bills] by [billId].
class BillItems extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get billId => integer().references(Bills, #id)();
  TextColumn get name => text()();
  RealColumn get quantity => real().withDefault(const Constant(1.0))();
  TextColumn get unit => text().nullable()(); // kg, pcs, ltr, etc.
  RealColumn get unitPrice => real().withDefault(const Constant(0.0))();
  RealColumn get totalPrice => real().withDefault(const Constant(0.0))();
}
