// lib/features/billing/presentation/providers/shop_profile_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../data/repositories/shop_profile_repository.dart';
import 'bill_provider.dart';

final shopProfileRepositoryProvider = Provider<ShopProfileRepository>((ref) {
  return ShopProfileRepository(
    db: ref.watch(appDatabaseProvider),
    supabase: Supabase.instance.client,
  );
});

// ── Shop profile state ────────────────────────────────────────

class ShopProfileNotifier extends AsyncNotifier<ShopProfileData?> {
  @override
  Future<ShopProfileData?> build() async {
    return ref.read(shopProfileRepositoryProvider).getProfile();
  }

  Future<void> save(ShopProfileData profile) async {
    state = const AsyncValue.loading();
    try {
      await ref.read(shopProfileRepositoryProvider).saveProfile(profile);
      state = AsyncValue.data(profile);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}

final shopProfileProvider =
    AsyncNotifierProvider<ShopProfileNotifier, ShopProfileData?>(
        ShopProfileNotifier.new);
