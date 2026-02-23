// lib/features/billing/data/services/pdf_share_service.dart
import 'dart:io';
import 'package:share_plus/share_plus.dart';

class PdfShareService {
  /// Opens the system share sheet to share or save a PDF file.
  ///
  /// [pdfFile] - The local PDF file to share.
  /// [invoiceNo] - Used as the default filename in the share sheet.
  /// [shopName] - Optional shop name for the share subject.
  static Future<void> shareViaSystem({
    required File pdfFile,
    required String invoiceNo,
    String? shopName,
  }) async {
    final xFile = XFile(
      pdfFile.path,
      name: '$invoiceNo.pdf',
      mimeType: 'application/pdf',
    );

    await Share.shareXFiles(
      [xFile],
      subject:
          'Invoice #$invoiceNo${shopName != null ? ' from $shopName' : ''}',
    );
  }

  /// Opens the system share sheet with one image file (single-page invoice).
  static Future<void> shareImageOnWhatsApp({
    required File imageFile,
    required String invoiceNo,
    required String phone,
    String? caption,
    String? shopName,
    String? customerName,
  }) async {
    await shareImagesOnWhatsApp(
      imageFiles: [imageFile],
      invoiceNo: invoiceNo,
      phone: phone,
      caption: caption,
      shopName: shopName,
      customerName: customerName,
    );
  }

  /// Opens the system share sheet with multiple image files (multi-page invoice).
  /// One image per page — standard format for multi-page invoice sharing.
  static Future<void> shareImagesOnWhatsApp({
    required List<File> imageFiles,
    required String invoiceNo,
    required String phone,
    String? caption,
    String? shopName,
    String? customerName,
  }) async {
    if (imageFiles.isEmpty) return;

    final xFiles = imageFiles.asMap().entries.map((e) {
      final i = e.key;
      final f = e.value;
      final name = imageFiles.length > 1 ? '${invoiceNo}_page_${i + 1}.png' : '$invoiceNo.png';
      return XFile(f.path, name: name, mimeType: 'image/png');
    }).toList();

    await Share.shareXFiles(
      xFiles,
      text: caption,
      subject: 'Invoice #$invoiceNo${shopName != null ? ' from $shopName' : ''}',
    );
  }
}
