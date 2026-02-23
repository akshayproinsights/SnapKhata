// lib/core/utils/whatsapp_utils.dart

enum OrderPaymentStatus { fullyPaid, partiallyPaid, unpaid }

class WhatsAppUtils {
  WhatsAppUtils._();

  /// Formats double amount into Indian Rupee format (e.g., ₹1,25,000)
  static String formatIndianCurrency(double amount) {
    String val = amount.toStringAsFixed(0);
    if (val.length <= 3) return '₹$val';

    String lastThree = val.substring(val.length - 3);
    String remaining = val.substring(0, val.length - 3);

    // Indian numbering: comma after first 3, then every 2
    StringBuffer sb = StringBuffer();
    int i = remaining.length;
    while (i > 2) {
      sb.write(',${remaining.substring(i - 2, i)}');
      i -= 2;
    }
    if (i > 0) {
      sb.write(remaining.substring(0, i));
    }

    // Reverse logic since we built it backwards or just use a simpler loop from right
    // Let's rewrite for clarity
    String result = '';
    String rem = remaining;
    while (rem.length > 2) {
      result = ',${rem.substring(rem.length - 2)}$result';
      rem = rem.substring(0, rem.length - 2);
    }
    result = rem + result;

    return '₹$result,$lastThree';
  }

  static String getWhatsAppCaption({
    required OrderPaymentStatus status,
    required String customerName,
    required String businessName,
    required String orderNumber,
    required double totalAmount,
    double? pendingAmount,
    String? upiDeepLink,
  }) {
    final totalFmt = formatIndianCurrency(totalAmount);
    final pendingFmt =
        pendingAmount != null ? formatIndianCurrency(pendingAmount) : '';

    switch (status) {
      case OrderPaymentStatus.unpaid:
        return 'Hi $customerName,\n'
            'Your order from *$businessName* is ready. Please check the attached image for full details.\n'
            '⚠️ *Amount Due: $totalFmt*\n'
            'Thank you for choosing *$businessName*.';

      case OrderPaymentStatus.partiallyPaid:
        return 'Hi $customerName,\n'
            'We have received your advance for *Order #$orderNumber*. The detailed bill is attached.\n'
            '⏳ *Balance Pending: $pendingFmt*';

      case OrderPaymentStatus.fullyPaid:
        return 'Hi $customerName,\n'
            'Your order *#$orderNumber* with *$businessName* is confirmed! 🎉\n'
            '✅ *Amount Paid: $totalFmt*\n'
            'Please find your final receipt attached. Thank you for doing business with us!';
    }
  }
}
