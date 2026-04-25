// ignore_for_file: prefer_typing_uninitialized_variables, deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import '../../core/utils/themes.dart';
import '../../core/services/shop_service.dart';
import 'package:get_storage/get_storage.dart';
import 'dart:typed_data';

class CreateShopScreen extends StatefulWidget {
  final VoidCallback? onShopCreated;
  const CreateShopScreen({super.key, this.onShopCreated});

  @override
  State<CreateShopScreen> createState() => _CreateShopScreenState();
}

class _CreateShopScreenState extends State<CreateShopScreen> {
  final _formKey = GlobalKey<FormState>();

  // Controllers
  final _cnicController = TextEditingController();
  final _shopNameController = TextEditingController();
  final _ownerNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _descriptionController = TextEditingController();

  bool _isLoading = false;
  Uint8List? _cnicImageBytes; // ✅ bytes only — works on Web + Mobile
  final List<Map<String, dynamic>> _riceCategories = [];

  final ImagePicker _picker = ImagePicker();

  // ── Pick CNIC image ────────────────────────────────────────
  Future<void> _pickCnicImage() async {
    final XFile? file = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
    );
    if (file != null) {
      final bytes = await file.readAsBytes();
      setState(() => _cnicImageBytes = bytes);
    }
  }

  // ── Add rice category dialog ───────────────────────────────
  void _showAddCategoryDialog() {
    final nameCtrl = TextEditingController();
    final priceCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFFD4C9A8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Add Rice Category', style: AppTextStyles.heading3),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _dialogField(nameCtrl, 'Category Name (e.g. Basmati)', Icons.grain),
            const SizedBox(height: 10),
            _dialogField(
              priceCtrl,
              'Price per kg (PKR)',
              Icons.currency_rupee,
              type: TextInputType.number,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: AppTextStyles.labelMuted),
          ),
          ElevatedButton(
            style: AppButtonStyles.primary.copyWith(
              minimumSize: WidgetStateProperty.all(const Size(80, 40)),
            ),
            onPressed: () {
              if (nameCtrl.text.isNotEmpty && priceCtrl.text.isNotEmpty) {
                setState(() {
                  _riceCategories.add({
                    'name': nameCtrl.text.trim(),
                    'price_per_kg': double.tryParse(priceCtrl.text) ?? 0,
                  });
                });
                Navigator.pop(context);
              }
            },
            child: const Text('Add', style: AppTextStyles.button),
          ),
        ],
      ),
    );
  }

  Widget _dialogField(
    TextEditingController ctrl,
    String hint,
    IconData icon, {
    TextInputType type = TextInputType.text,
  }) {
    return Container(
      decoration: AppDecorations.inputField,
      child: TextField(
        controller: ctrl,
        keyboardType: type,
        style: AppTextStyles.bodyLarge,
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: AppTextStyles.hint,
          prefixIcon: Icon(icon, color: AppColors.iconMuted, size: 18),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 14,
            vertical: 13,
          ),
        ),
      ),
    );
  }

  // ── Input field builder ────────────────────────────────────
  Widget _buildField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
    List<TextInputFormatter>? inputFormatters,
    String? Function(String?)? validator,
  }) {
    return Container(
      decoration: AppDecorations.inputField,
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        maxLines: maxLines,
        inputFormatters: inputFormatters,
        validator:
            validator ??
            (v) => (v == null || v.isEmpty) ? 'This field is required' : null,
        style: AppTextStyles.bodyLarge,
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: AppTextStyles.hint,
          prefixIcon: maxLines == 1
              ? Icon(icon, color: AppColors.iconMuted, size: 19)
              : Padding(
                  padding: const EdgeInsets.only(bottom: 50),
                  child: Icon(icon, color: AppColors.iconMuted, size: 19),
                ),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(
            horizontal: 16,
            vertical: maxLines > 1 ? 14 : 15,
          ),
        ),
      ),
    );
  }

  // ── Section card wrapper ───────────────────────────────────
  Widget _sectionCard({
    required String title,
    required Widget child,
    IconData? icon,
  }) {
    return Container(
      decoration: AppDecorations.card,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (icon != null) ...[
                Icon(icon, size: 18, color: AppColors.golden),
                const SizedBox(width: 8),
              ],
              Text(title, style: AppTextStyles.heading4),
            ],
          ),
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }

  // ── Label above a field ────────────────────────────────────
  Widget _label(String text) => Padding(
    padding: const EdgeInsets.only(bottom: 6),
    child: Text(text, style: AppTextStyles.labelMuted),
  );

  // ── Submit ─────────────────────────────────────────────────
  Future<void> _createShop() async {
    if (!_formKey.currentState!.validate()) return;

    // ✅ Check bytes, not File
    if (_cnicImageBytes == null) {
      Get.snackbar('Error', 'Please upload your CNIC image');
      return;
    }

    if (_riceCategories.isEmpty) {
      Get.snackbar('Error', 'Please add at least one rice category');
      return;
    }

    setState(() => _isLoading = true);

    final result = await ShopService.createShop(
      cnicNumber: _cnicController.text.trim(),
      cnicImageBytes: _cnicImageBytes!, // ✅ safe — guarded by null check above
      shopName: _shopNameController.text.trim(),
      ownerName: _ownerNameController.text.trim(),
      phone: _phoneController.text.trim(),
      address: _addressController.text.trim(),
      description: _descriptionController.text.trim(),
      riceCategories: _riceCategories,
    );

    setState(() => _isLoading = false);

    if (result['success']) {
      GetStorage().write('has_shop', true);
      Get.snackbar('Success', 'Your shop has been created!');
      widget.onShopCreated?.call();
    } else {
      Get.snackbar('Error', result['message'] ?? 'Something went wrong');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: AppDecorations.gradientBackground,
        child: SafeArea(
          child: Column(
            children: [
              // ── AppBar ──────────────────────────────────────
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 14,
                ),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        decoration: AppDecorations.iconButton,
                        padding: const EdgeInsets.all(8),
                        child: const Icon(
                          Icons.arrow_back,
                          size: 20,
                          color: AppColors.darkGreen,
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(
                              Icons.store_outlined,
                              size: 20,
                              color: AppColors.darkGreen,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'Create Your Shop',
                              style: AppTextStyles.heading3,
                            ),
                          ],
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Fill in the details to create your rice shop',
                          style: AppTextStyles.bodySmall,
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // ── Scrollable body ─────────────────────────────
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        // ── CNIC Section ──────────────────────
                        _sectionCard(
                          title: 'CNIC Information',
                          icon: Icons.credit_card_outlined,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _label('CNIC Number'),
                              _buildField(
                                controller: _cnicController,
                                hint: 'XXXXX-XXXXXXX-X',
                                icon: Icons.badge_outlined,
                                keyboardType: TextInputType.number,
                                inputFormatters: [
                                  FilteringTextInputFormatter.digitsOnly,
                                  _CnicFormatter(),
                                ],
                                validator: (v) {
                                  if (v == null || v.isEmpty)
                                    return 'CNIC is required';
                                  if (v.replaceAll('-', '').length != 13)
                                    return 'Enter valid 13-digit CNIC';
                                  return null;
                                },
                              ),
                              const SizedBox(height: 14),
                              _label('Upload CNIC Image'),
                              GestureDetector(
                                onTap: _pickCnicImage,
                                child: Container(
                                  height: 120,
                                  width: double.infinity,
                                  decoration: BoxDecoration(
                                    color: AppColors.inputFill,
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(
                                      color: AppColors.inputBorder,
                                    ),
                                  ),
                                  // ✅ Use _cnicImageBytes with Image.memory
                                  child: _cnicImageBytes != null
                                      ? ClipRRect(
                                          borderRadius: BorderRadius.circular(
                                            9,
                                          ),
                                          child: Image.memory(
                                            _cnicImageBytes!,
                                            fit: BoxFit.cover,
                                          ),
                                        )
                                      : Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Icon(
                                              Icons.upload_outlined,
                                              size: 32,
                                              color: AppColors.iconMuted,
                                            ),
                                            const SizedBox(height: 8),
                                            Text(
                                              'Click to upload CNIC image',
                                              style: AppTextStyles.labelMuted,
                                            ),
                                          ],
                                        ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 14),

                        // ── Shop Information ──────────────────
                        _sectionCard(
                          title: 'Shop Information',
                          icon: Icons.storefront_outlined,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _label('Shop Name'),
                              _buildField(
                                controller: _shopNameController,
                                hint: 'Enter your shop name',
                                icon: Icons.store_outlined,
                              ),
                              const SizedBox(height: 12),
                              _label('Owner Name'),
                              _buildField(
                                controller: _ownerNameController,
                                hint: 'Enter your full name',
                                icon: Icons.person_outline,
                              ),
                              const SizedBox(height: 12),
                              _label('Phone'),
                              _buildField(
                                controller: _phoneController,
                                hint: '+92 XXX XXXXXXX',
                                icon: Icons.phone_outlined,
                                keyboardType: TextInputType.phone,
                              ),
                              const SizedBox(height: 12),
                              _label('Shop Address'),
                              _buildField(
                                controller: _addressController,
                                hint: 'Enter your shop address',
                                icon: Icons.location_on_outlined,
                              ),
                              const SizedBox(height: 12),
                              _label('Tell us about your shop'),
                              _buildField(
                                controller: _descriptionController,
                                hint:
                                    'Tell customers about your shop, experience, and specialty...',
                                icon: Icons.info_outline,
                                maxLines: 4,
                                validator: (_) => null,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 14),

                        // ── Rice Categories ───────────────────
                        _sectionCard(
                          title: 'Rice Categories',
                          icon: Icons.grain,
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Categories',
                                    style: AppTextStyles.labelMuted,
                                  ),
                                  GestureDetector(
                                    onTap: _showAddCategoryDialog,
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 7,
                                      ),
                                      decoration: AppDecorations.pill,
                                      child: Row(
                                        children: [
                                          const Icon(
                                            Icons.add,
                                            size: 16,
                                            color: AppColors.darkGreen,
                                          ),
                                          const SizedBox(width: 4),
                                          Text(
                                            'Add Category',
                                            style: AppTextStyles.label.copyWith(
                                              fontSize: 13,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              if (_riceCategories.isEmpty)
                                Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.all(20),
                                  child: Center(
                                    child: Text(
                                      'No rice categories added yet. Click "Add Category" to start.',
                                      textAlign: TextAlign.center,
                                      style: AppTextStyles.bodySmall,
                                    ),
                                  ),
                                )
                              else
                                ListView.separated(
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  itemCount: _riceCategories.length,
                                  separatorBuilder: (_, __) =>
                                      const SizedBox(height: 8),
                                  itemBuilder: (_, i) {
                                    final cat = _riceCategories[i];
                                    return Container(
                                      decoration: AppDecorations.inputField,
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 14,
                                        vertical: 12,
                                      ),
                                      child: Row(
                                        children: [
                                          const Icon(
                                            Icons.grain,
                                            size: 18,
                                            color: AppColors.golden,
                                          ),
                                          const SizedBox(width: 10),
                                          Expanded(
                                            child: Text(
                                              cat['name'],
                                              style: AppTextStyles.bodyLarge,
                                            ),
                                          ),
                                          Text(
                                            'PKR ${cat['price_per_kg']}',
                                            style: AppTextStyles.label.copyWith(
                                              color: AppColors.golden,
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          GestureDetector(
                                            onTap: () => setState(
                                              () => _riceCategories.removeAt(i),
                                            ),
                                            child: const Icon(
                                              Icons.close,
                                              size: 18,
                                              color: AppColors.error,
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),

                        // ── Submit button ─────────────────────
                        SizedBox(
                          width: double.infinity,
                          height: 52,
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _createShop,
                            style: AppButtonStyles.primary,
                            child: _isLoading
                                ? const SizedBox(
                                    height: 22,
                                    width: 22,
                                    child: CircularProgressIndicator(
                                      color: AppColors.darkGreen,
                                      strokeWidth: 2.5,
                                    ),
                                  )
                                : const Text(
                                    'Create Your Shop',
                                    style: AppTextStyles.button,
                                  ),
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

  @override
  void dispose() {
    _cnicController.dispose();
    _shopNameController.dispose();
    _ownerNameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  CNIC auto-formatter  →  XXXXX-XXXXXXX-X
// ─────────────────────────────────────────────────────────────────────────────
class _CnicFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final digits = newValue.text.replaceAll('-', '');
    if (digits.length > 13) return oldValue;

    final buffer = StringBuffer();
    for (int i = 0; i < digits.length; i++) {
      if (i == 5 || i == 12) buffer.write('-');
      buffer.write(digits[i]);
    }
    final formatted = buffer.toString();
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}
