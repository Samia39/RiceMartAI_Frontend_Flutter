import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:frontend/screens/buyer/home/ai_result.dart';
import 'package:image_picker/image_picker.dart';

import 'package:permission_handler/permission_handler.dart'
    if (dart.library.html) 'package:frontend/core/utils/permission_stubs.dart';

import '../../../core/services/test_service.dart';
import '../../../core/utils/themes.dart';

class AIDetectionScreen extends StatefulWidget {
  const AIDetectionScreen({super.key});

  @override
  State<AIDetectionScreen> createState() => _AIDetectionScreenState();
}

class _AIDetectionScreenState extends State<AIDetectionScreen> {
  XFile? selectedImage;
  bool isLoading = false;
  String? imageSourceLabel;

  // ── Camera ──
  CameraController? _cameraController;
  List<CameraDescription>? _cameras;
  bool _cameraOpen = false;
  bool _cameraInitializing = false;

  final ImagePicker picker = ImagePicker();

  @override
  void dispose() {
    _cameraController?.dispose();
    super.dispose();
  }

  // ─────────────── OPEN LIVE CAMERA ───────────────
  Future<void> _openCamera() async {
    // Web: fall back to image_picker camera (browser handles permission)
    if (kIsWeb) {
      await _takePhotoImagePicker();
      return;
    }

    // Request permission first
    final status = await Permission.camera.request();
    if (!status.isGranted) {
      if (!mounted) return;
      if (status.isPermanentlyDenied) _showPermissionSettingsDialog();
      return;
    }

    setState(() => _cameraInitializing = true);

    try {
      _cameras ??= await availableCameras();

      if (_cameras == null || _cameras!.isEmpty) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text("No cameras found on this device."),
            backgroundColor: AppColors.error,
          ),
        );
        setState(() => _cameraInitializing = false);
        return;
      }

      // Prefer rear camera
      final rear = _cameras!.firstWhere(
        (c) => c.lensDirection == CameraLensDirection.back,
        orElse: () => _cameras!.first,
      );

      _cameraController = CameraController(
        rear,
        ResolutionPreset.high,
        enableAudio: false,
      );

      await _cameraController!.initialize();

      if (!mounted) return;
      setState(() {
        _cameraOpen = true;
        _cameraInitializing = false;
      });
    } catch (e) {
      setState(() => _cameraInitializing = false);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Could not open camera: $e"),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  // ─────────────── CAPTURE FROM LIVE CAMERA ───────────────
  Future<void> _capturePhoto() async {
    if (_cameraController == null || !_cameraController!.value.isInitialized) {
      return;
    }

    try {
      final XFile photo = await _cameraController!.takePicture();

      await _cameraController!.dispose();
      _cameraController = null;

      setState(() {
        selectedImage = photo;
        imageSourceLabel = "Camera";
        _cameraOpen = false;
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Capture failed: $e"),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  // ─────────────── CLOSE CAMERA WITHOUT CAPTURING ───────────────
  Future<void> _closeCamera() async {
    await _cameraController?.dispose();
    _cameraController = null;
    setState(() => _cameraOpen = false);
  }

  // ─────────────── WEB FALLBACK ───────────────
  Future<void> _takePhotoImagePicker() async {
    try {
      final XFile? image = await picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 85,
      );
      if (image != null) {
        setState(() {
          selectedImage = image;
          imageSourceLabel = "Camera";
        });
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
            "Camera not available in browser. Please use gallery.",
          ),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  // ─────────────── GALLERY ───────────────
  Future<void> pickGalleryImage() async {
    // Close camera if open
    if (_cameraOpen) await _closeCamera();

    try {
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
      );
      if (image != null) {
        setState(() {
          selectedImage = image;
          imageSourceLabel = "Gallery";
        });
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Gallery error: $e"),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  // ─────────────── PERMISSION DIALOG ───────────────
  void _showPermissionSettingsDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Camera Permission Required"),
        content: const Text(
          "Camera access was denied. Please enable it from app Settings.",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              openAppSettings();
            },
            child: const Text("Open Settings"),
          ),
        ],
      ),
    );
  }

  // ─────────────── SEND TO SERVER ───────────────
  Future<void> sendImage() async {
    if (selectedImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please select or capture an image first"),
        ),
      );
      return;
    }

    setState(() => isLoading = true);
    final response = await TestService.uploadImage(selectedImage!);
    setState(() => isLoading = false);

    if (!mounted) return;

    if (response['success'] == true) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => AIResultScreen(result: response['data']),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(response['message'] ?? 'Analysis failed'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  // ─────────────── BUILD IMAGE PREVIEW ───────────────
  Widget _buildImagePreview() {
    if (selectedImage == null) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.image_search_rounded,
            size: 80,
            color: AppColors.darkGreen.withOpacity(0.4),
          ),
          const SizedBox(height: 12),
          Text("No Image Selected", style: AppTextStyles.bodyLarge),
          const SizedBox(height: 6),
          Text(
            "Take a photo or pick from gallery",
            style: TextStyle(
              fontSize: 13,
              color: AppColors.darkGreen.withOpacity(0.5),
            ),
          ),
        ],
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: kIsWeb
          ? Image.network(
              selectedImage!.path,
              fit: BoxFit.cover,
              width: double.infinity,
              height: double.infinity,
              errorBuilder: (_, __, ___) =>
                  const Center(child: Icon(Icons.broken_image, size: 60)),
            )
          : Image.file(
              File(selectedImage!.path),
              fit: BoxFit.cover,
              width: double.infinity,
              height: double.infinity,
            ),
    );
  }

  // ─────────────── MAIN BUILD ───────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("AI Rice Detection")),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: AppDecorations.gradientBackground,
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Rice Category Detection",
                  style: AppTextStyles.heading2.copyWith(
                    color: AppColors.cream,
                  ),
                ),

                const SizedBox(height: 25),

                // ─────────── LIVE CAMERA PREVIEW or IMAGE PREVIEW ───────────
                Stack(
                  children: [
                    Container(
                      width: double.infinity,
                      height: 300,
                      decoration: AppDecorations.card,
                      child: _cameraOpen && _cameraController != null
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(16),
                              child: CameraPreview(_cameraController!),
                            )
                          : _cameraInitializing
                          ? const Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  CircularProgressIndicator(),
                                  SizedBox(height: 12),
                                  Text("Opening camera..."),
                                ],
                              ),
                            )
                          : _buildImagePreview(),
                    ),

                    // ── Capture button overlay (shown when camera is open) ──
                    if (_cameraOpen)
                      Positioned(
                        bottom: 12,
                        left: 0,
                        right: 0,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // Close camera
                            IconButton(
                              onPressed: _closeCamera,
                              icon: const Icon(
                                Icons.close,
                                color: Colors.white,
                                size: 28,
                              ),
                              style: IconButton.styleFrom(
                                backgroundColor: Colors.black45,
                              ),
                            ),
                            const SizedBox(width: 24),
                            // Shutter button
                            GestureDetector(
                              onTap: _capturePhoto,
                              child: Container(
                                width: 64,
                                height: 64,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.white,
                                  border: Border.all(
                                    color: Colors.white38,
                                    width: 4,
                                  ),
                                ),
                                child: const Icon(
                                  Icons.camera_alt,
                                  color: Colors.black87,
                                  size: 30,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                    // ── Source badge (shown when image is captured) ──
                    if (imageSourceLabel != null && !_cameraOpen)
                      Positioned(
                        top: 10,
                        right: 10,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.black54,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                imageSourceLabel == "Camera"
                                    ? Icons.camera_alt
                                    : Icons.photo_library,
                                color: Colors.white,
                                size: 14,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                imageSourceLabel!,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),

                const SizedBox(height: 25),

                // ─────────── GALLERY BUTTON ───────────
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton.icon(
                    onPressed: isLoading ? null : pickGalleryImage,
                    icon: const Icon(Icons.photo_library_outlined),
                    label: const Text("Upload From Gallery"),
                  ),
                ),

                const SizedBox(height: 16),

                // ─────────── CAMERA BUTTON ───────────
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton.icon(
                    onPressed: isLoading
                        ? null
                        : (_cameraOpen ? _closeCamera : _openCamera),
                    icon: Icon(
                      _cameraOpen
                          ? Icons.camera_alt
                          : Icons.camera_alt_outlined,
                    ),
                    label: Text(_cameraOpen ? "Close Camera" : "Open Camera"),
                  ),
                ),

                const SizedBox(height: 25),

                // ─────────── ANALYZE BUTTON ───────────
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton.icon(
                    onPressed: isLoading ? null : sendImage,
                    icon: isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Icon(Icons.biotech_outlined),
                    label: Text(
                      isLoading ? 'Analyzing...' : 'Analyze Rice',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),

                if (isLoading) ...[
                  const SizedBox(height: 16),
                  Center(
                    child: Text(
                      "Sending to server, please wait...",
                      style: TextStyle(color: AppColors.cream, fontSize: 13),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
