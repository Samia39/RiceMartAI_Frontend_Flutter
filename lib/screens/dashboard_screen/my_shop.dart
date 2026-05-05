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
  Uint8List? _cnicImageBytes; // non-null = newly picked

  // ── Category controllers stored in STATE (never recreated in build) ───────
  final List<TextEditingController> _nameCtrl = [];
  final List<TextEditingController> _priceCtrl = [];
  final List<TextEditingController> _stockCtrl = [];

  // Per-category: { 'imageUrl': String?, 'existingImage': String?, 'imageBytes': Uint8List? }
  List<Map<String, dynamic>> _catMeta = [];

  @override
  void initState() {
    super.initState();
    _loadShopData();
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

      // Dispose old category controllers
      for (int i = 0; i < _nameCtrl.length; i++) {
        _nameCtrl[i].dispose();
        _priceCtrl[i].dispose();
        _stockCtrl[i].dispose();
      }
      _nameCtrl.clear();
      _priceCtrl.clear();
      _stockCtrl.clear();
      _catMeta.clear();

      final cats = shop['rice_categories'];
      if (cats is List) {
        for (final c in cats) {
          _nameCtrl.add(
            TextEditingController(text: (c['name'] as String?) ?? ''),
          );
          _priceCtrl.add(
            TextEditingController(text: (c['price_per_kg'] ?? 0).toString()),
          );
          _stockCtrl.add(
            TextEditingController(text: (c['stock_kg'] ?? 0).toString()),
          );
          _catMeta.add({
            'imageUrl': c['image_url'] as String?, // full URL for display
            'existingImage': c['image'] as String?, // raw path sent on update
            'imageBytes': null,
          });
        }
      }
    } else {
      Get.snackbar(
        'Error',
        (result['message'] as String?) ?? 'Failed to load shop',
      );
    }

    setState(() => _isLoading = false);
  }

  // ── Pick CNIC image ───────────────────────────────────────────────────────
  Future<void> _pickCnicImage() async {
    final XFile? f = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
    );
    if (f != null) {
      final bytes = await f.readAsBytes();
      setState(() => _cnicImageBytes = bytes); // ✅ only updates _cnicImageBytes
    }
  }

  // ── Pick category image ───────────────────────────────────────────────────
  Future<void> _pickCategoryImage(int i) async {
    final XFile? f = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );
    if (f != null) {
      final bytes = await f.readAsBytes();
      setState(() {
        _catMeta[i]['imageBytes'] = bytes;
        _catMeta[i]['imageUrl'] = null; // hide old network image
      });
    }
  }

  // ── Add blank category ────────────────────────────────────────────────────
  void _addCategory() {
    setState(() {
      _nameCtrl.add(TextEditingController());
      _priceCtrl.add(TextEditingController());
      _stockCtrl.add(TextEditingController());
      _catMeta.add({
        'imageUrl': null,
        'existingImage': null,
        'imageBytes': null,
      });
    });
  }

  // ── Remove category ───────────────────────────────────────────────────────
  void _removeCategory(int i) {
    _nameCtrl[i].dispose();
    _priceCtrl[i].dispose();
    _stockCtrl[i].dispose();
    setState(() {
      _nameCtrl.removeAt(i);
      _priceCtrl.removeAt(i);
      _stockCtrl.removeAt(i);
      _catMeta.removeAt(i);
    });
  }

  // ── Save ──────────────────────────────────────────────────────────────────
  Future<void> _saveChanges() async {
    if (_shopNameCtrl.text.isEmpty ||
        _ownerNameCtrl.text.isEmpty ||
        _phoneCtrl.text.isEmpty ||
        _addressCtrl.text.isEmpty) {
      Get.snackbar('Error', 'Please fill all required fields');
      return;
    }
    for (int i = 0; i < _nameCtrl.length; i++) {
      if (_nameCtrl[i].text.trim().isEmpty) {
        Get.snackbar('Error', 'Category ${i + 1} needs a name');
        return;
      }
    }

    setState(() => _isSaving = true);

    final categories = List.generate(
      _nameCtrl.length,
      (i) => {
        'name': _nameCtrl[i].text.trim(),
        'price_per_kg': double.tryParse(_priceCtrl[i].text) ?? 0.0,
        'stock_kg': double.tryParse(_stockCtrl[i].text) ?? 0.0,
        'existingImage': _catMeta[i]['existingImage'], // raw path or null
        'imageBytes': _catMeta[i]['imageBytes'], // new bytes or null
      },
    );

    final result = await ShopService.updateShop(
      shopId: _shopData['id'].toString(),
      shopName: _shopNameCtrl.text.trim(),
      ownerName: _ownerNameCtrl.text.trim(),
      phone: _phoneCtrl.text.trim(),
      address: _addressCtrl.text.trim(),
      description: _descriptionCtrl.text.trim(),
      cnicNumber: _cnicNumberCtrl.text.trim().isNotEmpty
          ? _cnicNumberCtrl.text.trim()
          : null,
      cnicImageBytes: _cnicImageBytes,
      riceCategories: categories,
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
      final errors = result['errors'] as Map<String, dynamic>?;
      if (errors != null && errors.isNotEmpty) {
        final msg = errors.entries
            .map((e) => '${e.key}: ${(e.value as List).first}')
            .join('\n');
        Get.snackbar(
          'Validation Error',
          msg,
          duration: const Duration(seconds: 6),
          snackPosition: SnackPosition.BOTTOM,
        );
      } else {
        Get.snackbar('Error', result['message'] ?? 'Update failed');
      }
    }
  }

  // ── Delete ────────────────────────────────────────────────────────────────
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

  // ─────────────────────────────────────────────────────────────────────────
  //  BUILDERS
  // ─────────────────────────────────────────────────────────────────────────

  Widget _label(String text) => Padding(
    padding: const EdgeInsets.only(bottom: 6),
    child: Text(text, style: AppTextStyles.labelMuted),
  );

  Widget _sectionCard({
    required String title,
    IconData? icon,
    required Widget child,
  }) => Container(
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

  Widget _buildField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
    List<TextInputFormatter>? inputFormatters,
  }) => Container(
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

  // ── Category edit card — uses controllers from STATE ──────────────────────
  Widget _buildEditCategoryCard(int i) {
    final meta = _catMeta[i];
    final newBytes = meta['imageBytes'] as Uint8List?;
    final imageUrl = meta['imageUrl'] as String?;

    return Container(
      decoration: AppDecorations.card,
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Category ${i + 1}', style: AppTextStyles.heading4),
              GestureDetector(
                onTap: () => _removeCategory(i),
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

          // Rice Name
          _label('Rice Name'),
          Container(
            decoration: AppDecorations.inputField,
            child: TextField(
              controller: _nameCtrl[i], // ✅ stable controller from state
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

          // Rice Image
          _label('Rice Image'),
          GestureDetector(
            onTap: () => _pickCategoryImage(i),
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
                            errorBuilder: (_, __, ___) => _imgPlaceholder(),
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
                  : _imgPlaceholder(),
            ),
          ),
          const SizedBox(height: 12),

          // Stock + Price
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
                        controller: _stockCtrl[i], // ✅ stable
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
                        controller: _priceCtrl[i], // ✅ stable
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

  Widget _imgPlaceholder() => Column(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      Icon(Icons.upload_outlined, size: 28, color: AppColors.iconMuted),
      const SizedBox(height: 6),
      Text('Tap to update image', style: AppTextStyles.labelMuted),
    ],
  );

  // ── View-mode category tile ───────────────────────────────────────────────
  Widget _buildViewCategoryTile(int i) {
    final meta = _catMeta[i];
    final imageUrl = meta['imageUrl'] as String?;
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
                    errorBuilder: (_, __, ___) => _catIconBox(),
                  )
                : _catIconBox(),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(_nameCtrl[i].text, style: AppTextStyles.bodyLarge),
                const SizedBox(height: 2),
                Text(
                  'Stock: ${_stockCtrl[i].text} kg',
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
              'PKR ${_priceCtrl[i].text}',
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

  Widget _catIconBox() => Container(
    width: 48,
    height: 48,
    decoration: BoxDecoration(
      color: AppColors.inputFill,
      borderRadius: BorderRadius.circular(8),
    ),
    child: Icon(Icons.grain, size: 24, color: AppColors.golden),
  );

  Widget _quickStatItem({
    required IconData icon,
    required String label,
    required String value,
  }) => Expanded(
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

  Widget _approvalBadge() {
    final ok =
        _shopData['is_approved'] == true || _shopData['is_approved'] == 1;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: (ok ? AppColors.success : AppColors.warning).withOpacity(0.15),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: (ok ? AppColors.success : AppColors.warning).withOpacity(0.35),
        ),
      ),
      child: Text(
        ok ? '✅ Approved' : '⏳ Pending',
        style: AppTextStyles.bodySmall.copyWith(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          color: ok ? AppColors.success : AppColors.warning,
        ),
      ),
    );
  }

  // ── Main build ────────────────────────────────────────────────────────────
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
              // ── Header ─────────────────────────────────────────────────
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
                            value: _nameCtrl.length.toString(),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),

              // ── Body ───────────────────────────────────────────────────
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(16, 20, 16, 28),
                  child: Column(
                    children: [
                      // Overview card (view only)
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

                      // ── CNIC ─────────────────────────────────────────
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
                                  // ✅ CNIC image picker — works independently
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
                                          // Newly picked bytes
                                          ? ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(9),
                                              child: Image.memory(
                                                _cnicImageBytes!,
                                                fit: BoxFit.cover,
                                              ),
                                            )
                                          : _shopData['cnic_image'] != null
                                          // Existing network image
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

                      // ── Shop Info ─────────────────────────────────────
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
                                        '${_nameCtrl.length} items',
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

                            if (_nameCtrl.isEmpty)
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
                                itemCount: _nameCtrl.length,
                                separatorBuilder: (_, __) =>
                                    const SizedBox(height: 12),
                                itemBuilder: (_, i) => _isEditing
                                    ? _buildEditCategoryCard(i)
                                    : _buildViewCategoryTile(i),
                              ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),

                      // ── Buttons ───────────────────────────────────────
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

  @override
  void dispose() {
    _cnicNumberCtrl.dispose();
    _shopNameCtrl.dispose();
    _ownerNameCtrl.dispose();
    _phoneCtrl.dispose();
    _addressCtrl.dispose();
    _descriptionCtrl.dispose();
    for (int i = 0; i < _nameCtrl.length; i++) {
      _nameCtrl[i].dispose();
      _priceCtrl[i].dispose();
      _stockCtrl[i].dispose();
    }
    super.dispose();
  }
}

// ── CNIC formatter ────────────────────────────────────────────────────────────
class _CnicFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue old,
    TextEditingValue next,
  ) {
    final digits = next.text.replaceAll('-', '');
    if (digits.length > 13) return old;
    final buf = StringBuffer();
    for (int i = 0; i < digits.length; i++) {
      if (i == 5 || i == 12) buf.write('-');
      buf.write(digits[i]);
    }
    final f = buf.toString();
    return TextEditingValue(
      text: f,
      selection: TextSelection.collapsed(offset: f.length),
    );
  }
}
