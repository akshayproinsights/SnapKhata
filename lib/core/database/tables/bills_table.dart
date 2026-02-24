// lib/core/database/tables/bills_table.dart
import 'package:drift/drift.dart';

/// Stores scanned/created bills locally (offline-first).
class Bills extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get supabaseId => text().nullable()(); // synced remote ID
  TextColumn get customerName => text().withDefault(const Constant(''))();
  TextColumn get customerPhone =>
      text().nullable()(); // for customer ledger grouping
  TextColumn get billNumber =>
      text().nullable()(); // extracted manual bill number
  TextColumn get invoiceType => text().withDefault(
      const Constant('order_summary'))(); // 'gst' | 'order_summary'
  RealColumn get totalAmount => real().withDefault(const Constant(0.0))();
  RealColumn get amountPaid => real().withDefault(const Constant(0.0))();
  RealColumn get amountRemaining =>
      real().nullable()(); // null means full amount remaining
  TextColumn get status =>
      text().withDefault(const Constant('draft'))(); // 'draft' | 'sent'
  TextColumn get rawImagePath =>
      text().nullable()(); // local compressed image path
  BoolColumn get isSynced => boolean().withDefault(const Constant(false))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
}
