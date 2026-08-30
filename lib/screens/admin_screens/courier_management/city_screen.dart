import 'package:flutter/material.dart';
import '../../../core/services/admin/city_service.dart';
import '../../../core/utils/themes.dart';

class CityScreen extends StatefulWidget {
  const CityScreen({super.key});

  @override
  State<CityScreen> createState() => _CityScreenState();
}

class _CityScreenState extends State<CityScreen> {
  final CityService _cityService = CityService();

  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _codeController = TextEditingController();
  final TextEditingController _searchController = TextEditingController();

  List _cities = [];
  List _filteredCities = [];

  bool _isLoading = true;
  bool _isSaving = false;
  int? _editingCityId;

  @override
  void initState() {
    super.initState();
    _loadCities();
    _searchController.addListener(_applySearch);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _codeController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadCities() async {
    setState(() => _isLoading = true);

    final cities = await _cityService.getCities();

    // The backend returns cities ordered alphabetically by name, but we
    // want them shown in the order they were actually added to the
    // database. Sorting by "id" (ascending) restores that insertion order
    // since IDs are auto-incremented as new cities are created.
    final sortedCities = List.from(cities)
      ..sort((a, b) {
        final idA = a['id'] ?? 0;
        final idB = b['id'] ?? 0;
        return idA.compareTo(idB);
      });

    setState(() {
      _cities = sortedCities;
      _isLoading = false;
    });

    _applySearch();
  }

  void _applySearch() {
    final query = _searchController.text.trim().toLowerCase();
    setState(() {
      if (query.isEmpty) {
        _filteredCities = List.from(_cities);
      } else {
        _filteredCities = _cities.where((city) {
          final name = (city['name'] ?? '').toString().toLowerCase();
          final code = (city['code'] ?? '').toString().toLowerCase();
          return name.contains(query) || code.contains(query);
        }).toList();
      }
    });
  }

  void _resetForm() {
    _formKey.currentState?.reset();
    _nameController.clear();
    _codeController.clear();
    setState(() => _editingCityId = null);
  }

  void _startEdit(Map city) {
    setState(() {
      _editingCityId = city['id'];
      _nameController.text = city['name'] ?? '';
      _codeController.text = city['code'] ?? '';
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

  Future<void> _saveCity() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    final name = _nameController.text.trim();
    final code = _codeController.text.trim();

    Map<String, dynamic> result;
    if (_editingCityId == null) {
      result = await _cityService.addCity(name: name, code: code);
    } else {
      result = await _cityService.updateCity(
        cityId: _editingCityId!,
        name: name,
        code: code,
      );
    }

    setState(() => _isSaving = false);

    if (result['success'] == true) {
      _showSnack(result['message'] ?? 'Saved successfully.');
      _resetForm();
      _loadCities();
    } else {
      _showSnack(result['message'] ?? 'Something went wrong.', isError: true);
    }
  }

  Future<void> _confirmDelete(Map city) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.cream,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        title: Text('Delete City', style: AppTextStyles.heading3),
        content: Text(
          'Are you sure you want to delete "${city['name']}"?',
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
      final result = await _cityService.deleteCity(city['id']);
      if (result['success'] == true) {
        _showSnack(result['message'] ?? 'City deleted successfully.');
        if (_editingCityId == city['id']) _resetForm();
        _loadCities();
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
        title: const Text('Cities'),
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
                  onRefresh: _loadCities,
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                    children: [
                      _buildFormCard(),
                      const SizedBox(height: 16),
                      _buildSearchField(),
                      const SizedBox(height: 12),
                      _buildCountRow(),
                      const SizedBox(height: 8),
                      _buildCityList(),
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
                    _editingCityId == null ? Icons.add : Icons.edit,
                    size: 16,
                    color: AppColors.cream,
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  _editingCityId == null ? 'Add City' : 'Edit City',
                  style: AppTextStyles.heading4,
                ),
                const Spacer(),
                if (_editingCityId != null)
                  TextButton(
                    style: AppButtonStyles.ghost,
                    onPressed: _resetForm,
                    child: Text('Cancel', style: AppTextStyles.bodySmall),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _nameController,
              style: AppTextStyles.bodyLarge,
              decoration: const InputDecoration(
                hintText: 'Name',
                prefixIcon: Icon(Icons.location_city_outlined),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'City name is required';
                }
                return null;
              },
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _codeController,
              style: AppTextStyles.bodyLarge,
              decoration: const InputDecoration(
                hintText: 'Code (optional)',
                prefixIcon: Icon(Icons.tag_outlined),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isSaving ? null : _saveCity,
                child: _isSaving
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppColors.darkGreen,
                        ),
                      )
                    : Text(_editingCityId == null ? 'Save' : 'Update'),
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
          hintText: 'Search cities...',
          prefixIcon: Icon(Icons.search),
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
        ),
      ),
    );
  }

  // Shows how many cities are currently in the (filtered) list,
  // e.g. "1 city" / "3 cities".
  Widget _buildCountRow() {
    final count = _filteredCities.length;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Text(
        '$count ${count == 1 ? 'city' : 'cities'}',
        style: AppTextStyles.sectionTitle,
      ),
    );
  }

  // ── City list ────────────────────────────────────────────────
  // Renders each city as its OWN card (instead of one big container with
  // dividers) and separates them with a SizedBox, so cards never look
  // merged together — matches the spacing seen on the web screen.
  Widget _buildCityList() {
    if (_filteredCities.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 40),
        decoration: AppDecorations.card,
        alignment: Alignment.center,
        child: Text('No cities found', style: AppTextStyles.bodyMedium),
      );
    }

    return Column(
      children: List.generate(_filteredCities.length, (index) {
        final city = _filteredCities[index];
        final isLast = index == _filteredCities.length - 1;

        return Padding(
          // No bottom padding on the last card so the list doesn't end
          // with extra empty space.
          padding: EdgeInsets.only(bottom: isLast ? 0 : 12),
          child: _buildCityCard(city, index),
        );
      }),
    );
  }

  // A single city row, wrapped in the theme's standard card decoration
  // (rounded corners + gold border + soft shadow), same style used by
  // the Add/Edit form card above.
  Widget _buildCityCard(Map city, int index) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: AppDecorations.card,
      child: Row(
        children: [
          // Sequence number badge (1, 2, 3...) reflecting DB insertion order.
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

          // City name + code (code only shown if it exists).
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  city['name'] ?? '',
                  style: AppTextStyles.bodyLarge.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                if ((city['code'] ?? '').toString().isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    city['code'].toString(),
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.golden,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ],
            ),
          ),

          // Edit button — loads this city into the form above.
          IconButton(
            visualDensity: VisualDensity.compact,
            icon: Icon(Icons.edit_outlined, size: 19, color: AppColors.info),
            onPressed: () => _startEdit(city),
          ),

          // Delete button — asks for confirmation first.
          IconButton(
            visualDensity: VisualDensity.compact,
            icon: Icon(Icons.delete_outline, size: 19, color: AppColors.error),
            onPressed: () => _confirmDelete(city),
          ),
        ],
      ),
    );
  }
}
