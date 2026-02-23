// lib/features/billing/data/repositories/bill_repository.dart
import 'dart:io';
import 'package:drift/drift.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/database/app_database.dart';
import '../../../../core/utils/image_utils.dart';
import '../../../../core/utils/logger.dart';
import '../models/scanned_bill.dart';
import '../models/bill_item.dart' as domain;

class BillRepository {
  final AppDatabase _db;
  final SupabaseClient _supabase;

  BillRepository({required AppDatabase db, required SupabaseClient supabase})
      : _db = db,
        _supabase = supabase;

  /// Save a bill locally (Drift) + sync to Supabase if online.
  /// Returns a record with the local bill ID, sync status, and any sync error.
  Future<({int billId, bool isSynced, String? syncError})> saveBill({
    required ScannedBill scannedBill,
    required File imageFile,
    String invoiceType = 'order_summary', // 'order_summary' | 'gst_invoice'
  }) async {
    // Step 1: Compress image for storage
    final compressed =
        await ImageUtils.compressForUpload(imageFile) ?? imageFile;

    // Step 2: Save to local Drift DB first (offline-first)
    final billId = await _db.insertBill(BillsCompanion(
      customerName: Value(scannedBill.customerName ?? ''),
      customerPhone: Value(scannedBill.customerPhone),
      invoiceType: Value(invoiceType),
      totalAmount: Value(scannedBill.totalAmount),
      amountPaid: Value(scannedBill.amountPaid ?? 0.0),
      amountRemaining:
          Value(scannedBill.amountRemaining ?? scannedBill.totalAmount),
      status:
          Value(scannedBill.paymentStatus == 'paid' ? 'confirmed' : 'draft'),
      rawImagePath: Value(compressed.path),
      isSynced: const Value(false),
    ));

    // Step 3: Save line items
    final itemCompanions = scannedBill.items
        .map((item) => BillItemsCompanion(
              billId: Value(billId),
              name: Value(item.name),
              quantity: Value(item.quantity),
              unit: Value(item.unit),
              unitPrice: Value(item.unitPrice),
              totalPrice: Value(item.totalPrice),
            ))
        .toList();

    for (final ic in itemCompanions) {
      await _db.insertBillItem(ic);
    }

    // Step 4: Try to sync to Supabase
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) {
        log('No user session — skipping Supabase sync', tag: 'BillRepository');
        return (billId: billId, isSynced: false, syncError: 'Not logged in');
      }
      final userId = user.id;

      // Use email username (before @) as human-readable folder name
      final email = user.email ?? userId;
      final folderName = email.contains('@') ? email.split('@').first : userId;

      // Upload image to Supabase Storage
      final ext = compressed.path.split('.').last;
      final storagePath =
          '$folderName/bill_${DateTime.now().millisecondsSinceEpoch}.$ext';

      await _supabase.storage.from(AppConstants.billImagesBucket).upload(
          storagePath, compressed,
          fileOptions:
              const FileOptions(contentType: 'image/jpeg', upsert: true));

      final imageUrl = _supabase.storage
          .from(AppConstants.billImagesBucket)
          .getPublicUrl(storagePath);

      // Insert into Supabase bills table
      final response = await _supabase
          .from('bills')
          .insert({
            'user_id': userId,
            'customer_name': scannedBill.customerName,
            'customer_phone': scannedBill.customerPhone,
            'invoice_type': 'order_summary',
            'total_amount': scannedBill.totalAmount,
            'subtotal': scannedBill.subtotal,
            'discount': scannedBill.discount,
            'gst_amount': scannedBill.gstAmount,
            'gst_percent': scannedBill.gstPercent,
            'amount_paid': scannedBill.amountPaid,
            'amount_remaining': scannedBill.amountRemaining,
            'payment_status': scannedBill.paymentStatus,
            'status':
                scannedBill.paymentStatus == 'paid' ? 'confirmed' : 'draft',
            'image_url': imageUrl,
            'bill_date': scannedBill.date,
          })
          .select('id')
          .single();

      final supabaseId = response['id'] as String?;

      // Insert line items into Supabase bill_items table
      if (supabaseId != null && scannedBill.items.isNotEmpty) {
        try {
          final itemRows = scannedBill.items
              .map((item) => {
                    'bill_id': supabaseId,
                    'user_id': userId,
                    'name': item.name,
                    'quantity': item.quantity,
                    'unit': item.unit,
                    'unit_price': item.unitPrice,
                    'total_price': item.totalPrice,
                  })
              .toList();
          log('Inserting ${itemRows.length} items for bill $supabaseId',
              tag: 'BillRepository');
          await _supabase.from('bill_items').insert(itemRows);
          log('Bill items synced successfully', tag: 'BillRepository');
        } catch (e) {
          log('bill_items insert FAILED: $e', tag: 'BillRepository');
          // Bill itself is synced — don't fail the whole save for items
        }
      } else {
        log('Skipping items insert: supabaseId=$supabaseId, items=${scannedBill.items.length}',
            tag: 'BillRepository');
      }

      // Step 5: Update local record as synced
      final localBill = await (_db.select(_db.bills)
            ..where((t) => t.id.equals(billId)))
          .getSingle();
      await _db.updateBill(localBill.copyWith(
        isSynced: true,
        supabaseId: Value(supabaseId),
      ));

      log('Bill synced to Supabase: $supabaseId', tag: 'BillRepository');
      return (billId: billId, isSynced: true, syncError: null);
    } catch (e) {
      final errMsg = e.toString();
      log('Supabase sync failed: $errMsg', tag: 'BillRepository');
      return (billId: billId, isSynced: false, syncError: errMsg);
    }
  }

  /// Save a manual bill (no image) locally + sync to Supabase.
  Future<({int billId, bool isSynced, String? syncError})> saveManualBill({
    required ScannedBill scannedBill,
  }) async {
    // Step 1: Save to local Drift DB (offline-first)
    final billId = await _db.insertBill(BillsCompanion(
      customerName: Value(scannedBill.customerName ?? ''),
      customerPhone: Value(scannedBill.customerPhone),
      invoiceType: const Value('order_summary'),
      totalAmount: Value(scannedBill.totalAmount),
      amountPaid: Value(scannedBill.amountPaid ?? 0.0),
      amountRemaining:
          Value(scannedBill.amountRemaining ?? scannedBill.totalAmount),
      status:
          Value(scannedBill.paymentStatus == 'paid' ? 'confirmed' : 'draft'),
      rawImagePath: const Value(null),
      isSynced: const Value(false),
    ));

    // Step 2: Save line items
    for (final item in scannedBill.items) {
      await _db.insertBillItem(BillItemsCompanion(
        billId: Value(billId),
        name: Value(item.name),
        quantity: Value(item.quantity),
        unit: Value(item.unit),
        unitPrice: Value(item.unitPrice),
        totalPrice: Value(item.totalPrice),
      ));
    }

    // Step 3: Upsert catalog items (self-learning catalog)
    for (final item in scannedBill.items) {
      if (item.name.trim().isNotEmpty) {
        await _db.upsertCatalogItem(CatalogItemsCompanion(
          name: Value(item.name.trim()),
          normalizedName: Value(item.name.trim().toLowerCase()),
          lastPrice: Value(item.unitPrice),
          unit: Value(item.unit ?? 'pcs'),
          timesOrdered: const Value(1),
          lastSeenAt: Value(DateTime.now()),
        ));
      }
    }

    // Step 4: Try to sync to Supabase
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) {
        log('No user session — skipping Supabase sync', tag: 'BillRepository');
        return (billId: billId, isSynced: false, syncError: 'Not logged in');
      }
      final userId = user.id;

      final response = await _supabase
          .from('bills')
          .insert({
            'user_id': userId,
            'customer_name': scannedBill.customerName,
            'customer_phone': scannedBill.customerPhone,
            'invoice_type': 'order_summary',
            'total_amount': scannedBill.totalAmount,
            'subtotal': scannedBill.subtotal,
            'discount': scannedBill.discount,
            'amount_paid': scannedBill.amountPaid,
            'amount_remaining': scannedBill.amountRemaining,
            'payment_status': scannedBill.paymentStatus,
            'status':
                scannedBill.paymentStatus == 'paid' ? 'confirmed' : 'draft',
            'bill_date': scannedBill.date,
          })
          .select('id')
          .single();

      final supabaseId = response['id'] as String?;

      // Insert line items into Supabase
      if (supabaseId != null && scannedBill.items.isNotEmpty) {
        try {
          final itemRows = scannedBill.items
              .map((item) => {
                    'bill_id': supabaseId,
                    'user_id': userId,
                    'name': item.name,
                    'quantity': item.quantity,
                    'unit': item.unit,
                    'unit_price': item.unitPrice,
                    'total_price': item.totalPrice,
                  })
              .toList();
          await _supabase.from('bill_items').insert(itemRows);
        } catch (e) {
          log('Manual bill items sync failed: $e', tag: 'BillRepository');
        }
      }

      // Update local record as synced
      final localBill = await (_db.select(_db.bills)
            ..where((t) => t.id.equals(billId)))
          .getSingle();
      await _db.updateBill(localBill.copyWith(
        isSynced: true,
        supabaseId: Value(supabaseId),
      ));

      log('Manual bill synced to Supabase: $supabaseId',
          tag: 'BillRepository');
      return (billId: billId, isSynced: true, syncError: null);
    } catch (e) {
      final errMsg = e.toString();
      log('Supabase sync failed for manual bill: $errMsg',
          tag: 'BillRepository');
      return (billId: billId, isSynced: false, syncError: errMsg);
    }
  }

  /// Watch recent bills from local Drift DB.
  Stream<List<Bill>> watchRecentBills({int limit = 5}) =>
      _db.watchRecentBills(limit: limit);

  /// Get all line items for a bill.
  Future<List<domain.BillItem>> getBillItems(int billId) async {
    final rows = await _db.getBillItems(billId);
    return rows
        .map((r) => domain.BillItem(
              name: r.name,
              quantity: r.quantity,
              unit: r.unit,
              unitPrice: r.unitPrice,
              totalPrice: r.totalPrice,
            ))
        .toList();
  }

  /// Deletes a bill locally and from Supabase (live-sync).
  Future<void> deleteBill(int localId) async {
    // 1. Fetch to get supabaseId
    final bill = await (_db.select(_db.bills)
          ..where((t) => t.id.equals(localId)))
        .getSingleOrNull();

    // 2. Delete locally first
    await _db.deleteBill(localId);

    // 3. Try deleting from Supabase
    if (bill?.supabaseId != null) {
      try {
        log('Deleting bill from Supabase: ${bill!.supabaseId}',
            tag: 'BillRepository');
        await _supabase.from('bills').delete().eq('id', bill.supabaseId!);
        log('Bill deleted from Supabase successfully', tag: 'BillRepository');
      } catch (e) {
        log('Failed to delete from Supabase: $e', tag: 'BillRepository');
        // Live-sync failure is ignored per plan
      }
    }
  }
}
