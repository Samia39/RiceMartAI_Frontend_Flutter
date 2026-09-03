import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../core/services/rice_detection_service.dart';
import '../models/rice_detection_result.dart';
import 'user_dashboard.dart'; // AppColors, AppGradients, AppTextStyles yahan se aa rahe hain

class AiRiceDetectionScreen extends StatefulWidget {
  const AiRiceDetectionScreen({super.key});

  @override
  State<AiRiceDetectionScreen> createState() => _AiRiceDetectionScreenState();
}

class _AiRiceDetectionScreenState extends State<AiRiceDetectionScreen> {
  Uint8List? _selectedImageBytes;
  String? _selectedFileName;
  bool _isLoading = false;
  RiceDetectionResult? _result;
  String? _error;

  Future<void> _pickImage(ImageSource source) async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: source, imageQuality: 80);
    if (picked != null) {
      final bytes = await picked.readAsBytes();
      setState(() {
        _selectedImageBytes = bytes;
        _selectedFileName = picked.name;
        _result = null;
        _error = null;
      });
      _uploadAndDetect();
    }
  }

  Future<void> _uploadAndDetect() async {
    if (_selectedImageBytes == null) return;
    setState(() {
      _isLoading = true;
      _error = null;
    });
    final stopwatch = Stopwatch()..start();
    try {
      final result = await RiceDetectionService.detectRice(
        _selectedImageBytes!,
        _selectedFileName ?? 'rice_image.jpg',
      );
      stopwatch.stop();
      setState(() {
        _result = result.copyWith(processingTimeMs: stopwatch.elapsedMilliseconds);
        _isLoading = false;
      });
    } catch (e) {
      stopwatch.stop();
      setState(() {
        _error = "Detection failed: $e";
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppGradients.background),
        child: SafeArea(
          child: Column(
            children: [
              // Custom header (back button + title) — matches app's icon style
              Padding(
                padding: const EdgeInsets.fromLTRB(10, 10, 16, 6),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.cream.withOpacity(0.25),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                              color: AppColors.borderGold.withOpacity(0.50)),
                        ),
                        child: Icon(Icons.arrow_back,
                            color: AppColors.darkGreen, size: 20),
                      ),
                    ),
                    const SizedBox(width: 14),
                    const Text(
                      "AI Rice Category Detection",
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                        color: AppColors.darkGreen,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      GestureDetector(
                        onTap: _showImageSourceSheet,
                        child: Container(
                          height: 220,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: AppColors.cardFill,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: AppColors.cardBorder, width: 1.5),
                          ),
                          child: _selectedImageBytes == null
                              ? Center(
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(Icons.cloud_upload_outlined,
                                          color: AppColors.iconMuted, size: 40),
                                      const SizedBox(height: 8),
                                      Text("Tap to upload rice image",
                                          style: AppTextStyles.labelMuted),
                                    ],
                                  ),
                                )
                              : ClipRRect(
                                  borderRadius: BorderRadius.circular(20),
                                  child: Image.memory(_selectedImageBytes!,
                                      fit: BoxFit.cover),
                                ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      if (_isLoading)
                        Column(
                          children: [
                            CircularProgressIndicator(color: AppColors.darkGreen),
                            const SizedBox(height: 10),
                            Text("Detecting rice category...",
                                style: AppTextStyles.labelMuted),
                          ],
                        ),
                      if (_error != null)
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppColors.error.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                                color: AppColors.error.withOpacity(0.4)),
                          ),
                          child: Text(_error!,
                              style: TextStyle(color: AppColors.darkGreen)),
                        ),
                      if (_result != null) _buildResultCard(_result!),
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

  void _showImageSourceSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => Container(
        decoration: BoxDecoration(
          gradient: AppGradients.background,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: Icon(Icons.camera_alt, color: AppColors.darkGreen),
                title: Text("Take Photo",
                    style: TextStyle(
                        color: AppColors.darkGreen, fontFamily: 'Poppins')),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.camera);
                },
              ),
              ListTile(
                leading: Icon(Icons.photo_library, color: AppColors.darkGreen),
                title: Text("Choose from Gallery",
                    style: TextStyle(
                        color: AppColors.darkGreen, fontFamily: 'Poppins')),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.gallery);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildResultCard(RiceDetectionResult result) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.cardFill,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.rice_bowl, color: AppColors.darkGreen),
              const SizedBox(width: 8),
              Expanded(
                child: Text(result.category, style: AppTextStyles.heading3),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.lightGreen.withOpacity(0.35),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text("${(result.confidence * 100).toStringAsFixed(1)}%",
                    style: TextStyle(
                        color: AppColors.darkGreen,
                        fontSize: 12,
                        fontWeight: FontWeight.bold)),
              ),
            ],
          ),
          Divider(color: AppColors.divider, height: 28),
          _detailRow(Icons.timer_outlined, "Detection Time",
              "${result.processingTimeMs} ms"),
          const SizedBox(height: 12),
          _detailRow(Icons.local_fire_department_outlined, "Cooking Time",
              result.cookingTime),
          const SizedBox(height: 12),
          _detailRow(Icons.restaurant_menu, "Commonly Used For", result.commonUses),
          const SizedBox(height: 12),
          _detailRow(Icons.info_outline, "Description", result.description),
        ],
      ),
    );
  }

  Widget _detailRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: AppColors.iconMuted, size: 20),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: AppTextStyles.bodySmall),
              const SizedBox(height: 2),
              Text(value, style: AppTextStyles.bodyLarge),
            ],
          ),
        ),
      ],
    );
  }
}