// lib/core/database/tables/catalog_items_table.dart
import 'package:drift/drift.dart';

/// Self-learning item catalog — grows from each scanned bill.
class CatalogItems extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text()(); // e.g., "Amul Butter 500g"
  TextColumn get normalizedName => text()(); // lowercased for search
  RealColumn get lastPrice => real().withDefault(const Constant(0.0))();
  TextColumn get unit => text().withDefault(const Constant('pcs'))(); // kg, pcs, ltr…
  TextColumn get category => text().nullable()();
  IntColumn get timesOrdered => integer().withDefault(const Constant(0))();
  DateTimeColumn get lastSeenAt => dateTime().withDefault(currentDateAndTime)();
  BoolColumn get isSynced => boolean().withDefault(const Constant(false))();
}
