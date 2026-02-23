// lib/features/billing/presentation/providers/scan_provider.dart
import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/scanned_bill.dart';
import '../../data/services/ocr_service.dart';
import '../../../../core/utils/logger.dart';

// ─────────────────────────────────────────────────
// Camera providers
// ─────────────────────────────────────────────────

/// Available cameras on the device.
final availableCamerasProvider = FutureProvider<List<CameraDescription>>((ref) {
  return availableCameras();
});

/// The active camera controller — initialized lazily.
final cameraControllerProvider =
    FutureProvider.autoDispose<CameraController>((ref) async {
  final cameras = await ref.watch(availableCamerasProvider.future);
  if (cameras.isEmpty) throw Exception('No cameras available');

  final camera = cameras.first; // default back camera
  final controller = CameraController(
    camera,
    ResolutionPreset.high,
    enableAudio: false,
    imageFormatGroup: ImageFormatGroup.jpeg,
  );

  ref.onDispose(() => controller.dispose());

  await controller.initialize();
  return controller;
});

// ─────────────────────────────────────────────────
// OCR state
// ─────────────────────────────────────────────────

enum OcrStatus { idle, loading, success, error }

class OcrState {
  final OcrStatus status;
  final ScannedBill? result;
  final OcrUsage? usage;
  final String? errorMessage;

  const OcrState({
    this.status = OcrStatus.idle,
    this.result,
    this.usage,
    this.errorMessage,
  });

  OcrState copyWith({
    OcrStatus? status,
    ScannedBill? result,
    OcrUsage? usage,
    String? errorMessage,
  }) {
    return OcrState(
      status: status ?? this.status,
      result: result ?? this.result,
      usage: usage ?? this.usage,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

class OcrNotifier extends AutoDisposeNotifier<OcrState> {
  @override
  OcrState build() => const OcrState();

  Future<ScannedBill?> extractBill(File imageFile) async {
    state = const OcrState(status: OcrStatus.loading);
    try {
      final ocrResult = await OcrService.extractBill(imageFile);
      log('OCR complete: ${ocrResult.usage}', tag: 'OcrNotifier');
      state = OcrState(
        status: OcrStatus.success,
        result: ocrResult.data,
        usage: ocrResult.usage,
      );
      return ocrResult.data;
    } catch (e) {
      state = OcrState(
        status: OcrStatus.error,
        errorMessage: 'Could not read bill. Please try again.\n($e)',
      );
      return null;
    }
  }

  void reset() => state = const OcrState();
}

final ocrNotifierProvider =
    AutoDisposeNotifierProvider<OcrNotifier, OcrState>(OcrNotifier.new);
