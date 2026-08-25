import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/services/complaint_service.dart';
import '../../../core/utils/themes.dart';

class SellerNewComplaintScreen extends StatefulWidget {
  const SellerNewComplaintScreen({super.key});

  @override
  State<SellerNewComplaintScreen> createState() =>
      _SellerNewComplaintScreenState();
}

class _SellerNewComplaintScreenState extends State<SellerNewComplaintScreen> {
  final _formKey = GlobalKey<FormState>();
  final _subjectController = TextEditingController();
  final _messageController = TextEditingController();
  final ComplaintService _service = ComplaintService();

  String _category = 'other';

  Uint8List? _attachmentBytes;
  String? _attachmentFileName;

  bool _submitting = false;

  final _categories = const {
    'payment': 'Payment Issue',
    'order': 'Order Issue',
    'account': 'Account Issue',
    'other': 'Other',
  };

  final _categoryIcons = const {
    'payment': Icons.payments_outlined,
    'order': Icons.shopping_bag_outlined,
    'account': Icons.person_outline,
    'other': Icons.help_outline,
  };

  Future<void> _pickImage() async {
    final picker = ImagePicker();

    final picked = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 70,
    );

    if (picked != null) {
      final bytes = await picked.readAsBytes();

      setState(() {
        _attachmentBytes = bytes;
        _attachmentFileName = picked.name;
      });
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _submitting = true);

    final result = await _service.createComplaint(
      category: _category,
      subject: _subjectController.text.trim(),
      message: _messageController.text.trim(),
      imageBytes: _attachmentBytes,
      fileName: _attachmentFileName,
    );

    setState(() => _submitting = false);

    if (!mounted) return;

    if (result['success'] == true) {
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result['message'] ?? 'Failed to submit complaint'),
        ),
      );
    }
  }

  @override
  void dispose() {
    _subjectController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('New Complaint')),
      body: Container(
        decoration: AppDecorations.gradientBackground,
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text('Category', style: AppTextStyles.label),

              const SizedBox(height: 8),

              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: _categories.entries.map((e) {
                  final selected = _category == e.key;

                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _category = e.key;
                      });
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 150),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: selected
                            ? AppColors.golden.withOpacity(0.30)
                            : AppColors.cream.withOpacity(0.25),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: selected
                              ? AppColors.golden
                              : AppColors.borderGold.withOpacity(0.4),
                          width: selected ? 1.6 : 1,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            _categoryIcons[e.key],
                            size: 18,
                            color: AppColors.darkGreen,
                          ),

                          const SizedBox(width: 6),

                          Text(
                            e.value,
                            style: AppTextStyles.bodyMedium.copyWith(
                              fontWeight: selected
                                  ? FontWeight.w700
                                  : FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),

              const SizedBox(height: 20),

              Text('Subject', style: AppTextStyles.label),

              const SizedBox(height: 6),

              TextFormField(
                controller: _subjectController,
                decoration: const InputDecoration(
                  hintText: 'Brief summary of your issue',
                ),
                validator: (v) {
                  if (v == null || v.trim().isEmpty) {
                    return 'Subject is required';
                  }

                  return null;
                },
              ),

              const SizedBox(height: 16),

              Text('Message', style: AppTextStyles.label),

              const SizedBox(height: 6),

              TextFormField(
                controller: _messageController,
                maxLines: 5,
                decoration: const InputDecoration(
                  hintText: 'Describe your issue in detail',
                ),
                validator: (v) {
                  if (v == null || v.trim().isEmpty) {
                    return 'Message is required';
                  }

                  return null;
                },
              ),

              const SizedBox(height: 16),

              Text('Attachment (optional)', style: AppTextStyles.label),

              const SizedBox(height: 6),

              GestureDetector(
                onTap: _pickImage,
                child: Container(
                  height: 130,
                  width: double.infinity,
                  decoration: AppDecorations.inputField,
                  child: _attachmentBytes == null
                      ? Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.add_a_photo_outlined,
                              color: AppColors.iconMuted,
                              size: 30,
                            ),

                            const SizedBox(height: 6),

                            Text(
                              'Tap to attach a photo',
                              style: AppTextStyles.bodySmall,
                            ),
                          ],
                        )
                      : Stack(
                          fit: StackFit.expand,
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: Image.memory(
                                _attachmentBytes!,
                                fit: BoxFit.cover,
                              ),
                            ),

                            Positioned(
                              top: 6,
                              right: 6,
                              child: GestureDetector(
                                onTap: () {
                                  setState(() {
                                    _attachmentBytes = null;
                                    _attachmentFileName = null;
                                  });
                                },
                                child: Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: const BoxDecoration(
                                    color: Colors.black54,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.close,
                                    color: Colors.white,
                                    size: 16,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                ),
              ),

              const SizedBox(height: 28),

              ElevatedButton(
                onPressed: _submitting ? null : _submit,
                child: _submitting
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Submit Complaint'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
