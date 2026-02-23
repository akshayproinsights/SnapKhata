// lib/features/billing/data/repositories/shop_profile_repository.dart
import 'package:drift/drift.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/database/app_database.dart';
import '../../../../core/utils/logger.dart';

/// Domain model for the shop/business profile.
class ShopProfileData {
  final int? localId;
  final String shopName;
  final String? shopAddress;
  final String? shopPhone;
  final String? shopGstNumber;
  final String? shopEmail;
  final String? logoPath;

  const ShopProfileData({
    this.localId,
    required this.shopName,
    this.shopAddress,
    this.shopPhone,
    this.shopGstNumber,
    this.shopEmail,
    this.logoPath,
  });

  ShopProfileData copyWith({
    int? localId,
    String? shopName,
    String? shopAddress,
    String? shopPhone,
    String? shopGstNumber,
    String? shopEmail,
    String? logoPath,
  }) =>
      ShopProfileData(
        localId: localId ?? this.localId,
        shopName: shopName ?? this.shopName,
        shopAddress: shopAddress ?? this.shopAddress,
        shopPhone: shopPhone ?? this.shopPhone,
        shopGstNumber: shopGstNumber ?? this.shopGstNumber,
        shopEmail: shopEmail ?? this.shopEmail,
        logoPath: logoPath ?? this.logoPath,
      );

  /// Abbreviated shop name for invoice number prefix (max 8 chars, uppercase).
  String get shopCode {
    final first = shopName.trim().split(RegExp(r'[\s\-_/]')).first;
    final cleaned = first.toUpperCase().replaceAll(RegExp(r'[^A-Z0-9]'), '');
    if (cleaned.isEmpty) return 'SK';
    return cleaned.length > 8 ? cleaned.substring(0, 8) : cleaned;
  }
}

class ShopProfileRepository {
  final AppDatabase _db;
  final SupabaseClient _supabase;

  ShopProfileRepository(
      {required AppDatabase db, required SupabaseClient supabase})
      : _db = db,
        _supabase = supabase;

  /// Load profile from local DB. Returns null if not yet set up.
  Future<ShopProfileData?> getProfile() async {
    final row = await _db.getShopProfile();
    if (row == null) return null;
    return ShopProfileData(
      localId: row.id,
      shopName: row.shopName,
      shopAddress: row.shopAddress,
      shopPhone: row.shopPhone,
      shopGstNumber: row.shopGstNumber,
      shopEmail: row.shopEmail,
      logoPath: row.logoPath,
    );
  }

  /// Save/update shop profile locally + sync to Supabase.
  Future<void> saveProfile(ShopProfileData profile) async {
    final companion = ShopProfilesCompanion(
      shopName: Value(profile.shopName),
      shopAddress: Value(profile.shopAddress),
      shopPhone: Value(profile.shopPhone),
      shopGstNumber: Value(profile.shopGstNumber),
      shopEmail: Value(profile.shopEmail),
      logoPath: Value(profile.logoPath),
      isSynced: const Value(false),
      updatedAt: Value(DateTime.now()),
    );

    await _db.upsertShopProfile(companion);
    log('Shop profile saved locally', tag: 'ShopProfileRepo');

    // Sync to Supabase
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) return;

      await _supabase.from('shop_profiles').upsert({
        'user_id': user.id,
        'shop_name': profile.shopName,
        'shop_address': profile.shopAddress,
        'shop_phone': profile.shopPhone,
        'shop_gst_number': profile.shopGstNumber,
        'shop_email': profile.shopEmail,
        'updated_at': DateTime.now().toIso8601String(),
      }, onConflict: 'user_id');

      log('Shop profile synced to Supabase', tag: 'ShopProfileRepo');
    } catch (e) {
      log('Supabase shop profile sync failed: $e', tag: 'ShopProfileRepo');
      // Not fatal — local save succeeded
    }
  }
}
