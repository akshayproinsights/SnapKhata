// lib/core/database/tables/shop_profile_table.dart
import 'package:drift/drift.dart';

/// Stores the SMB owner's shop profile — extracted once from the receipt pad scan.
/// One row per user (upserted on save).
class ShopProfiles extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get shopName => text().withDefault(const Constant('My Shop'))();
  TextColumn get shopAddress => text().nullable()();
  TextColumn get shopPhone => text().nullable()();
  TextColumn get shopGstNumber => text().nullable()();
  TextColumn get shopEmail => text().nullable()();
  TextColumn get logoPath =>
      text().nullable()(); // local file path to logo image
  TextColumn get supabaseId => text().nullable()();
  BoolColumn get isSynced => boolean().withDefault(const Constant(false))();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
}
