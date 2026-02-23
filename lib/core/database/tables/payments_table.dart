// lib/core/database/tables/payments_table.dart
import 'package:drift/drift.dart';

/// Records ad-hoc payments made by a customer (cash/UPI).
/// These are separate from bill's amountPaid — they are manual entries
/// by the shopkeeper when the customer physically pays.
class Payments extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get supabaseId => text().nullable()();
  TextColumn get customerPhone =>
      text().nullable()(); // group key — matches Bills.customerPhone
  TextColumn get customerName => text().withDefault(const Constant(''))();
  RealColumn get amount => real().withDefault(const Constant(0.0))();
  TextColumn get note =>
      text().nullable()(); // e.g. "Cash", "UPI", "Part payment"
  BoolColumn get isSynced => boolean().withDefault(const Constant(false))();
  DateTimeColumn get paidAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}
