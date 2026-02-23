// lib/features/billing/presentation/providers/bill_provider.dart
import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/database/app_database.dart';
import '../../data/models/scanned_bill.dart';
import '../../data/repositories/bill_repository.dart';

// ─────────────────────────────────────────────────
// Singletons
// ─────────────────────────────────────────────────

final appDatabaseProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase();
  ref.onDispose(db.close);
  return db;
});

final billRepositoryProvider = Provider<BillRepository>((ref) {
  return BillRepository(
    db: ref.watch(appDatabaseProvider),
    supabase: Supabase.instance.client,
  );
});

// ─────────────────────────────────────────────────
// Recent bills (home screen)
// ─────────────────────────────────────────────────

final recentBillsProvider = StreamProvider<List<Bill>>((ref) {
  return ref.watch(billRepositoryProvider).watchRecentBills(limit: 5);
});

// ─────────────────────────────────────────────────
// Save bill notifier
// ─────────────────────────────────────────────────

enum SaveStatus { idle, loading, success, error }

class SaveBillState {
  final SaveStatus status;
  final int? savedBillId;
  final bool isSynced;
  final String? errorMessage;
  final String?
      syncError; // non-null when saved locally but Supabase sync failed

  const SaveBillState({
    this.status = SaveStatus.idle,
    this.savedBillId,
    this.isSynced = false,
    this.errorMessage,
    this.syncError,
  });
}

class SaveBillNotifier extends AutoDisposeNotifier<SaveBillState> {
  @override
  SaveBillState build() => const SaveBillState();

  Future<int?> save({
    required ScannedBill scannedBill,
    required File imageFile,
    String invoiceType = 'order_summary',
  }) async {
    state = const SaveBillState(status: SaveStatus.loading);
    try {
      final result = await ref.read(billRepositoryProvider).saveBill(
            scannedBill: scannedBill,
            imageFile: imageFile,
            invoiceType: invoiceType,
          );

      state = SaveBillState(
        status: SaveStatus.success,
        savedBillId: result.billId,
        isSynced: result.isSynced,
        syncError: result.syncError,
      );
      return result.billId;
    } catch (e) {
      state = SaveBillState(
        status: SaveStatus.error,
        errorMessage: 'Could not save bill: $e',
      );
      return null;
    }
  }
}

final saveBillProvider =
    AutoDisposeNotifierProvider<SaveBillNotifier, SaveBillState>(
        SaveBillNotifier.new);

// ─────────────────────────────────────────────────
// Save manual bill notifier (no image)
// ─────────────────────────────────────────────────

class SaveManualBillNotifier extends AutoDisposeNotifier<SaveBillState> {
  @override
  SaveBillState build() => const SaveBillState();

  Future<int?> save({required ScannedBill scannedBill}) async {
    state = const SaveBillState(status: SaveStatus.loading);
    try {
      final result = await ref.read(billRepositoryProvider).saveManualBill(
            scannedBill: scannedBill,
          );

      state = SaveBillState(
        status: SaveStatus.success,
        savedBillId: result.billId,
        isSynced: result.isSynced,
        syncError: result.syncError,
      );
      return result.billId;
    } catch (e) {
      state = SaveBillState(
        status: SaveStatus.error,
        errorMessage: 'Could not save bill: $e',
      );
      return null;
    }
  }
}

final saveManualBillProvider =
    AutoDisposeNotifierProvider<SaveManualBillNotifier, SaveBillState>(
        SaveManualBillNotifier.new);
