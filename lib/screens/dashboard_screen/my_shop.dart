// ignore_for_file: unused_import, deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '/core/utils/themes.dart';
import '/core/services/shop_service.dart';
import '/routes/app_routes.dart';
import 'create_shops.dart';

// ─────────────────────────────────────────────
//  MY SHOP SCREEN
// ─────────────────────────────────────────────
class MyShopScreen extends StatefulWidget {
  const MyShopScreen({Key? key}) : super(key: key);

  @override
  State<MyShopScreen> createState() => _MyShopScreenState();
}

class _MyShopScreenState extends State<MyShopScreen> {
  final ImagePicker _picker = ImagePicker();

  Map<String, dynamic> _shopData = {};
  bool _isEditing = false;
  bool _isLoading = true;
  bool _isSaving = false;

  // Controllers — match CreateShopScreen fields exactly
  final _shopNameCtrl = TextEditingController();
  final _ownerNameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _addressCtrl = TextEditingController();
  final _descriptionCtrl = TextEditingController();

  File? _cnicImage;
  List<Map<String, dynamic>> _categories = [];

  // ── Load ────────────────────────────────────────────────────
  @override
  void initState() {
    super.initState();
    _loadShopData();
  }

  Future<void> _loadShopData() async {
    setState(() => _isLoading = true);

    final result = await ShopService.getMyShop();

    if (result['success']) {
      final shop = result['data']['data'] ?? result['data'];
      setState(() {
        _shopData = shop;
        _shopNameCtrl.text = shop['shop_name'] ?? '';
        _ownerNameCtrl.text = shop['owner_name'] ?? '';
        _phoneCtrl.text = shop['phone'] ?? '';
        _addressCtrl.text = shop['address'] ?? '';
        _descriptionCtrl.text = shop['description'] ?? '';

        // rice_categories comes as a list from the API
        if (shop['rice_categories'] != null) {
          _categories = List<Map<String, dynamic>>.from(
            (shop['rice_categories'] as List).map(
              (c) => {
                'id': c['id'],
                'name': c['name'] ?? '',
                'price_per_kg': c['price_per_kg'] ?? 0,
              },
            ),
          );
        }
      });
    } else {
      Get.snackbar('Error', result['message'] ?? 'Failed to load shop');
    }

    setState(() => _isLoading = false);
  }

  // ── Pick new CNIC image ──────────────────────────────────────
  Future<void> _pickImage() async {
    final XFile? file = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
    );
    if (file != null) setState(() => _cnicImage = File(file.path));
  }

  // ── Save / update ────────────────────────────────────────────
  Future<void> _saveChanges() async {
    if (_shopNameCtrl.text.isEmpty ||
        _ownerNameCtrl.text.isEmpty ||
        _phoneCtrl.text.isEmpty ||
        _addressCtrl.text.isEmpty) {
      Get.snackbar('Error', 'Please fill all required fields');
      return;
    }

    setState(() => _isSaving = true);

    var _cnicImageBytes;
    final result = await ShopService.updateShop(
      shopId: _shopData['id'].toString(),
      shopName: _shopNameCtrl.text.trim(),
      ownerName: _ownerNameCtrl.text.trim(),
      phone: _phoneCtrl.text.trim(),
      address: _addressCtrl.text.trim(),
      description: _descriptionCtrl.text.trim(),
      riceCategories: _categories,
      cnicImageBytes: _cnicImageBytes!,
    );

    setState(() => _isSaving = false);

    if (result['success']) {
      setState(() => _isEditing = false);
      Get.snackbar('Success', 'Shop updated successfully!');
      _loadShopData();
    } else {
      Get.snackbar('Error', result['message'] ?? 'Update failed');
    }
  }

  // ── Delete shop ──────────────────────────────────────────────
  void _deleteShop() {
    Get.defaultDialog(
      title: 'Delete Shop?',
      middleText:
          'Are you sure you want to delete your shop? This cannot be undone.',
      textCancel: 'Cancel',
      textConfirm: 'Delete',
      confirmTextColor: Colors.white,
      buttonColor: AppColors.error,
      onConfirm: () async {
        Get.back();
        final result = await ShopService.deleteShop(_shopData['id'].toString());
        if (result['success']) {
          Get.offAllNamed(AppRoutes.createshops);
        } else {
          Get.snackbar('Error', result['message'] ?? 'Delete failed');
        }
      },
    );
  }

  // ── Add category dialog ──────────────────────────────────────
  void _showAddCategoryDialog() {
    final nameCtrl = TextEditingController();
    final priceCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.cream.withOpacity(0.97),
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
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.golden,
              foregroundColor: Colors.white,
              minimumSize: const Size(80, 40),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onPressed: () {
              if (nameCtrl.text.isNotEmpty && priceCtrl.text.isNotEmpty) {
                setState(() {
                  _categories.add({
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

  // ── Edit category dialog ─────────────────────────────────────
  void _showEditCategoryDialog(int index) {
    final cat = _categories[index];
    final nameCtrl = TextEditingController(text: cat['name']);
    final priceCtrl = TextEditingController(
      text: cat['price_per_kg'].toString(),
    );
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.cream.withOpacity(0.97),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Edit Rice Category', style: AppTextStyles.heading3),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _dialogField(nameCtrl, 'Category Name', Icons.grain),
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
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.golden,
              foregroundColor: Colors.white,
              minimumSize: const Size(80, 40),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onPressed: () {
              if (nameCtrl.text.isNotEmpty && priceCtrl.text.isNotEmpty) {
                setState(() {
                  _categories[index] = {
                    'id': cat['id'],
                    'name': nameCtrl.text.trim(),
                    'price_per_kg': double.tryParse(priceCtrl.text) ?? 0,
                  };
                });
                Navigator.pop(context);
              }
            },
            child: const Text('Save', style: AppTextStyles.button),
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

  // ── Section card ─────────────────────────────────────────────
  Widget _sectionCard({
    required String title,
    IconData? icon,
    required Widget child,
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

  // ── Label ────────────────────────────────────────────────────
  Widget _label(String text) => Padding(
    padding: const EdgeInsets.only(bottom: 6),
    child: Text(text, style: AppTextStyles.labelMuted),
  );

  // ── Input field ──────────────────────────────────────────────
  Widget _buildField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
  }) {
    return Container(
      decoration: AppDecorations.inputField,
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        maxLines: maxLines,
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

  // ── Info row (view mode) ─────────────────────────────────────
  Widget _infoRow(IconData icon, String label, String value) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 10),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: AppColors.golden),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: AppTextStyles.bodySmall.copyWith(
                fontSize: 11,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              value,
              style: AppTextStyles.bodyLarge.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ],
    ),
  );

  Widget _divider() => Padding(
    padding: const EdgeInsets.symmetric(vertical: 2),
    child: Divider(height: 1, color: AppColors.divider),
  );

  // ════════════════════════════════════════════
  //  BUILD
  // ════════════════════════════════════════════
  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        body: Container(
          decoration: AppDecorations.gradientBackground,
          child: const Center(
            child: CircularProgressIndicator(color: AppColors.golden),
          ),
        ),
      );
    }

    return Scaffold(
      body: Container(
        decoration: AppDecorations.gradientBackground,
        child: SafeArea(
          child: Column(
            children: [
              // ── AppBar ───────────────────────────────────────
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
                            Text('My Shop', style: AppTextStyles.heading3),
                          ],
                        ),
                        const SizedBox(height: 2),
                        Text(
                          _isEditing
                              ? 'Edit your shop details'
                              : 'View your shop',
                          style: AppTextStyles.bodySmall,
                        ),
                      ],
                    ),
                    const Spacer(),
                    if (!_isEditing)
                      GestureDetector(
                        onTap: () => setState(() => _isEditing = true),
                        child: Container(
                          decoration: AppDecorations.iconButton,
                          padding: const EdgeInsets.all(8),
                          child: const Icon(
                            Icons.edit_outlined,
                            size: 18,
                            color: AppColors.darkGreen,
                          ),
                        ),
                      ),
                  ],
                ),
              ),

              // ── Body ─────────────────────────────────────────
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 28),
                  child: Column(
                    children: [
                      // ── CNIC Section ────────────────────────
                      _sectionCard(
                        title: 'CNIC Information',
                        icon: Icons.credit_card_outlined,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (_isEditing) ...[
                              // CNIC number is not editable for security
                              _infoRow(
                                Icons.badge_outlined,
                                'CNIC Number',
                                _shopData['cnic_number'] ?? 'N/A',
                              ),
                              _divider(),
                              const SizedBox(height: 10),
                              _label('CNIC Image'),
                              GestureDetector(
                                onTap: _pickImage,
                                child: Container(
                                  height: 110,
                                  width: double.infinity,
                                  decoration: BoxDecoration(
                                    color: AppColors.inputFill,
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(
                                      color: AppColors.inputBorder,
                                    ),
                                  ),
                                  child: _cnicImage != null
                                      ? ClipRRect(
                                          borderRadius: BorderRadius.circular(
                                            9,
                                          ),
                                          child: Image.file(
                                            _cnicImage!,
                                            fit: BoxFit.cover,
                                          ),
                                        )
                                      : _shopData['cnic_image'] != null
                                      ? Stack(
                                          children: [
                                            ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(9),
                                              child: Image.network(
                                                _shopData['cnic_image'],
                                                fit: BoxFit.cover,
                                                width: double.infinity,
                                                height: 110,
                                              ),
                                            ),
                                            Container(
                                              decoration: BoxDecoration(
                                                color: Colors.black26,
                                                borderRadius:
                                                    BorderRadius.circular(9),
                                              ),
                                              child: Center(
                                                child: Icon(
                                                  Icons.edit,
                                                  color: Colors.white
                                                      .withOpacity(0.8),
                                                  size: 28,
                                                ),
                                              ),
                                            ),
                                          ],
                                        )
                                      : Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Icon(
                                              Icons.upload_outlined,
                                              size: 28,
                                              color: AppColors.iconMuted,
                                            ),
                                            const SizedBox(height: 6),
                                            Text(
                                              'Tap to update CNIC image',
                                              style: AppTextStyles.labelMuted,
                                            ),
                                          ],
                                        ),
                                ),
                              ),
                            ] else ...[
                              _infoRow(
                                Icons.badge_outlined,
                                'CNIC Number',
                                _shopData['cnic_number'] ?? 'N/A',
                              ),
                              _divider(),
                              const SizedBox(height: 10),
                              _label('CNIC Image'),
                              if (_shopData['cnic_image'] != null)
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(10),
                                  child: Image.network(
                                    _shopData['cnic_image'],
                                    height: 110,
                                    width: double.infinity,
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, __, ___) => Container(
                                      height: 110,
                                      color: AppColors.inputFill,
                                      child: Center(
                                        child: Icon(
                                          Icons.broken_image_outlined,
                                          color: AppColors.iconMuted,
                                        ),
                                      ),
                                    ),
                                  ),
                                )
                              else
                                Text(
                                  'No image uploaded',
                                  style: AppTextStyles.bodySmall,
                                ),
                            ],
                          ],
                        ),
                      ),
                      const SizedBox(height: 14),

                      // ── Shop Information ─────────────────────
                      _sectionCard(
                        title: 'Shop Information',
                        icon: Icons.storefront_outlined,
                        child: _isEditing
                            ? Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _label('Shop Name'),
                                  _buildField(
                                    controller: _shopNameCtrl,
                                    hint: 'Enter your shop name',
                                    icon: Icons.store_outlined,
                                  ),
                                  const SizedBox(height: 12),
                                  _label('Owner Name'),
                                  _buildField(
                                    controller: _ownerNameCtrl,
                                    hint: 'Enter your full name',
                                    icon: Icons.person_outline,
                                  ),
                                  const SizedBox(height: 12),
                                  _label('Phone'),
                                  _buildField(
                                    controller: _phoneCtrl,
                                    hint: '+92 XXX XXXXXXX',
                                    icon: Icons.phone_outlined,
                                    keyboardType: TextInputType.phone,
                                  ),
                                  const SizedBox(height: 12),
                                  _label('Shop Address'),
                                  _buildField(
                                    controller: _addressCtrl,
                                    hint: 'Enter your shop address',
                                    icon: Icons.location_on_outlined,
                                  ),
                                  const SizedBox(height: 12),
                                  _label('Tell us about your shop'),
                                  _buildField(
                                    controller: _descriptionCtrl,
                                    hint: 'Tell customers about your shop...',
                                    icon: Icons.info_outline,
                                    maxLines: 4,
                                  ),
                                ],
                              )
                            : Column(
                                children: [
                                  _infoRow(
                                    Icons.store_outlined,
                                    'Shop Name',
                                    _shopData['shop_name'] ?? 'N/A',
                                  ),
                                  _divider(),
                                  _infoRow(
                                    Icons.person_outline,
                                    'Owner Name',
                                    _shopData['owner_name'] ?? 'N/A',
                                  ),
                                  _divider(),
                                  _infoRow(
                                    Icons.phone_outlined,
                                    'Phone',
                                    _shopData['phone'] ?? 'N/A',
                                  ),
                                  _divider(),
                                  _infoRow(
                                    Icons.location_on_outlined,
                                    'Address',
                                    _shopData['address'] ?? 'N/A',
                                  ),
                                  _divider(),
                                  _infoRow(
                                    Icons.info_outline,
                                    'Description',
                                    _shopData['description'] ?? 'N/A',
                                  ),
                                  _divider(),
                                  _infoRow(
                                    Icons.verified_outlined,
                                    'Approval Status',
                                    (_shopData['is_approved'] == true ||
                                            _shopData['is_approved'] == 1)
                                        ? '✅ Approved'
                                        : '⏳ Pending Approval',
                                  ),
                                ],
                              ),
                      ),
                      const SizedBox(height: 14),

                      // ── Rice Categories ──────────────────────
                      _sectionCard(
                        title: 'Rice Categories',
                        icon: Icons.grain,
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      'Categories',
                                      style: AppTextStyles.labelMuted,
                                    ),
                                    const SizedBox(width: 8),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 7,
                                        vertical: 2,
                                      ),
                                      decoration: BoxDecoration(
                                        color: AppColors.success.withOpacity(
                                          0.12,
                                        ),
                                        borderRadius: BorderRadius.circular(6),
                                        border: Border.all(
                                          color: AppColors.success.withOpacity(
                                            0.35,
                                          ),
                                        ),
                                      ),
                                      child: Text(
                                        '${_categories.length} items',
                                        style: AppTextStyles.bodySmall.copyWith(
                                          fontSize: 10,
                                          color: AppColors.success,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                if (_isEditing)
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
                            if (_categories.isEmpty)
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(20),
                                child: Center(
                                  child: Text(
                                    _isEditing
                                        ? 'No categories yet. Tap "Add Category" to start.'
                                        : 'No rice categories added.',
                                    textAlign: TextAlign.center,
                                    style: AppTextStyles.bodySmall,
                                  ),
                                ),
                              )
                            else
                              ListView.separated(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: _categories.length,
                                separatorBuilder: (_, __) =>
                                    const SizedBox(height: 8),
                                itemBuilder: (_, i) {
                                  final cat = _categories[i];
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
                                            cat['name'] ?? '',
                                            style: AppTextStyles.bodyLarge,
                                          ),
                                        ),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 8,
                                            vertical: 4,
                                          ),
                                          decoration: BoxDecoration(
                                            color: AppColors.golden.withOpacity(
                                              0.15,
                                            ),
                                            borderRadius: BorderRadius.circular(
                                              6,
                                            ),
                                          ),
                                          child: Text(
                                            'PKR ${cat['price_per_kg']}',
                                            style: AppTextStyles.label.copyWith(
                                              color: AppColors.golden,
                                              fontSize: 12,
                                            ),
                                          ),
                                        ),
                                        if (_isEditing) ...[
                                          const SizedBox(width: 8),
                                          GestureDetector(
                                            onTap: () =>
                                                _showEditCategoryDialog(i),
                                            child: Container(
                                              padding: const EdgeInsets.all(5),
                                              decoration: BoxDecoration(
                                                color: AppColors.info
                                                    .withOpacity(0.12),
                                                borderRadius:
                                                    BorderRadius.circular(6),
                                              ),
                                              child: const Icon(
                                                Icons.edit_outlined,
                                                size: 15,
                                                color: AppColors.info,
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 6),
                                          GestureDetector(
                                            onTap: () => setState(
                                              () => _categories.removeAt(i),
                                            ),
                                            child: Container(
                                              padding: const EdgeInsets.all(5),
                                              decoration: BoxDecoration(
                                                color: AppColors.error
                                                    .withOpacity(0.12),
                                                borderRadius:
                                                    BorderRadius.circular(6),
                                              ),
                                              child: const Icon(
                                                Icons.close,
                                                size: 15,
                                                color: AppColors.error,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ],
                                    ),
                                  );
                                },
                              ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),

                      // ── Action buttons ───────────────────────
                      if (_isEditing)
                        Row(
                          children: [
                            Expanded(
                              child: ElevatedButton(
                                onPressed: () {
                                  setState(() => _isEditing = false);
                                  _loadShopData(); // reset
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.cream.withOpacity(
                                    0.2,
                                  ),
                                  foregroundColor: AppColors.darkGreen,
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 14,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    side: BorderSide(
                                      color: AppColors.borderGold.withOpacity(
                                        0.5,
                                      ),
                                    ),
                                  ),
                                ),
                                child: Text(
                                  'Cancel',
                                  style: AppTextStyles.button,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: ElevatedButton(
                                onPressed: _isSaving ? null : _saveChanges,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.golden,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 14,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                                child: _isSaving
                                    ? const SizedBox(
                                        height: 20,
                                        width: 20,
                                        child: CircularProgressIndicator(
                                          color: Colors.white,
                                          strokeWidth: 2,
                                        ),
                                      )
                                    : Text(
                                        'Save Changes',
                                        style: AppTextStyles.button.copyWith(
                                          color: Colors.white,
                                        ),
                                      ),
                              ),
                            ),
                          ],
                        ),

                      if (!_isEditing)
                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton(
                            onPressed: _deleteShop,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.error.withOpacity(
                                0.12,
                              ),
                              foregroundColor: AppColors.error,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                                side: BorderSide(
                                  color: AppColors.error.withOpacity(0.35),
                                ),
                              ),
                            ),
                            child: Text(
                              'Delete Shop',
                              style: AppTextStyles.button.copyWith(
                                color: AppColors.error,
                              ),
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
      ),
    );
  }

  @override
  void dispose() {
    _shopNameCtrl.dispose();
    _ownerNameCtrl.dispose();
    _phoneCtrl.dispose();
    _addressCtrl.dispose();
    _descriptionCtrl.dispose();
    super.dispose();
  }
}
