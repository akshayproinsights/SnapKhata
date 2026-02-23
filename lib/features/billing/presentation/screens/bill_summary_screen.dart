// lib/features/billing/presentation/screens/bill_summary_screen.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../data/models/scanned_bill.dart';
import '../../data/services/pdf_service.dart';
import '../../data/services/pdf_share_service.dart';
import '../providers/shop_profile_provider.dart';
import '../../../../core/utils/whatsapp_utils.dart';

class BillSummaryScreen extends ConsumerStatefulWidget {
  final ScannedBill bill;
  final int billId;
  final bool isSynced;
  final String imagePath;
  final String invoiceType; // 'gst_invoice' | 'order_summary'

  const BillSummaryScreen({
    super.key,
    required this.bill,
    required this.billId,
    required this.isSynced,
    required this.imagePath,
    this.invoiceType = 'order_summary',
  });

  @override
  ConsumerState<BillSummaryScreen> createState() => _BillSummaryScreenState();
}

class _BillSummaryScreenState extends ConsumerState<BillSummaryScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _checkController;
  late Animation<double> _checkScale;
  late Animation<double> _checkOpacity;

  // Tracks phone number — may be edited via the WhatsApp bottom-sheet
  late String _phone;

  // PDF generation state
  File? _generatedPdf;
  bool _isGeneratingPdf = false;

  // Image generation state (PDF → PNG; one image per page for multi-page invoices)
  List<File>? _generatedImages;
  bool _isGeneratingImage = false;

  @override
  void initState() {
    super.initState();
    _phone = widget.bill.customerPhone ?? '';
    _checkController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _checkScale = Tween<double>(begin: 0.3, end: 1.0).animate(
      CurvedAnimation(parent: _checkController, curve: Curves.elasticOut),
    );
    _checkOpacity = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
          parent: _checkController,
          curve: const Interval(0, 0.4, curve: Curves.easeIn)),
    );
    _checkController.forward();
  }

  @override
  void dispose() {
    _checkController.dispose();
    super.dispose();
  }

  // ── PDF generation ────────────────────────────────────────────

  Future<File?> _getOrGeneratePdf() async {
    if (_generatedPdf != null) return _generatedPdf;

    setState(() => _isGeneratingPdf = true);
    try {
      final shop = await ref.read(shopProfileRepositoryProvider).getProfile();
      final pdf = await PdfService.generateBillPdf(
        bill: widget.bill,
        shop: shop,
        billId: widget.billId,
        invoiceType: widget.invoiceType,
      );
      setState(() {
        _generatedPdf = pdf;
        _isGeneratingPdf = false;
      });
      return pdf;
    } catch (e) {
      setState(() => _isGeneratingPdf = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('PDF generation failed: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
      return null;
    }
  }

  // ── Share actions ─────────────────────────────────────────────

  /// Returns one image per page (multi-page invoice = multiple images).
  Future<List<File>?> _getOrGenerateImages() async {
    if (_generatedImages != null && _generatedImages!.isNotEmpty) return _generatedImages;
    final pdf = await _getOrGeneratePdf();
    if (pdf == null) return null;

    setState(() => _isGeneratingImage = true);
    try {
      final images = await PdfService.renderBillAsImages(pdf);
      setState(() {
        _generatedImages = images;
        _isGeneratingImage = false;
      });
      return images;
    } catch (e) {
      setState(() => _isGeneratingImage = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Image render failed: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
      return null;
    }
  }

  Future<void> _shareViaSystem() async {
    final pdf = await _getOrGeneratePdf();
    if (pdf == null || !mounted) return;
    final shop = await ref.read(shopProfileRepositoryProvider).getProfile();
    await PdfShareService.shareViaSystem(
      pdfFile: pdf,
      invoiceNo: pdf.path.split('/').last.replaceAll('.pdf', ''),
      shopName: shop?.shopName,
    );
  }

  Future<void> _shareImageOnWhatsApp() async {
    if (_phone.isEmpty) {
      final entered = await _promptForPhone();
      if (entered == null) return;
      setState(() => _phone = entered);
    }

    final images = await _getOrGenerateImages();
    if (images == null || images.isEmpty || !mounted) return;

    final shop = await ref.read(shopProfileRepositoryProvider).getProfile();
    final rawName = _generatedPdf?.path.split(RegExp(r'[/\\]')).last ?? images.first.path.split(RegExp(r'[/\\]')).last;
    final invoiceNo = rawName.replaceAll('.pdf', '').replaceAll(RegExp(r'_page_\d+\.png$'), '');

    if (!mounted) return;
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _WhatsAppShareGuideSheet(
        phone: _phone,
        customerName: widget.bill.customerName,
        imageFiles: images,
        invoiceNo: invoiceNo,
        shopName: shop?.shopName,
        bill: widget.bill,
      ),
    );
  }

  Future<String?> _promptForPhone() async {
    final ctrl = TextEditingController();
    return showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Padding(
          padding:
              EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
          child: Container(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
            decoration: BoxDecoration(
              color: Theme.of(ctx).colorScheme.surface,
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    margin: const EdgeInsets.only(bottom: 20),
                    decoration: BoxDecoration(
                      color:
                          Theme.of(ctx).colorScheme.onSurface.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const Text(
                  "Customer's Mobile Number",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(
                  'Enter to open directly in their WhatsApp chat',
                  style: TextStyle(
                      fontSize: 13,
                      color: Theme.of(ctx)
                          .colorScheme
                          .onSurface
                          .withOpacity(0.55)),
                ),
                const SizedBox(height: 16),
                StatefulBuilder(
                  builder: (_, setLocal) => TextField(
                    controller: ctrl,
                    keyboardType: TextInputType.phone,
                    maxLength: 10,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    autofocus: true,
                    onChanged: (_) => setLocal(() {}),
                    decoration: InputDecoration(
                      labelText: 'Mobile Number',
                      hintText: '10-digit number',
                      counterText: '',
                      prefixIcon: const Icon(Icons.phone_outlined, size: 20),
                      prefixText: '+91  ',
                      suffixIcon: ctrl.text.isNotEmpty
                          ? Icon(
                              ctrl.text.length == 10
                                  ? Icons.check_circle_rounded
                                  : Icons.cancel_rounded,
                              size: 20,
                              color: ctrl.text.length == 10
                                  ? const Color(0xFF25D366)
                                  : Colors.redAccent,
                            )
                          : null,
                      filled: true,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 14),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(ctx, ''),
                        style: OutlinedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        child: const Text('Skip'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 2,
                      child: FilledButton.icon(
                        icon: const Text('💬', style: TextStyle(fontSize: 18)),
                        label: const Text('Continue'),
                        onPressed: () => Navigator.pop(ctx, ctrl.text),
                        style: FilledButton.styleFrom(
                          backgroundColor: const Color(0xFF25D366),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ── Build ─────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final bill = widget.bill;
    final theme = Theme.of(context);
    final isPartial = bill.paymentStatus == 'partial';
    final isUnpaid = bill.paymentStatus == 'unpaid';

    return Scaffold(
      backgroundColor: theme.colorScheme.background,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ── Success header ────────────────────────────────
              _buildSuccessHeader(theme),

              // ── Offline banner ───────────────────────────────
              if (!widget.isSynced)
                Container(
                  margin: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: Colors.orange.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.orange.withOpacity(0.4)),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.cloud_off_outlined,
                          color: Colors.orange, size: 18),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Saved offline — will sync when connected',
                          style: TextStyle(color: Colors.orange, fontSize: 13),
                        ),
                      ),
                    ],
                  ),
                ),

              // ── Bill details card ────────────────────────────
              Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                elevation: 0,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20)),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Invoice type badge
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: widget.invoiceType == 'gst_invoice'
                                  ? const Color(0xFF0066FF).withOpacity(0.1)
                                  : Colors.green.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: widget.invoiceType == 'gst_invoice'
                                    ? const Color(0xFF0066FF).withOpacity(0.3)
                                    : Colors.green.withOpacity(0.3),
                              ),
                            ),
                            child: Text(
                              widget.invoiceType == 'gst_invoice'
                                  ? '🧾 GST Invoice'
                                  : '📋 Order Summary',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: widget.invoiceType == 'gst_invoice'
                                    ? const Color(0xFF0066FF)
                                    : Colors.green.shade700,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      // Customer info
                      if (bill.customerName != null &&
                          bill.customerName!.isNotEmpty) ...[
                        Row(
                          children: [
                            const Icon(Icons.person_outline_rounded,
                                size: 16, color: Color(0xFF0066FF)),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                bill.customerName!,
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 16),
                              ),
                            ),
                          ],
                        ),
                        if (_phone.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(left: 22, top: 2),
                            child: Row(
                              children: [
                                const Icon(Icons.phone_outlined,
                                    size: 13, color: Color(0xFF25D366)),
                                const SizedBox(width: 4),
                                Text(
                                  '+91 $_phone',
                                  style: TextStyle(
                                      color: theme.colorScheme.onSurface
                                          .withOpacity(0.55),
                                      fontSize: 13),
                                ),
                              ],
                            ),
                          ),
                        const Divider(height: 20),
                      ],

                      // Items list
                      Text('Items',
                          style: theme.textTheme.labelLarge?.copyWith(
                              color: theme.colorScheme.onSurface
                                  .withOpacity(0.55))),
                      const SizedBox(height: 8),
                      ...bill.items.map((item) => Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    '${item.name} × ${item.quantity.toStringAsFixed(item.quantity == item.quantity.roundToDouble() ? 0 : 1)}',
                                    style: const TextStyle(fontSize: 14),
                                  ),
                                ),
                                Text(
                                  '₹${item.totalPrice.toStringAsFixed(2)}',
                                  style: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 14),
                                ),
                              ],
                            ),
                          )),

                      const Divider(height: 20),

                      // Totals
                      if ((bill.discount ?? 0) > 0)
                        _SummaryRow('Discount',
                            '-₹${bill.discount!.toStringAsFixed(2)}',
                            valueColor: Colors.green),
                      if ((bill.gstAmount ?? 0) > 0 &&
                          widget.invoiceType == 'gst_invoice')
                        _SummaryRow(
                            'GST (${bill.gstPercent?.toStringAsFixed(0)}%)',
                            '₹${bill.gstAmount!.toStringAsFixed(2)}'),
                      _SummaryRow(
                        'Total',
                        '₹${bill.totalAmount.toStringAsFixed(2)}',
                        bold: true,
                        fontSize: 18,
                      ),
                    ],
                  ),
                ),
              ),

              // ── Payment status ───────────────────────────────
              if (isPartial || isUnpaid)
                Card(
                  margin:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  elevation: 0,
                  color: Colors.orange.shade50,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                      side: BorderSide(color: Colors.orange.shade200)),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Icon(Icons.warning_amber_rounded,
                            color: Colors.orange.shade700, size: 28),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if ((bill.amountPaid ?? 0) > 0)
                                Text(
                                  'Paid: ₹${bill.amountPaid!.toStringAsFixed(2)}',
                                  style: const TextStyle(
                                      color: Colors.green,
                                      fontWeight: FontWeight.w600),
                                ),
                              Text(
                                'Balance Due: ₹${(bill.amountRemaining ?? 0).toStringAsFixed(2)}',
                                style: TextStyle(
                                    color: Colors.orange.shade700,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16),
                              ),
                              Text(
                                isUnpaid
                                    ? 'Payment not received'
                                    : 'Partial payment received',
                                style: TextStyle(
                                    color: Colors.orange.shade600,
                                    fontSize: 12),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              else
                Card(
                  margin:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  elevation: 0,
                  color: Colors.green.shade50,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                      side: BorderSide(color: Colors.green.shade200)),
                  child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: Row(
                      children: [
                        Icon(Icons.check_circle_outline_rounded,
                            color: Colors.green.shade700, size: 24),
                        const SizedBox(width: 10),
                        Text(
                          'Fully Paid ✓  ₹${bill.totalAmount.toStringAsFixed(2)}',
                          style: TextStyle(
                              color: Colors.green.shade700,
                              fontWeight: FontWeight.bold,
                              fontSize: 15),
                        ),
                      ],
                    ),
                  ),
                ),

              const SizedBox(height: 16),

              // ── Action buttons ───────────────────────────────
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  children: [
                    // ── SHARE SECTION HEADER ───────────────────
                    Row(
                      children: [
                        const Icon(Icons.share_rounded,
                            size: 15, color: Color(0xFF0066FF)),
                        const SizedBox(width: 6),
                        Text(
                          'Share Invoice',
                          style: theme.textTheme.labelLarge?.copyWith(
                              color: const Color(0xFF0066FF),
                              fontWeight: FontWeight.bold),
                        ),
                        const Spacer(),
                        if (_isGeneratingPdf || _isGeneratingImage)
                          const SizedBox(
                            width: 14,
                            height: 14,
                            child: CircularProgressIndicator(
                                strokeWidth: 2, color: Color(0xFF0066FF)),
                          )
                        else if (_generatedImages != null && _generatedImages!.isNotEmpty)
                          const Icon(Icons.check_circle_rounded,
                              size: 16, color: Colors.green),
                      ],
                    ),
                    const SizedBox(height: 10),

                    // Send Invoice Image on WhatsApp
                    SizedBox(
                      width: double.infinity,
                      height: 54,
                      child: ElevatedButton(
                        onPressed: (_isGeneratingPdf || _isGeneratingImage)
                            ? null
                            : _shareImageOnWhatsApp,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF25D366),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14)),
                          elevation: 2,
                          shadowColor: const Color(0xFF25D366).withOpacity(0.3),
                        ),
                        child: (_isGeneratingPdf || _isGeneratingImage)
                            ? Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const SizedBox(
                                    width: 18,
                                    height: 18,
                                    child: CircularProgressIndicator(
                                        strokeWidth: 2, color: Colors.white),
                                  ),
                                  const SizedBox(width: 10),
                                  Text(
                                    _isGeneratingPdf
                                        ? 'Preparing Bill…'
                                        : 'Rendering Image…',
                                    style: const TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w600),
                                  ),
                                ],
                              )
                            : const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  _WhatsAppIcon(size: 22),
                                  SizedBox(width: 10),
                                  Text(
                                    'Share Image on WhatsApp',
                                    style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w600),
                                  ),
                                ],
                              ),
                      ),
                    ),
                    const SizedBox(height: 10),

                    // Share / Save PDF (system share sheet)
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: OutlinedButton.icon(
                        icon: const Icon(Icons.share_rounded, size: 20),
                        label: const Text('Share / Save PDF'),
                        onPressed: _isGeneratingPdf ? null : _shareViaSystem,
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFF0066FF),
                          side: const BorderSide(
                              color: Color(0xFF0066FF), width: 1.5),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14)),
                          textStyle: const TextStyle(
                              fontSize: 15, fontWeight: FontWeight.w600),
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Share PDF via Gmail, Drive, Telegram, etc.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontSize: 11,
                          color: theme.colorScheme.onSurface.withOpacity(0.45)),
                    ),

                    const SizedBox(height: 10),

                    // Done
                    SizedBox(
                      width: double.infinity,
                      height: 54,
                      child: FilledButton(
                        onPressed: () => context.go('/'),
                        style: FilledButton.styleFrom(
                          backgroundColor: const Color(0xFF0066FF),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14)),
                        ),
                        child: const Text(
                          'Done — Go to Home',
                          style: TextStyle(
                              fontSize: 15, fontWeight: FontWeight.w600),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSuccessHeader(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF0066FF),
            Color(0xFF0044BB),
          ],
        ),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(32)),
      ),
      child: Column(
        children: [
          AnimatedBuilder(
            animation: _checkController,
            builder: (_, __) => Opacity(
              opacity: _checkOpacity.value,
              child: Transform.scale(
                scale: _checkScale.value,
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check_rounded,
                    color: Colors.white,
                    size: 48,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 14),
          const Text(
            'Bill Saved!',
            style: TextStyle(
              color: Colors.white,
              fontSize: 26,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Bill #${widget.billId} saved successfully',
            style: const TextStyle(color: Colors.white70, fontSize: 13),
          ),
        ],
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;
  final bool bold;
  final double fontSize;

  const _SummaryRow(
    this.label,
    this.value, {
    this.valueColor,
    this.bold = false,
    this.fontSize = 14,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: TextStyle(
                  fontWeight: bold ? FontWeight.bold : FontWeight.normal,
                  fontSize: fontSize)),
          Text(value,
              style: TextStyle(
                  fontWeight: bold ? FontWeight.bold : FontWeight.w600,
                  fontSize: fontSize,
                  color: valueColor)),
        ],
      ),
    );
  }
}

/// Self-contained WhatsApp icon — no assets required.
/// Draws the iconic green rounded square with white phone glyph.
class _WhatsAppIcon extends StatelessWidget {
  final double size;
  const _WhatsAppIcon({this.size = 24});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: const Color(0xFF25D366),
        borderRadius: BorderRadius.circular(size * 0.22),
      ),
      alignment: Alignment.center,
      child: Icon(
        Icons.phone_in_talk_rounded,
        size: size * 0.6,
        color: Colors.white,
      ),
    );
  }
}

/// Two-step bottom sheet that guides the user to send an invoice image
/// on WhatsApp — even if the customer's number is NOT saved in contacts.
///
/// Step 1: Opens WhatsApp chat directly for the customer's number via wa.me
///         (works for unsaved numbers — WhatsApp opens a new chat with them).
/// Step 2: Opens the system share sheet with the invoice image attached.
///         User picks WhatsApp → selects the same contact → sends.
class _WhatsAppShareGuideSheet extends StatefulWidget {
  final String phone;
  final String? customerName;
  final List<File> imageFiles;
  final String invoiceNo;
  final String? shopName;
  final ScannedBill bill;

  const _WhatsAppShareGuideSheet({
    required this.phone,
    required this.imageFiles,
    required this.invoiceNo,
    required this.bill,
    this.customerName,
    this.shopName,
  });

  @override
  State<_WhatsAppShareGuideSheet> createState() =>
      _WhatsAppShareGuideSheetState();
}

class _WhatsAppShareGuideSheetState extends State<_WhatsAppShareGuideSheet> {
  bool _step1Done = false;

  Future<void> _openWhatsAppChat() async {
    final cleanPhone = widget.phone.replaceAll(RegExp(r'\D'), '');
    final fullPhone =
        cleanPhone.startsWith('91') ? cleanPhone : '91$cleanPhone';
    final name = widget.customerName?.isNotEmpty == true
        ? widget.customerName!
        : 'there';

    // Map status
    final status = widget.bill.paymentStatus == 'partial'
        ? OrderPaymentStatus.partiallyPaid
        : widget.bill.paymentStatus == 'unpaid'
            ? OrderPaymentStatus.unpaid
            : OrderPaymentStatus.fullyPaid;

    final caption = WhatsAppUtils.getWhatsAppCaption(
      status: status,
      customerName: name,
      businessName: widget.shopName ?? "SnapKhata",
      orderNumber: widget.invoiceNo,
      totalAmount: widget.bill.totalAmount,
      pendingAmount: widget.bill.amountRemaining,
    );

    final msg = Uri.encodeComponent(caption);
    final uri = Uri.parse('https://wa.me/$fullPhone?text=$msg');
    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
        if (mounted) setState(() => _step1Done = true);
      } else {
        // Alternative: try whatsapp:// direct scheme if wa.me is blocked
        final whatsappUri =
            Uri.parse('whatsapp://send?phone=$fullPhone&text=$msg');
        if (await canLaunchUrl(whatsappUri)) {
          await launchUrl(whatsappUri, mode: LaunchMode.externalApplication);
          if (mounted) setState(() => _step1Done = true);
        } else if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                  'Could not open WhatsApp. Please ensure it is installed.'),
              backgroundColor: Colors.orange,
            ),
          );
          // Set to true anyway so they can try Step 2 (sharing image)
          setState(() => _step1Done = true);
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
        setState(() => _step1Done = true);
      }
    }
  }

  Future<void> _shareImage() async {
    // Map status again for caption
    final status = widget.bill.paymentStatus == 'partial'
        ? OrderPaymentStatus.partiallyPaid
        : widget.bill.paymentStatus == 'unpaid'
            ? OrderPaymentStatus.unpaid
            : OrderPaymentStatus.fullyPaid;

    final caption = WhatsAppUtils.getWhatsAppCaption(
      status: status,
      customerName: widget.customerName?.isNotEmpty == true
          ? widget.customerName!
          : 'valued customer',
      businessName: widget.shopName ?? "SnapKhata",
      orderNumber: widget.invoiceNo,
      totalAmount: widget.bill.totalAmount,
      pendingAmount: widget.bill.amountRemaining,
    );

    await PdfShareService.shareImagesOnWhatsApp(
      imageFiles: widget.imageFiles,
      invoiceNo: widget.invoiceNo,
      phone: widget.phone,
      caption: caption,
      shopName: widget.shopName,
      customerName: widget.customerName,
    );
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final displayPhone = '+91 ${widget.phone}';
    final name = widget.customerName?.isNotEmpty == true
        ? widget.customerName!
        : displayPhone;

    return Padding(
      padding:
          EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle bar
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: theme.colorScheme.onSurface.withOpacity(0.18),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),

            // Header
            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: const Color(0xFF25D366).withOpacity(0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.send_rounded,
                      color: Color(0xFF25D366), size: 22),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Send Invoice on WhatsApp',
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold)),
                      Text(
                        'Follow the 2 steps below',
                        style: TextStyle(
                            fontSize: 13,
                            color:
                                theme.colorScheme.onSurface.withOpacity(0.55)),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // ── Step 1 ────────────────────────────────────────────
            _StepCard(
              step: 1,
              isDone: _step1Done,
              title: 'Open WhatsApp chat',
              subtitle: widget.customerName?.isNotEmpty == true
                  ? 'Opens chat with $name ($displayPhone)\n'
                      'Works even if not saved in contacts ✓'
                  : 'Opens WhatsApp chat for $displayPhone\n'
                      'Works even if not saved in contacts ✓',
              buttonLabel: _step1Done ? 'Opened ✓' : 'Open Chat',
              buttonColor: _step1Done ? Colors.grey : const Color(0xFF25D366),
              onTap: _step1Done ? null : _openWhatsAppChat,
            ),

            const SizedBox(height: 10),

            // ── Step 2 ────────────────────────────────────────────
            _StepCard(
              step: 2,
              isDone: false,
              title: 'Share the invoice image',
              subtitle: _step1Done
                  ? 'Pick WhatsApp → select $name → Send'
                  : 'Complete Step 1 first, then share the image',
              buttonLabel: 'Share Image',
              buttonColor: _step1Done
                  ? const Color(0xFF25D366)
                  : theme.colorScheme.onSurface.withOpacity(0.3),
              onTap: _step1Done ? _shareImage : null,
            ),

            const SizedBox(height: 16),

            // Skip / dismiss
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel',
                  style: TextStyle(
                      color: theme.colorScheme.onSurface.withOpacity(0.45))),
            ),
          ],
        ),
      ),
    );
  }
}

class _StepCard extends StatelessWidget {
  final int step;
  final bool isDone;
  final String title;
  final String subtitle;
  final String buttonLabel;
  final Color buttonColor;
  final VoidCallback? onTap;

  const _StepCard({
    required this.step,
    required this.isDone,
    required this.title,
    required this.subtitle,
    required this.buttonLabel,
    required this.buttonColor,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDone
            ? Colors.green.withOpacity(0.06)
            : theme.colorScheme.surfaceVariant.withOpacity(0.5),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDone
              ? Colors.green.withOpacity(0.3)
              : theme.colorScheme.outline.withOpacity(0.15),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Step circle
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: isDone
                  ? Colors.green
                  : const Color(0xFF25D366).withOpacity(0.12),
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: isDone
                ? const Icon(Icons.check, color: Colors.white, size: 16)
                : Text('$step',
                    style: const TextStyle(
                        color: Color(0xFF25D366),
                        fontWeight: FontWeight.bold,
                        fontSize: 14)),
          ),
          const SizedBox(width: 12),
          // Text
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(
                        fontWeight: FontWeight.w600, fontSize: 14)),
                const SizedBox(height: 3),
                Text(subtitle,
                    style: TextStyle(
                        fontSize: 12.5,
                        color: theme.colorScheme.onSurface.withOpacity(0.6),
                        height: 1.4)),
              ],
            ),
          ),
          const SizedBox(width: 10),
          // Action button
          GestureDetector(
            onTap: onTap,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
              decoration: BoxDecoration(
                color: buttonColor,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                buttonLabel,
                style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 13),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
