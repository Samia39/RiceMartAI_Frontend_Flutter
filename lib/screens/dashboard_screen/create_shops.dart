import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';

// ─────────────────────────────────────────────
//  COLOR PALETTE (same as dashboard)
// ─────────────────────────────────────────────
class _C {
  static const darkGreen = Color(0xFF1A2820);
  static const lightGreen = Color(0xFF5A8A6E);
  static const golden = Color(0xFF9D7E3F);
  static const cream = Color(0xFFD4C9A8);
  static const border = Color(0xFFB8A97A);
}

// ─────────────────────────────────────────────
//  RICE CATEGORY MODEL
// ─────────────────────────────────────────────
class RiceCategory {
  String name;
  String pricePerKg;
  RiceCategory({required this.name, required this.pricePerKg});
}

// ─────────────────────────────────────────────
//  CREATE SHOP SCREEN
// ─────────────────────────────────────────────
class CreateScreen extends StatefulWidget {
  const CreateScreen({Key? key}) : super(key: key);

  @override
  State<CreateScreen> createState() => _CreateScreenState();
}

class _CreateScreenState extends State<CreateScreen> {
  final _formKey = GlobalKey<FormState>();

  // Controllers
  final _cnicCtrl = TextEditingController();
  final _shopNameCtrl = TextEditingController();
  final _ownerNameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _addressCtrl = TextEditingController();
  final _descriptionCtrl = TextEditingController();

  File? _cnicImage;
  final List<RiceCategory> _categories = [];
  bool _submitting = false;

  // ── section card ──────────────────────────
  Widget _sectionCard({required String title, required Widget child}) =>
      Container(
        margin: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
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
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 3,
                    height: 16,
                    decoration: BoxDecoration(
                      color: _C.golden,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: _C.darkGreen,
                      letterSpacing: 0.3,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              child,
            ],
          ),
        ),
      );

  // ── styled text field ─────────────────────
  Widget _field({
    required TextEditingController controller,
    required String label,
    String? hint,
    int maxLines = 1,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
    String? Function(String?)? validator,
  }) => Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: _C.darkGreen.withOpacity(0.75),
            letterSpacing: 0.2,
          ),
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          maxLines: maxLines,
          keyboardType: keyboardType,
          inputFormatters: inputFormatters,
          validator:
              validator ??
              (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
          style: const TextStyle(color: _C.darkGreen, fontSize: 14),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(
              color: _C.darkGreen.withOpacity(0.4),
              fontSize: 13.5,
            ),
            filled: true,
            fillColor: _C.cream.withOpacity(0.25),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 12,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: _C.border.withOpacity(0.5)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: _C.lightGreen, width: 1.5),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Color(0xFFC62828), width: 1),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(
                color: Color(0xFFC62828),
                width: 1.5,
              ),
            ),
          ),
        ),
      ],
    ),
  );

  // ── CNIC image picker ─────────────────────
  Future<void> _pickCnicImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
    );
    if (picked != null) setState(() => _cnicImage = File(picked.path));
  }

  // ── category dialog ───────────────────────
  void _showAddCategoryDialog() {
    final nameCtrl = TextEditingController();
    final priceCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFFF0EBD8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Add Rice Category',
          style: TextStyle(
            color: _C.darkGreen,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _dialogField(
              controller: nameCtrl,
              label: 'Category Name',
              hint: 'e.g. Basmati Rice',
            ),
            const SizedBox(height: 10),
            _dialogField(
              controller: priceCtrl,
              label: 'Price per kg (Rs)',
              hint: 'e.g. 280',
              keyboardType: TextInputType.number,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text(
              'Cancel',
              style: TextStyle(color: _C.darkGreen.withOpacity(0.6)),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              if (nameCtrl.text.trim().isNotEmpty) {
                setState(
                  () => _categories.add(
                    RiceCategory(
                      name: nameCtrl.text.trim(),
                      pricePerKg: priceCtrl.text.trim(),
                    ),
                  ),
                );
                Get.back();
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: _C.golden,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  Widget _dialogField({
    required TextEditingController controller,
    required String label,
    String? hint,
    TextInputType? keyboardType,
  }) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        label,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: _C.darkGreen.withOpacity(0.75),
        ),
      ),
      const SizedBox(height: 5),
      TextField(
        controller: controller,
        keyboardType: keyboardType,
        style: const TextStyle(color: _C.darkGreen, fontSize: 14),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(
            color: _C.darkGreen.withOpacity(0.4),
            fontSize: 13,
          ),
          filled: true,
          fillColor: _C.cream.withOpacity(0.35),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 10,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: _C.border.withOpacity(0.5)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: _C.lightGreen, width: 1.5),
          ),
        ),
      ),
    ],
  );

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _submitting = true);
    await Future.delayed(const Duration(seconds: 2)); // simulate API call
    setState(() => _submitting = false);
    Get.snackbar(
      'Success',
      'Your shop has been created!',
      backgroundColor: _C.lightGreen,
      colorText: Colors.white,
      icon: const Icon(Icons.check_circle, color: Colors.white),
      snackPosition: SnackPosition.BOTTOM,
      margin: const EdgeInsets.all(16),
    );
  }

  @override
  void dispose() {
    _cnicCtrl.dispose();
    _shopNameCtrl.dispose();
    _ownerNameCtrl.dispose();
    _phoneCtrl.dispose();
    _addressCtrl.dispose();
    _descriptionCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Header ─────────────────────────────
              Padding(
                padding: const EdgeInsets.fromLTRB(18, 16, 18, 4),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () => Get.back(),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: _C.cream.withOpacity(0.30),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: _C.border.withOpacity(0.45),
                          ),
                        ),
                        child: const Icon(
                          Icons.arrow_back_ios_new,
                          size: 16,
                          color: _C.darkGreen,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.storefront_outlined,
                              size: 20,
                              color: _C.darkGreen.withOpacity(0.85),
                            ),
                            const SizedBox(width: 6),
                            const Text(
                              'Create Your Shop',
                              style: TextStyle(
                                fontSize: 19,
                                fontWeight: FontWeight.bold,
                                color: _C.darkGreen,
                                letterSpacing: 0.2,
                              ),
                            ),
                          ],
                        ),
                        Text(
                          'Fill in the details to create your rice shop',
                          style: TextStyle(
                            fontSize: 12,
                            color: _C.darkGreen.withOpacity(0.6),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),

              // ── CNIC Section ───────────────────────
              _sectionCard(
                title: 'CNIC Information',
                child: Column(
                  children: [
                    _field(
                      controller: _cnicCtrl,
                      label: 'CNIC Number',
                      hint: 'XXXXX-XXXXXXX-X',
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(13),
                        _CnicFormatter(),
                      ],
                      validator: (v) {
                        if (v == null || v.isEmpty) return 'Required';
                        if (v.replaceAll('-', '').length != 13)
                          return 'Enter valid 13-digit CNIC';
                        return null;
                      },
                    ),
                    // CNIC Image Upload
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Upload CNIC Image',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: _C.darkGreen.withOpacity(0.75),
                          ),
                        ),
                        const SizedBox(height: 8),
                        GestureDetector(
                          onTap: _pickCnicImage,
                          child: Container(
                            width: double.infinity,
                            height: 120,
                            decoration: BoxDecoration(
                              color: _C.cream.withOpacity(0.22),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: _C.border.withOpacity(0.5),
                                style: BorderStyle.solid,
                              ),
                            ),
                            child: _cnicImage != null
                                ? ClipRRect(
                                    borderRadius: BorderRadius.circular(11),
                                    child: Image.file(
                                      _cnicImage!,
                                      fit: BoxFit.cover,
                                    ),
                                  )
                                : Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.upload_outlined,
                                        size: 32,
                                        color: _C.darkGreen.withOpacity(0.55),
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        'Click to upload CNIC image',
                                        style: TextStyle(
                                          fontSize: 13,
                                          color: _C.darkGreen.withOpacity(0.6),
                                        ),
                                      ),
                                    ],
                                  ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // ── Shop Info Section ──────────────────
              _sectionCard(
                title: 'Shop Information',
                child: Column(
                  children: [
                    _field(
                      controller: _shopNameCtrl,
                      label: 'Shop Name',
                      hint: 'Enter your shop name',
                    ),
                    _field(
                      controller: _ownerNameCtrl,
                      label: 'Owner Name',
                      hint: 'Enter your full name',
                    ),
                    _field(
                      controller: _phoneCtrl,
                      label: 'Phone',
                      hint: '+92 XXX XXXXXXX',
                      keyboardType: TextInputType.phone,
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) return 'Required';
                        if (v.trim().length < 11) return 'Enter valid phone';
                        return null;
                      },
                    ),
                    _field(
                      controller: _addressCtrl,
                      label: 'Shop Address',
                      hint: 'Enter your shop address',
                    ),
                    _field(
                      controller: _descriptionCtrl,
                      label: 'Tell us about your shop',
                      hint:
                          'Tell customers about your shop, experience, and specialty...',
                      maxLines: 3,
                      validator: (_) => null, // optional
                    ),
                  ],
                ),
              ),

              // ── Rice Categories ────────────────────
              _sectionCard(
                title: 'Rice Categories',
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '${_categories.length} categories added',
                          style: TextStyle(
                            fontSize: 12.5,
                            color: _C.darkGreen.withOpacity(0.6),
                          ),
                        ),
                        GestureDetector(
                          onTap: _showAddCategoryDialog,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 7,
                            ),
                            decoration: BoxDecoration(
                              color: _C.lightGreen.withOpacity(0.25),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: _C.lightGreen.withOpacity(0.5),
                              ),
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.add, size: 16, color: _C.darkGreen),
                                SizedBox(width: 5),
                                Text(
                                  'Add Category',
                                  style: TextStyle(
                                    fontSize: 12.5,
                                    fontWeight: FontWeight.w600,
                                    color: _C.darkGreen,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    if (_categories.isEmpty)
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 20),
                        decoration: BoxDecoration(
                          color: _C.cream.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: _C.border.withOpacity(0.3)),
                        ),
                        child: Text(
                          'No rice categories added yet.\nClick "Add Category" to start.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 13,
                            color: _C.darkGreen.withOpacity(0.55),
                            height: 1.5,
                          ),
                        ),
                      )
                    else
                      ..._categories.asMap().entries.map((e) {
                        final cat = e.value;
                        return Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 11,
                          ),
                          decoration: BoxDecoration(
                            color: _C.cream.withOpacity(0.25),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: _C.border.withOpacity(0.35),
                            ),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.grain,
                                size: 16,
                                color: _C.golden,
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  cat.name,
                                  style: const TextStyle(
                                    fontSize: 13.5,
                                    fontWeight: FontWeight.w600,
                                    color: _C.darkGreen,
                                  ),
                                ),
                              ),
                              if (cat.pricePerKg.isNotEmpty)
                                Text(
                                  'Rs ${cat.pricePerKg}/kg',
                                  style: TextStyle(
                                    fontSize: 12.5,
                                    color: _C.darkGreen.withOpacity(0.7),
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              const SizedBox(width: 8),
                              GestureDetector(
                                onTap: () =>
                                    setState(() => _categories.removeAt(e.key)),
                                child: Icon(
                                  Icons.close,
                                  size: 16,
                                  color: _C.darkGreen.withOpacity(0.5),
                                ),
                              ),
                            ],
                          ),
                        );
                      }),
                  ],
                ),
              ),

              // ── Submit button ──────────────────────
              Padding(
                padding: const EdgeInsets.fromLTRB(18, 8, 18, 28),
                child: GestureDetector(
                  onTap: _submitting ? null : _submit,
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: _submitting
                            ? [
                                _C.lightGreen.withOpacity(0.5),
                                _C.golden.withOpacity(0.5),
                              ]
                            : [_C.lightGreen, _C.golden],
                      ),
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: [
                        BoxShadow(
                          color: _C.golden.withOpacity(0.35),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: _submitting
                        ? const Center(
                            child: SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2.5,
                              ),
                            ),
                          )
                        : const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.storefront,
                                size: 18,
                                color: Colors.white,
                              ),
                              SizedBox(width: 8),
                              Text(
                                'Create Your Shop',
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ],
                          ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  CNIC TEXT INPUT FORMATTER  (XXXXX-XXXXXXX-X)
// ─────────────────────────────────────────────
class _CnicFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final digits = newValue.text.replaceAll('-', '');
    final buffer = StringBuffer();
    for (int i = 0; i < digits.length && i < 13; i++) {
      if (i == 5 || i == 12) buffer.write('-');
      buffer.write(digits[i]);
    }
    final formatted = buffer.toString();
    return newValue.copyWith(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}
