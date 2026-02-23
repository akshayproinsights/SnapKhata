// lib/features/billing/data/models/bill_item.dart

/// A single line item on a scanned bill.
class BillItem {
  final String name;
  final double quantity;
  final String? unit;
  final double unitPrice;
  final double totalPrice;

  const BillItem({
    required this.name,
    required this.quantity,
    this.unit,
    required this.unitPrice,
    required this.totalPrice,
  });

  BillItem copyWith({
    String? name,
    double? quantity,
    String? unit,
    double? unitPrice,
    double? totalPrice,
  }) {
    return BillItem(
      name: name ?? this.name,
      quantity: quantity ?? this.quantity,
      unit: unit ?? this.unit,
      unitPrice: unitPrice ?? this.unitPrice,
      totalPrice: totalPrice ?? this.totalPrice,
    );
  }

  factory BillItem.fromJson(Map<String, dynamic> json) {
    return BillItem(
      name: (json['name'] as String?) ?? '',
      quantity: _toDouble(json['quantity']) ?? 1.0,
      unit: json['unit'] as String?,
      unitPrice: _toDouble(json['unit_price']) ?? 0.0,
      totalPrice: _toDouble(json['total_price']) ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() => {
        'name': name,
        'quantity': quantity,
        'unit': unit,
        'unit_price': unitPrice,
        'total_price': totalPrice,
      };

  static double? _toDouble(dynamic v) {
    if (v == null) return null;
    if (v is double) return v;
    if (v is int) return v.toDouble();
    return double.tryParse(v.toString());
  }
}
