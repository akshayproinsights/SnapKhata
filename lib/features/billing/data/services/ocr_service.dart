// lib/features/billing/data/services/ocr_service.dart
import 'dart:convert';
import 'dart:io';

import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import '../../../../core/constants/app_constants.dart';

import '../../../../core/utils/logger.dart';
import '../models/scanned_bill.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Token usage & cost snapshot returned with every OCR result.
// ─────────────────────────────────────────────────────────────────────────────

class OcrUsage {
  final String modelUsed;
  final int inputTokens;
  final int outputTokens;
  final double costInr;
  final bool usedFallback;

  const OcrUsage({
    required this.modelUsed,
    required this.inputTokens,
    required this.outputTokens,
    required this.costInr,
    required this.usedFallback,
  });

  @override
  String toString() =>
      'OcrUsage(model=$modelUsed, in=$inputTokens, out=$outputTokens, '
      '₹${costInr.toStringAsFixed(4)}, fallback=$usedFallback)';
}

// ─────────────────────────────────────────────────────────────────────────────
// Wrapper that bundles the extracted data with its usage metadata.
// ─────────────────────────────────────────────────────────────────────────────

class OcrResult<T> {
  final T data;
  final OcrUsage usage;

  const OcrResult({required this.data, required this.usage});
}

// ─────────────────────────────────────────────────────────────────────────────
// System instruction persona — given to the model before any image/prompt.
// Equivalent to types.GenerateContentConfig(system_instruction=...) in Python.
// ─────────────────────────────────────────────────────────────────────────────

const _systemInstruction = '''
You are BillBot, an expert AI assistant specialized in reading Indian shop bills,
invoices, and receipts for small and medium businesses (SMBs) across India.
You understand English, Hindi (Devanagari script), and Marathi fluently.

Language rule:
- ALL output field values must be in English.
- If a name, item, or label is in Hindi or Marathi, translate it to English
  AND append the original text in parentheses for the shopkeeper's reference.
  Example: "Refined Oil (शुद्ध तेल)", "Wheat Flour (गव्हाचे पीठ)"

Date rule:
- Indian bills always use dd-mm-yyyy, dd-mm-yy, or dd/mm/yy format.
- Always parse dates in that order (day first, then month, then year).
- Convert to YYYY-MM-DD for the "date" output field.
  Example: "20/02/26" → "2026-02-20", "5-3-2025" → "2025-03-05"

Your sole job is to extract structured data from raw OCR text (from Indian shop bills) and return it as
valid JSON — nothing else. Never include markdown, explanations, or commentary
in your response. Always return raw, parseable JSON only.
''';

// ─────────────────────────────────────────────────────────────────────────────
// OcrService
// ─────────────────────────────────────────────────────────────────────────────

class OcrService {
  OcrService._();

  // PRIMARY model: fast + cost-effective (gemini-2.5-flash)
  static final _primaryModel = GenerativeModel(
    model: AppConstants.primaryModel,
    apiKey: AppConstants.geminiApiKey,
    systemInstruction: Content.system(_systemInstruction),
    generationConfig: GenerationConfig(
      temperature: 0.1,
      responseMimeType: 'application/json',
    ),
  );

  // FALLBACK model: higher accuracy (gemini-2.5-pro)
  static final _fallbackModel = GenerativeModel(
    model: AppConstants.fallbackModel,
    apiKey: AppConstants.geminiApiKey,
    systemInstruction: Content.system(_systemInstruction),
    generationConfig: GenerationConfig(
      temperature: 0.1,
      responseMimeType: 'application/json',
    ),
  );

  // ─────────────────────────────────────────────────────────────
  // Image Compression Helper
  // ─────────────────────────────────────────────────────────────

  /// Compresses the image to reduce payload size and potentially improve OCR.
  static Future<File> _compressImage(File file) async {
    try {
      final String filePath = file.absolute.path;
      final String outPath = p.join(
        (await getTemporaryDirectory()).path,
        "compressed_${p.basename(filePath)}",
      );

      final int originalSize = await file.length();
      log('OCR: original size: ${(originalSize / 1024).toStringAsFixed(2)} KB',
          tag: 'OcrService');

      final XFile? result = await FlutterImageCompress.compressAndGetFile(
        filePath,
        outPath,
        quality: 70,
        minWidth: 1200,
        minHeight: 1200,
      );

      if (result == null) {
        log('OCR: compression failed, using original', tag: 'OcrService');
        return file;
      }

      final File compressedFile = File(result.path);
      final int compressedSize = await compressedFile.length();
      log('OCR: compressed size: ${(compressedSize / 1024).toStringAsFixed(2)} KB',
          tag: 'OcrService');

      return compressedFile;
    } catch (e) {
      log('OCR COMPRESSION EXCEPTION: $e', tag: 'OcrService');
      return file;
    }
  }

  // No longer used: Sarvam OCR replaced by Gemini Multimodal OCR

  // ─────────────────────────────────────────────────────────────
  // Mode A — Extract filled bill data
  // ─────────────────────────────────────────────────────────────

  static const _billPrompt = '''
Analyze the provided image of an Indian shop bill / invoice / receipt.
CRITICAL: Analyze the entire image provided. Do not skip any parts.
Many bills have items at the very bottom or footer; ensure EVERY single line item is captured.
AIM FOR 100% ACCURACY. Do not skip or omit any details.

Return ONLY valid JSON (no markdown, no explanation) matching this exact schema:

{
  "customer_name": "string or null — translate to English, keep original in brackets e.g. 'Ramesh Kumar (रमेश कुमार)'",
  "customer_phone": "string or null — digits only, no spaces or dashes",
  "date": "YYYY-MM-DD or null — Indian bills use dd-mm-yyyy / dd-mm-yy / dd/mm/yy, parse day-first always",
  "items": [
    {
      "name": "English name, original in brackets if non-English e.g. 'Refined Oil (शुद्ध तेल)'",
      "quantity": "number (default to 1 if not clearly specified)",
      "unit": "kg / pcs / ltr / gm / dozen / bundle / bag / box or null (Optional)",
      "unit_price": "number or null (if missing, derive from total_price / quantity)",
      "total_price": "number"
    }
  ],
  "subtotal": "number or null (sum of total_price if missing)",
  "discount": "number or null",
  "gst_amount": "number or null",
  "gst_percent": "number or null",
  "total_amount": "number",
  "amount_paid": "number or null",
  "amount_remaining": "number or null",
  "payment_status": "paid | partial | unpaid",
  "confidence_score": "number (0–100)"
}

Indian SMB billing terms glossary (recognise any of these):

  CUSTOMER / NAME
    ग्राहक, नाव, नाम, खरीदार, Party Name, Customer, Name, M/s

  DATE
    तारीख, दिनांक, Date, Dt., Dt
    Format is ALWAYS day-first: dd-mm-yyyy or dd/mm/yy or dd-mm-yy

  QUANTITY / UNIT
    नग, पीस, किलो, ग्राम, लिटर, डझन, गठ्ठा
    Pcs, Nos, Kg, Gm, Ltr, Ml, Dozen, Doz, Bundle, Bag, Box, Carton

  RATE / PRICE PER UNIT
    दर, भाव, Rate, Price, MRP, Per

  AMOUNT / TOTAL
    एकूण, कुल, रक्कम, Total, Grand Total, Net Amount, Bill Amount, Amt

  SUBTOTAL (before tax/discount)
    उप-एकूण, Sub Total, Gross Amount

  DISCOUNT
    सवलत, छूट, Discount, Disc, Rebate

  TAX / GST
    जीएसटी, कर, GST, CGST, SGST, IGST, Tax, VAT

  AMOUNT PAID (money received today)
    जमा, भरलेले, आज दिले, Paid, Received, Cash Received, Advance

  BALANCE DUE (remaining to be paid)
    बाकी, शिल्लक, उधार, Baki, Balance, Due, Remaining, Credit

  CUSTOMER MOBILE / PHONE
    मोबाईल, फोन, संपर्क, दूरध्वनी, Mob, Mobile, Ph, Phone, Contact, Tel, M.
    Indian mobile numbers are always 10 digits starting with 6, 7, 8, or 9.
    Strip any country code (+91, 0) and spaces/dashes before returning.
    Return digits only (no spaces, no dashes, no +91).

Rules:
  1. All output values must be in English; non-English text → English (original).
  2. Dates: parse day-first; output as YYYY-MM-DD.
  3. Use null (never 0) for fields that are absent or not written on the bill.
  4. All monetary values must be numbers, not strings.
  5. If unit_price is missing, compute it as total_price / quantity when possible.
  6. If subtotal is missing, sum all item total_price values.
  7. payment_status: "paid" = fully paid, "partial" = partly paid, "unpaid" = nothing paid.
  8. confidence_score: 100 = every field crystal-clear, 0 = completely unreadable.
  9. THOROUGH SCAN: Check the bottom edges and unconventional locations for items.
  10. NO OMISSIONS: If you see a list of items, extract ALL of them without skipping entries.
  11. 100% ACCURACY: Double check every digit and character extracted.
''';

  /// Extract bill data from a filled customer bill image.
  /// 1. Uses Sarvam to get raw text.
  /// 2. Uses Gemini to structure that text.
  /// 1. Compresses the image.
  /// 2. Uses Sarvam to get raw text.
  /// 3. Uses Gemini to structure that text.
  static Future<OcrResult<ScannedBill>> extractBill(File imageFile) async {
    // 1. Compress image
    final compressedFile = await _compressImage(imageFile);
    final imageBytes = await compressedFile.readAsBytes();

    final content = [
      Content.multi([
        TextPart(_billPrompt),
        DataPart('image/jpeg', imageBytes),
      ])
    ];

    // ── Primary attempt ──
    log('OCR: processing with primary model (${AppConstants.primaryModel})',
        tag: 'OcrService');
    final primary = await _primaryModel.generateContent(content);
    final primaryUsage =
        _parseUsage(primary, AppConstants.primaryModel, isPro: false);
    log('OCR primary usage: $primaryUsage', tag: 'OcrService');

    final primaryJson = _extractJson(primary.text ?? '');
    final primaryMap = jsonDecode(primaryJson) as Map<String, dynamic>;
    final confidence =
        (primaryMap['confidence_score'] as num?)?.toDouble() ?? 0.0;

    log('OCR primary confidence: $confidence', tag: 'OcrService');

    // ── Fallback if accuracy too low ──
    if (confidence < AppConstants.accuracyThreshold) {
      log(
        'OCR: confidence $confidence < ${AppConstants.accuracyThreshold}% → '
        'retrying with fallback model (${AppConstants.fallbackModel})',
        tag: 'OcrService',
      );
      final fallback = await _fallbackModel.generateContent(content);
      final fallbackUsage =
          _parseUsage(fallback, AppConstants.fallbackModel, isPro: true);
      log('OCR fallback usage: $fallbackUsage', tag: 'OcrService');

      final fallbackJson = _extractJson(fallback.text ?? '');
      final fallbackMap = jsonDecode(fallbackJson) as Map<String, dynamic>;
      return OcrResult(
        data: ScannedBill.fromJson(fallbackMap),
        usage: fallbackUsage,
      );
    }

    return OcrResult(
      data: ScannedBill.fromJson(primaryMap),
      usage: primaryUsage,
    );
  }

  // ─────────────────────────────────────────────────────────────
  // Mode B — Extract shop template from blank receipt
  // ─────────────────────────────────────────────────────────────

  static const _templatePrompt = '''
Analyze the provided image of a blank/empty Indian shop receipt, invoice pad, or letterhead.
Extract ONLY the pre-printed shop/business details (not any customer-filled rows).
Return ONLY valid JSON (no markdown, no explanation):

{
  "shop_name": "English name; original in brackets if non-English e.g. 'Ganesh Stores (गणेश स्टोर्स)'",
  "shop_address": "string or null — translate to English, keep original in brackets",
  "shop_phone": "string or null — may be multiple numbers, separate with comma",
  "shop_gst_number": "string or null — format: 2 digits + 10-char PAN + 1Z + 2 chars",
  "shop_email": "string or null",
  "confidence_score": number (0–100)
}

Notes:
  - The image may be in English, Hindi (Devanagari), Marathi, or a mixed script.
  - Translate all extracted text to English; append original in parentheses if non-English.
  - Dates, quantities, and customer-filled rows must be IGNORED — shop header only.
  - GST label variants: GSTIN, GST No., GST Number, जीएसटी क्र.
  - Phone label variants: Ph., Mob., Mobile, दूरध्वनी, संपर्क
  - confidence_score: 100 = every detail perfectly readable, 0 = completely unreadable.
''';

  static Future<OcrResult<ShopTemplate>> extractShopTemplate(
      File imageFile) async {
    // 1. Compress image
    final compressedFile = await _compressImage(imageFile);
    final imageBytes = await compressedFile.readAsBytes();

    final content = [
      Content.multi([
        TextPart(_templatePrompt),
        DataPart('image/jpeg', imageBytes),
      ])
    ];

    log('OCR: processing shop template with primary model', tag: 'OcrService');
    final primary = await _primaryModel.generateContent(content);
    final usage = _parseUsage(primary, AppConstants.primaryModel, isPro: false);
    log('OCR template usage: $usage', tag: 'OcrService');

    final jsonStr = _extractJson(primary.text ?? '');
    final map = jsonDecode(jsonStr) as Map<String, dynamic>;

    final confidence = (map['confidence_score'] as num?)?.toDouble() ?? 0.0;

    if (confidence < AppConstants.accuracyThreshold) {
      log(
        'OCR template: confidence $confidence < threshold → using fallback model',
        tag: 'OcrService',
      );
      final fallback = await _fallbackModel.generateContent(content);
      final fallbackUsage =
          _parseUsage(fallback, AppConstants.fallbackModel, isPro: true);
      final fallbackJson = _extractJson(fallback.text ?? '');
      final fallbackMap = jsonDecode(fallbackJson) as Map<String, dynamic>;
      return OcrResult(
          data: ShopTemplate.fromJson(fallbackMap), usage: fallbackUsage);
    }

    return OcrResult(data: ShopTemplate.fromJson(map), usage: usage);
  }

  // ─────────────────────────────────────────────────────────────
  // Helpers
  // ─────────────────────────────────────────────────────────────

  // No longer used since switching to Sarvam + Gemini (Text-only)
  // static Future<Uint8List> _prepareImage(File imageFile) ...
  // static List<Content> _buildContent(String prompt, Uint8List bytes) ...

  /// Parse token counts from the response and calculate INR cost.
  static OcrUsage _parseUsage(
    GenerateContentResponse response,
    String modelName, {
    required bool isPro,
  }) {
    final meta = response.usageMetadata;
    // TODO: Update INR multiplier for Gemini 3 Flash and Gemini 3.1 Pro pricing tables.
    final inputTokens = meta?.promptTokenCount ?? 0;
    final outputTokens = meta?.candidatesTokenCount ?? 0;

    final inputPrice = isPro
        ? AppConstants.proInputPricePer1M
        : AppConstants.flashInputPricePer1M;
    final outputPrice = isPro
        ? AppConstants.proOutputPricePer1M
        : AppConstants.flashOutputPricePer1M;

    final costInr =
        (inputTokens * inputPrice + outputTokens * outputPrice) / 1000000;

    return OcrUsage(
      modelUsed: modelName,
      inputTokens: inputTokens,
      outputTokens: outputTokens,
      costInr: costInr,
      usedFallback: isPro,
    );
  }

  /// Strips markdown code fences if Gemini wraps the JSON in them.
  static String _extractJson(String raw) {
    final trimmed = raw.trim();
    if (trimmed.startsWith('```')) {
      final start = trimmed.indexOf('{');
      final end = trimmed.lastIndexOf('}');
      if (start != -1 && end != -1) return trimmed.substring(start, end + 1);
    }
    final start = trimmed.indexOf('{');
    final end = trimmed.lastIndexOf('}');
    if (start != -1 && end != -1) return trimmed.substring(start, end + 1);
    return trimmed;
  }
}
