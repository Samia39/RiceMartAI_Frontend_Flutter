import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/utils/themes.dart';
import '../../../core/services/complaint_service.dart';

class CustomerNewComplaintScreen extends StatefulWidget {
  const CustomerNewComplaintScreen({super.key});

  @override
  State<CustomerNewComplaintScreen> createState() =>
      _CustomerNewComplaintScreenState();
}

class _CustomerNewComplaintScreenState
    extends State<CustomerNewComplaintScreen> {
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
              const SizedBox(height: 6),

              Container(
                decoration: AppDecorations.inputField,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _category,
                    isExpanded: true,
                    items: _categories.entries
                        .map(
                          (e) => DropdownMenuItem(
                            value: e.key,
                            child: Text(e.value),
                          ),
                        )
                        .toList(),
                    onChanged: (val) {
                      setState(() {
                        _category = val ?? 'other';
                      });
                    },
                  ),
                ),
              ),

              const SizedBox(height: 16),

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
                  height: 120,
                  decoration: AppDecorations.inputField,
                  child: _attachmentBytes == null
                      ? Center(
                          child: Icon(
                            Icons.add_a_photo,
                            color: AppColors.iconMuted,
                            size: 32,
                          ),
                        )
                      : ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Image.memory(
                            _attachmentBytes!,
                            fit: BoxFit.cover,
                            width: double.infinity,
                          ),
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
