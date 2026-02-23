// lib/features/billing/data/services/pdf_service.dart
//
// Premium Invoice PDF — top-1% SaaS quality.
// Inspired by: Stripe, Zoho Invoice, Razorpay POS.
// Layout: clean white card, blue accent strip, structured grid.
//
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../../data/models/bill_item.dart';
import '../../data/models/scanned_bill.dart';
import '../../data/repositories/shop_profile_repository.dart';
import '../../../../core/utils/invoice_number_helper.dart';
import '../../../../core/utils/logger.dart';

// ── Brand palette ──────────────────────────────────────────────────────────
const _ink = PdfColor.fromInt(0xFF0F172A); // slate-900
const _inkMid = PdfColor.fromInt(0xFF475569); // slate-600
const _inkLight = PdfColor.fromInt(0xFF94A3B8); // slate-400
const _blue = PdfColor.fromInt(0xFF2563EB); // blue-600
const _blueLight = PdfColor.fromInt(0xFFEFF6FF); // blue-50
const _divider = PdfColor.fromInt(0xFFE2E8F0); // slate-200
const _green = PdfColor.fromInt(0xFF16A34A);
const _orange = PdfColor.fromInt(0xFFEA580C);
const _red = PdfColor.fromInt(0xFFDC2626);
const _bgPage = PdfColor.fromInt(0xFFF8FAFC); // slate-50

/// Max line items per page (A4 with header/footer). Standard multi-page invoice.
const int _rowsPerPage = 14;

class PdfService {
  PdfService._();

  static Future<File> generateBillPdf({
    required ScannedBill bill,
    required ShopProfileData? shop,
    required int billId,
    required String invoiceType,
    String? ocrInvoiceNumber,
  }) async {
    final now = DateTime.now();
    final invoiceNo = InvoiceNumberHelper.generate(
      ocrInvoiceNumber: ocrInvoiceNumber,
      shopName: shop?.shopName ?? 'SnapKhata',
      billId: billId,
      at: now,
    );

    final pdf = pw.Document(
      title: 'Invoice $invoiceNo',
      author: shop?.shopName ?? 'SnapKhata',
      creator: 'SnapKhata',
    );

    pw.ImageProvider? logoImage;
    if (shop?.logoPath != null) {
      try {
        final logoFile = File(shop!.logoPath!);
        if (await logoFile.exists()) {
          logoImage = pw.MemoryImage(await logoFile.readAsBytes());
        }
      } catch (e) {
        log('Could not load logo: $e', tag: 'PdfService');
      }
    }

    final isGst = invoiceType == 'gst_invoice';
    final isPartial = bill.paymentStatus == 'partial';
    final isUnpaid = bill.paymentStatus == 'unpaid';
    final hasDue = (bill.amountRemaining ?? 0) > 0;

    // Split items into pages (standard multi-page invoice)
    final rawChunks = _chunkList<BillItem>(bill.items, _rowsPerPage);
    final itemChunks = rawChunks.isEmpty ? <List<BillItem>>[[]] : rawChunks;
    final totalPages = itemChunks.length;

    final pageTheme = pw.PageTheme(
      pageFormat: PdfPageFormat.a4,
      margin: const pw.EdgeInsets.symmetric(horizontal: 40, vertical: 36),
      buildBackground: (ctx) => pw.FullPage(
        ignoreMargins: true,
        child: pw.Container(color: _bgPage),
      ),
    );

    for (var pageIndex = 0; pageIndex < totalPages; pageIndex++) {
      final isFirst = pageIndex == 0;
      final isLast = pageIndex == totalPages - 1;
      final chunk = itemChunks[pageIndex];
      final startRowIndex = pageIndex * _rowsPerPage;

      final pageChildren = <pw.Widget>[];

      // First page: full header + Bill To + Status. Continuation pages: short "Page N" header
      if (isFirst) {
        pageChildren.addAll([
          _buildHeader(shop, logoImage, isGst, invoiceNo, bill, now),
          pw.SizedBox(height: 20),
          _buildBillToAndStatus(bill, isPartial, isUnpaid),
          pw.SizedBox(height: 20),
        ]);
      } else {
        pageChildren.addAll([
          _buildContinuationHeader(invoiceNo, pageIndex + 1, totalPages),
          pw.SizedBox(height: 16),
        ]);
      }

      // Items table for this page only
      pageChildren.add(_buildItemsTableSlice(bill, chunk, startRowIndex));

      if (isLast) {
        // Totals, due banner, footer only on last page
        pageChildren.addAll([
          pw.SizedBox(height: 16),
          pw.Row(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Expanded(child: pw.SizedBox()),
              _buildTotals(bill, isGst),
            ],
          ),
          if (hasDue) ...[
            pw.SizedBox(height: 14),
            _buildDueBanner(bill),
          ],
          pw.Spacer(),
          _buildFooter(shop),
        ]);
      } else {
        // "Continued on next page" — standard multi-page invoice convention
        pageChildren.addAll([
          pw.SizedBox(height: 12),
          pw.Align(
            alignment: pw.Alignment.centerRight,
            child: pw.Text(
              'Continued on next page...',
              style: pw.TextStyle(
                fontSize: 8,
                color: _inkLight,
                fontStyle: pw.FontStyle.italic,
              ),
            ),
          ),
          pw.Spacer(),
        ]);
      }

      pdf.addPage(
        pw.Page(
          pageTheme: pageTheme,
          build: (ctx) => pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.stretch,
            children: pageChildren,
          ),
        ),
      );
    }

    final dir = await getTemporaryDirectory();
    final file = File('${dir.path}/invoice_$invoiceNo.pdf');
    await file.writeAsBytes(await pdf.save());
    log('PDF saved: ${file.path}', tag: 'PdfService');
    return file;
  }

  // ───────────────────────────────────────────────────────────────────────
  // HEADER — two-column: shop info (left) | invoice meta (right)
  // ───────────────────────────────────────────────────────────────────────
  static pw.Widget _buildHeader(
    ShopProfileData? shop,
    pw.ImageProvider? logo,
    bool isGst,
    String invoiceNo,
    ScannedBill bill,
    DateTime now,
  ) {
    final shopName = shop?.shopName ?? 'My Shop';
    final docLabel = isGst ? 'TAX INVOICE' : 'INVOICE';
    final formattedDate = _formatDate(bill.date) ?? _fmtDateTime(now);

    return pw.Container(
      decoration: const pw.BoxDecoration(color: PdfColors.white),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.stretch,
        children: [
          // ── Blue accent top bar ─────────────────────────────────────
          pw.Container(
            height: 4,
            decoration: const pw.BoxDecoration(
              color: _blue,
              borderRadius: pw.BorderRadius.only(
                topLeft: pw.Radius.circular(8),
                topRight: pw.Radius.circular(8),
              ),
            ),
          ),
          // ── Main header row ─────────────────────────────────────────
          pw.Container(
            padding: const pw.EdgeInsets.fromLTRB(20, 20, 20, 20),
            decoration: pw.BoxDecoration(
              color: PdfColors.white,
              border: pw.Border.all(color: _divider),
              borderRadius: const pw.BorderRadius.only(
                bottomLeft: pw.Radius.circular(8),
                bottomRight: pw.Radius.circular(8),
              ),
            ),
            child: pw.Row(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                // ── Left: Logo + shop details ──────────────────────────
                pw.Expanded(
                  flex: 3,
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      // Logo row
                      pw.Row(
                        crossAxisAlignment: pw.CrossAxisAlignment.center,
                        children: [
                          if (logo != null) ...[
                            pw.Container(
                              width: 44,
                              height: 44,
                              decoration: pw.BoxDecoration(
                                shape: pw.BoxShape.circle,
                                border:
                                    pw.Border.all(color: _divider, width: 1.5),
                              ),
                              child: pw.ClipOval(
                                child: pw.Image(logo, fit: pw.BoxFit.cover),
                              ),
                            ),
                            pw.SizedBox(width: 10),
                          ],
                          // Shop name — flex to prevent overflow
                          pw.Flexible(
                            child: pw.Text(
                              shopName,
                              style: pw.TextStyle(
                                color: _ink,
                                fontSize: 20,
                                fontWeight: pw.FontWeight.bold,
                              ),
                              // Clamp to 2 lines max
                              maxLines: 2,
                            ),
                          ),
                        ],
                      ),
                      pw.SizedBox(height: 8),
                      // Address — constrained, wraps to max 2 lines
                      if (shop?.shopAddress != null) ...[
                        _headerDetail(
                          _trimAddress(shop!.shopAddress!),
                          maxLines: 2,
                        ),
                        pw.SizedBox(height: 4),
                      ],
                      // Contact chips row
                      pw.Wrap(
                        spacing: 12,
                        runSpacing: 3,
                        children: [
                          if (shop?.shopPhone != null)
                            _chip('Ph: ${shop!.shopPhone!}'),
                          if (shop?.shopEmail != null) _chip(shop!.shopEmail!),
                          if (shop?.shopGstNumber != null)
                            _chip('GSTIN: ${shop!.shopGstNumber!}',
                                highlight: true),
                        ],
                      ),
                    ],
                  ),
                ),

                pw.SizedBox(width: 28),

                // ── Right: Invoice meta card ───────────────────────────
                pw.Container(
                  width: 172,
                  padding: const pw.EdgeInsets.all(16),
                  decoration: pw.BoxDecoration(
                    color: _blueLight,
                    borderRadius: pw.BorderRadius.circular(8),
                  ),
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        docLabel,
                        style: pw.TextStyle(
                          color: _blue,
                          fontSize: 9,
                          fontWeight: pw.FontWeight.bold,
                          letterSpacing: 1.8,
                        ),
                      ),
                      pw.SizedBox(height: 10),
                      _metaField('Invoice No.', invoiceNo),
                      pw.SizedBox(height: 8),
                      _metaField('Date', formattedDate),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Truncates very long addresses — keeps first ~80 chars of each segment
  static String _trimAddress(String address) {
    // Split by common separators and rebuild cleanly
    final parts = address
        .split(RegExp(r'[,\n]'))
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty)
        .toList();
    if (parts.length <= 2) return address.trim();
    // Show first 3 parts: locality, city, state
    return parts.take(3).join(', ');
  }

  static pw.Widget _headerDetail(String text, {int maxLines = 1}) {
    return pw.Text(
      text,
      style: const pw.TextStyle(fontSize: 9, color: _inkMid),
      maxLines: maxLines,
    );
  }

  static pw.Widget _chip(String label, {bool highlight = false}) {
    return pw.Container(
      padding: const pw.EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: pw.BoxDecoration(
        color: highlight ? _blueLight : const PdfColor.fromInt(0xFFF1F5F9),
        borderRadius: pw.BorderRadius.circular(4),
      ),
      child: pw.Text(
        label,
        style: pw.TextStyle(
          fontSize: 8,
          color: highlight ? _blue : _inkMid,
          fontWeight: highlight ? pw.FontWeight.bold : pw.FontWeight.normal,
        ),
      ),
    );
  }

  static pw.Widget _metaField(String label, String value) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          label,
          style: const pw.TextStyle(fontSize: 7.5, color: _inkLight),
        ),
        pw.SizedBox(height: 1),
        pw.Text(
          value,
          style: pw.TextStyle(
            fontSize: 10.5,
            fontWeight: pw.FontWeight.bold,
            color: _ink,
          ),
        ),
      ],
    );
  }

  // ───────────────────────────────────────────────────────────────────────
  // BILL TO + PAYMENT STATUS — side by side cards
  // ───────────────────────────────────────────────────────────────────────
  static pw.Widget _buildBillToAndStatus(
      ScannedBill bill, bool isPartial, bool isUnpaid) {
    final statusText = isUnpaid
        ? 'UNPAID'
        : isPartial
            ? 'PARTIAL'
            : 'PAID';
    final statusColor = isUnpaid
        ? _red
        : isPartial
            ? _orange
            : _green;
    final statusBg = isUnpaid
        ? const PdfColor.fromInt(0xFFFEF2F2)
        : isPartial
            ? const PdfColor.fromInt(0xFFFFF7ED)
            : const PdfColor.fromInt(0xFFF0FDF4);

    return pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        // Bill To card
        pw.Expanded(
          flex: 3,
          child: pw.Container(
            padding: const pw.EdgeInsets.all(16),
            decoration: pw.BoxDecoration(
              color: PdfColors.white,
              border: pw.Border.all(color: _divider),
              borderRadius: pw.BorderRadius.circular(8),
            ),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  'BILL TO',
                  style: pw.TextStyle(
                    fontSize: 7.5,
                    fontWeight: pw.FontWeight.bold,
                    color: _inkLight,
                    letterSpacing: 1.4,
                  ),
                ),
                pw.SizedBox(height: 7),
                // Customer name
                if (bill.customerName != null && bill.customerName!.isNotEmpty)
                  pw.Text(
                    bill.customerName!,
                    style: pw.TextStyle(
                      fontSize: 15,
                      fontWeight: pw.FontWeight.bold,
                      color: _ink,
                    ),
                  )
                else
                  pw.Text(
                    'Walk-in Customer',
                    style: pw.TextStyle(
                      fontSize: 13,
                      fontStyle: pw.FontStyle.italic,
                      color: _inkLight,
                    ),
                  ),
                if (bill.customerPhone != null &&
                    bill.customerPhone!.isNotEmpty) ...[
                  pw.SizedBox(height: 4),
                  pw.Text(
                    '+91 ${bill.customerPhone}',
                    style: const pw.TextStyle(fontSize: 10, color: _inkMid),
                  ),
                ],
              ],
            ),
          ),
        ),

        pw.SizedBox(width: 12),

        // Payment status card
        pw.Container(
          width: 160,
          padding: const pw.EdgeInsets.all(16),
          decoration: pw.BoxDecoration(
            color: PdfColors.white,
            border: pw.Border.all(color: _divider),
            borderRadius: pw.BorderRadius.circular(8),
          ),
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                'PAYMENT STATUS',
                style: pw.TextStyle(
                  fontSize: 7.5,
                  fontWeight: pw.FontWeight.bold,
                  color: _inkLight,
                  letterSpacing: 1.4,
                ),
              ),
              pw.SizedBox(height: 10),
              pw.Container(
                padding:
                    const pw.EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: pw.BoxDecoration(
                  color: statusBg,
                  border: pw.Border.all(color: statusColor, width: 0.8),
                  borderRadius: pw.BorderRadius.circular(5),
                ),
                child: pw.Text(
                  statusText,
                  style: pw.TextStyle(
                    color: statusColor,
                    fontSize: 9,
                    fontWeight: pw.FontWeight.bold,
                    letterSpacing: 1.2,
                  ),
                ),
              ),
              if (isPartial && (bill.amountPaid ?? 0) > 0) ...[
                pw.SizedBox(height: 6),
                pw.Text(
                  'Paid: Rs.${_fmt(bill.amountPaid!)}',
                  style: const pw.TextStyle(fontSize: 9, color: _green),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  /// Splits [list] into chunks of at most [size]. Used for multi-page item table.
  static List<List<T>> _chunkList<T>(List<T> list, int size) {
    if (list.isEmpty) return [];
    if (size <= 0) return [list];
    final chunks = <List<T>>[];
    for (var i = 0; i < list.length; i += size) {
      chunks.add(list.sublist(i, (i + size).clamp(0, list.length)));
    }
    return chunks;
  }

  /// Continuation header for page 2+ (e.g. "Invoice NEHA-xxx — Page 2 of 3").
  static pw.Widget _buildContinuationHeader(
      String invoiceNo, int pageNum, int totalPages) {
    return pw.Container(
      padding: const pw.EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      decoration: pw.BoxDecoration(
        color: PdfColors.white,
        border: pw.Border.all(color: _divider),
        borderRadius: pw.BorderRadius.circular(8),
      ),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(
            'Invoice $invoiceNo',
            style: pw.TextStyle(
              fontSize: 10,
              fontWeight: pw.FontWeight.bold,
              color: _ink,
            ),
          ),
          pw.Text(
            'Page $pageNum of $totalPages',
            style: pw.TextStyle(
              fontSize: 9,
              color: _inkLight,
              fontWeight: pw.FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }

  // ───────────────────────────────────────────────────────────────────────
  // ITEMS TABLE (single slice for multi-page)
  // ───────────────────────────────────────────────────────────────────────
  static pw.Widget _buildItemsTableSlice(
      ScannedBill bill, List<BillItem> slice, int startRowIndex) {
    const headers = ['#', 'Item Description', 'Qty', 'Rate', 'Amount'];
    const colWidths = {
      0: pw.FlexColumnWidth(0.5),
      1: pw.FlexColumnWidth(3.8),
      2: pw.FlexColumnWidth(0.8),
      3: pw.FlexColumnWidth(1.4),
      4: pw.FlexColumnWidth(1.4),
    };

    return pw.ClipRRect(
      horizontalRadius: 8,
      verticalRadius: 8,
      child: pw.Table(
        columnWidths: colWidths,
        border: pw.TableBorder.all(color: _divider, width: 0.5),
        children: [
          pw.TableRow(
            decoration: const pw.BoxDecoration(color: _ink),
            children: headers
                .asMap()
                .entries
                .map((e) => _tableCell(
                      e.value,
                      isBold: true,
                      color: PdfColors.white,
                      isHeader: true,
                      right: e.key >= 3,
                      center: e.key == 2,
                    ))
                .toList(),
          ),
          ...slice.asMap().entries.map((entry) {
            final localIdx = entry.key;
            final idx = startRowIndex + localIdx;
            final item = entry.value;
            final isAlt = idx % 2 == 1;
            final qty = item.quantity == item.quantity.roundToDouble()
                ? item.quantity.toInt().toString()
                : item.quantity.toStringAsFixed(1);
            return pw.TableRow(
              decoration: isAlt
                  ? const pw.BoxDecoration(color: PdfColor.fromInt(0xFFF8FAFC))
                  : const pw.BoxDecoration(color: PdfColors.white),
              children: [
                _tableCell('${idx + 1}', center: true),
                _tableCell(item.name),
                _tableCell(qty, center: true),
                _tableCell(
                  item.unitPrice > 0 ? 'Rs.${_fmt(item.unitPrice)}' : '-',
                  right: true,
                ),
                _tableCell(
                  'Rs.${_fmt(item.totalPrice)}',
                  right: true,
                  isBold: true,
                ),
              ],
            );
          }),
        ],
      ),
    );
  }

  static pw.Widget _buildItemsTable(ScannedBill bill) {
    return _buildItemsTableSlice(bill, bill.items, 0);
  }

  static pw.Widget _tableCell(
    String text, {
    bool isBold = false,
    bool center = false,
    bool right = false,
    bool isHeader = false,
    PdfColor? color,
  }) {
    return pw.Padding(
      padding: pw.EdgeInsets.symmetric(
        horizontal: isHeader ? 10 : 8,
        vertical: isHeader ? 11 : 9,
      ),
      child: pw.Text(
        text,
        textAlign: right
            ? pw.TextAlign.right
            : center
                ? pw.TextAlign.center
                : pw.TextAlign.left,
        style: pw.TextStyle(
          fontSize: isHeader ? 8 : 9.5,
          fontWeight: isBold ? pw.FontWeight.bold : pw.FontWeight.normal,
          color: color ?? _ink,
          letterSpacing: isHeader ? 0.8 : 0,
        ),
      ),
    );
  }

  // ───────────────────────────────────────────────────────────────────────
  // TOTALS PANEL
  // ───────────────────────────────────────────────────────────────────────
  static pw.Widget _buildTotals(ScannedBill bill, bool isGst) {
    final rows = <pw.TableRow>[];

    void addRow(
      String label,
      String value, {
      bool isBold = false,
      PdfColor? valueColor,
      bool topLine = false,
      double fs = 9.5,
    }) {
      rows.add(pw.TableRow(
        decoration: topLine
            ? const pw.BoxDecoration(
                border: pw.Border(
                  top: pw.BorderSide(color: _divider, width: 0.8),
                ),
              )
            : null,
        children: [
          pw.Padding(
            padding:
                pw.EdgeInsets.only(top: topLine ? 10 : 5, bottom: 5, right: 20),
            child: pw.Text(
              label,
              textAlign: pw.TextAlign.right,
              style: pw.TextStyle(
                fontSize: fs,
                fontWeight: isBold ? pw.FontWeight.bold : pw.FontWeight.normal,
                color: isBold ? _ink : _inkMid,
              ),
            ),
          ),
          pw.Padding(
            padding: pw.EdgeInsets.only(top: topLine ? 10 : 5, bottom: 5),
            child: pw.Text(
              value,
              textAlign: pw.TextAlign.right,
              style: pw.TextStyle(
                fontSize: fs,
                fontWeight: pw.FontWeight.bold,
                color: valueColor ?? _ink,
              ),
            ),
          ),
        ],
      ));
    }

    // ── Subtotal ──────────────────────────────────────────────────────
    addRow('Subtotal', 'Rs.${_fmt(bill.subtotal)}');

    // ── Discount ──────────────────────────────────────────────────────
    if ((bill.discount ?? 0) > 0) {
      addRow('Discount', '- Rs.${_fmt(bill.discount!)}', valueColor: _green);
    }

    // ── GST ──────────────────────────────────────────────────────────
    // Show GST whenever gstAmount > 0 — it's always included in totalAmount.
    // Label says "GST (x%)" when percent is available.
    if ((bill.gstAmount ?? 0) > 0) {
      final pct = (bill.gstPercent != null && bill.gstPercent! > 0)
          ? ' (${bill.gstPercent!.toStringAsFixed(0)}%)'
          : (isGst ? '' : '');
      addRow('GST$pct', 'Rs.${_fmt(bill.gstAmount!)}');
    }

    // ── Grand Total ───────────────────────────────────────────────────
    addRow(
      'TOTAL',
      'Rs.${_fmt(bill.totalAmount)}',
      isBold: true,
      topLine: true,
      fs: 13,
    );

    // ── Paid / Balance ────────────────────────────────────────────────
    if ((bill.amountPaid ?? 0) > 0) {
      addRow('Amount Paid', 'Rs.${_fmt(bill.amountPaid!)}', valueColor: _green);
    }
    if ((bill.amountRemaining ?? 0) > 0) {
      addRow(
        'Balance Due',
        'Rs.${_fmt(bill.amountRemaining!)}',
        isBold: true,
        valueColor: _red,
        fs: 11,
        topLine: true,
      );
    }

    return pw.Container(
      width: 252,
      decoration: pw.BoxDecoration(
        color: PdfColors.white,
        border: pw.Border.all(color: _divider),
        borderRadius: pw.BorderRadius.circular(8),
      ),
      padding: const pw.EdgeInsets.fromLTRB(12, 14, 14, 14),
      child: pw.Table(
        columnWidths: const {
          0: pw.FlexColumnWidth(1.5),
          1: pw.FlexColumnWidth(1.1),
        },
        children: rows,
      ),
    );
  }

  // ───────────────────────────────────────────────────────────────────────
  // DUE BANNER
  // ───────────────────────────────────────────────────────────────────────
  static pw.Widget _buildDueBanner(ScannedBill bill) {
    return pw.Container(
      padding: const pw.EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: pw.BoxDecoration(
        color: const PdfColor.fromInt(0xFFFFF7ED),
        border: pw.Border.all(color: _orange, width: 0.8),
        borderRadius: pw.BorderRadius.circular(8),
      ),
      child: pw.Row(
        children: [
          pw.Container(
            width: 18,
            height: 18,
            decoration: pw.BoxDecoration(
              color: _orange,
              borderRadius: pw.BorderRadius.circular(4),
            ),
            child: pw.Center(
              child: pw.Text(
                '!',
                style: pw.TextStyle(
                  color: PdfColors.white,
                  fontSize: 11,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
            ),
          ),
          pw.SizedBox(width: 10),
          pw.Expanded(
            child: pw.Text(
              'Balance of Rs.${_fmt(bill.amountRemaining ?? 0)} is due.'
              ' Please settle at your earliest convenience.',
              style: const pw.TextStyle(fontSize: 9.5, color: _orange),
            ),
          ),
        ],
      ),
    );
  }

  // ───────────────────────────────────────────────────────────────────────
  // FOOTER
  // ───────────────────────────────────────────────────────────────────────
  static pw.Widget _buildFooter(ShopProfileData? shop) {
    return pw.Column(
      children: [
        pw.Divider(color: _divider, height: 1),
        pw.SizedBox(height: 8),
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Text(
              'Generated by SnapKhata  |  snapkhata.app',
              style: const pw.TextStyle(fontSize: 7.5, color: _inkLight),
            ),
            pw.Text(
              'Thank you for your business.',
              style: pw.TextStyle(
                fontSize: 7.5,
                color: _blue,
                fontStyle: pw.FontStyle.italic,
              ),
            ),
          ],
        ),
      ],
    );
  }

  // ───────────────────────────────────────────────────────────────────────
  // Helpers
  // ───────────────────────────────────────────────────────────────────────
  static String _fmt(double v) => v.toStringAsFixed(2);

  static String? _formatDate(String? raw) {
    if (raw == null) return null;
    try {
      final parts = raw.split('-');
      if (parts.length == 3) {
        return '${parts[2]}/${parts[1]}/${parts[0]}';
      }
    } catch (_) {}
    return raw;
  }

  static String _fmtDateTime(DateTime dt) {
    final dd = dt.day.toString().padLeft(2, '0');
    final mm = dt.month.toString().padLeft(2, '0');
    return '$dd/$mm/${dt.year}';
  }

  // ─────────────────────────────────────────────────────────────────────
  // IMAGE EXPORT
  // ─────────────────────────────────────────────────────────────────────

  /// Renders the first page of a PDF to a high-resolution PNG (backward compatible).
  /// For multi-page invoices use [renderBillAsImages] to get one image per page.
  static Future<File> renderBillAsImage(File pdfFile) async {
    final images = await renderBillAsImages(pdfFile);
    return images.first;
  }

  /// Renders every page of the invoice PDF to separate PNG images (one per page).
  /// Standard for multi-page invoices: share/send as 2+ images or use PDF for full document.
  ///
  /// Uses 300 DPI — sharp for A4. Files are named like invoice_XXX_page_1.png, invoice_XXX_page_2.png.
  static Future<List<File>> renderBillAsImages(File pdfFile) async {
    final pdfBytes = await pdfFile.readAsBytes();
    final pages = Printing.raster(pdfBytes, dpi: 300);

    final dir = await getTemporaryDirectory();
    final baseName = pdfFile.path.split(RegExp(r'[/\\]')).last.replaceAll('.pdf', '');

    final files = <File>[];
    var pageNum = 1;
    await for (final page in pages) {
      final pngBytes = await page.toPng();
      final name = '${baseName}_page_$pageNum.png';
      final imageFile = File('${dir.path}/$name');
      await imageFile.writeAsBytes(pngBytes);
      files.add(imageFile);
      pageNum++;
    }

    log('Invoice images saved: ${files.length} page(s)', tag: 'PdfService');
    return files;
  }
}
