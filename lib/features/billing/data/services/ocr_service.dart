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

const _systemInstruction =
    '''You are BillBot, an AI expert extracting data from Indian SMB bills.

Rules:
- Language: All output values must be strictly in English. If the original text is Hindi or Marathi, output as: English Translation (Original Text). Example: Wheat Flour (गव्हाचे पीठ). If original is English, output as-is without brackets.
- Dates: Assume input dates are DD-MM-YY or DD-MM-YYYY. Convert and output strictly as YYYY-MM-DD. Example: 20/02/26 becomes 2026-02-20.
- Output: Return ONLY raw, valid JSON. Do not include markdown formatting, json tags, or explanations. 100% accuracy required.''';

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
      temperature: 0.2,
      responseMimeType: 'application/json',
      maxOutputTokens: 4096,
    ),
  );

  // FALLBACK model: higher accuracy (gemini-2.5-pro)
  static final _fallbackModel = GenerativeModel(
    model: AppConstants.fallbackModel,
    apiKey: AppConstants.geminiApiKey,
    systemInstruction: Content.system(_systemInstruction),
    generationConfig: GenerationConfig(
      temperature: 0.2,
      responseMimeType: 'application/json',
      maxOutputTokens: 4096,
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
        quality: 40,
        minWidth: 640,
        minHeight: 640,
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
Return valid JSON representing this bill. Capture EVERY item.
{
  "customer_name": "English name (original in brackets if non-English)",
  "customer_phone": "10 digits or null",
  "invoice_id": "string or null",
  "date": "YYYY-MM-DD or null",
  "items": [{"name": "English (original if non-English)", "quantity": number, "unit_price": number, "total_price": number}],
  "subtotal": number, "discount": number, "gst_amount": number, "gst_percent": number,
  "total_amount": number, "amount_paid": number, "amount_remaining": number,
  "payment_status": "paid|partial|unpaid",
  "confidence_score": number (0.0 to 1.0, default to 0.95 if mostly readable)
}
Rules: Keep English as is. Translate non-English to English & append original in brackets. Derive prices if missing.
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
    log('OCR: starting primary model generation for ${AppConstants.primaryModel}',
        tag: 'OcrService');
    final stopwatch = Stopwatch()..start();

    try {
      final primary = await _primaryModel.generateContent(content);
      stopwatch.stop();
      log('OCR: primary model responded in ${stopwatch.elapsed.inSeconds}s',
          tag: 'OcrService');

      final primaryUsage =
          _parseUsage(primary, AppConstants.primaryModel, isPro: false);
      log('OCR primary usage: $primaryUsage', tag: 'OcrService');

      final text = primary.text ?? '';
      log('OCR raw text length: ${text.length}', tag: 'OcrService');
      if (text.isEmpty) {
        log('OCR WARNING: Primary model returned empty text!',
            tag: 'OcrService');
      }

      final primaryJson = _extractJson(text);
      log('OCR extracted JSON: $primaryJson', tag: 'OcrService');

      // Validate JSON is complete before parsing
      if (!_isValidJson(primaryJson)) {
        log('OCR ERROR: Primary model returned incomplete/invalid JSON → using fallback',
            tag: 'OcrService');

        // Directly use fallback model for incomplete JSON
        final fallbackStopwatch = Stopwatch()..start();
        final fallback = await _fallbackModel.generateContent(content);
        fallbackStopwatch.stop();
        log('OCR: fallback model responded in ${fallbackStopwatch.elapsed.inSeconds}s',
            tag: 'OcrService');

        final fallbackUsage =
            _parseUsage(fallback, AppConstants.fallbackModel, isPro: true);
        log('OCR fallback usage: $fallbackUsage', tag: 'OcrService');

        final fallbackJson = _extractJson(fallback.text ?? '');

        // Validate fallback JSON as well
        if (!_isValidJson(fallbackJson)) {
          log('OCR ERROR: Fallback model also returned incomplete/invalid JSON',
              tag: 'OcrService');
          throw FormatException('Both models returned incomplete JSON');
        }

        final fallbackMap = jsonDecode(fallbackJson) as Map<String, dynamic>;
        return OcrResult(
          data: ScannedBill.fromJson(fallbackMap),
          usage: fallbackUsage,
        );
      }

      final primaryMap = jsonDecode(primaryJson) as Map<String, dynamic>;
      final confidence =
          (primaryMap['confidence_score'] as num?)?.toDouble() ?? 0.0;

      log('OCR primary confidence: $confidence', tag: 'OcrService');

      // ── Fallback if accuracy too low ──
      if (confidence < AppConstants.accuracyThreshold) {
        log(
          'OCR: confidence $confidence < ${AppConstants.accuracyThreshold} → '
          'retrying with fallback model (${AppConstants.fallbackModel})',
          tag: 'OcrService',
        );
        final fallbackStopwatch = Stopwatch()..start();
        final fallback = await _fallbackModel.generateContent(content);
        fallbackStopwatch.stop();
        log('OCR: fallback model responded in ${fallbackStopwatch.elapsed.inSeconds}s',
            tag: 'OcrService');

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
    } catch (e, stack) {
      log('OCR CRITICAL ERROR: $e', tag: 'OcrService');
      log('OCR STACK TRACE: $stack', tag: 'OcrService');
      rethrow;
    }
  }

  // ─────────────────────────────────────────────────────────────
  // Mode B — Extract shop template from blank receipt
  // ─────────────────────────────────────────────────────────────

  static const _templatePrompt = '''
Extract pre-printed shop details from this empty Indian receipt/pad. IGNORE customer-filled rows. Return ONLY valid JSON:
{
  "shop_name": "English name (original in brackets if non-English)",
  "shop_address": "string or null (translate, keep original in brackets)",
  "shop_phone": "string or null (comma separated if multiple)",
  "shop_gst_number": "string or null",
  "shop_email": "string or null",
  "confidence_score": number (0.0 to 1.0)
}
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
  /// Also attempts to fix common JSON formatting issues.
  static String _extractJson(String raw) {
    final trimmed = raw.trim();
    String jsonStr = trimmed;

    // Remove markdown code fences
    if (jsonStr.startsWith('```')) {
      final start = jsonStr.indexOf('{');
      final end = jsonStr.lastIndexOf('}');
      if (start != -1 && end != -1) {
        jsonStr = jsonStr.substring(start, end + 1);
      }
    } else {
      final start = jsonStr.indexOf('{');
      final end = jsonStr.lastIndexOf('}');
      if (start != -1 && end != -1) {
        jsonStr = jsonStr.substring(start, end + 1);
      }
    }

    // Attempt to fix incomplete JSON by adding missing closing brackets/braces
    return _fixIncompleteJson(jsonStr);
  }

  /// Attempts to fix common incomplete JSON issues
  static String _fixIncompleteJson(String jsonStr) {
    if (jsonStr.isEmpty) return jsonStr;

    final fixed = StringBuffer();
    int openBraces = 0;
    int openBrackets = 0;
    bool inString = false;
    bool escaped = false;

    for (int i = 0; i < jsonStr.length; i++) {
      final char = jsonStr[i];
      fixed.write(char);

      if (escaped) {
        escaped = false;
        continue;
      }

      if (char == '\\' && inString) {
        escaped = true;
        continue;
      }

      if (char == '"') {
        inString = !inString;
        continue;
      }

      if (!inString) {
        if (char == '{') openBraces++;
        if (char == '}') openBraces--;
        if (char == '[') openBrackets++;
        if (char == ']') openBrackets--;
      }
    }

    // Add missing closing brackets and braces
    while (openBrackets > 0) {
      fixed.write(']');
      openBrackets--;
    }
    while (openBraces > 0) {
      fixed.write('}');
      openBraces--;
    }

    return fixed.toString();
  }

  /// Validates that extracted JSON is syntactically complete.
  static bool _isValidJson(String jsonStr) {
    if (jsonStr.isEmpty) return false;

    try {
      jsonDecode(jsonStr);
      return true;
    } catch (e) {
      log('OCR JSON validation failed: $e', tag: 'OcrService');
      return false;
    }
  }
}
