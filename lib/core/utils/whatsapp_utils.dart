// lib/core/utils/whatsapp_utils.dart

import 'package:url_launcher/url_launcher.dart';

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
            'We have received your advance for *Order #$orderNumber*. The detailed order snapshot is attached.\n'
            '⏳ *Balance Pending: $pendingFmt*';

      case OrderPaymentStatus.fullyPaid:
        return 'Hi $customerName,\n'
            'Your order *#$orderNumber* with *$businessName* is confirmed! 🎉\n'
            '✅ *Amount Paid: $totalFmt*\n'
            'Please find your final receipt attached. Thank you for doing business with us!';
    }
  }

  /// Normalizes an Indian mobile number to `91XXXXXXXXXX` (digits only).
  static String normalizeIndianPhone(String phone) {
    final digitsOnly = phone.replaceAll(RegExp(r'\D'), '');
    if (digitsOnly.startsWith('91')) return digitsOnly;
    return '91$digitsOnly';
  }

  /// Builds a wa.me deep link for the given phone and message.
  ///
  /// Example: https://wa.me/91XXXXXXXXXX?text=<url_encoded_message>
  static Uri buildWaMeUri({
    required String phone,
    required String message,
  }) {
    final normalized = normalizeIndianPhone(phone);
    final encodedMessage = Uri.encodeComponent(message);
    return Uri.parse('https://wa.me/$normalized?text=$encodedMessage');
  }

  /// Opens WhatsApp using the wa.me deep link in an external application mode.
  ///
  /// Returns `true` if the native WhatsApp app (or browser) could be opened.
  static Future<bool> openWhatsAppChat({
    required String phone,
    required String message,
  }) async {
    final uri = buildWaMeUri(phone: phone, message: message);
    if (await canLaunchUrl(uri)) {
      return launchUrl(uri, mode: LaunchMode.externalApplication);
    }
    return false;
  }
}
