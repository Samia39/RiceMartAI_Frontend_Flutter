import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/services/test_service.dart';
import '../../../core/utils/themes.dart';

class AIDetectionScreen extends StatefulWidget {
  const AIDetectionScreen({super.key});

  @override
  State<AIDetectionScreen> createState() => _AIDetectionScreenState();
}

class _AIDetectionScreenState extends State<AIDetectionScreen> {
  XFile? selectedImage;

  String result = "";

  final ImagePicker picker = ImagePicker();

  // ================= GALLERY IMAGE =================
  Future<void> pickGalleryImage() async {
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      setState(() {
        selectedImage = image;
      });
    }
  }

  // ================= CAMERA IMAGE =================
  Future<void> takePhoto() async {
    final XFile? image = await picker.pickImage(source: ImageSource.camera);

    if (image != null) {
      setState(() {
        selectedImage = image;
      });
    }
  }

  // ================= SEND IMAGE =================
  Future<void> sendImage() async {
    if (selectedImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please select an image first")),
      );

      return;
    }

    bool success = await TestService.uploadImage(selectedImage!);

    if (success) {
      setState(() {
        result = "Image uploaded successfully";
      });
    } else {
      setState(() {
        result = "Upload failed";
      });
    }
  }

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

                // ================= IMAGE PREVIEW =================
                Container(
                  width: double.infinity,
                  height: 300,

                  decoration: AppDecorations.card,

                  child: selectedImage != null
                      // ================= SELECTED IMAGE =================
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(16),

                          child: Image.network(
                            selectedImage!.path,
                            fit: BoxFit.cover,
                          ),
                        )
                      // ================= EMPTY VIEW =================
                      : Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.image_outlined,
                              size: 80,
                              color: AppColors.darkGreen.withOpacity(0.5),
                            ),

                            const SizedBox(height: 12),

                            Text(
                              "No Image Selected",
                              style: AppTextStyles.bodyLarge,
                            ),
                          ],
                        ),
                ),

                const SizedBox(height: 25),

                // ================= GALLERY BUTTON =================
                SizedBox(
                  width: double.infinity,
                  height: 52,

                  child: ElevatedButton.icon(
                    onPressed: pickGalleryImage,

                    icon: const Icon(Icons.photo_library_outlined),

                    label: const Text("Upload From Gallery"),
                  ),
                ),

                const SizedBox(height: 16),

                // ================= CAMERA BUTTON =================
                SizedBox(
                  width: double.infinity,
                  height: 52,

                  child: ElevatedButton.icon(
                    onPressed: takePhoto,

                    icon: const Icon(Icons.camera_alt_outlined),

                    label: const Text("Take Photo"),
                  ),
                ),

                const SizedBox(height: 25),

                // ================= SEND BUTTON =================
                SizedBox(
                  width: double.infinity,
                  height: 52,

                  child: ElevatedButton(
                    onPressed: sendImage,

                    child: const Text("Send"),
                  ),
                ),

                const SizedBox(height: 30),

                // ================= RESULT =================
                if (result.isNotEmpty)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(18),

                    decoration: AppDecorations.card,

                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,

                      children: [
                        Text("Detection Result", style: AppTextStyles.heading3),

                        const SizedBox(height: 14),

                        Row(
                          children: [
                            Icon(
                              result == "Upload failed"
                                  ? Icons.error
                                  : Icons.check_circle,

                              color: result == "Upload failed"
                                  ? AppColors.error
                                  : AppColors.success,
                            ),

                            const SizedBox(width: 10),

                            Expanded(
                              child: Text(
                                result,

                                style: AppTextStyles.bodyLarge.copyWith(
                                  fontWeight: FontWeight.w600,

                                  color: result == "Upload failed"
                                      ? AppColors.error
                                      : AppColors.success,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
