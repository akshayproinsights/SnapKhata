import 'package:flutter_dotenv/flutter_dotenv.dart';

/// App-wide constants for SnapKhata.
class AppConstants {
  AppConstants._();

  static const String appName = 'SnapKhata';
  static const String appVersion = '1.0.0';

  /// Gemini API key — loaded from the `.env` file at runtime.
  /// Never hardcode this value in source code.
  static String get geminiApiKey =>
      dotenv.env['GEMINI_API_KEY'] ??
      (throw StateError('GEMINI_API_KEY not found in .env'));

  /// Sarvam AI API key.
  static String get sarvamApiKey =>
      dotenv.env['SARVAM_API_KEY'] ??
      (throw StateError('SARVAM_API_KEY not found in .env'));

  // ─── Gemini Models ────────────────────────────────────────────
  /// Primary OCR model — fast & cost-effective.
  static const String primaryModel = 'gemini-3-flash-preview';

  /// Fallback OCR model — higher accuracy, used when primary score < [accuracyThreshold].
  static const String fallbackModel = 'gemini-3.1-pro-preview';

  /// If OCR confidence score falls below this percentage, retry with [fallbackModel].
  static const double accuracyThreshold = 0.70;

  // ─── Token Pricing (INR per 1M tokens) ───────────────────────
  // Gemini 2.5 Flash pricing (approximate, update as Google publishes rates)
  static const double flashInputPricePer1M = 52.0; // ~$0.625/1M → ~₹52
  static const double flashOutputPricePer1M = 208.0; // ~$2.5/1M   → ~₹208

  // Gemini 2.5 Pro pricing
  static const double proInputPricePer1M = 1050.0; // ~$12.5/1M  → ~₹1050
  static const double proOutputPricePer1M = 4200.0; // ~$50/1M    → ~₹4200

  // ─── Supabase ─────────────────────────────────────────────────
  /// Supabase Storage bucket for bill images.
  static const String billImagesBucket = 'bill-images';

  /// Base URL for customer-facing order pages.
  ///
  /// Example: https://my.snapkhata.app/order
  /// Final share link will look like: `$orderShareBaseUrl/<supabase_id>`.
  static String get orderShareBaseUrl =>
      dotenv.env['ORDER_SHARE_BASE_URL'] ?? 'https://snapkhata.app/order';
}
