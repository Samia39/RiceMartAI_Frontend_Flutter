import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../services/rice_detection_service.dart';
import '../models/rice_detection_result.dart';

class AiRiceDetectionScreen extends StatefulWidget {
  const AiRiceDetectionScreen({super.key});

  @override
  State<AiRiceDetectionScreen> createState() => _AiRiceDetectionScreenState();
}

class _AiRiceDetectionScreenState extends State<AiRiceDetectionScreen> {
  File? _selectedImage;
  bool _isLoading = false;
  RiceDetectionResult? _result;
  String? _error;

  Future<void> _pickImage(ImageSource source) async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: source, imageQuality: 80);
    if (picked != null) {
      setState(() {
        _selectedImage = File(picked.path);
        _result = null;
        _error = null;
      });
      _uploadAndDetect();
    }
  }

  Future<void> _uploadAndDetect() async {
    if (_selectedImage == null) return;
    setState(() {
      _isLoading = true;
      _error = null;
    });
    final stopwatch = Stopwatch()..start();
    try {
      final result = await RiceDetectionService.detectRice(_selectedImage!);
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
      backgroundColor: const Color(0xFF6B7A5E),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text("AI Rice Category Detection",
            style: TextStyle(color: Colors.white, fontSize: 18)),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            GestureDetector(
              onTap: _showImageSourceSheet,
              child: Container(
                height: 220,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.white38, width: 1.5),
                ),
                child: _selectedImage == null
                    ? const Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.cloud_upload_outlined,
                                color: Colors.white70, size: 40),
                            SizedBox(height: 8),
                            Text("Tap to upload rice image",
                                style: TextStyle(color: Colors.white70)),
                          ],
                        ),
                      )
                    : ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: Image.file(_selectedImage!, fit: BoxFit.cover),
                      ),
              ),
            ),
            const SizedBox(height: 20),
            if (_isLoading)
              const Column(
                children: [
                  CircularProgressIndicator(color: Colors.white),
                  SizedBox(height: 10),
                  Text("Detecting rice category...",
                      style: TextStyle(color: Colors.white70)),
                ],
              ),
            if (_error != null)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(_error!, style: const TextStyle(color: Colors.white)),
              ),
            if (_result != null) _buildResultCard(_result!),
          ],
        ),
      ),
    );
  }

  void _showImageSourceSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF6B7A5E),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt, color: Colors.white),
              title: const Text("Take Photo", style: TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library, color: Colors.white),
              title: const Text("Choose from Gallery",
                  style: TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.gallery);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResultCard(RiceDetectionResult result) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.rice_bowl, color: Colors.white),
              const SizedBox(width: 8),
              Text(result.category,
                  style: const TextStyle(
                      color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text("${(result.confidence * 100).toStringAsFixed(1)}%",
                    style: const TextStyle(color: Colors.white, fontSize: 12)),
              ),
            ],
          ),
          const Divider(color: Colors.white24, height: 28),
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
        Icon(icon, color: Colors.white70, size: 20),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(color: Colors.white54, fontSize: 12)),
              const SizedBox(height: 2),
              Text(value, style: const TextStyle(color: Colors.white, fontSize: 14)),
            ],
          ),
        ),
      ],
    );
  }
}