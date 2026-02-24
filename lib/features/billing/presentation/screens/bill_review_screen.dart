// lib/features/billing/presentation/screens/bill_review_screen.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../data/models/bill_item.dart';
import '../../data/models/scanned_bill.dart';
import '../providers/bill_provider.dart';

class BillReviewScreen extends ConsumerStatefulWidget {
  final ScannedBill initialBill;
  final String imagePath;

  const BillReviewScreen({
    super.key,
    required this.initialBill,
    required this.imagePath,
  });

  @override
  ConsumerState<BillReviewScreen> createState() => _BillReviewScreenState();
}

class _BillReviewScreenState extends ConsumerState<BillReviewScreen> {
  // Customer fields
  late TextEditingController _nameCtrl;
  late TextEditingController _phoneCtrl;
  late TextEditingController _dateCtrl;

  // Payment fields
  late TextEditingController _discountCtrl;
  late TextEditingController _gstPercentCtrl;
  late TextEditingController _amountPaidCtrl;

  // Line items (mutable copy)
  late List<_EditableBillItem> _items;

  // Derived totals
  double _subtotal = 0;
  double _gstAmount = 0;
  double _totalAmount = 0;
  double _amountRemaining = 0;
  String _paymentStatus =
      'paid'; // Default: paid, changed if user enters partial

  // Invoice type toggle
  String _invoiceType = 'order_summary'; // 'order_summary' | 'gst_invoice'

  @override
  void initState() {
    super.initState();
    final b = widget.initialBill;

    _nameCtrl = TextEditingController(text: b.customerName ?? '');
    _phoneCtrl = TextEditingController(text: b.customerPhone ?? '');
    _dateCtrl = TextEditingController(text: b.date ?? '');
    _discountCtrl =
        TextEditingController(text: b.discount?.toStringAsFixed(2) ?? '');
    _gstPercentCtrl =
        TextEditingController(text: b.gstPercent?.toStringAsFixed(1) ?? '');
    // Default: paid in full. User may override to set partial/unpaid.
    _amountPaidCtrl = TextEditingController(
      text: b.amountPaid != null && b.amountPaid! > 0
          ? b.amountPaid!.toStringAsFixed(2)
          : '', // will be set after first _recalculate
    );

    _items =
        b.items.map((item) => _EditableBillItem.fromBillItem(item)).toList();

    _recalculate();
    // After first calc, default amountPaid to totalAmount if no explicit value
    if ((b.amountPaid ?? 0) <= 0) {
      _amountPaidCtrl.text = _totalAmount.toStringAsFixed(2);
      _recalculate();
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    _dateCtrl.dispose();
    _discountCtrl.dispose();
    _gstPercentCtrl.dispose();
    _amountPaidCtrl.dispose();
    for (final i in _items) {
      i.dispose();
    }
    super.dispose();
  }

  void _recalculate() {
    double sub = 0;
    for (final item in _items) {
      sub += item.totalPrice;
    }
    final discount = double.tryParse(_discountCtrl.text) ?? 0;
    final gstPct = double.tryParse(_gstPercentCtrl.text) ?? 0;
    final afterDiscount = sub - discount;
    final gst = afterDiscount * gstPct / 100;
    final total = afterDiscount + gst;
    final paid = double.tryParse(_amountPaidCtrl.text) ?? 0;
    final remaining = (total - paid).clamp(0, double.infinity);

    String status;
    if (paid <= 0) {
      status = 'unpaid';
    } else if (paid >= total) {
      status = 'paid';
    } else {
      status = 'partial';
    }

    setState(() {
      _subtotal = sub;
      _gstAmount = gst;
      _totalAmount = total;
      _amountRemaining = remaining.toDouble();
      _paymentStatus = status;
    });
  }

  void _addItem() {
    setState(() {
      _items.add(_EditableBillItem.empty());
    });
    _recalculate();
  }

  void _deleteItem(int index) {
    _items[index].dispose();
    setState(() {
      _items.removeAt(index);
    });
    _recalculate();
  }

  ScannedBill _buildUpdatedBill() {
    return ScannedBill(
      customerName:
          _nameCtrl.text.trim().isEmpty ? null : _nameCtrl.text.trim(),
      customerPhone:
          _phoneCtrl.text.trim().isEmpty ? null : _phoneCtrl.text.trim(),
      date: _dateCtrl.text.trim().isEmpty ? null : _dateCtrl.text.trim(),
      items: _items.map((i) => i.toBillItem()).toList(),
      subtotal: _subtotal,
      discount: double.tryParse(_discountCtrl.text),
      gstPercent: double.tryParse(_gstPercentCtrl.text),
      gstAmount: _gstAmount,
      totalAmount: _totalAmount,
      amountPaid: double.tryParse(_amountPaidCtrl.text),
      amountRemaining: _amountRemaining,
      paymentStatus: _paymentStatus,
    );
  }

  Future<void> _save() async {
    final bill = _buildUpdatedBill();
    final imageFile = File(widget.imagePath);

    final billId = await ref.read(saveBillProvider.notifier).save(
          scannedBill: bill,
          imageFile: imageFile,
          invoiceType: _invoiceType,
        );

    if (!mounted) return;

    final saveState = ref.read(saveBillProvider);
    if (saveState.status == SaveStatus.error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(saveState.errorMessage ?? 'Save failed'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 8),
        ),
      );
      return;
    }

    if (billId != null) {
      context.push('/bill-summary', extra: {
        'bill': bill,
        'billId': billId,
        'isSynced': saveState.isSynced,
        'imagePath': widget.imagePath,
        'invoiceType': _invoiceType,
      });

      // Show sync error after navigation so it's visible on the summary screen
      if (saveState.syncError != null && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '⚠️ Saved locally — Supabase sync failed:',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                ),
                const SizedBox(height: 4),
                Text(
                  saveState.syncError!,
                  style: const TextStyle(fontSize: 12),
                  maxLines: 4,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
            backgroundColor: Colors.orange.shade800,
            duration: const Duration(seconds: 12),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final saveState = ref.watch(saveBillProvider);
    final isSaving = saveState.status == SaveStatus.loading;
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.background,
      appBar: AppBar(
        title: const Text('Review Order'),
        centerTitle: false,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 120),
        children: [
          // Bill image preview
          _buildImagePreview(context),
          const SizedBox(height: 16),

          // Customer section
          _SectionCard(
            title: 'Customer Details',
            subtitle: 'ग्राहक माहिती',
            icon: Icons.person_outline_rounded,
            children: [
              _LabeledField(
                label: 'Customer Name',
                hint: 'जसे: राज शर्मा',
                controller: _nameCtrl,
                icon: Icons.person_outline,
              ),
              const SizedBox(height: 12),
              // Phone field with live validity indicator
              StatefulBuilder(
                builder: (context, setFieldState) {
                  final isValid = _phoneCtrl.text.length == 10;
                  return TextField(
                    controller: _phoneCtrl,
                    keyboardType: TextInputType.phone,
                    maxLength: 10,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    onChanged: (_) => setFieldState(() {}),
                    decoration: InputDecoration(
                      labelText: 'Phone Number',
                      hintText: '10-digit mobile number',
                      helperText: 'Required for WhatsApp sharing',
                      counterText: '',
                      prefixIcon: const Icon(Icons.phone_outlined, size: 20),
                      suffixIcon: _phoneCtrl.text.isNotEmpty
                          ? Icon(
                              isValid
                                  ? Icons.check_circle_rounded
                                  : Icons.cancel_rounded,
                              size: 20,
                              color: isValid
                                  ? const Color(0xFF25D366)
                                  : Colors.redAccent,
                            )
                          : null,
                      filled: true,
                      fillColor: Theme.of(context)
                          .colorScheme
                          .surfaceVariant
                          .withOpacity(0.4),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 14),
                    ),
                  );
                },
              ),
              const SizedBox(height: 12),
              _LabeledField(
                label: 'Date',
                hint: 'YYYY-MM-DD',
                controller: _dateCtrl,
                icon: Icons.calendar_today_outlined,
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Items section
          _SectionCard(
            title: 'Order Items',
            subtitle: 'वस्तू यादी',
            icon: Icons.list_alt_rounded,
            trailing: TextButton.icon(
              icon: const Icon(Icons.add_circle_outline, size: 18),
              label: const Text('Add Item'),
              onPressed: _addItem,
            ),
            children: [
              if (_items.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: Center(
                    child: Text(
                      'No items detected\nTap + Add Item to add manually',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          color: theme.colorScheme.onSurface.withOpacity(0.45)),
                    ),
                  ),
                ),
              ...List.generate(_items.length, (i) {
                return Column(
                  children: [
                    _ItemRow(
                      item: _items[i],
                      index: i,
                      onChanged: _recalculate,
                      onDelete: () => _deleteItem(i),
                    ),
                    if (i < _items.length - 1)
                      Divider(
                          height: 1,
                          color: theme.colorScheme.outline.withOpacity(0.2)),
                  ],
                );
              }),
            ],
          ),

          const SizedBox(height: 12),

          // Payment section
          _SectionCard(
            title: 'Payment Summary',
            subtitle: 'रकमेचा तपशील',
            icon: Icons.payments_outlined,
            children: [
              Row(
                children: [
                  Expanded(
                    child: _LabeledField(
                      label: 'Discount (₹)',
                      hint: '0.00',
                      controller: _discountCtrl,
                      icon: Icons.discount_outlined,
                      keyboardType: TextInputType.number,
                      onChanged: (_) => _recalculate(),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _LabeledField(
                      label: 'GST %',
                      hint: '0',
                      controller: _gstPercentCtrl,
                      icon: Icons.percent_rounded,
                      keyboardType: TextInputType.number,
                      onChanged: (_) => _recalculate(),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              _LabeledField(
                label: 'Amount Paid (₹)  [जमा / Paid]',
                hint: '0.00',
                controller: _amountPaidCtrl,
                icon: Icons.currency_rupee,
                keyboardType: TextInputType.number,
                onChanged: (_) => _recalculate(),
              ),
              const SizedBox(height: 16),
              // ── Invoice Type toggle ─────────────────────────
              Container(
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceVariant.withOpacity(0.4),
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.all(4),
                child: Row(
                  children: [
                    Expanded(
                      child: _InvoiceTypePill(
                        label: '📋 Order Summary',
                        selected: _invoiceType == 'order_summary',
                        onTap: () =>
                            setState(() => _invoiceType = 'order_summary'),
                      ),
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: _InvoiceTypePill(
                        label: '🧾 GST Receipt',
                        selected: _invoiceType == 'gst_invoice',
                        onTap: () =>
                            setState(() => _invoiceType = 'gst_invoice'),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              _AmountSummary(
                subtotal: _subtotal,
                discount: double.tryParse(_discountCtrl.text) ?? 0,
                gstAmount: _gstAmount,
                gstPercent: double.tryParse(_gstPercentCtrl.text) ?? 0,
                total: _totalAmount,
                paid: double.tryParse(_amountPaidCtrl.text) ?? 0,
                remaining: _amountRemaining,
                paymentStatus: _paymentStatus,
              ),
            ],
          ),
        ],
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 16,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Total',
                          style: TextStyle(
                              color:
                                  theme.colorScheme.onSurface.withOpacity(0.6),
                              fontSize: 12)),
                      Text(
                        '₹${_totalAmount.toStringAsFixed(2)}',
                        style: const TextStyle(
                            fontSize: 24, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
                _PaymentStatusBadge(status: _paymentStatus),
              ],
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              height: 54,
              child: FilledButton.icon(
                onPressed: isSaving ? null : _save,
                icon: isSaving
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: Colors.white),
                      )
                    : const Icon(Icons.save_outlined),
                label: Text(isSaving ? 'Saving...' : 'Save Order'),
                style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFF0066FF),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                  textStyle: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImagePreview(BuildContext context) {
    return GestureDetector(
      onTap: () => _showFullImage(context),
      child: Hero(
        tag: 'bill_image',
        child: Container(
          height: 180,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            color: Colors.black,
            boxShadow: [
              BoxShadow(
                  color: Colors.black.withOpacity(0.15),
                  blurRadius: 12,
                  offset: const Offset(0, 4)),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Stack(
              fit: StackFit.expand,
              children: [
                Image.file(File(widget.imagePath), fit: BoxFit.cover),
                Align(
                  alignment: Alignment.bottomRight,
                  child: Container(
                    margin: const EdgeInsets.all(8),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.65),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.zoom_out_map, color: Colors.white, size: 14),
                        SizedBox(width: 4),
                        Text('Tap to expand',
                            style:
                                TextStyle(color: Colors.white, fontSize: 11)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showFullImage(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => Scaffold(
          backgroundColor: Colors.black,
          appBar: AppBar(
            backgroundColor: Colors.black,
            foregroundColor: Colors.white,
            title: const Text('Bill Image'),
          ),
          body: InteractiveViewer(
            child: Hero(
              tag: 'bill_image',
              child: Image.file(File(widget.imagePath), fit: BoxFit.contain),
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Editable line item (mutable state wrapper)
// ─────────────────────────────────────────────────────────────

class _EditableBillItem {
  final TextEditingController nameCtrl;
  final TextEditingController qtyCtrl;
  final TextEditingController unitPriceCtrl;
  final TextEditingController totalPriceCtrl;

  _EditableBillItem({
    required this.nameCtrl,
    required this.qtyCtrl,
    required this.unitPriceCtrl,
    required this.totalPriceCtrl,
  });

  factory _EditableBillItem.fromBillItem(BillItem item) {
    double qty = item.quantity;
    if (qty <= 0) qty = 1.0;

    double price = item.unitPrice;
    double total = item.totalPrice;

    // Fallback logic
    if (price <= 0 && total > 0) {
      price = total / qty;
    } else if (total <= 0 && price > 0) {
      total = price * qty;
    }

    return _EditableBillItem(
      nameCtrl: TextEditingController(text: item.name),
      qtyCtrl: TextEditingController(text: qty.toString()),
      unitPriceCtrl: TextEditingController(text: price.toStringAsFixed(2)),
      totalPriceCtrl: TextEditingController(text: total.toStringAsFixed(2)),
    );
  }

  factory _EditableBillItem.empty() {
    return _EditableBillItem(
      nameCtrl: TextEditingController(),
      qtyCtrl: TextEditingController(text: '1'),
      unitPriceCtrl: TextEditingController(text: '0.00'),
      totalPriceCtrl: TextEditingController(text: '0.00'),
    );
  }

  double get totalPrice =>
      double.tryParse(totalPriceCtrl.text.replaceAll(',', '')) ?? 0;

  BillItem toBillItem() {
    return BillItem(
      name: nameCtrl.text.trim(),
      quantity: double.tryParse(qtyCtrl.text) ?? 1.0,
      unit: null,
      unitPrice: double.tryParse(unitPriceCtrl.text) ?? 0,
      totalPrice: totalPrice,
    );
  }

  void dispose() {
    nameCtrl.dispose();
    qtyCtrl.dispose();
    unitPriceCtrl.dispose();
    totalPriceCtrl.dispose();
  }
}

// ─────────────────────────────────────────────────────────────
// Item row widget
// ─────────────────────────────────────────────────────────────

class _ItemRow extends StatefulWidget {
  final _EditableBillItem item;
  final int index;
  final VoidCallback onChanged;
  final VoidCallback onDelete;

  const _ItemRow({
    required this.item,
    required this.index,
    required this.onChanged,
    required this.onDelete,
  });

  @override
  State<_ItemRow> createState() => _ItemRowState();
}

class _ItemRowState extends State<_ItemRow> {
  void _updateFromQtyOrRate() {
    final qty = double.tryParse(widget.item.qtyCtrl.text) ?? 1;
    final price = double.tryParse(widget.item.unitPriceCtrl.text) ?? 0;
    widget.item.totalPriceCtrl.text = (qty * price).toStringAsFixed(2);
    widget.onChanged();
  }

  void _updateFromTotal() {
    final qty = double.tryParse(widget.item.qtyCtrl.text) ?? 1;
    final total = double.tryParse(widget.item.totalPriceCtrl.text) ?? 0;
    if (qty > 0) {
      widget.item.unitPriceCtrl.text = (total / qty).toStringAsFixed(2);
    }
    widget.onChanged();
  }

  @override
  Widget build(BuildContext context) {
    final qty = double.tryParse(widget.item.qtyCtrl.text) ?? 1;
    final price = double.tryParse(widget.item.unitPriceCtrl.text) ?? 0;
    final total = double.tryParse(widget.item.totalPriceCtrl.text) ?? 0;

    // Check for mismatch: Rate * Qty != Total
    // Using a small epsilon for double comparison if needed, but here simple != should suffice for manual entry
    final bool hasMismatch =
        (qty * price).toStringAsFixed(2) != total.toStringAsFixed(2);

    return Container(
      decoration: BoxDecoration(
        color: hasMismatch ? Colors.red.withOpacity(0.08) : null,
        borderRadius: BorderRadius.circular(8),
      ),
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
      margin: const EdgeInsets.only(bottom: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                '#${widget.index + 1}',
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF0066FF),
                  fontSize: 13,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: TextField(
                  controller: widget.item.nameCtrl,
                  onChanged: (_) => widget.onChanged(),
                  style: const TextStyle(fontWeight: FontWeight.w500),
                  decoration: const InputDecoration(
                    hintText: 'Item name',
                    isDense: true,
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.delete_outline,
                    size: 20, color: Colors.red),
                onPressed: widget.onDelete,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                tooltip: 'Remove item',
              ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              // Qty
              Expanded(
                flex: 2,
                child: _MiniField(
                  label: 'Qty',
                  controller: widget.item.qtyCtrl,
                  onChanged: (_) => _updateFromQtyOrRate(),
                  keyboardType: TextInputType.number,
                ),
              ),
              const SizedBox(width: 8),
              // Unit price
              Expanded(
                flex: 3,
                child: _MiniField(
                  label: 'Rate (₹)',
                  controller: widget.item.unitPriceCtrl,
                  onChanged: (_) => _updateFromQtyOrRate(),
                  keyboardType: TextInputType.number,
                ),
              ),
              const SizedBox(width: 8),
              // Total
              Expanded(
                flex: 3,
                child: _MiniField(
                  label: 'Total (₹)',
                  controller: widget.item.totalPriceCtrl,
                  onChanged: (_) => _updateFromTotal(),
                  keyboardType: TextInputType.number,
                  isBold: true,
                  textColor: hasMismatch ? Colors.red : null,
                ),
              ),
            ],
          ),
          if (hasMismatch)
            Padding(
              padding: const EdgeInsets.only(top: 4, left: 24),
              child: Text(
                'Calculated: ₹${(qty * price).toStringAsFixed(2)}',
                style: const TextStyle(
                  color: Colors.red,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _MiniField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final ValueChanged<String>? onChanged;
  final TextInputType? keyboardType;
  final bool isBold;
  final Color? textColor;

  const _MiniField({
    required this.label,
    required this.controller,
    this.onChanged,
    this.keyboardType,
    this.isBold = false,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: TextStyle(
                fontSize: 10,
                color:
                    Theme.of(context).colorScheme.onSurface.withOpacity(0.5))),
        const SizedBox(height: 2),
        TextField(
          controller: controller,
          onChanged: onChanged,
          keyboardType: keyboardType,
          style: TextStyle(
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            fontSize: 14,
            color: textColor ?? (isBold ? const Color(0xFF0066FF) : null),
          ),
          decoration: InputDecoration(
            isDense: true,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            filled: true,
            fillColor:
                Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.5),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide.none,
            ),
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Payment amount summary
// ─────────────────────────────────────────────────────────────

class _AmountSummary extends StatelessWidget {
  final double subtotal;
  final double discount;
  final double gstAmount;
  final double gstPercent;
  final double total;
  final double paid;
  final double remaining;
  final String paymentStatus;

  const _AmountSummary({
    required this.subtotal,
    required this.discount,
    required this.gstAmount,
    required this.gstPercent,
    required this.total,
    required this.paid,
    required this.remaining,
    required this.paymentStatus,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceVariant.withOpacity(0.4),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          _AmountRow('Subtotal', subtotal),
          if (discount > 0)
            _AmountRow('Discount', -discount, color: Colors.green),
          if (gstAmount > 0)
            _AmountRow('GST (${gstPercent.toStringAsFixed(0)}%)', gstAmount),
          const Divider(height: 16),
          _AmountRow('Total', total, bold: true, fontSize: 18),
          if (paid > 0) ...[
            const SizedBox(height: 4),
            _AmountRow('Paid', paid, color: Colors.green),
            _AmountRow(
              paymentStatus == 'paid' ? 'Balance' : '⚠️  Remaining',
              remaining,
              color: remaining > 0 ? Colors.orange.shade700 : Colors.green,
              bold: remaining > 0,
            ),
          ],
        ],
      ),
    );
  }
}

class _AmountRow extends StatelessWidget {
  final String label;
  final double amount;
  final Color? color;
  final bool bold;
  final double fontSize;

  const _AmountRow(
    this.label,
    this.amount, {
    this.color,
    this.bold = false,
    this.fontSize = 14,
  });

  @override
  Widget build(BuildContext context) {
    final style = TextStyle(
      fontWeight: bold ? FontWeight.bold : FontWeight.normal,
      fontSize: fontSize,
      color: color,
    );
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: style),
          Text(
            '₹${amount.abs().toStringAsFixed(2)}',
            style: style,
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Section card
// ─────────────────────────────────────────────────────────────

class _SectionCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final List<Widget> children;
  final Widget? trailing;

  const _SectionCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.children,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: theme.colorScheme.surface,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 20, color: const Color(0xFF0066FF)),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title,
                          style: theme.textTheme.titleSmall
                              ?.copyWith(fontWeight: FontWeight.bold)),
                      Text(subtitle,
                          style: TextStyle(
                              fontSize: 11,
                              color: theme.colorScheme.onSurface
                                  .withOpacity(0.45))),
                    ],
                  ),
                ),
                if (trailing != null) trailing!,
              ],
            ),
            const SizedBox(height: 14),
            ...children,
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Labeled text field
// ─────────────────────────────────────────────────────────────

class _LabeledField extends StatelessWidget {
  final String label;
  final String hint;
  final TextEditingController controller;
  final IconData icon;
  final TextInputType? keyboardType;
  final ValueChanged<String>? onChanged;

  const _LabeledField({
    required this.label,
    required this.hint,
    required this.controller,
    required this.icon,
    this.keyboardType,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      onChanged: onChanged,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon, size: 20),
        filled: true,
        fillColor:
            Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.4),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Payment status badge
// ─────────────────────────────────────────────────────────────

class _PaymentStatusBadge extends StatelessWidget {
  final String status;

  const _PaymentStatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    Color color;
    String label;
    switch (status) {
      case 'paid':
        color = Colors.green;
        label = 'Paid ✓';
        break;
      case 'partial':
        color = Colors.orange;
        label = 'Partial';
        break;
      default:
        color = Colors.red;
        label = 'Unpaid';
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.5)),
      ),
      child: Text(label,
          style: TextStyle(
              color: color, fontWeight: FontWeight.bold, fontSize: 13)),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Invoice type pill selector
// ─────────────────────────────────────────────────────────────

class _InvoiceTypePill extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _InvoiceTypePill({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        height: 42,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: selected ? const Color(0xFF0066FF) : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 12,
            fontWeight: selected ? FontWeight.bold : FontWeight.w500,
            color: selected
                ? Colors.white
                : Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
          ),
        ),
      ),
    );
  }
}
