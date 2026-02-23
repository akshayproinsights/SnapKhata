// lib/features/billing/presentation/screens/scan_screen.dart
import 'dart:io';
import 'dart:ui';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/utils/logger.dart';
import '../../data/services/ocr_service.dart';
import '../providers/scan_provider.dart';

class ScanScreen extends ConsumerStatefulWidget {
  const ScanScreen({super.key});

  @override
  ConsumerState<ScanScreen> createState() => _ScanScreenState();
}

class _ScanScreenState extends ConsumerState<ScanScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  bool _flashOn = false;
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
    _pulseAnimation = Tween<double>(begin: 0.97, end: 1.03).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  // ── Capture ─────────────────────────────────────────────────
  Future<void> _capture(CameraController cam) async {
    if (_isProcessing) return;
    try {
      HapticFeedback.mediumImpact();
      final xFile = await cam.takePicture();
      await _process(File(xFile.path));
    } catch (e) {
      _showError('Capture failed: $e');
    }
  }

  Future<void> _pickGallery() async {
    if (_isProcessing) return;
    final picked = await ImagePicker()
        .pickImage(source: ImageSource.gallery, imageQuality: 80);
    if (picked == null) return;
    await _process(File(picked.path));
  }

  Future<void> _process(File imageFile) async {
    setState(() => _isProcessing = true);
    try {
      // Start OCR and a minimum delay for the loading sequence animation
      final ocrTask = OcrService.extractBill(imageFile);
      // Increased delay to 6s for a more premium, "earned" feel as we cycle through 6 steps
      final minDelay = Future.delayed(const Duration(milliseconds: 6000));

      final results = await Future.wait([ocrTask, minDelay]);
      final ocrResult = results[0];

      if (!mounted) return;
      context.push('/bill-review', extra: {
        'bill': ocrResult.data,
        'imagePath': imageFile.path,
      });
    } catch (e) {
      log('OCR error: $e', tag: 'ScanScreen');
      _showError(
          'Could not read bill.\nPlease make sure the image is clear and try again.');
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  void _showError(String msg) {
    if (!mounted) return;
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Oops!'),
        content: Text(msg),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Retry')),
          TextButton(
              onPressed: () {
                Navigator.pop(context);
                context.pop();
              },
              child: const Text('Go Back')),
        ],
      ),
    );
  }

  // ── Build ────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          _CameraBody(
            onCapture: _capture,
            onGallery: _pickGallery,
            pulseAnimation: _pulseAnimation,
            flashOn: _flashOn,
            onFlashToggle: (cam) async {
              final mode = _flashOn ? FlashMode.off : FlashMode.torch;
              await cam.setFlashMode(mode);
              setState(() => _flashOn = !_flashOn);
            },
          ),

          // Top bar overlay
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_ios_new,
                        color: Colors.white),
                    onPressed: () => context.pop(),
                  ),
                  const Spacer(),
                  const Text(
                    '📄  Scan Filled Bill',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 17,
                        fontWeight: FontWeight.w600),
                  ),
                  const Spacer(),
                  const SizedBox(width: 48),
                ],
              ),
            ),
          ),

          // Processing overlay
          if (_isProcessing) _buildLoadingOverlay(),
        ],
      ),
    );
  }

  Widget _buildLoadingOverlay() => const _LoadingOverlay();
}

// ─────────────────────────────────────────────────────────────
// Animated loading overlay — cycles friendly SMB step hints
// ─────────────────────────────────────────────────────────────

class _LoadingOverlay extends StatefulWidget {
  const _LoadingOverlay();

  @override
  State<_LoadingOverlay> createState() => _LoadingOverlayState();
}

class _LoadingOverlayState extends State<_LoadingOverlay>
    with SingleTickerProviderStateMixin {
  static const _steps = [
    (title: 'Reading Customer Name', sub: '📋 Identifying customer details...'),
    (title: 'Scanning Items', sub: '🛍️ Picking up each item on the bill...'),
    (title: 'Matching Prices', sub: '💰 Verifying rates & quantities...'),
    (title: 'Calculating Totals', sub: '🧮 Adding up discounts...'),
    (title: 'Checking Payment', sub: '💳 Detecting paid / unpaid status...'),
    (title: 'Creating Invoice', sub: '✨ Preparing your smart order!'),
  ];

  int _index = 0;
  late final AnimationController _progressController;
  late final dynamic _stepSub;

  @override
  void initState() {
    super.initState();
    _progressController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 6000),
    )..forward();

    _stepSub =
        Stream.periodic(const Duration(milliseconds: 1100)).listen((_) {
      if (mounted) {
        setState(() {
          if (_index < _steps.length - 1) {
            _index++;
          }
        });
      }
    });
  }

  @override
  void dispose() {
    _stepSub.cancel();
    _progressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final current = _steps[_index];
    final progress = (_index + 1) / _steps.length;

    return Container(
      color: Colors.black.withOpacity(0.7),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Column(
          children: [
            const Spacer(flex: 3),
            // Premium Progress Indicator with Glow
            Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF0066FF).withOpacity(0.3),
                    blurRadius: 30,
                    spreadRadius: 10,
                  ),
                ],
              ),
              child: const SizedBox(
                width: 64,
                height: 64,
                child: CircularProgressIndicator(
                  color: Color(0xFF0066FF),
                  strokeWidth: 5,
                  strokeCap: StrokeCap.round,
                ),
              ),
            ),
            const SizedBox(height: 48),
            // Title transition
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 600),
              child: Text(
                current.title,
                key: ValueKey('title_$_index'),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.2,
                ),
              ),
            ),
            const SizedBox(height: 12),
            // Subtitle transition
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 600),
              transitionBuilder: (child, animation) => FadeTransition(
                opacity: animation,
                child: SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(0, 0.1),
                    end: Offset.zero,
                  ).animate(CurvedAnimation(
                    parent: animation,
                    curve: Curves.easeOutCubic,
                  )),
                  child: child,
                ),
              ),
              child: Text(
                current.sub,
                key: ValueKey('sub_$_index'),
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.6),
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                  letterSpacing: 0.1,
                ),
              ),
            ),
            const Spacer(flex: 2),
            // ── Step counter ──
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Step ${_index + 1} of ${_steps.length}',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.5),
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    '${(progress * 100).toInt()}%',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.5),
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            // ── Smooth progress bar ──
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: AnimatedBuilder(
                animation: _progressController,
                builder: (_, __) {
                  // Blend step-based progress with time-based for smoothness
                  final timeProgress = _progressController.value;
                  final stepProgress = progress;
                  final blended = (timeProgress * 0.4 + stepProgress * 0.6)
                      .clamp(0.0, 1.0);
                  return ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: blended,
                      minHeight: 6,
                      backgroundColor: Colors.white.withOpacity(0.1),
                      valueColor: const AlwaysStoppedAnimation<Color>(
                        Color(0xFF0066FF),
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 48),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Camera body widget
// ─────────────────────────────────────────────────────────────

class _CameraBody extends ConsumerWidget {
  final Future<void> Function(CameraController) onCapture;
  final VoidCallback onGallery;
  final Animation<double> pulseAnimation;
  final bool flashOn;
  final Future<void> Function(CameraController) onFlashToggle;

  const _CameraBody({
    required this.onCapture,
    required this.onGallery,
    required this.pulseAnimation,
    required this.flashOn,
    required this.onFlashToggle,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final camAsync = ref.watch(cameraControllerProvider);
    return camAsync.when(
      loading: () => const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(color: Color(0xFF0066FF)),
            SizedBox(height: 16),
            Text('Starting camera...', style: TextStyle(color: Colors.white70)),
          ],
        ),
      ),
      error: (e, _) => Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Text('Camera unavailable: $e',
              style: const TextStyle(color: Colors.white70),
              textAlign: TextAlign.center),
        ),
      ),
      data: (controller) => Stack(
        fit: StackFit.expand,
        children: [
          CameraPreview(controller),
          _ScanOverlay(pulseAnimation: pulseAnimation),
          Align(
            alignment: Alignment.bottomCenter,
            child: _BottomControls(
              controller: controller,
              onCapture: onCapture,
              onGallery: onGallery,
              flashOn: flashOn,
              onFlashToggle: onFlashToggle,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Scan overlay (animated corner frame + hint text)
// ─────────────────────────────────────────────────────────────

class _ScanOverlay extends StatelessWidget {
  final Animation<double> pulseAnimation;

  const _ScanOverlay({required this.pulseAnimation});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        AnimatedBuilder(
          animation: pulseAnimation,
          builder: (_, __) => CustomPaint(
            painter: _FramePainter(scale: pulseAnimation.value),
            size: Size.infinite,
          ),
        ),
        Align(
          alignment: const Alignment(0, 0.55),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFF0066FF).withOpacity(0.85),
              borderRadius: BorderRadius.circular(24),
            ),
            child: const Text(
              'Place the bill inside the frame',
              style: TextStyle(color: Colors.white, fontSize: 13),
            ),
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Bottom controls
// ─────────────────────────────────────────────────────────────

class _BottomControls extends StatelessWidget {
  final CameraController controller;
  final Future<void> Function(CameraController) onCapture;
  final VoidCallback onGallery;
  final bool flashOn;
  final Future<void> Function(CameraController) onFlashToggle;

  const _BottomControls({
    required this.controller,
    required this.onCapture,
    required this.onGallery,
    required this.flashOn,
    required this.onFlashToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(40, 20, 40, 52),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.bottomCenter,
          end: Alignment.topCenter,
          colors: [Colors.black.withOpacity(0.85), Colors.transparent],
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Gallery
          _CircleBtn(
            icon: Icons.photo_library_outlined,
            onTap: onGallery,
            tooltip: 'Gallery',
          ),

          // Capture button
          GestureDetector(
            onTap: () => onCapture(controller),
            child: Container(
              width: 76,
              height: 76,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white,
                border: Border.all(color: const Color(0xFF0066FF), width: 4),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF0066FF).withOpacity(0.45),
                    blurRadius: 20,
                    spreadRadius: 4,
                  ),
                ],
              ),
              child: const Icon(Icons.camera_alt_rounded,
                  color: Color(0xFF0066FF), size: 34),
            ),
          ),

          // Flash toggle
          _CircleBtn(
            icon: flashOn ? Icons.flash_on_rounded : Icons.flash_off_rounded,
            iconColor: flashOn ? Colors.yellow : Colors.white,
            onTap: () => onFlashToggle(controller),
            tooltip: 'Flash',
          ),
        ],
      ),
    );
  }
}

class _CircleBtn extends StatelessWidget {
  final IconData icon;
  final Color? iconColor;
  final VoidCallback onTap;
  final String tooltip;

  const _CircleBtn({
    required this.icon,
    this.iconColor,
    required this.onTap,
    required this.tooltip,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: 52,
          height: 52,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.15),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: iconColor ?? Colors.white, size: 26),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Frame painter
// ─────────────────────────────────────────────────────────────

class _FramePainter extends CustomPainter {
  final double scale;
  _FramePainter({required this.scale});

  @override
  void paint(Canvas canvas, Size size) {
    const cl = 36.0; // corner length
    const sw = 3.5; // stroke width
    const frameColor = Color(0xFF0066FF);

    final fw = size.width * 0.82 * scale;
    final fh = size.height * 0.52 * scale;
    final l = (size.width - fw) / 2;
    final t = (size.height - fh) / 2;
    final r = l + fw;
    final b = t + fh;

    // Dim overlay outside frame
    final dim = Paint()..color = Colors.black.withOpacity(0.42);
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, t), dim);
    canvas.drawRect(Rect.fromLTWH(0, b, size.width, size.height - b), dim);
    canvas.drawRect(Rect.fromLTWH(0, t, l, fh), dim);
    canvas.drawRect(Rect.fromLTWH(r, t, size.width - r, fh), dim);

    final p = Paint()
      ..color = frameColor
      ..strokeWidth = sw
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    // TL
    canvas.drawLine(Offset(l, t + cl), Offset(l, t), p);
    canvas.drawLine(Offset(l, t), Offset(l + cl, t), p);
    // TR
    canvas.drawLine(Offset(r - cl, t), Offset(r, t), p);
    canvas.drawLine(Offset(r, t), Offset(r, t + cl), p);
    // BL
    canvas.drawLine(Offset(l, b - cl), Offset(l, b), p);
    canvas.drawLine(Offset(l, b), Offset(l + cl, b), p);
    // BR
    canvas.drawLine(Offset(r - cl, b), Offset(r, b), p);
    canvas.drawLine(Offset(r, b), Offset(r, b - cl), p);
  }

  @override
  bool shouldRepaint(_FramePainter old) => old.scale != scale;
}
