// lib/features/billing/presentation/screens/shop_profile_screen.dart
//
// Shop profile screen — edit shop details that appear on every PDF invoice.
// Includes an "Auto-fill via Receipt Scan" button powered by Gemini OCR.
//
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import '../../data/repositories/shop_profile_repository.dart';
import '../../data/services/ocr_service.dart';
import '../providers/shop_profile_provider.dart';

class ShopProfileScreen extends ConsumerStatefulWidget {
  const ShopProfileScreen({super.key});

  @override
  ConsumerState<ShopProfileScreen> createState() => _ShopProfileScreenState();
}

class _ShopProfileScreenState extends ConsumerState<ShopProfileScreen> {
  late final TextEditingController _nameCtrl;
  late final TextEditingController _addressCtrl;
  late final TextEditingController _phoneCtrl;
  late final TextEditingController _gstCtrl;
  late final TextEditingController _emailCtrl;
  String? _logoPath;
  bool _isSaving = false;
  bool _isScanning = false;

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController();
    _addressCtrl = TextEditingController();
    _phoneCtrl = TextEditingController();
    _gstCtrl = TextEditingController();
    _emailCtrl = TextEditingController();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadExisting());
  }

  Future<void> _loadExisting() async {
    final existing = await ref.read(shopProfileRepositoryProvider).getProfile();
    if (existing != null && mounted) {
      setState(() {
        if (_nameCtrl.text.isEmpty) _nameCtrl.text = existing.shopName;
        if (_addressCtrl.text.isEmpty) {
          _addressCtrl.text = existing.shopAddress ?? '';
        }
        if (_phoneCtrl.text.isEmpty) _phoneCtrl.text = existing.shopPhone ?? '';
        if (_gstCtrl.text.isEmpty) _gstCtrl.text = existing.shopGstNumber ?? '';
        if (_emailCtrl.text.isEmpty) _emailCtrl.text = existing.shopEmail ?? '';
        _logoPath = existing.logoPath;
      });
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _addressCtrl.dispose();
    _phoneCtrl.dispose();
    _gstCtrl.dispose();
    _emailCtrl.dispose();
    super.dispose();
  }

  // ── Auto-fill via OCR ─────────────────────────────────────────
  Future<void> _scanReceiptToAutoFill() async {
    // Let user pick: camera or gallery
    final source = await _pickSourceSheet();
    if (source == null || !mounted) return;

    final picked = await ImagePicker().pickImage(
      source: source,
      imageQuality: 90,
    );
    if (picked == null || !mounted) return;

    setState(() => _isScanning = true);
    try {
      // Start OCR and a minimum delay for the loading sequence animation
      final ocrTask = OcrService.extractShopTemplate(File(picked.path));
      final minDelay = Future.delayed(const Duration(milliseconds: 4000));

      final results = await Future.wait([ocrTask, minDelay]);
      final result = results[0];

      if (!mounted) return;
      final t = result.data;
      setState(() {
        if (t.shopName.isNotEmpty) _nameCtrl.text = t.shopName;
        if (t.shopAddress != null) _addressCtrl.text = t.shopAddress!;
        if (t.shopPhone != null) _phoneCtrl.text = t.shopPhone!;
        if (t.shopGstNumber != null) _gstCtrl.text = t.shopGstNumber!;
        if (t.shopEmail != null) _emailCtrl.text = t.shopEmail!;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✅ Fields auto-filled! Review and save.'),
          backgroundColor: Color(0xFF00875A),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Could not read receipt: $e'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isScanning = false);
    }
  }

  Future<ImageSource?> _pickSourceSheet() async {
    return showModalBottomSheet<ImageSource>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        decoration: BoxDecoration(
          color: Theme.of(ctx).colorScheme.surface,
          borderRadius: BorderRadius.circular(24),
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: Theme.of(ctx).colorScheme.onSurface.withOpacity(0.2),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const Text(
              'Scan Receipt Pad',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              'Pick an image to auto-fill shop details',
              style: TextStyle(
                  fontSize: 13,
                  color: Theme.of(ctx).colorScheme.onSurface.withOpacity(0.55)),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: _SourceBtn(
                    icon: Icons.camera_alt_outlined,
                    label: 'Camera',
                    onTap: () => Navigator.pop(ctx, ImageSource.camera),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _SourceBtn(
                    icon: Icons.photo_library_outlined,
                    label: 'Gallery',
                    onTap: () => Navigator.pop(ctx, ImageSource.gallery),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ── Logo picker ───────────────────────────────────────────────
  Future<void> _pickLogo() async {
    final picked = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      maxWidth: 512,
      maxHeight: 512,
      imageQuality: 85,
    );
    if (picked != null && mounted) {
      setState(() => _logoPath = picked.path);
    }
  }

  // ── Save ──────────────────────────────────────────────────────
  Future<void> _save() async {
    if (_nameCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Shop name is required')),
      );
      return;
    }
    setState(() => _isSaving = true);
    final profile = ShopProfileData(
      shopName: _nameCtrl.text.trim(),
      shopAddress:
          _addressCtrl.text.trim().isEmpty ? null : _addressCtrl.text.trim(),
      shopPhone: _phoneCtrl.text.trim().isEmpty ? null : _phoneCtrl.text.trim(),
      shopGstNumber: _gstCtrl.text.trim().isEmpty
          ? null
          : _gstCtrl.text.trim().toUpperCase(),
      shopEmail: _emailCtrl.text.trim().isEmpty ? null : _emailCtrl.text.trim(),
      logoPath: _logoPath,
    );
    await ref.read(shopProfileProvider.notifier).save(profile);
    setState(() => _isSaving = false);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✅ Shop profile saved!'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      context.pop();
    }
  }

  // ── Build ─────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.background,
      appBar: AppBar(
        title: Text(
          _nameCtrl.text.isNotEmpty
              ? '${_nameCtrl.text} Profile'
              : 'Shop Profile',
        ),
        centerTitle: false,
        elevation: 0,
        actions: [
          TextButton(
            onPressed: _isSaving ? null : _save,
            child: const Text('Save',
                style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
      body: Stack(
        children: [
          ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // ── Header card ─────────────────────────────────────
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF0066FF), Color(0xFF0044CC)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    // Logo picker
                    GestureDetector(
                      onTap: _pickLogo,
                      child: Stack(
                        children: [
                          Container(
                            width: 72,
                            height: 72,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white.withOpacity(0.2),
                              border: Border.all(
                                  color: Colors.white.withOpacity(0.6),
                                  width: 2),
                            ),
                            child: _logoPath != null
                                ? ClipOval(
                                    child: Image.file(File(_logoPath!),
                                        fit: BoxFit.cover))
                                : const Icon(Icons.storefront_rounded,
                                    color: Colors.white, size: 36),
                          ),
                          Positioned(
                            right: 0,
                            bottom: 0,
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: const BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.edit,
                                  size: 14, color: Color(0xFF0066FF)),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Your Business Profile',
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 17,
                                fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'This appears on every PDF Order you send',
                            style: TextStyle(
                                color: Colors.white.withOpacity(0.75),
                                fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // ── OCR Auto-Fill button ─────────────────────────────
              SizedBox(
                width: double.infinity,
                height: 50,
                child: OutlinedButton.icon(
                  onPressed: (_isScanning || _isSaving)
                      ? null
                      : _scanReceiptToAutoFill,
                  icon: const Icon(Icons.document_scanner_outlined, size: 20),
                  label: const Text(
                    'Scan Receipt Pad to Auto-Fill',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                  ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF0066FF),
                    side:
                        const BorderSide(color: Color(0xFF0066FF), width: 1.5),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 6, bottom: 8),
                child: Text(
                  'Take a photo of your blank receipt pad — fields will be auto-filled from the photo',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontSize: 11,
                      color: theme.colorScheme.onSurface.withOpacity(0.5)),
                ),
              ),

              const SizedBox(height: 8),

              // ── Business details ─────────────────────────────────
              _SectionCard(
                title: 'Business Details',
                icon: Icons.storefront_outlined,
                children: [
                  _Field(
                    label: 'Shop / Business Name *',
                    hint: 'e.g. Ganesh Kirana Store',
                    controller: _nameCtrl,
                    icon: Icons.storefront_outlined,
                  ),
                  const SizedBox(height: 14),
                  _Field(
                    label: 'Address',
                    hint: 'Street, City, State, PIN',
                    controller: _addressCtrl,
                    icon: Icons.location_on_outlined,
                    maxLines: 2,
                  ),
                ],
              ),

              const SizedBox(height: 12),

              _SectionCard(
                title: 'Contact & Tax',
                icon: Icons.phone_outlined,
                children: [
                  _Field(
                    label: 'Phone / WhatsApp',
                    hint: '10-digit mobile number',
                    controller: _phoneCtrl,
                    icon: Icons.phone_outlined,
                    keyboard: TextInputType.phone,
                  ),
                  const SizedBox(height: 14),
                  _Field(
                    label: 'Email',
                    hint: 'shop@example.com',
                    controller: _emailCtrl,
                    icon: Icons.email_outlined,
                    keyboard: TextInputType.emailAddress,
                  ),
                  const SizedBox(height: 14),
                  _Field(
                    label: 'GSTIN',
                    hint: '22AAAAA0000A1Z5',
                    controller: _gstCtrl,
                    icon: Icons.receipt_long_outlined,
                    isUpperCase: true,
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 6, left: 4),
                    child: Text(
                      'Required for GST Receipts. Appears on every PDF.',
                      style: TextStyle(
                          fontSize: 11,
                          color: theme.colorScheme.onSurface.withOpacity(0.5)),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 32),

              SizedBox(
                width: double.infinity,
                height: 54,
                child: FilledButton.icon(
                  onPressed: _isSaving ? null : _save,
                  icon: _isSaving
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                              strokeWidth: 2.5, color: Colors.white),
                        )
                      : const Icon(Icons.save_rounded),
                  label: Text(_isSaving ? 'Saving…' : 'Save Shop Profile'),
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFF0066FF),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                    textStyle: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
          // ── Scan overlay ──────────────────────────────────────
          if (_isScanning) const _ShopScanOverlay(),
        ],
      ),
    );
  }
}

// ── Source picker button ──────────────────────────────────────

class _SourceBtn extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _SourceBtn({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      icon: Icon(icon, size: 20),
      label: Text(label),
      onPressed: onTap,
      style: OutlinedButton.styleFrom(
        foregroundColor: const Color(0xFF0066FF),
        side: const BorderSide(color: Color(0xFF0066FF)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        padding: const EdgeInsets.symmetric(vertical: 14),
      ),
    );
  }
}

// ── Reusable section card ─────────────────────────────────────

class _SectionCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final List<Widget> children;

  const _SectionCard({
    required this.title,
    required this.icon,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: const Color(0xFF0066FF)),
              const SizedBox(width: 6),
              Text(title,
                  style: theme.textTheme.labelLarge?.copyWith(
                      color: theme.colorScheme.onSurface.withOpacity(0.55),
                      fontWeight: FontWeight.w600)),
            ],
          ),
          const SizedBox(height: 14),
          ...children,
        ],
      ),
    );
  }
}

// ── Reusable field ────────────────────────────────────────────

class _Field extends StatelessWidget {
  final String label;
  final String? hint;
  final TextEditingController controller;
  final IconData? icon;
  final TextInputType? keyboard;
  final int maxLines;
  final bool isUpperCase;

  const _Field({
    required this.label,
    required this.controller,
    this.hint,
    this.icon,
    this.keyboard,
    this.maxLines = 1,
    this.isUpperCase = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color:
                    Theme.of(context).colorScheme.onSurface.withOpacity(0.7))),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          keyboardType: keyboard,
          maxLines: maxLines,
          textCapitalization: isUpperCase
              ? TextCapitalization.characters
              : TextCapitalization.words,
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: icon != null ? Icon(icon, size: 18) : null,
            filled: true,
            fillColor:
                Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.4),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Animated overlay for shop profile scan — cycles friendly SMB step hints
// ─────────────────────────────────────────────────────────────────────────────

class _ShopScanOverlay extends StatefulWidget {
  const _ShopScanOverlay();

  @override
  State<_ShopScanOverlay> createState() => _ShopScanOverlayState();
}

class _ShopScanOverlayState extends State<_ShopScanOverlay> {
  static const _steps = [
    (title: 'Scanning Shop', sub: '🏪 Finding your shop name...'),
    (title: 'Locating Address', sub: '📍 Reading your address...'),
    (title: 'Contact Details', sub: '📞 Picking up phone number...'),
    (title: 'Tax Information', sub: '🧾 Looking for GST number...'),
    (title: 'Auto-filling', sub: '✅ Almost done — filling in your details!'),
  ];

  int _index = 0;
  late final _timer =
      Stream.periodic(const Duration(milliseconds: 800)).listen((_) {
    if (mounted) {
      setState(() {
        if (_index < _steps.length - 1) {
          _index++;
        }
      });
    }
  });

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final current = _steps[_index];

    return Container(
      color: Colors.black.withOpacity(0.85),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(
              width: 72,
              height: 72,
              child: CircularProgressIndicator(
                color: Color(0xFF0066FF),
                strokeWidth: 4,
              ),
            ),
            const SizedBox(height: 32),
            // Title transition
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 400),
              child: Text(
                current.title,
                key: ValueKey('title_$_index'),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.5,
                ),
              ),
            ),
            const SizedBox(height: 8),
            // Subtitle transition
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 400),
              transitionBuilder: (child, animation) => FadeTransition(
                opacity: animation,
                child: SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(0, 0.2),
                    end: Offset.zero,
                  ).animate(animation),
                  child: child,
                ),
              ),
              child: Text(
                current.sub,
                key: ValueKey('sub_$_index'),
                style: TextStyle(
                  color: Colors.white.withOpacity(0.7),
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
