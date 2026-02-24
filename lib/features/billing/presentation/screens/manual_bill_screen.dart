// lib/features/billing/presentation/screens/manual_bill_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../data/models/bill_item.dart';
import '../../data/models/scanned_bill.dart';
import '../providers/bill_provider.dart';

// ─────────────────────────────────────────────────────────────
// Colors
// ─────────────────────────────────────────────────────────────
const _kGreen = Color(0xFF1B8A2A);
const _kRed = Color(0xFFC62828);
const _kBlue = Color(0xFF0066FF);
const _kOrange = Color(0xFFE65100);
const _kDivider = Color(0xFFEEEEEE);

// ─────────────────────────────────────────────────────────────
// ManualBillScreen
// ─────────────────────────────────────────────────────────────

class ManualBillScreen extends ConsumerStatefulWidget {
  const ManualBillScreen({super.key});

  @override
  ConsumerState<ManualBillScreen> createState() => _ManualBillScreenState();
}

class _ManualBillScreenState extends ConsumerState<ManualBillScreen> {
  // ── Bill type ──────────────────────────────────────────────
  bool _isCredit = true; // true = Credit (udhaar), false = Cash (paid)

  // ── Customer fields ────────────────────────────────────────
  late TextEditingController _nameCtrl;
  late TextEditingController _phoneCtrl;

  // ── Date ───────────────────────────────────────────────────
  DateTime _billDate = DateTime.now();

  // ── Line items ─────────────────────────────────────────────
  late List<_EditableItem> _items;

  // ── Payment ────────────────────────────────────────────────
  bool _receivedChecked = false;
  late TextEditingController _receivedAmountCtrl;
  String _paymentType = 'Cash';

  // ── Derived ────────────────────────────────────────────────
  double _totalAmount = 0;
  double _balanceDue = 0;

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController();
    _phoneCtrl = TextEditingController();
    _receivedAmountCtrl = TextEditingController();
    _items = [_EditableItem.empty()];
    _recalculate();
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    _receivedAmountCtrl.dispose();
    for (final i in _items) {
      i.dispose();
    }
    super.dispose();
  }

  void _recalculate() {
    double total = 0;
    for (final item in _items) {
      total += item.totalPrice;
    }
    final received =
        _receivedChecked ? (double.tryParse(_receivedAmountCtrl.text) ?? 0) : 0;
    setState(() {
      _totalAmount = total;
      _balanceDue = (total - received).clamp(0, double.infinity).toDouble();
    });
  }

  void _addItem() {
    setState(() {
      _items.add(_EditableItem.empty());
    });
  }

  void _removeItem(int index) {
    if (_items.length <= 1) return;
    _items[index].dispose();
    setState(() {
      _items.removeAt(index);
    });
    _recalculate();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _billDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 1)),
    );
    if (picked != null) {
      setState(() => _billDate = picked);
    }
  }

  String get _paymentStatus {
    final received =
        _receivedChecked ? (double.tryParse(_receivedAmountCtrl.text) ?? 0) : 0;
    if (received <= 0) return 'unpaid';
    if (received >= _totalAmount) return 'paid';
    return 'partial';
  }

  ScannedBill _buildBill() {
    final received =
        _receivedChecked ? (double.tryParse(_receivedAmountCtrl.text) ?? 0) : 0;
    return ScannedBill(
      customerName:
          _nameCtrl.text.trim().isEmpty ? null : _nameCtrl.text.trim(),
      customerPhone:
          _phoneCtrl.text.trim().isEmpty ? null : _phoneCtrl.text.trim(),
      date:
          '${_billDate.year}-${_billDate.month.toString().padLeft(2, '0')}-${_billDate.day.toString().padLeft(2, '0')}',
      items: _items
          .where((i) => i.nameCtrl.text.trim().isNotEmpty)
          .map((i) => i.toBillItem())
          .toList(),
      subtotal: _totalAmount,
      totalAmount: _totalAmount,
      amountPaid: received.toDouble(),
      amountRemaining: _balanceDue,
      paymentStatus: _paymentStatus,
    );
  }

  bool _validate() {
    if (_nameCtrl.text.trim().isEmpty) {
      _showError('Please enter customer name');
      return false;
    }
    final validItems =
        _items.where((i) => i.nameCtrl.text.trim().isNotEmpty).toList();
    if (validItems.isEmpty) {
      _showError('Please add at least one item');
      return false;
    }
    if (_totalAmount <= 0) {
      _showError('Total amount must be greater than zero');
      return false;
    }
    return true;
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: _kRed),
    );
  }

  Future<void> _save({bool saveAndNew = false}) async {
    if (!_validate()) return;

    final bill = _buildBill();
    final billId =
        await ref.read(saveManualBillProvider.notifier).save(scannedBill: bill);

    if (!mounted) return;

    final saveState = ref.read(saveManualBillProvider);
    if (saveState.status == SaveStatus.error) {
      _showError(saveState.errorMessage ?? 'Save failed');
      return;
    }

    if (billId != null) {
      if (saveState.syncError != null && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Saved locally — cloud sync pending'),
            backgroundColor: Colors.orange.shade800,
            duration: const Duration(seconds: 3),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Order saved successfully!'),
            backgroundColor: _kGreen,
            duration: Duration(seconds: 2),
          ),
        );
      }

      if (saveAndNew) {
        _resetForm();
      } else {
        if (mounted) context.pop();
      }
    }
  }

  void _resetForm() {
    _nameCtrl.clear();
    _phoneCtrl.clear();
    _receivedAmountCtrl.clear();
    for (final i in _items) {
      i.dispose();
    }
    setState(() {
      _isCredit = true;
      _billDate = DateTime.now();
      _items = [_EditableItem.empty()];
      _receivedChecked = false;
      _paymentType = 'Cash';
      _totalAmount = 0;
      _balanceDue = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    final saveState = ref.watch(saveManualBillProvider);
    final isSaving = saveState.status == SaveStatus.loading;
    final theme = Theme.of(context);
    final dateStr =
        '${_billDate.day.toString().padLeft(2, '0')}/${_billDate.month.toString().padLeft(2, '0')}/${_billDate.year}';

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
          'New Order',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w800,
            color: Colors.black87,
          ),
        ),
        centerTitle: false,
        actions: [
          // Credit / Cash toggle
          Container(
            margin: const EdgeInsets.only(right: 8),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFFE0E0E0)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _ToggleChip(
                  label: 'Credit',
                  isSelected: _isCredit,
                  selectedColor: _kBlue,
                  onTap: () {
                    setState(() {
                      _isCredit = true;
                      _receivedChecked = false;
                      _receivedAmountCtrl.clear();
                    });
                    _recalculate();
                  },
                ),
                _ToggleChip(
                  label: 'Cash',
                  isSelected: !_isCredit,
                  selectedColor: _kGreen,
                  onTap: () {
                    setState(() {
                      _isCredit = false;
                      _receivedChecked = true;
                      _receivedAmountCtrl.text =
                          _totalAmount.toStringAsFixed(2);
                    });
                    _recalculate();
                  },
                ),
              ],
            ),
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: isSaving
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Column(
                children: [
                  // ── Invoice No & Date ──────────────────────
                  _buildInvoiceHeader(theme, dateStr),
                  const SizedBox(height: 8),

                  // ── Customer Info ──────────────────────────
                  _buildCustomerSection(theme),
                  const SizedBox(height: 8),

                  // ── Billed Items ───────────────────────────
                  _buildItemsSection(theme),
                  const SizedBox(height: 8),

                  // ── Totals ─────────────────────────────────
                  _buildTotalsSection(theme),
                  const SizedBox(height: 8),

                  // ── Payment Type ───────────────────────────
                  _buildPaymentTypeSection(theme),

                  const SizedBox(height: 100),
                ],
              ),
            ),
      bottomNavigationBar: isSaving
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
                      onPressed: () => _save(saveAndNew: true),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: _kBlue,
                        side: const BorderSide(color: _kBlue),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text('Save & New',
                          style: TextStyle(
                              fontWeight: FontWeight.w700, fontSize: 15)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: FilledButton(
                      onPressed: () => _save(),
                      style: FilledButton.styleFrom(
                        backgroundColor: _kBlue,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text('Save',
                          style: TextStyle(
                              fontWeight: FontWeight.w700, fontSize: 15)),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  // ─────────────────────────────────────────────────────────────
  // Invoice Header
  // ─────────────────────────────────────────────────────────────

  Widget _buildInvoiceHeader(ThemeData theme, String dateStr) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Order No.',
                    style: theme.textTheme.bodySmall?.copyWith(
                        color: Colors.black45, fontWeight: FontWeight.w500)),
                const SizedBox(height: 2),
                Text('Auto',
                    style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800, color: Colors.black54)),
              ],
            ),
          ),
          Container(width: 1, height: 36, color: _kDivider),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(left: 20),
              child: GestureDetector(
                onTap: _pickDate,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Date',
                        style: theme.textTheme.bodySmall?.copyWith(
                            color: Colors.black45,
                            fontWeight: FontWeight.w500)),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        Text(dateStr,
                            style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w800,
                                color: Colors.black87)),
                        const SizedBox(width: 4),
                        const Icon(Icons.keyboard_arrow_down,
                            size: 18, color: Colors.black45),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────
  // Customer Section
  // ─────────────────────────────────────────────────────────────

  Widget _buildCustomerSection(ThemeData theme) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            controller: _nameCtrl,
            textCapitalization: TextCapitalization.words,
            decoration: InputDecoration(
              labelText: 'Customer *',
              hintText: 'e.g. Akshay',
              border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _phoneCtrl,
            keyboardType: TextInputType.phone,
            maxLength: 10,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            decoration: InputDecoration(
              labelText: 'Phone Number',
              hintText: '10-digit mobile',
              counterText: '',
              border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            ),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────
  // Items Section
  // ─────────────────────────────────────────────────────────────

  Widget _buildItemsSection(ThemeData theme) {
    return Container(
      color: Colors.white,
      child: Column(
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

          // Item rows
          ...List.generate(_items.length, (index) {
            return _ItemRowWidget(
              item: _items[index],
              index: index + 1,
              canDelete: _items.length > 1,
              onChanged: _recalculate,
              onDelete: () => _removeItem(index),
            );
          }),

          // Summary row
          if (_items.isNotEmpty)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              decoration: const BoxDecoration(
                border: Border(top: BorderSide(color: _kDivider)),
              ),
              child: Row(
                children: [
                  Text(
                      'Total Qty: ${_items.fold<double>(0, (s, i) => s + (double.tryParse(i.qtyCtrl.text) ?? 0)).toStringAsFixed(1)}',
                      style: theme.textTheme.bodySmall
                          ?.copyWith(color: Colors.black45, fontSize: 12)),
                  const Spacer(),
                  Text('Subtotal: ${_totalAmount.toStringAsFixed(2)}',
                      style: theme.textTheme.bodySmall
                          ?.copyWith(color: Colors.black45, fontSize: 12)),
                ],
              ),
            ),

          // Add Items button
          InkWell(
            onTap: _addItem,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 14),
              decoration: const BoxDecoration(
                border: Border(top: BorderSide(color: _kDivider)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.add_circle, color: _kBlue, size: 20),
                  const SizedBox(width: 6),
                  Text('Add Items',
                      style: TextStyle(
                          color: _kBlue,
                          fontWeight: FontWeight.w700,
                          fontSize: 14)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────
  // Totals Section
  // ─────────────────────────────────────────────────────────────

  Widget _buildTotalsSection(ThemeData theme) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Column(
        children: [
          // Total Amount
          Row(
            children: [
              Text('Total Amount',
                  style: theme.textTheme.bodyLarge
                      ?.copyWith(fontWeight: FontWeight.w700, fontSize: 16)),
              const Spacer(),
              Text('₹',
                  style: theme.textTheme.bodyMedium
                      ?.copyWith(color: Colors.black45)),
              const SizedBox(width: 8),
              Text(_totalAmount.toStringAsFixed(2),
                  style: theme.textTheme.titleMedium
                      ?.copyWith(fontWeight: FontWeight.w800)),
            ],
          ),
          const SizedBox(height: 16),

          // Received checkbox + amount
          Row(
            children: [
              SizedBox(
                width: 24,
                height: 24,
                child: Checkbox(
                  value: _receivedChecked,
                  activeColor: _kBlue,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4)),
                  onChanged: (v) {
                    setState(() {
                      _receivedChecked = v ?? false;
                      if (_receivedChecked &&
                          _receivedAmountCtrl.text.isEmpty) {
                        _receivedAmountCtrl.text =
                            _totalAmount.toStringAsFixed(2);
                      }
                    });
                    _recalculate();
                  },
                ),
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
              if (_receivedChecked)
                SizedBox(
                  width: 100,
                  child: TextField(
                    controller: _receivedAmountCtrl,
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    textAlign: TextAlign.right,
                    style: theme.textTheme.bodyMedium
                        ?.copyWith(fontWeight: FontWeight.w700),
                    decoration: const InputDecoration(
                      isDense: true,
                      contentPadding:
                          EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                      border: UnderlineInputBorder(),
                    ),
                    onChanged: (_) => _recalculate(),
                  ),
                )
              else
                Text('—',
                    style: theme.textTheme.bodyMedium
                        ?.copyWith(color: Colors.black38)),
            ],
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

          // Balance Due
          Row(
            children: [
              Text('Balance Due',
                  style: theme.textTheme.bodyMedium?.copyWith(
                      color: _balanceDue > 0 ? _kRed : _kGreen,
                      fontWeight: FontWeight.w700)),
              const Spacer(),
              Text('₹',
                  style: theme.textTheme.bodyMedium
                      ?.copyWith(color: _balanceDue > 0 ? _kRed : _kGreen)),
              const SizedBox(width: 8),
              Text(
                _balanceDue.toStringAsFixed(2),
                style: theme.textTheme.titleMedium?.copyWith(
                    color: _balanceDue > 0 ? _kRed : _kGreen,
                    fontWeight: FontWeight.w900),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────
  // Payment Type Section
  // ─────────────────────────────────────────────────────────────

  Widget _buildPaymentTypeSection(ThemeData theme) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        children: [
          Text('Payment Type',
              style:
                  theme.textTheme.bodyMedium?.copyWith(color: Colors.black54)),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: const Color(0xFFF5F5F5),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: const Color(0xFFE0E0E0)),
            ),
            child: PopupMenuButton<String>(
              onSelected: (v) => setState(() => _paymentType = v),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              itemBuilder: (_) => ['Cash', 'UPI', 'Card', 'Bank Transfer']
                  .map((t) => PopupMenuItem(value: t, child: Text(t)))
                  .toList(),
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
                  Text(_paymentType,
                      style: theme.textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.w700, color: Colors.black87)),
                  const SizedBox(width: 4),
                  const Icon(Icons.keyboard_arrow_down,
                      size: 16, color: Colors.black45),
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
// Toggle Chip (Credit / Cash)
// ─────────────────────────────────────────────────────────────

class _ToggleChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final Color selectedColor;
  final VoidCallback onTap;

  const _ToggleChip({
    required this.label,
    required this.isSelected,
    required this.selectedColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? selectedColor : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.black54,
            fontWeight: FontWeight.w700,
            fontSize: 13,
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Editable Item (mutable state wrapper)
// ─────────────────────────────────────────────────────────────

class _EditableItem {
  final TextEditingController nameCtrl;
  final TextEditingController qtyCtrl;
  final TextEditingController unitPriceCtrl;

  _EditableItem({
    required this.nameCtrl,
    required this.qtyCtrl,
    required this.unitPriceCtrl,
  });

  factory _EditableItem.empty() {
    return _EditableItem(
      nameCtrl: TextEditingController(),
      qtyCtrl: TextEditingController(text: '1'),
      unitPriceCtrl: TextEditingController(),
    );
  }

  double get quantity => double.tryParse(qtyCtrl.text) ?? 0;
  double get unitPrice => double.tryParse(unitPriceCtrl.text) ?? 0;
  double get totalPrice => quantity * unitPrice;

  BillItem toBillItem() {
    return BillItem(
      name: nameCtrl.text.trim(),
      quantity: quantity,
      unitPrice: unitPrice,
      totalPrice: totalPrice,
    );
  }

  void dispose() {
    nameCtrl.dispose();
    qtyCtrl.dispose();
    unitPriceCtrl.dispose();
  }
}

// ─────────────────────────────────────────────────────────────
// Item Row Widget
// ─────────────────────────────────────────────────────────────

class _ItemRowWidget extends StatelessWidget {
  final _EditableItem item;
  final int index;
  final bool canDelete;
  final VoidCallback onChanged;
  final VoidCallback onDelete;

  const _ItemRowWidget({
    required this.item,
    required this.index,
    required this.canDelete,
    required this.onChanged,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: _kDivider)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Item name + total price + delete
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
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
                child: TextField(
                  controller: item.nameCtrl,
                  textCapitalization: TextCapitalization.words,
                  style: theme.textTheme.bodyMedium
                      ?.copyWith(fontWeight: FontWeight.w700),
                  decoration: InputDecoration(
                    hintText: 'Item name',
                    isDense: true,
                    contentPadding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(6),
                        borderSide: const BorderSide(color: Color(0xFFDDDDDD))),
                  ),
                  onChanged: (_) => onChanged(),
                ),
              ),
              const SizedBox(width: 8),
              Text('₹ ${item.totalPrice.toStringAsFixed(0)}',
                  style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w800, color: Colors.black87)),
              if (canDelete) ...[
                const SizedBox(width: 4),
                GestureDetector(
                  onTap: onDelete,
                  child: const Icon(Icons.close, size: 18, color: _kRed),
                ),
              ],
            ],
          ),
          const SizedBox(height: 10),
          // Qty + Unit Price row
          Padding(
            padding: const EdgeInsets.only(left: 34),
            child: Row(
              children: [
                // Qty
                SizedBox(
                  width: 60,
                  child: TextField(
                    controller: item.qtyCtrl,
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodySmall
                        ?.copyWith(fontWeight: FontWeight.w600),
                    decoration: InputDecoration(
                      labelText: 'Qty',
                      isDense: true,
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 8),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(6)),
                    ),
                    onChanged: (_) => onChanged(),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Text('x',
                      style: theme.textTheme.bodySmall
                          ?.copyWith(color: Colors.black45)),
                ),
                // Unit Price
                SizedBox(
                  width: 80,
                  child: TextField(
                    controller: item.unitPriceCtrl,
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodySmall
                        ?.copyWith(fontWeight: FontWeight.w600),
                    decoration: InputDecoration(
                      labelText: 'Rate',
                      prefixText: '₹',
                      isDense: true,
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 8),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(6)),
                    ),
                    onChanged: (_) => onChanged(),
                  ),
                ),
                const Spacer(),
                Text(
                  '= ₹ ${item.totalPrice.toStringAsFixed(0)}',
                  style: theme.textTheme.bodySmall
                      ?.copyWith(color: Colors.black45, fontSize: 12),
                ),
              ],
            ),
          ),
          const SizedBox(height: 6),
          // Discount row (static 0 — no tax as per requirement)
          Padding(
            padding: const EdgeInsets.only(left: 34),
            child: Row(
              children: [
                Text('Discount(%): 0',
                    style: TextStyle(
                        color: _kOrange,
                        fontSize: 11,
                        fontWeight: FontWeight.w500)),
                const Spacer(),
                Text('₹ 0',
                    style: TextStyle(
                        color: _kOrange,
                        fontSize: 11,
                        fontWeight: FontWeight.w500)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
