import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

// ─────────────────────────────────────────────
//  SHARED COLOR PALETTE
// ─────────────────────────────────────────────
class _C {
  static const darkGreen = Color(0xFF1A2820);
  static const lightGreen = Color(0xFF5A8A6E);
  static const golden = Color(0xFF9D7E3F);
  static const cream = Color(0xFFD4C9A8);
  static const border = Color(0xFFB8A97A);
}

// ─────────────────────────────────────────────
//  DETECTION RESULT MODEL
// ─────────────────────────────────────────────
class DetectionResult {
  final String riceName;
  final String quality; // e.g. "Premium", "Standard", "Low"
  final double qualityScore; // 0.0 – 1.0
  final String priceRange;
  final String description;
  final List<String> characteristics;
  final Map<String, String> nutrition;

  const DetectionResult({
    required this.riceName,
    required this.quality,
    required this.qualityScore,
    required this.priceRange,
    required this.description,
    required this.characteristics,
    required this.nutrition,
  });
}

// Demo result (replace with real AI call)
const _demoResult = DetectionResult(
  riceName: 'Basmati Rice',
  quality: 'Premium',
  qualityScore: 0.91,
  priceRange: 'Rs 280–320/kg',
  description:
      'Long-grain aromatic rice with a distinctive fragrance. '
      'Grains are slender, aged, and cook to a fluffy, non-sticky texture.',
  characteristics: [
    'Long, slender grains',
    'Strong natural aroma',
    'Non-sticky when cooked',
    'Low moisture content',
    'Uniform color & size',
  ],
  nutrition: {
    'Calories': '210 per cup',
    'Protein': '4.4 per cup',
    'Carbohydrates': '46g per cup',
    'Fiber': '0.6g per cup',
  },
);

// ─────────────────────────────────────────────
//  AI DETECTION SCREEN
// ─────────────────────────────────────────────
class AiDetectionScreen extends StatefulWidget {
  const AiDetectionScreen({Key? key}) : super(key: key);

  @override
  State<AiDetectionScreen> createState() => _AiDetectionScreenState();
}

class _AiDetectionScreenState extends State<AiDetectionScreen>
    with SingleTickerProviderStateMixin {
  File? _image;
  bool _analyzing = false;
  bool _analyzed = false;
  DetectionResult? _result;

  late final AnimationController _pulseCtrl;
  late final Animation<double> _pulse;

  @override
  void initState() {
    super.initState();
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);
    _pulse = Tween(
      begin: 0.92,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _pulseCtrl.dispose();
    super.dispose();
  }

  // ── pick image ────────────────────────────
  Future<void> _pick(ImageSource source) async {
    final picked = await ImagePicker().pickImage(
      source: source,
      imageQuality: 88,
    );
    if (picked == null) return;
    setState(() {
      _image = File(picked.path);
      _analyzed = false;
      _result = null;
    });
    _analyze();
  }

  // ── simulate AI call ──────────────────────
  Future<void> _analyze() async {
    setState(() => _analyzing = true);
    await Future.delayed(const Duration(seconds: 3));
    setState(() {
      _analyzing = false;
      _analyzed = true;
      _result = _demoResult;
    });
  }

  void _reset() => setState(() {
    _image = null;
    _analyzed = false;
    _result = null;
  });

  // ─── helpers ──────────────────────────────
  Color _qualityColor(String q) {
    switch (q.toLowerCase()) {
      case 'premium':
        return const Color(0xFF2E7D32);
      case 'standard':
        return _C.golden;
      default:
        return const Color(0xFFC62828);
    }
  }

  Widget _sectionCard({required Widget child, EdgeInsets? padding}) =>
      Container(
        width: double.infinity,
        margin: const EdgeInsets.symmetric(horizontal: 18, vertical: 7),
        padding: padding ?? const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: _C.cream.withOpacity(0.22),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: _C.border.withOpacity(0.45)),
          boxShadow: [
            BoxShadow(
              color: _C.darkGreen.withOpacity(0.07),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: child,
      );

  Widget _sectionTitle(String title, IconData icon) => Row(
    children: [
      Icon(icon, size: 17, color: _C.golden),
      const SizedBox(width: 8),
      Text(
        title,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: _C.darkGreen,
          letterSpacing: 0.2,
        ),
      ),
    ],
  );

  // ─────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final sw = MediaQuery.of(context).size.width;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [_C.lightGreen, _C.golden],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // ── Top bar ───────────────────
              Padding(
                padding: const EdgeInsets.fromLTRB(14, 10, 18, 0),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () => Get.back(),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.arrow_back_ios,
                            size: 16,
                            color: _C.darkGreen,
                          ),
                          Text(
                            'Back to Home',
                            style: TextStyle(
                              fontSize: 13.5,
                              color: _C.darkGreen.withOpacity(0.85),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Spacer(),
                    if (_analyzed)
                      GestureDetector(
                        onTap: _reset,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: _C.cream.withOpacity(0.30),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: _C.border.withOpacity(0.5),
                            ),
                          ),
                          child: const Row(
                            children: [
                              Icon(
                                Icons.refresh,
                                size: 14,
                                color: _C.darkGreen,
                              ),
                              SizedBox(width: 4),
                              Text(
                                'Retry',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: _C.darkGreen,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              ),

              // ── Title ─────────────────────
              Padding(
                padding: const EdgeInsets.fromLTRB(18, 10, 18, 4),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'AI Detection & Suggestion',
                        style: TextStyle(
                          fontSize: 19,
                          fontWeight: FontWeight.bold,
                          color: _C.darkGreen,
                          letterSpacing: 0.2,
                        ),
                      ),
                      Text(
                        'Analyze rice quality using AI technology',
                        style: TextStyle(
                          fontSize: 12.5,
                          color: _C.darkGreen.withOpacity(0.65),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // ── Scrollable body ───────────
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.only(bottom: 28),
                  child: Column(
                    children: [
                      const SizedBox(height: 8),

                      // ── Upload / Preview card ──
                      _sectionCard(
                        child: _image == null
                            ? _uploadPlaceholder(sw)
                            : _imagePreview(sw),
                      ),

                      // ── Analyzing indicator ────
                      if (_analyzing) ...[
                        const SizedBox(height: 8),
                        _sectionCard(
                          child: Column(
                            children: [
                              ScaleTransition(
                                scale: _pulse,
                                child: Container(
                                  width: 56,
                                  height: 56,
                                  decoration: BoxDecoration(
                                    color: _C.lightGreen.withOpacity(0.3),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Center(
                                    child: CircularProgressIndicator(
                                      color: _C.golden,
                                      strokeWidth: 3,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 14),
                              const Text(
                                'Analyzing rice quality...',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: _C.darkGreen,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Please wait a moment',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: _C.darkGreen.withOpacity(0.6),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],

                      // ── Results ────────────────
                      if (_analyzed && _result != null) ...[
                        _buildResultCards(_result!),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Upload placeholder ─────────────────────
  Widget _uploadPlaceholder(double sw) => Column(
    children: [
      Container(
        width: sw * 0.3,
        height: sw * 0.3,
        decoration: BoxDecoration(
          color: _C.lightGreen.withOpacity(0.25),
          shape: BoxShape.circle,
          border: Border.all(color: _C.border.withOpacity(0.4), width: 2),
        ),
        child: Icon(
          Icons.camera_alt_outlined,
          size: sw * 0.12,
          color: _C.darkGreen.withOpacity(0.55),
        ),
      ),
      const SizedBox(height: 16),
      Text(
        'Capture or Upload Rice Image',
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: _C.darkGreen.withOpacity(0.75),
        ),
      ),
      const SizedBox(height: 16),
      _actionBtn(
        icon: Icons.camera_alt_outlined,
        label: 'Use Camera',
        onTap: () => _pick(ImageSource.camera),
      ),
      const SizedBox(height: 10),
      _actionBtn(
        icon: Icons.upload_outlined,
        label: 'Upload from Gallery',
        onTap: () => _pick(ImageSource.gallery),
      ),
    ],
  );

  // ── Image preview with action buttons ──────
  Widget _imagePreview(double sw) => Column(
    children: [
      ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Image.file(
          _image!,
          height: sw * 0.55,
          width: double.infinity,
          fit: BoxFit.cover,
        ),
      ),
      if (!_analyzing && !_analyzed) ...[
        const SizedBox(height: 14),
        _actionBtn(
          icon: Icons.auto_awesome,
          label: 'Analyze Now',
          onTap: _analyze,
          filled: true,
        ),
        const SizedBox(height: 8),
        _actionBtn(
          icon: Icons.swap_horiz,
          label: 'Choose Different Image',
          onTap: () => _pick(ImageSource.gallery),
        ),
      ],
    ],
  );

  // ── Reusable button ───────────────────────
  Widget _actionBtn({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    bool filled = false,
  }) => GestureDetector(
    onTap: onTap,
    child: Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 13),
      decoration: BoxDecoration(
        gradient: filled
            ? const LinearGradient(colors: [_C.lightGreen, _C.golden])
            : null,
        color: filled ? null : _C.cream.withOpacity(0.30),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: filled ? Colors.transparent : _C.border.withOpacity(0.5),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 18, color: filled ? Colors.white : _C.darkGreen),
          const SizedBox(width: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: filled ? Colors.white : _C.darkGreen,
            ),
          ),
        ],
      ),
    ),
  );

  // ── Result cards ──────────────────────────
  Widget _buildResultCards(DetectionResult r) {
    final qColor = _qualityColor(r.quality);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Rice name + quality banner ─────
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 18, vertical: 7),
          decoration: BoxDecoration(
            color: _C.cream.withOpacity(0.22),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: _C.border.withOpacity(0.45)),
          ),
          child: Column(
            children: [
              // Header strip
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
                decoration: BoxDecoration(
                  color: _C.darkGreen.withOpacity(0.12),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(16),
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.grain, size: 20, color: _C.golden),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        r.riceName,
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                          color: _C.darkGreen,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: qColor.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: qColor.withOpacity(0.4)),
                      ),
                      child: Text(
                        r.quality,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: qColor,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // Quality score bar
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Quality Score',
                          style: TextStyle(
                            fontSize: 12.5,
                            color: _C.darkGreen.withOpacity(0.7),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Text(
                          '${(r.qualityScore * 100).toStringAsFixed(0)}%',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: qColor,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: LinearProgressIndicator(
                        value: r.qualityScore,
                        minHeight: 8,
                        backgroundColor: _C.cream.withOpacity(0.5),
                        valueColor: AlwaysStoppedAnimation(qColor),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        const Icon(
                          Icons.attach_money,
                          size: 16,
                          color: _C.golden,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          r.priceRange,
                          style: const TextStyle(
                            fontSize: 13.5,
                            fontWeight: FontWeight.w600,
                            color: _C.darkGreen,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        // ── Description ────────────────────
        _sectionCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _sectionTitle('About This Rice', Icons.info_outline),
              const SizedBox(height: 10),
              Text(
                r.description,
                style: TextStyle(
                  fontSize: 13.5,
                  color: _C.darkGreen.withOpacity(0.8),
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),

        // ── Characteristics ────────────────
        _sectionCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _sectionTitle('Characteristics', Icons.checklist_outlined),
              const SizedBox(height: 10),
              ...r.characteristics.map(
                (c) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.check_circle,
                        size: 16,
                        color: Color(0xFF2E7D32),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          c,
                          style: TextStyle(
                            fontSize: 13.5,
                            color: _C.darkGreen.withOpacity(0.85),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),

        // ── Nutrition ──────────────────────
        _sectionCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _sectionTitle(
                'Nutritional Information',
                Icons.restaurant_outlined,
              ),
              const SizedBox(height: 12),
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                mainAxisSpacing: 10,
                crossAxisSpacing: 10,
                childAspectRatio: 2.4,
                children: r.nutrition.entries.map((e) {
                  return Container(
                    decoration: BoxDecoration(
                      color: _C.cream.withOpacity(0.30),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: _C.border.withOpacity(0.35)),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          e.key,
                          style: TextStyle(
                            fontSize: 11,
                            color: _C.darkGreen.withOpacity(0.6),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          e.value,
                          style: const TextStyle(
                            fontSize: 13,
                            color: _C.darkGreen,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        ),

        // ── CTA ────────────────────────────
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
          child: GestureDetector(
            onTap: () => Get.back(),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 14),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [_C.lightGreen, _C.golden],
                ),
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: _C.golden.withOpacity(0.35),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.home_outlined, size: 18, color: Colors.white),
                  SizedBox(width: 8),
                  Text(
                    'Back to Home',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                      letterSpacing: 0.4,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
