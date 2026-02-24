// lib/features/billing/presentation/screens/order_detail_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/database/app_database.dart';
import '../../data/models/bill_item.dart' as domain;
import '../providers/bill_provider.dart';
import '../providers/shop_profile_provider.dart';
import '../../../../core/utils/whatsapp_utils.dart';

// ─────────────────────────────────────────────────────────────
// Colors
// ─────────────────────────────────────────────────────────────
const _kGreen = Color(0xFF1B8A2A);
const _kRed = Color(0xFFC62828);
const _kOrange = Color(0xFFE65100);
const _kBlue = Color(0xFF0066FF);
const _kDivider = Color(0xFFEEEEEE);

// ─────────────────────────────────────────────────────────────
// Provider to fetch bill items
// ─────────────────────────────────────────────────────────────
final billItemsProvider =
    FutureProvider.family<List<domain.BillItem>, int>((ref, billId) {
  return ref.watch(billRepositoryProvider).getBillItems(billId);
});

// ─────────────────────────────────────────────────────────────
// OrderDetailScreen
// ─────────────────────────────────────────────────────────────

class OrderDetailScreen extends ConsumerStatefulWidget {
  final Bill bill;

  const OrderDetailScreen({super.key, required this.bill});

  @override
  ConsumerState<OrderDetailScreen> createState() => _OrderDetailScreenState();
}

class _OrderDetailScreenState extends ConsumerState<OrderDetailScreen> {
  bool _isDeleting = false;

  Future<void> _deleteBill() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Delete Order',
            style: TextStyle(fontWeight: FontWeight.w800)),
        content: const Text(
            'Are you sure you want to delete this order? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: FilledButton.styleFrom(backgroundColor: _kRed),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    setState(() => _isDeleting = true);
    try {
      await ref.read(billRepositoryProvider).deleteBill(widget.bill.id);
      if (mounted) context.pop();
    } catch (e) {
      setState(() => _isDeleting = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Failed to delete: $e'), backgroundColor: _kRed),
        );
      }
    }
  }

  Future<void> _shareOrder() async {
    final bill = widget.bill;

    try {
      final phone = bill.customerPhone;
      if (phone == null || phone.isEmpty) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Add customer mobile number to share on WhatsApp.'),
          ),
        );
        return;
      }

      // Build the public web URL for this order from Supabase ID.
      final repo = ref.read(billRepositoryProvider);
      final shareUrl = await repo.getBillShareUrl(bill.id);

      if (!mounted) return;

      if (shareUrl == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text(
                'Cloud link will be ready once sync completes. Please connect to internet and try again.'),
            backgroundColor: _kOrange,
          ),
        );
        return;
      }

      final shop = await ref.read(shopProfileRepositoryProvider).getProfile();
      final name = bill.customerName.isNotEmpty ? bill.customerName : 'there';

      final status = bill.status == 'confirmed'
          ? OrderPaymentStatus.fullyPaid
          : (bill.amountPaid > 0
              ? OrderPaymentStatus.partiallyPaid
              : OrderPaymentStatus.unpaid);

      final caption = WhatsAppUtils.getWhatsAppCaption(
        status: status,
        customerName: name,
        businessName: shop?.shopName ?? 'SnapKhata',
        orderNumber: bill.id.toString(),
        totalAmount: bill.totalAmount,
        pendingAmount: bill.amountRemaining,
      );

      final message = '$caption\n\n📋 View full order:\n$shareUrl';

      final opened = await WhatsAppUtils.openWhatsAppChat(
        phone: phone,
        message: message,
      );

      if (!opened && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
                'Could not open WhatsApp. Please ensure WhatsApp is installed.'),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Share failed: $e'), backgroundColor: _kRed),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final bill = widget.bill;
    final theme = Theme.of(context);
    final itemsAsync = ref.watch(billItemsProvider(bill.id));

    final bool isPaid = bill.status == 'confirmed';
    final double balanceDue =
        bill.amountRemaining ?? (bill.totalAmount - bill.amountPaid);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        elevation: 0.5,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'Order Detail',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w800,
            color: Colors.black87,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.share_outlined, color: Colors.black54),
            tooltip: 'Share',
            onPressed: _shareOrder,
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, color: Colors.black54),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            onSelected: (value) {
              if (value == 'delete') _deleteBill();
            },
            itemBuilder: (ctx) => [
              const PopupMenuItem(
                value: 'delete',
                child: Row(
                  children: [
                    Icon(Icons.delete_outline, color: _kRed, size: 20),
                    SizedBox(width: 8),
                    Text('Delete Order',
                        style: TextStyle(
                            color: _kRed, fontWeight: FontWeight.w600)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: _isDeleting
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Column(
                children: [
                  // ── Invoice No & Date ──────────────────────────
                  _InvoiceHeader(bill: bill),

                  const SizedBox(height: 8),

                  // ── Customer Info ──────────────────────────────
                  _CustomerCard(bill: bill),

                  const SizedBox(height: 8),

                  // ── Items ──────────────────────────────────────
                  _ItemsCard(itemsAsync: itemsAsync),

                  const SizedBox(height: 8),

                  // ── Totals ─────────────────────────────────────
                  _TotalsCard(
                    bill: bill,
                    isPaid: isPaid,
                    balanceDue: balanceDue,
                  ),

                  const SizedBox(height: 8),

                  // ── Payment Info ───────────────────────────────
                  _PaymentCard(bill: bill, isPaid: isPaid),

                  const SizedBox(height: 100),
                ],
              ),
            ),
      bottomNavigationBar: _isDeleting
          ? null
          : Container(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.06),
                    blurRadius: 10,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _deleteBill,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: _kRed,
                        side: const BorderSide(color: _kRed),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text('Delete',
                          style: TextStyle(
                              fontWeight: FontWeight.w700, fontSize: 15)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: FilledButton(
                      onPressed: _shareOrder,
                      style: FilledButton.styleFrom(
                        backgroundColor: _kBlue,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text('Share',
                          style: TextStyle(
                              fontWeight: FontWeight.w700, fontSize: 15)),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Invoice Header
// ─────────────────────────────────────────────────────────────

class _InvoiceHeader extends StatelessWidget {
  final Bill bill;
  const _InvoiceHeader({required this.bill});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final date = bill.createdAt;
    final dateStr =
        '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';

    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        children: [
          // Invoice No
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Order No.',
                    style: theme.textTheme.bodySmall?.copyWith(
                        color: Colors.black45, fontWeight: FontWeight.w500)),
                const SizedBox(height: 2),
                Text('#${bill.id}',
                    style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800, color: Colors.black87)),
              ],
            ),
          ),
          // Divider
          Container(
            width: 1,
            height: 36,
            color: _kDivider,
          ),
          // Date
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(left: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Date',
                      style: theme.textTheme.bodySmall?.copyWith(
                          color: Colors.black45, fontWeight: FontWeight.w500)),
                  const SizedBox(height: 2),
                  Text(dateStr,
                      style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w800, color: Colors.black87)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Customer Card
// ─────────────────────────────────────────────────────────────

class _CustomerCard extends StatelessWidget {
  final Bill bill;
  const _CustomerCard({required this.bill});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final name = bill.customerName.isNotEmpty ? bill.customerName : 'Unknown';

    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Party Balance row
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text('Party Balance: ',
                  style: theme.textTheme.bodySmall
                      ?.copyWith(color: Colors.black45)),
              Text(
                '₹ ${(bill.amountRemaining ?? 0).toStringAsFixed(2)}',
                style: theme.textTheme.bodySmall
                    ?.copyWith(color: _kBlue, fontWeight: FontWeight.w700),
              ),
            ],
          ),
          const SizedBox(height: 8),
          // Customer Name field
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              border: Border.all(color: const Color(0xFFDDDDDD)),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Customer Name',
                    style: theme.textTheme.labelSmall
                        ?.copyWith(color: Colors.black45, fontSize: 11)),
                const SizedBox(height: 2),
                Text(name,
                    style: theme.textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w600, color: Colors.black87)),
              ],
            ),
          ),
          if (bill.customerPhone != null && bill.customerPhone!.isNotEmpty) ...[
            const SizedBox(height: 10),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                border: Border.all(color: const Color(0xFFDDDDDD)),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Phone Number',
                      style: theme.textTheme.labelSmall
                          ?.copyWith(color: Colors.black45, fontSize: 11)),
                  const SizedBox(height: 2),
                  Text(bill.customerPhone!,
                      style: theme.textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.w600, color: Colors.black87)),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Items Card
// ─────────────────────────────────────────────────────────────

class _ItemsCard extends StatelessWidget {
  final AsyncValue<List<domain.BillItem>> itemsAsync;
  const _ItemsCard({required this.itemsAsync});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF43A047), Color(0xFF66BB6A)],
              ),
            ),
            child: Row(
              children: [
                const Icon(Icons.verified, color: Colors.white, size: 16),
                const SizedBox(width: 6),
                Text('Ordered Items',
                    style: theme.textTheme.labelLarge?.copyWith(
                        color: Colors.white, fontWeight: FontWeight.w700)),
              ],
            ),
          ),

          // Items list
          itemsAsync.when(
            loading: () => const Padding(
              padding: EdgeInsets.all(24),
              child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
            ),
            error: (e, _) => Padding(
              padding: const EdgeInsets.all(16),
              child: Text('Failed to load items: $e',
                  style: const TextStyle(color: _kRed)),
            ),
            data: (items) {
              if (items.isEmpty) {
                return const Padding(
                  padding: EdgeInsets.all(24),
                  child: Center(
                      child: Text('No items',
                          style: TextStyle(color: Colors.black45))),
                );
              }
              return Column(
                children: items.asMap().entries.map((entry) {
                  final idx = entry.key;
                  final item = entry.value;
                  return _ItemRow(index: idx + 1, item: item);
                }).toList(),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _ItemRow extends StatelessWidget {
  final int index;
  final domain.BillItem item;
  const _ItemRow({required this.index, required this.item});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final qtyStr = item.quantity == item.quantity.roundToDouble()
        ? item.quantity.toInt().toString()
        : item.quantity.toStringAsFixed(1);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: _kDivider)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Item name & price
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  border: Border.all(color: const Color(0xFFCCCCCC)),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Center(
                  child: Text('#$index',
                      style: theme.textTheme.labelSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: Colors.black54,
                          fontSize: 10)),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(item.name,
                    style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w700, color: Colors.black87)),
              ),
              Text('₹ ${item.totalPrice.toStringAsFixed(0)}',
                  style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w800, color: Colors.black87)),
            ],
          ),
          const SizedBox(height: 6),
          // Subtotal row
          Padding(
            padding: const EdgeInsets.only(left: 34),
            child: Text(
              'Item Subtotal    $qtyStr  x  ${item.unitPrice.toStringAsFixed(0)} = ₹ ${item.totalPrice.toStringAsFixed(0)}',
              style: theme.textTheme.bodySmall
                  ?.copyWith(color: Colors.black45, fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Totals Card
// ─────────────────────────────────────────────────────────────

class _TotalsCard extends StatelessWidget {
  final Bill bill;
  final bool isPaid;
  final double balanceDue;
  const _TotalsCard(
      {required this.bill, required this.isPaid, required this.balanceDue});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Column(
        children: [
          // Subtotal
          _TotalRow(
            label: 'Subtotal',
            value: '₹',
            amount: bill.totalAmount.toStringAsFixed(2),
            isBold: false,
            fontSize: 14,
          ),
          const SizedBox(height: 12),

          // Discount
          _TotalRow(
            label: 'Discount',
            value: '₹',
            amount: '0.00',
            isBold: false,
            fontSize: 14,
          ),
          const SizedBox(height: 12),

          // Dashed divider
          Row(
            children: List.generate(
              40,
              (i) => Expanded(
                child: Container(
                  height: 1,
                  color:
                      i.isEven ? const Color(0xFFCCCCCC) : Colors.transparent,
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Total Amount
          _TotalRow(
            label: 'Total Amount',
            value: '₹',
            amount: bill.totalAmount.toStringAsFixed(2),
            isBold: true,
            fontSize: 16,
          ),
          const SizedBox(height: 12),

          // Received
          Row(
            children: [
              Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  color: isPaid ? _kGreen : _kBlue,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Icon(Icons.check, color: Colors.white, size: 14),
              ),
              const SizedBox(width: 8),
              Text('Received',
                  style: theme.textTheme.bodyMedium
                      ?.copyWith(fontWeight: FontWeight.w600)),
              const Spacer(),
              Text('₹',
                  style: theme.textTheme.bodyMedium
                      ?.copyWith(color: Colors.black45)),
              const SizedBox(width: 8),
              Text(bill.amountPaid.toStringAsFixed(2),
                  style: theme.textTheme.bodyMedium
                      ?.copyWith(fontWeight: FontWeight.w700)),
            ],
          ),

          const SizedBox(height: 12),

          // Balance Due
          Row(
            children: [
              Text('Balance Due',
                  style: theme.textTheme.bodyMedium?.copyWith(
                      color: balanceDue > 0 ? _kRed : _kGreen,
                      fontWeight: FontWeight.w700)),
              const Spacer(),
              Text('₹',
                  style: theme.textTheme.bodyMedium
                      ?.copyWith(color: balanceDue > 0 ? _kRed : _kGreen)),
              const SizedBox(width: 8),
              Text(
                balanceDue.toStringAsFixed(2),
                style: theme.textTheme.titleMedium?.copyWith(
                    color: balanceDue > 0 ? _kRed : _kGreen,
                    fontWeight: FontWeight.w900),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _TotalRow extends StatelessWidget {
  final String label;
  final String value;
  final String amount;
  final bool isBold;
  final double fontSize;

  const _TotalRow({
    required this.label,
    required this.value,
    required this.amount,
    this.isBold = false,
    this.fontSize = 14,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Text(label,
            style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: isBold ? FontWeight.w700 : FontWeight.w500,
                fontSize: fontSize)),
        const Spacer(),
        Text(value,
            style: theme.textTheme.bodyMedium
                ?.copyWith(color: Colors.black45, fontSize: fontSize)),
        const SizedBox(width: 8),
        Text(amount,
            style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: isBold ? FontWeight.w800 : FontWeight.w600,
                fontSize: fontSize)),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Payment Card
// ─────────────────────────────────────────────────────────────

class _PaymentCard extends StatelessWidget {
  final Bill bill;
  final bool isPaid;
  const _PaymentCard({required this.bill, required this.isPaid});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text('Payment Type',
                  style: theme.textTheme.bodyMedium
                      ?.copyWith(color: Colors.black54)),
              const Spacer(),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: const Color(0xFFF5F5F5),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: const Color(0xFFE0E0E0)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 18,
                      height: 18,
                      decoration: BoxDecoration(
                        color: _kGreen,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Icon(Icons.currency_rupee,
                          color: Colors.white, size: 12),
                    ),
                    const SizedBox(width: 6),
                    Text('Cash',
                        style: theme.textTheme.bodySmall?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: Colors.black87)),
                    const SizedBox(width: 4),
                    const Icon(Icons.keyboard_arrow_down,
                        size: 16, color: Colors.black45),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
