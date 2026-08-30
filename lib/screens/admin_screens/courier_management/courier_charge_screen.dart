import 'package:flutter/material.dart';
import '../../../core/services/admin/courier_charge_service.dart';
// ignore: depend_on_referenced_packages
import 'package:ricemart_ai/core/utils/themes.dart';

class CourierChargeScreen extends StatefulWidget {
  const CourierChargeScreen({super.key});

  @override
  State<CourierChargeScreen> createState() => _CourierChargeScreenState();
}

class _CourierChargeScreenState extends State<CourierChargeScreen> {
  final CourierChargeService _chargeService = CourierChargeService();

  final _formKey = GlobalKey<FormState>();
  final TextEditingController _chargeController = TextEditingController();
  final TextEditingController _searchController = TextEditingController();

  // Full list of courier charges (as returned by the backend) and the
  // subset currently visible after the search filter is applied.
  List _charges = [];
  List _filteredCharges = [];

  // Cities that don't already have a courier charge assigned — these are
  // the only ones normally allowed to be picked from the dropdown.
  List _availableCities = [];

  bool _isLoading = true;
  bool _isSaving = false;

  // When editing, holds the id of the charge being edited (null = add mode).
  int? _editingChargeId;
  int? _selectedCityId;

  // When we start editing a charge, its city is stored here. That city
  // already has a charge (itself), so it won't be in `_availableCities` —
  // we need to inject it back into the dropdown manually so it still shows
  // as selected while editing.
  Map? _editingCityData;

  @override
  void initState() {
    super.initState();
    _loadData();
    _searchController.addListener(_applySearch);
  }

  @override
  void dispose() {
    _chargeController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  // Loads both the courier charges list and the list of cities that are
  // still available to be assigned a charge (used for the dropdown).
  Future<void> _loadData() async {
    setState(() => _isLoading = true);

    final results = await Future.wait([
      _chargeService.getCourierCharges(),
      _chargeService.getAvailableCities(),
    ]);

    setState(() {
      _charges = results[0];
      _availableCities = results[1];
      _isLoading = false;
    });

    _applySearch();
  }

  void _applySearch() {
    final query = _searchController.text.trim().toLowerCase();
    setState(() {
      if (query.isEmpty) {
        _filteredCharges = List.from(_charges);
      } else {
        _filteredCharges = _charges.where((item) {
          final cityName = (item['city']?['name'] ?? '')
              .toString()
              .toLowerCase();
          final charge = (item['charge'] ?? '').toString().toLowerCase();
          return cityName.contains(query) || charge.contains(query);
        }).toList();
      }
    });
  }

  // Cities available for selection in the dropdown: the "available" cities
  // from the backend, plus (while editing) the city already assigned to
  // the charge being edited, so it doesn't disappear from the list.
  List get _dropdownCities {
    final list = List<Map>.from(_availableCities);
    if (_editingCityData != null &&
        !list.any((c) => c['id'] == _editingCityData!['id'])) {
      list.add(_editingCityData!);
    }
    list.sort(
      (a, b) =>
          (a['name'] ?? '').toString().compareTo((b['name'] ?? '').toString()),
    );
    return list;
  }

  void _resetForm() {
    _formKey.currentState?.reset();
    _chargeController.clear();
    setState(() {
      _editingChargeId = null;
      _selectedCityId = null;
      _editingCityData = null;
    });
  }

  void _startEdit(Map item) {
    setState(() {
      _editingChargeId = item['id'];
      _editingCityData = item['city'];
      _selectedCityId = item['city']?['id'];
      _chargeController.text = (item['charge'] ?? '').toString();
    });
  }

  void _showSnack(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: AppTextStyles.bodyLarge.copyWith(
            color: isError ? AppColors.error : AppColors.darkGreen,
          ),
        ),
      ),
    );
  }

  Future<void> _saveCharge() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedCityId == null) {
      _showSnack('Please select a city.', isError: true);
      return;
    }

    setState(() => _isSaving = true);

    final charge = _chargeController.text.trim();

    Map<String, dynamic> result;
    if (_editingChargeId == null) {
      result = await _chargeService.addCourierCharge(
        cityId: _selectedCityId!,
        charge: charge,
      );
    } else {
      result = await _chargeService.updateCourierCharge(
        chargeId: _editingChargeId!,
        cityId: _selectedCityId!,
        charge: charge,
      );
    }

    setState(() => _isSaving = false);

    if (result['success'] == true) {
      _showSnack(result['message'] ?? 'Saved successfully.');
      _resetForm();
      _loadData();
    } else {
      _showSnack(result['message'] ?? 'Something went wrong.', isError: true);
    }
  }

  Future<void> _confirmDelete(Map item) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.cream,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        title: Text('Delete Courier Charge', style: AppTextStyles.heading3),
        content: Text(
          'Are you sure you want to delete the charge for "${item['city']?['name'] ?? ''}"?',
          style: AppTextStyles.bodyMedium,
        ),
        actions: [
          TextButton(
            style: AppButtonStyles.ghost,
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            style: AppButtonStyles.ghost,
            onPressed: () => Navigator.pop(context, true),
            child: Text('Delete', style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final result = await _chargeService.deleteCourierCharge(item['id']);
      if (result['success'] == true) {
        _showSnack(result['message'] ?? 'Courier charge deleted successfully.');
        if (_editingChargeId == item['id']) _resetForm();
        _loadData();
      } else {
        _showSnack(result['message'] ?? 'Delete failed.', isError: true);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('Courier Charges'),
        leading: IconButton(
          icon: Container(
            padding: const EdgeInsets.all(6),
            decoration: AppDecorations.iconButton,
            child: const Icon(Icons.arrow_back, size: 18),
          ),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: AppDecorations.gradientBackground,
        child: SafeArea(
          child: _isLoading
              ? const Center(
                  child: CircularProgressIndicator(color: AppColors.darkGreen),
                )
              : RefreshIndicator(
                  color: AppColors.darkGreen,
                  onRefresh: _loadData,
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                    children: [
                      _buildFormCard(),
                      const SizedBox(height: 16),
                      _buildSearchField(),
                      const SizedBox(height: 12),
                      _buildCountRow(),
                      const SizedBox(height: 8),
                      _buildChargeList(),
                    ],
                  ),
                ),
        ),
      ),
    );
  }

  // ── Add / Edit form card ───────────────────────────────────
  Widget _buildFormCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: AppDecorations.card,
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: AppColors.darkGreen,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    _editingChargeId == null ? Icons.add : Icons.edit,
                    size: 16,
                    color: AppColors.cream,
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  _editingChargeId == null
                      ? 'Add Courier Charge'
                      : 'Edit Courier Charge',
                  style: AppTextStyles.heading4,
                ),
                const Spacer(),
                if (_editingChargeId != null)
                  TextButton(
                    style: AppButtonStyles.ghost,
                    onPressed: _resetForm,
                    child: Text('Cancel', style: AppTextStyles.bodySmall),
                  ),
              ],
            ),
            const SizedBox(height: 16),

            // City label (matches the "City" label seen above the
            // dropdown on the web screen).
            Text('City', style: AppTextStyles.label),
            const SizedBox(height: 6),

            // City dropdown — picks from `_dropdownCities`, which is the
            // list of cities without a charge yet (plus the current city
            // when editing).
            DropdownButtonFormField<int>(
              initialValue: _selectedCityId,
              isExpanded: true,
              icon: const Icon(Icons.keyboard_arrow_down),
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.location_city_outlined),
                hintText: 'Select city',
              ),
              style: AppTextStyles.bodyLarge,
              items: _dropdownCities.map<DropdownMenuItem<int>>((city) {
                return DropdownMenuItem<int>(
                  value: city['id'],
                  child: Text(city['name'] ?? ''),
                );
              }).toList(),
              onChanged: (value) => setState(() => _selectedCityId = value),
              validator: (value) =>
                  value == null ? 'Please select a city' : null,
            ),
            const SizedBox(height: 12),

            // Charge amount field.
            TextFormField(
              controller: _chargeController,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              style: AppTextStyles.bodyLarge,
              decoration: const InputDecoration(
                hintText: 'Charge (PKR)',
                prefixIcon: Icon(Icons.attach_money),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Charge amount is required';
                }
                final parsed = num.tryParse(value.trim());
                if (parsed == null || parsed < 0) {
                  return 'Enter a valid amount';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isSaving ? null : _saveCharge,
                child: _isSaving
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppColors.darkGreen,
                        ),
                      )
                    : Text(_editingChargeId == null ? 'Save' : 'Update'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Search field ────────────────────────────────────────────
  Widget _buildSearchField() {
    return Container(
      decoration: AppDecorations.inputField,
      child: TextField(
        controller: _searchController,
        style: AppTextStyles.bodyLarge,
        decoration: const InputDecoration(
          hintText: 'Search charges...',
          prefixIcon: Icon(Icons.search),
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
        ),
      ),
    );
  }

  // Shows how many charges are currently in the (filtered) list,
  // e.g. "1 charge" / "4 charges".
  Widget _buildCountRow() {
    final count = _filteredCharges.length;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Text(
        '$count ${count == 1 ? 'charge' : 'charges'}',
        style: AppTextStyles.sectionTitle,
      ),
    );
  }

  // ── Courier charge list ─────────────────────────────────────
  // Each entry is its own card (proper spacing between them) instead of
  // one merged container with dividers.
  Widget _buildChargeList() {
    if (_filteredCharges.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 40),
        decoration: AppDecorations.card,
        alignment: Alignment.center,
        child: Text(
          'No courier charges found',
          style: AppTextStyles.bodyMedium,
        ),
      );
    }

    return Column(
      children: List.generate(_filteredCharges.length, (index) {
        final item = _filteredCharges[index];
        final isLast = index == _filteredCharges.length - 1;

        return Padding(
          padding: EdgeInsets.only(bottom: isLast ? 0 : 12),
          child: _buildChargeCard(item, index),
        );
      }),
    );
  }

  Widget _buildChargeCard(Map item, int index) {
    final cityName = item['city']?['name'] ?? '';
    final charge = item['charge']?.toString() ?? '';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: AppDecorations.card,
      child: Row(
        children: [
          // Sequence number badge.
          Container(
            width: 28,
            height: 28,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: AppColors.overlayLight,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.borderGold.withOpacity(0.5)),
            ),
            child: Text(
              '${index + 1}',
              style: AppTextStyles.bodySmall.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(width: 12),

          // City name + charge amount.
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  cityName,
                  style: AppTextStyles.bodyLarge.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  'PKR $charge',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.darkGreen.withOpacity(0.75),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),

          // Edit button.
          IconButton(
            visualDensity: VisualDensity.compact,
            icon: Icon(Icons.edit_outlined, size: 19, color: AppColors.info),
            onPressed: () => _startEdit(item),
          ),

          // Delete button.
          IconButton(
            visualDensity: VisualDensity.compact,
            icon: Icon(Icons.delete_outline, size: 19, color: AppColors.error),
            onPressed: () => _confirmDelete(item),
          ),
        ],
      ),
    );
  }
}
