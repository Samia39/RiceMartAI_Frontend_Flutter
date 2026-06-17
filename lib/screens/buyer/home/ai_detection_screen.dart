// ignore_for_file: deprecated_member_use

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

  // ── Camera (mobile only) ──
  CameraController? _cameraController;
  List<CameraDescription>? _cameras;
  bool _cameraOpen = false;
  bool _cameraInitializing = false;

  final ImagePicker picker = ImagePicker();

  // ── Desktop check ──
  // Desktop = Windows / macOS / Linux (not web, not mobile)
  bool get _isDesktop =>
      !kIsWeb && (Platform.isWindows || Platform.isMacOS || Platform.isLinux);

  bool get _isMobile => !kIsWeb && (Platform.isAndroid || Platform.isIOS);

  @override
  void dispose() {
    _cameraController?.dispose();
    super.dispose();
  }

  // ════════════════════════════════════════
  //  CAMERA BUTTON PRESSED
  //  → Desktop/Web: image_picker file dialog
  //  → Mobile: live camera preview
  // ════════════════════════════════════════
  Future<void> handleCameraButton() async {
    if (_isDesktop || kIsWeb) {
      // Desktop & Web: image_picker handles it natively
      await _takePhotoImagePicker();
    } else if (_isMobile) {
      // Mobile: toggle live camera preview
      if (_cameraOpen) {
        await _closeCamera();
      } else {
        await _openCamera();
      }
    }
  }

  // ════════════════════════════════════════
  //  OPEN LIVE CAMERA (mobile only)
  // ════════════════════════════════════════
  Future<void> _openCamera() async {
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

  // ════════════════════════════════════════
  //  CAPTURE PHOTO (mobile live preview)
  // ════════════════════════════════════════
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

  // ════════════════════════════════════════
  //  CLOSE CAMERA (mobile)
  // ════════════════════════════════════════
  Future<void> _closeCamera() async {
    await _cameraController?.dispose();
    _cameraController = null;
    setState(() => _cameraOpen = false);
  }

  // ════════════════════════════════════════
  //  IMAGE PICKER CAMERA (desktop + web fallback)
  //  Desktop pe: system camera app ya file dialog
  //  Web pe: browser camera popup
  // ════════════════════════════════════════
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
      // Desktop mein camera nahi hoga toh gallery suggest karo
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
            "Camera not available. Please use Gallery to select an image.",
          ),
          backgroundColor: AppColors.warning,
        ),
      );
    }
  }

  // ════════════════════════════════════════
  //  GALLERY
  // ════════════════════════════════════════
  Future<void> pickGalleryImage() async {
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

  // ════════════════════════════════════════
  //  PERMISSION DIALOG
  // ════════════════════════════════════════
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

  // ════════════════════════════════════════
  //  SEND TO SERVER & NAVIGATE
  // ════════════════════════════════════════
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

  // ════════════════════════════════════════
  //  CAMERA BUTTON LABEL & ICON
  //  changes based on platform + state
  // ════════════════════════════════════════
  String get _cameraButtonLabel {
    if (_isDesktop) return "Take Photo"; // desktop: file dialog
    if (kIsWeb) return "Take Photo"; // web: browser camera
    if (_cameraOpen) return "Close Camera"; // mobile: toggle
    return "Open Camera";
  }

  IconData get _cameraButtonIcon {
    if (_cameraOpen) return Icons.camera_alt;
    return Icons.camera_alt_outlined;
  }

  // ════════════════════════════════════════
  //  IMAGE PREVIEW WIDGET
  // ════════════════════════════════════════
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

  // ════════════════════════════════════════
  //  MAIN BUILD
  // ════════════════════════════════════════
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
                // ── Title ────────────────────────────────
                Text(
                  "Rice Category Detection",
                  style: AppTextStyles.heading2.copyWith(
                    color: AppColors.cream,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  "Upload or capture a rice image for AI analysis",
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.cream.withOpacity(0.80),
                  ),
                ),

                const SizedBox(height: 20),

                // ── Platform badge ────────────────────────
                Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.darkGreen.withOpacity(0.55),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          _isDesktop
                              ? Icons.computer
                              : kIsWeb
                              ? Icons.web
                              : Icons.smartphone,
                          color: AppColors.cream,
                          size: 14,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          _isDesktop
                              ? "Desktop Mode"
                              : kIsWeb
                              ? "Web Mode"
                              : "Mobile Mode",
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.cream,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // ── Image / Camera Preview ────────────────
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
                          ? Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  CircularProgressIndicator(
                                    color: AppColors.darkGreen,
                                  ),
                                  const SizedBox(height: 12),
                                  Text(
                                    "Opening camera...",
                                    style: AppTextStyles.bodyMedium,
                                  ),
                                ],
                              ),
                            )
                          : _buildImagePreview(),
                    ),

                    // ── Shutter overlay (mobile live preview) ──
                    if (_cameraOpen)
                      Positioned(
                        bottom: 12,
                        left: 0,
                        right: 0,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
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
                            GestureDetector(
                              onTap: _capturePhoto,
                              child: Container(
                                width: 68,
                                height: 68,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.white,
                                  border: Border.all(
                                    color: Colors.white54,
                                    width: 4,
                                  ),
                                ),
                                child: const Icon(
                                  Icons.camera_alt,
                                  color: Colors.black87,
                                  size: 32,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                    // ── Source badge (after image selected) ──
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
                                size: 13,
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

                const SizedBox(height: 20),

                // ── Gallery + Camera buttons ────────────────
                Row(
                  children: [
                    // Gallery
                    Expanded(
                      child: SizedBox(
                        height: 52,
                        child: ElevatedButton.icon(
                          onPressed: isLoading ? null : pickGalleryImage,
                          icon: const Icon(
                            Icons.photo_library_outlined,
                            size: 18,
                          ),
                          label: const Text("Gallery"),
                        ),
                      ),
                    ),

                    const SizedBox(width: 12),

                    // Camera — label & behavior changes by platform
                    Expanded(
                      child: SizedBox(
                        height: 52,
                        child: ElevatedButton.icon(
                          onPressed: isLoading ? null : handleCameraButton,
                          icon: Icon(_cameraButtonIcon, size: 18),
                          label: Text(_cameraButtonLabel),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 14),

                // ── Analyze Button ──────────────────────────
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton.icon(
                    onPressed: isLoading ? null : sendImage,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.darkGreen.withOpacity(0.80),
                      foregroundColor: AppColors.cream,
                      disabledBackgroundColor: AppColors.darkGreen.withOpacity(
                        0.35,
                      ),
                    ),
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

                // ── Loading hint ────────────────────────────
                if (isLoading) ...[
                  const SizedBox(height: 14),
                  Center(
                    child: Text(
                      "AI is analyzing your rice image...\nThis may take 10–20 seconds",
                      textAlign: TextAlign.center,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.cream.withOpacity(0.80),
                      ),
                    ),
                  ),
                ],

                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
