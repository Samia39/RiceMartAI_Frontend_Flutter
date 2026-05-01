// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:typed_data';
import '/core/utils/themes.dart';
import '/core/services/shop_service.dart';

class MyShopScreen extends StatefulWidget {
  final VoidCallback? onShopDeleted;
  const MyShopScreen({Key? key, this.onShopDeleted}) : super(key: key);

  @override
  State<MyShopScreen> createState() => _MyShopScreenState();
}

class _MyShopScreenState extends State<MyShopScreen> {
  final ImagePicker _picker = ImagePicker();

  Map<String, dynamic> _shopData = {};
  bool _isEditing = false;
  bool _isLoading = true;
  bool _isSaving = false;

  // ── Shop-level controllers ───────────────────────────────────────────────
  final _cnicNumberCtrl = TextEditingController();
  final _shopNameCtrl = TextEditingController();
  final _ownerNameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _addressCtrl = TextEditingController();
  final _descriptionCtrl = TextEditingController();

  // ── CNIC image ───────────────────────────────────────────────────────────
  Uint8List? _cnicImageBytes; // non-null = user picked a new image

  // ── Rice categories ──────────────────────────────────────────────────────
  // Each map: { 'id': int?, 'name': String, 'price_per_kg': double,
  //             'stock_kg': double,
  //             'imageUrl': String?,       ← full URL from server (display)
  //             'existingImage': String?,  ← raw storage path (sent on update)
  //             'imageBytes': Uint8List? } ← new pick
  List<Map<String, dynamic>> _categories = [];

  // ── Per-category controllers (index-stable, created in _syncCategoryControllers)
  // Kept at state level so setState() does NOT recreate them.
  final List<TextEditingController> _catNameCtrls = [];
  final List<TextEditingController> _catPriceCtrls = [];
  final List<TextEditingController> _catStockCtrls = [];

  @override
  void initState() {
    super.initState();
    _loadShopData();
  }

  // ── Sync per-category controllers to match _categories list ─────────────
  // Called whenever _categories is mutated (load, add, remove).
  void _syncCategoryControllers() {
    // Dispose extras
    while (_catNameCtrls.length > _categories.length) {
      _catNameCtrls.removeLast().dispose();
      _catPriceCtrls.removeLast().dispose();
      _catStockCtrls.removeLast().dispose();
    }
    // Add missing
    while (_catNameCtrls.length < _categories.length) {
      final i = _catNameCtrls.length;
      final cat = _categories[i];

      final nameCtrl = TextEditingController(
        text: cat['name']?.toString() ?? '',
      );
      final priceCtrl = TextEditingController(
        text: cat['price_per_kg']?.toString() ?? '',
      );
      final stockCtrl = TextEditingController(
        text: cat['stock_kg']?.toString() ?? '',
      );

      // Keep _categories in sync as the user types
      nameCtrl.addListener(() {
        if (i < _categories.length) _categories[i]['name'] = nameCtrl.text;
      });
      priceCtrl.addListener(() {
        if (i < _categories.length) {
          _categories[i]['price_per_kg'] =
              double.tryParse(priceCtrl.text) ?? 0.0;
        }
      });
      stockCtrl.addListener(() {
        if (i < _categories.length) {
          _categories[i]['stock_kg'] = double.tryParse(stockCtrl.text) ?? 0.0;
        }
      });

      _catNameCtrls.add(nameCtrl);
      _catPriceCtrls.add(priceCtrl);
      _catStockCtrls.add(stockCtrl);
    }

    // Update text values for existing controllers (e.g. after reload)
    for (int i = 0; i < _categories.length; i++) {
      final cat = _categories[i];
      if (_catNameCtrls[i].text != (cat['name'] ?? '')) {
        _catNameCtrls[i].text = cat['name']?.toString() ?? '';
      }
      if (_catPriceCtrls[i].text != cat['price_per_kg']?.toString()) {
        _catPriceCtrls[i].text = cat['price_per_kg']?.toString() ?? '';
      }
      if (_catStockCtrls[i].text != cat['stock_kg']?.toString()) {
        _catStockCtrls[i].text = cat['stock_kg']?.toString() ?? '';
      }
    }
  }

  // ── Load ─────────────────────────────────────────────────────────────────
  Future<void> _loadShopData() async {
    setState(() => _isLoading = true);

    final result = await ShopService.getMyShop();

    if (result['success'] == true) {
      final shop = (result['shop'] as Map?)?.cast<String, dynamic>() ?? {};
      _shopData = shop;
      _cnicNumberCtrl.text = (shop['cnic_number'] as String?) ?? '';
      _shopNameCtrl.text = (shop['shop_name'] as String?) ?? '';
      _ownerNameCtrl.text = (shop['owner_name'] as String?) ?? '';
      _phoneCtrl.text = (shop['phone'] as String?) ?? '';
      _addressCtrl.text = (shop['address'] as String?) ?? '';
      _descriptionCtrl.text = (shop['description'] as String?) ?? '';

      if (shop['rice_categories'] is List) {
        _categories = (shop['rice_categories'] as List).map((c) {
          return <String, dynamic>{
            'id': c['id'],
            'name': (c['name'] as String?) ?? '',
            'price_per_kg': (c['price_per_kg'] as num?)?.toDouble() ?? 0.0,
            'stock_kg': (c['stock_kg'] as num?)?.toDouble() ?? 0.0,
            'imageUrl': c['image'] as String?,
            'existingImage': c['image_path'] as String?,
            'imageBytes': null,
          };
        }).toList();
      }

      _syncCategoryControllers();
    } else {
      Get.snackbar(
        'Error',
        (result['message'] as String?) ?? 'Failed to load shop',
      );
    }

    setState(() => _isLoading = false);
  }

  // ── Pick CNIC image ──────────────────────────────────────────────────────
  // FIX: read bytes BEFORE setState so the async gap is outside setState.
  Future<void> _pickCnicImage() async {
    final XFile? file = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
    );
    if (file == null) return;

    final bytes = await file.readAsBytes(); // ← await fully outside setState
    setState(() => _cnicImageBytes = bytes); // ← setState is synchronous here
  }

  // ── Pick category image ──────────────────────────────────────────────────
  Future<void> _pickCategoryImage(int index) async {
    final XFile? file = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );
    if (file == null) return;

    final bytes = await file.readAsBytes();
    setState(() {
      _categories[index]['imageBytes'] = bytes;
      _categories[index]['imageUrl'] = null; // hide old network image
    });
  }

  // ── Add blank category ───────────────────────────────────────────────────
  void _addCategory() {
    _categories.add({
      'id': null,
      'name': '',
      'price_per_kg': 0.0,
      'stock_kg': 0.0,
      'imageUrl': null,
      'existingImage': null,
      'imageBytes': null,
    });
    _syncCategoryControllers(); // create controllers for the new entry
    setState(() {});
  }

  // ── Remove category ──────────────────────────────────────────────────────
  void _removeCategory(int index) {
    _categories.removeAt(index);
    // Dispose removed controllers
    _catNameCtrls.removeAt(index).dispose();
    _catPriceCtrls.removeAt(index).dispose();
    _catStockCtrls.removeAt(index).dispose();
    setState(() {});
  }

  // ── Save ─────────────────────────────────────────────────────────────────
  Future<void> _saveChanges() async {
    if (_shopNameCtrl.text.isEmpty ||
        _ownerNameCtrl.text.isEmpty ||
        _phoneCtrl.text.isEmpty ||
        _addressCtrl.text.isEmpty) {
      Get.snackbar('Error', 'Please fill all required fields');
      return;
    }

    for (int i = 0; i < _categories.length; i++) {
      if ((_categories[i]['name'] as String).trim().isEmpty) {
        Get.snackbar('Error', 'Category ${i + 1} needs a name');
        return;
      }
    }

    setState(() => _isSaving = true);

    final result = await ShopService.updateShop(
      shopId: _shopData['id'].toString(),
      cnicNumber: _cnicNumberCtrl.text.trim().isNotEmpty
          ? _cnicNumberCtrl.text.trim()
          : null,
      cnicImageBytes: _cnicImageBytes,
      shopName: _shopNameCtrl.text.trim(),
      ownerName: _ownerNameCtrl.text.trim(),
      phone: _phoneCtrl.text.trim(),
      address: _addressCtrl.text.trim(),
      description: _descriptionCtrl.text.trim(),
      riceCategories: _categories
          .map(
            (cat) => {
              'name': cat['name'],
              'price_per_kg': cat['price_per_kg'],
              'stock_kg': cat['stock_kg'],
              'existingImage': cat['existingImage'],
              'imageBytes': cat['imageBytes'],
            },
          )
          .toList(),
    );

    setState(() => _isSaving = false);

    if (result['success'] == true) {
      setState(() {
        _isEditing = false;
        _cnicImageBytes = null;
      });
      Get.snackbar('Success', 'Shop updated successfully!');
      _loadShopData();
    } else {
      Get.snackbar('Error', (result['message'] as String?) ?? 'Update failed');
    }
  }

  // ── Delete ───────────────────────────────────────────────────────────────
  void _deleteShop() {
    Get.defaultDialog(
      title: 'Delete Shop?',
      middleText: 'Are you sure? This cannot be undone.',
      textCancel: 'Cancel',
      textConfirm: 'Delete',
      confirmTextColor: Colors.white,
      buttonColor: AppColors.error,
      onConfirm: () async {
        Get.back();
        final result = await ShopService.deleteShop(_shopData['id'].toString());
        if (result['success'] == true) {
          widget.onShopDeleted?.call();
        } else {
          Get.snackbar(
            'Error',
            (result['message'] as String?) ?? 'Delete failed',
          );
        }
      },
    );
  }

  // ── UI helpers ────────────────────────────────────────────────────────────

  Widget _label(String text) => Padding(
    padding: const EdgeInsets.only(bottom: 6),
    child: Text(text, style: AppTextStyles.labelMuted),
  );

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

  Widget _buildField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
    List<TextInputFormatter>? inputFormatters,
  }) {
    return Container(
      decoration: AppDecorations.inputField,
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        maxLines: maxLines,
        inputFormatters: inputFormatters,
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

  Widget _infoRow(IconData icon, String label, String value) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 10),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: AppColors.golden),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
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
        ),
      ],
    ),
  );

  Widget _divider() => Padding(
    padding: const EdgeInsets.symmetric(vertical: 2),
    child: Divider(height: 1, color: AppColors.divider),
  );

  Widget _approvalBadge() {
    final approved =
        _shopData['is_approved'] == true || _shopData['is_approved'] == 1;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: (approved ? AppColors.success : AppColors.warning).withOpacity(
          0.15,
        ),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: (approved ? AppColors.success : AppColors.warning).withOpacity(
            0.35,
          ),
        ),
      ),
      child: Text(
        approved ? '✅ Approved' : '⏳ Pending',
        style: AppTextStyles.bodySmall.copyWith(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          color: approved ? AppColors.success : AppColors.warning,
        ),
      ),
    );
  }

  Widget _quickStatItem({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Expanded(
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.cream.withOpacity(0.15),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.cream.withOpacity(0.25)),
        ),
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        child: Column(
          children: [
            Icon(icon, size: 16, color: AppColors.cream),
            const SizedBox(height: 6),
            Text(value, style: AppTextStyles.heading4),
            const SizedBox(height: 2),
            Text(
              label,
              style: AppTextStyles.bodySmall.copyWith(
                fontSize: 10,
                color: AppColors.cream.withOpacity(0.8),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Category card (EDIT mode) ─────────────────────────────────────────────
  // Controllers come from state-level lists — NOT created here — so they
  // survive setState() calls caused by CNIC or other image picks.
  Widget _buildEditCategoryCard(int index) {
    final cat = _categories[index];
    final newBytes = cat['imageBytes'] as Uint8List?;
    final imageUrl = cat['imageUrl'] as String?;

    return Container(
      decoration: AppDecorations.inputField,
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header ──────────────────────────────────────────────────────
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Category ${index + 1}', style: AppTextStyles.heading4),
              GestureDetector(
                onTap: () => _removeCategory(index),
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: AppColors.error.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Icon(Icons.close, size: 16, color: AppColors.error),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // ── Rice Name ────────────────────────────────────────────────────
          _label('Rice Name'),
          Container(
            decoration: AppDecorations.inputField,
            child: TextField(
              controller: _catNameCtrls[index], // ← state-level controller
              style: AppTextStyles.bodyLarge,
              decoration: InputDecoration(
                hintText: 'e.g. Basmati',
                hintStyle: AppTextStyles.hint,
                prefixIcon: Icon(
                  Icons.grain,
                  color: AppColors.iconMuted,
                  size: 18,
                ),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 13,
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),

          // ── Rice Image ───────────────────────────────────────────────────
          _label('Rice Image'),
          GestureDetector(
            onTap: () => _pickCategoryImage(index),
            child: Container(
              height: 110,
              width: double.infinity,
              decoration: BoxDecoration(
                color: AppColors.inputFill,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.inputBorder),
              ),
              child: newBytes != null
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(9),
                      child: Image.memory(newBytes, fit: BoxFit.cover),
                    )
                  : imageUrl != null
                  ? Stack(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(9),
                          child: Image.network(
                            imageUrl,
                            fit: BoxFit.cover,
                            width: double.infinity,
                            height: 110,
                            errorBuilder: (_, __, ___) => _imagePlaceholder(),
                          ),
                        ),
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.black26,
                            borderRadius: BorderRadius.circular(9),
                          ),
                          child: Center(
                            child: Icon(
                              Icons.edit,
                              color: Colors.white.withOpacity(0.8),
                              size: 28,
                            ),
                          ),
                        ),
                      ],
                    )
                  : _imagePlaceholder(),
            ),
          ),
          const SizedBox(height: 12),

          // ── Stock + Price ────────────────────────────────────────────────
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _label('Stock (kg)'),
                    Container(
                      decoration: AppDecorations.inputField,
                      child: TextField(
                        controller: _catStockCtrls[index], // ← state-level
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        style: AppTextStyles.bodyLarge,
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(
                            RegExp(r'^\d*\.?\d*'),
                          ),
                        ],
                        decoration: InputDecoration(
                          hintText: '0',
                          hintStyle: AppTextStyles.hint,
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 13,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _label('Price (Rs/kg)'),
                    Container(
                      decoration: AppDecorations.inputField,
                      child: TextField(
                        controller: _catPriceCtrls[index], // ← state-level
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        style: AppTextStyles.bodyLarge,
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(
                            RegExp(r'^\d*\.?\d*'),
                          ),
                        ],
                        decoration: InputDecoration(
                          hintText: '0',
                          hintStyle: AppTextStyles.hint,
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 13,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _imagePlaceholder() => Column(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      Icon(Icons.upload_outlined, size: 28, color: AppColors.iconMuted),
      const SizedBox(height: 6),
      Text('Tap to update image', style: AppTextStyles.labelMuted),
    ],
  );

  // ── Category tile (VIEW mode) ────────────────────────────────────────────
  Widget _buildViewCategoryTile(Map<String, dynamic> cat) {
    final imageUrl = cat['imageUrl'] as String?;
    return Container(
      decoration: AppDecorations.inputField,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: imageUrl != null
                ? Image.network(
                    imageUrl,
                    width: 48,
                    height: 48,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => _categoryIconBox(),
                  )
                : _categoryIconBox(),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  cat['name']?.toString() ?? '',
                  style: AppTextStyles.bodyLarge,
                ),
                const SizedBox(height: 2),
                Text(
                  'Stock: ${cat['stock_kg']} kg',
                  style: AppTextStyles.bodySmall,
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.golden.withOpacity(0.15),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              'PKR ${cat['price_per_kg']}',
              style: AppTextStyles.label.copyWith(
                color: AppColors.golden,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _categoryIconBox() => Container(
    width: 48,
    height: 48,
    decoration: BoxDecoration(
      color: AppColors.inputFill,
      borderRadius: BorderRadius.circular(8),
    ),
    child: Icon(Icons.grain, size: 24, color: AppColors.golden),
  );

  // ── Build ─────────────────────────────────────────────────────────────────
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
              // ── Top Header ───────────────────────────────────────────────
              Container(
                decoration: BoxDecoration(
                  gradient: AppGradients.background,
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(20),
                    bottomRight: Radius.circular(20),
                  ),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 20,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
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
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  const Icon(
                                    Icons.store_outlined,
                                    size: 22,
                                    color: AppColors.darkGreen,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'My Shop',
                                    style: AppTextStyles.heading2,
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(
                                _isEditing
                                    ? 'Edit your shop details'
                                    : 'Manage your shop information',
                                style: AppTextStyles.bodySmall,
                              ),
                            ],
                          ),
                        ),
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
                    if (!_isEditing) ...[
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          _quickStatItem(
                            icon: Icons.receipt_outlined,
                            label: 'Orders',
                            value: '0',
                          ),
                          const SizedBox(width: 12),
                          _quickStatItem(
                            icon: Icons.star_outline,
                            label: 'Rating',
                            value: '0/5',
                          ),
                          const SizedBox(width: 12),
                          _quickStatItem(
                            icon: Icons.category_outlined,
                            label: 'Categories',
                            value: _categories.length.toString(),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),

              // ── Scrollable body ──────────────────────────────────────────
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(16, 20, 16, 28),
                  child: Column(
                    children: [
                      // ── Overview card (view mode) ──────────────────────
                      if (!_isEditing) ...[
                        Container(
                          decoration: AppDecorations.card,
                          padding: const EdgeInsets.all(18),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    width: 60,
                                    height: 60,
                                    decoration: BoxDecoration(
                                      gradient: AppGradients.background,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: const Icon(
                                      Icons.storefront_outlined,
                                      size: 32,
                                      color: AppColors.cream,
                                    ),
                                  ),
                                  const SizedBox(width: 14),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          _shopData['shop_name'] ?? 'Shop Name',
                                          style: AppTextStyles.heading4,
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          'Owner: ${_shopData['owner_name'] ?? 'N/A'}',
                                          style: AppTextStyles.bodySmall,
                                        ),
                                        const SizedBox(height: 8),
                                        _approvalBadge(),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 14),
                              _divider(),
                              const SizedBox(height: 14),
                              _infoRow(
                                Icons.phone_outlined,
                                'Phone',
                                _shopData['phone'] ?? 'N/A',
                              ),
                              _infoRow(
                                Icons.location_on_outlined,
                                'Address',
                                _shopData['address'] ?? 'N/A',
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],

                      // ── CNIC Section ──────────────────────────────────
                      _sectionCard(
                        title: 'CNIC Information',
                        icon: Icons.credit_card_outlined,
                        child: _isEditing
                            ? Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _label('CNIC Number'),
                                  _buildField(
                                    controller: _cnicNumberCtrl,
                                    hint: 'XXXXX-XXXXXXX-X',
                                    icon: Icons.badge_outlined,
                                    keyboardType: TextInputType.number,
                                    inputFormatters: [
                                      FilteringTextInputFormatter.digitsOnly,
                                      _CnicFormatter(),
                                    ],
                                  ),
                                  const SizedBox(height: 14),
                                  _label('CNIC Image (tap to update)'),
                                  GestureDetector(
                                    onTap: _pickCnicImage,
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
                                      child: _cnicImageBytes != null
                                          // Newly picked image
                                          ? ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(9),
                                              child: Image.memory(
                                                _cnicImageBytes!,
                                                fit: BoxFit.cover,
                                              ),
                                            )
                                          : _shopData['cnic_image'] != null
                                          // Existing server image
                                          ? Stack(
                                              children: [
                                                ClipRRect(
                                                  borderRadius:
                                                      BorderRadius.circular(9),
                                                  child: Image.network(
                                                    _shopData['cnic_image']
                                                        as String,
                                                    fit: BoxFit.cover,
                                                    width: double.infinity,
                                                    height: 110,
                                                  ),
                                                ),
                                                Container(
                                                  decoration: BoxDecoration(
                                                    color: Colors.black26,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          9,
                                                        ),
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
                                          // No image yet
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
                                                  'Tap to upload CNIC image',
                                                  style:
                                                      AppTextStyles.labelMuted,
                                                ),
                                              ],
                                            ),
                                    ),
                                  ),
                                ],
                              )
                            : Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _infoRow(
                                    Icons.badge_outlined,
                                    'CNIC Number',
                                    (_shopData['cnic_number'] as String?) ??
                                        'N/A',
                                  ),
                                  _divider(),
                                  const SizedBox(height: 10),
                                  _label('CNIC Image'),
                                  if (_shopData['cnic_image'] != null)
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(10),
                                      child: Image.network(
                                        _shopData['cnic_image'] as String,
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
                              ),
                      ),
                      const SizedBox(height: 14),

                      // ── Shop Info Section ─────────────────────────────
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
                                    (_shopData['shop_name'] as String?) ??
                                        'N/A',
                                  ),
                                  _divider(),
                                  _infoRow(
                                    Icons.person_outline,
                                    'Owner Name',
                                    (_shopData['owner_name'] as String?) ??
                                        'N/A',
                                  ),
                                  _divider(),
                                  _infoRow(
                                    Icons.phone_outlined,
                                    'Phone',
                                    (_shopData['phone'] as String?) ?? 'N/A',
                                  ),
                                  _divider(),
                                  _infoRow(
                                    Icons.location_on_outlined,
                                    'Address',
                                    (_shopData['address'] as String?) ?? 'N/A',
                                  ),
                                  _divider(),
                                  _infoRow(
                                    Icons.info_outline,
                                    'Description',
                                    (_shopData['description'] as String?) ??
                                        'N/A',
                                  ),
                                ],
                              ),
                      ),
                      const SizedBox(height: 14),

                      // ── Rice Categories ───────────────────────────────
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
                                    onTap: _addCategory,
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
                                        ? 'No categories yet. Tap "Add Category".'
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
                                    const SizedBox(height: 12),
                                itemBuilder: (_, i) => _isEditing
                                    ? _buildEditCategoryCard(i)
                                    : _buildViewCategoryTile(_categories[i]),
                              ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),

                      // ── Action Buttons ────────────────────────────────
                      if (_isEditing)
                        Row(
                          children: [
                            Expanded(
                              child: ElevatedButton(
                                onPressed: () {
                                  setState(() {
                                    _isEditing = false;
                                    _cnicImageBytes = null;
                                  });
                                  _loadShopData();
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

  // ── Dispose ───────────────────────────────────────────────────────────────
  @override
  void dispose() {
    _cnicNumberCtrl.dispose();
    _shopNameCtrl.dispose();
    _ownerNameCtrl.dispose();
    _phoneCtrl.dispose();
    _addressCtrl.dispose();
    _descriptionCtrl.dispose();
    for (final c in _catNameCtrls) c.dispose();
    for (final c in _catPriceCtrls) c.dispose();
    for (final c in _catStockCtrls) c.dispose();
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
