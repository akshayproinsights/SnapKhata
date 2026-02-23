// lib/core/utils/image_utils.dart
import 'dart:io';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'logger.dart';

/// Compresses a camera image from ~5MB down to ~300KB before upload.
/// Keeps Gemini token usage and Supabase storage costs minimal.
class ImageUtils {
  ImageUtils._();

  /// Compress [sourceFile] and return the compressed [File].
  /// Returns null if compression fails.
  static Future<File?> compressForUpload(File sourceFile) async {
    try {
      final dir = await getTemporaryDirectory();
      final targetPath = p.join(
        dir.path,
        '${DateTime.now().millisecondsSinceEpoch}_compressed.jpg',
      );

      final result = await FlutterImageCompress.compressAndGetFile(
        sourceFile.absolute.path,
        targetPath,
        quality: 70,       // good balance: quality vs size
        minWidth: 1080,
        minHeight: 1080,
        format: CompressFormat.jpeg,
      );

      if (result == null) return null;

      final compressed = File(result.path);
      log(
        'Compressed: ${_kb(sourceFile)} KB → ${_kb(compressed)} KB',
        tag: 'ImageUtils',
      );
      return compressed;
    } catch (e) {
      log('Compression failed: $e', tag: 'ImageUtils');
      return null;
    }
  }

  static String _kb(File f) =>
      (f.lengthSync() / 1024).toStringAsFixed(1);
}
