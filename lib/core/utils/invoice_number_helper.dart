// lib/core/utils/invoice_number_helper.dart

/// Generates a professional invoice number for SnapKhata bills.
///
/// If the OCR extracted an invoice number from the image, that is used as-is.
/// Otherwise, generates: {SHOPCODE}-{DDMMYYYY}-{HHMM}
///   e.g. "GANESH-21022026-1433"
///
/// Shop code rules (so customer instantly knows who sent the PDF):
///   1. Take the first word of shop name (before first space).
///   2. Uppercase it.
///   3. Strip special characters, keep only A–Z digits.
///   4. Truncate to 8 characters max.
///   Fallback to "SK" if name is empty.
class InvoiceNumberHelper {
  InvoiceNumberHelper._();

  /// [ocrInvoiceNumber] — if OCR found one, use it directly.
  /// [shopName]         — used to build shop code prefix.
  /// [billId]           — local DB id (used if everything else fails).
  /// [at]               — timestamp for the suffix (defaults to now).
  static String generate({
    String? ocrInvoiceNumber,
    required String shopName,
    required int billId,
    DateTime? at,
  }) {
    // Use OCR-extracted number if present and non-trivial
    if (ocrInvoiceNumber != null && ocrInvoiceNumber.trim().isNotEmpty) {
      return ocrInvoiceNumber.trim();
    }

    final ts = at ?? DateTime.now();
    final shopCode = _buildShopCode(shopName);
    final dd = ts.day.toString().padLeft(2, '0');
    final mm = ts.month.toString().padLeft(2, '0');
    final yyyy = ts.year.toString();
    final hh = ts.hour.toString().padLeft(2, '0');
    final min = ts.minute.toString().padLeft(2, '0');

    return '$shopCode-$dd$mm$yyyy-$hh$min';
  }

  static String _buildShopCode(String shopName) {
    final name = shopName.trim();
    if (name.isEmpty) return 'SK';

    // Take first word only
    final firstWord = name.split(RegExp(r'[\s\-_/]')).first;

    // Keep only alpha-numeric characters and uppercase
    final cleaned =
        firstWord.toUpperCase().replaceAll(RegExp(r'[^A-Z0-9]'), '');

    if (cleaned.isEmpty) return 'SK';

    // Max 8 chars so it stays readable
    return cleaned.length > 8 ? cleaned.substring(0, 8) : cleaned;
  }
}
