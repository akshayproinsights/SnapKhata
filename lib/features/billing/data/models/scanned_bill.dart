// lib/features/billing/data/models/scanned_bill.dart
import 'bill_item.dart';

/// Result of Gemini OCR on a filled customer bill (Mode A).
class ScannedBill {
  final String? customerName;
  final String? customerPhone;
  final String? invoiceId; // Extracted bill/invoice number
  final String? date; // YYYY-MM-DD
  final List<BillItem> items;
  final double subtotal;
  final double? discount;
  final double? gstAmount;
  final double? gstPercent;
  final double totalAmount;
  final double? amountPaid;
  final double? amountRemaining;
  final String paymentStatus; // 'paid' | 'partial' | 'unpaid'

  const ScannedBill({
    this.customerName,
    this.customerPhone,
    this.invoiceId,
    this.date,
    required this.items,
    required this.subtotal,
    this.discount,
    this.gstAmount,
    this.gstPercent,
    required this.totalAmount,
    this.amountPaid,
    this.amountRemaining,
    required this.paymentStatus,
  });

  ScannedBill copyWith({
    String? customerName,
    String? customerPhone,
    String? invoiceId,
    String? date,
    List<BillItem>? items,
    double? subtotal,
    double? discount,
    double? gstAmount,
    double? gstPercent,
    double? totalAmount,
    double? amountPaid,
    double? amountRemaining,
    String? paymentStatus,
  }) {
    return ScannedBill(
      customerName: customerName ?? this.customerName,
      customerPhone: customerPhone ?? this.customerPhone,
      invoiceId: invoiceId ?? this.invoiceId,
      date: date ?? this.date,
      items: items ?? this.items,
      subtotal: subtotal ?? this.subtotal,
      discount: discount ?? this.discount,
      gstAmount: gstAmount ?? this.gstAmount,
      gstPercent: gstPercent ?? this.gstPercent,
      totalAmount: totalAmount ?? this.totalAmount,
      amountPaid: amountPaid ?? this.amountPaid,
      amountRemaining: amountRemaining ?? this.amountRemaining,
      paymentStatus: paymentStatus ?? this.paymentStatus,
    );
  }

  factory ScannedBill.fromJson(Map<String, dynamic> json) {
    final rawItems = json['items'];
    final items = (rawItems is List)
        ? rawItems
            .whereType<Map<String, dynamic>>()
            .map(BillItem.fromJson)
            .toList()
        : <BillItem>[];

    return ScannedBill(
      customerName: json['customer_name'] as String?,
      customerPhone: json['customer_phone'] as String?,
      invoiceId: json['invoice_id'] as String?,
      date: json['date'] as String?,
      items: items,
      subtotal: _toDouble(json['subtotal']) ?? 0.0,
      discount: _toDouble(json['discount']),
      gstAmount: _toDouble(json['gst_amount']),
      gstPercent: _toDouble(json['gst_percent']),
      totalAmount: _toDouble(json['total_amount']) ?? 0.0,
      amountPaid: _toDouble(json['amount_paid']),
      amountRemaining: _toDouble(json['amount_remaining']),
      paymentStatus: (json['payment_status'] as String?) ?? 'unpaid',
    );
  }

  static double? _toDouble(dynamic v) {
    if (v == null) return null;
    if (v is double) return v;
    if (v is int) return v.toDouble();
    return double.tryParse(v.toString());
  }
}

/// Result of Gemini OCR on an empty shop receipt / template (Mode B).
class ShopTemplate {
  final String shopName;
  final String? shopAddress;
  final String? shopPhone;
  final String? shopGstNumber;
  final String? shopEmail;

  const ShopTemplate({
    required this.shopName,
    this.shopAddress,
    this.shopPhone,
    this.shopGstNumber,
    this.shopEmail,
  });

  factory ShopTemplate.fromJson(Map<String, dynamic> json) {
    return ShopTemplate(
      shopName: (json['shop_name'] as String?) ?? 'My Shop',
      shopAddress: json['shop_address'] as String?,
      shopPhone: json['shop_phone'] as String?,
      shopGstNumber: json['shop_gst_number'] as String?,
      shopEmail: json['shop_email'] as String?,
    );
  }
}
