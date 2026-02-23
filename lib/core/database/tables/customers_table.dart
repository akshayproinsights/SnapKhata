// lib/core/database/tables/customers_table.dart
import 'package:drift/drift.dart';

/// Stores customer records built up from bills over time.
class Customers extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get supabaseId => text().nullable()();
  TextColumn get name => text()();
  TextColumn get phone => text().nullable()();
  RealColumn get totalPurchases => real().withDefault(const Constant(0.0))();
  DateTimeColumn get lastPurchaseAt => dateTime().nullable()();
  BoolColumn get isSynced => boolean().withDefault(const Constant(false))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}
