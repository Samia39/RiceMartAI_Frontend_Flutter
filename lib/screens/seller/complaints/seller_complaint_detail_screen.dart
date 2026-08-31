import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/services/complaint_service.dart';
import '../../../core/utils/themes.dart';

class SellerComplaintDetailScreen extends StatefulWidget {
  const SellerComplaintDetailScreen({super.key});

  int get complaintId => Get.arguments as int;

  @override
  State<SellerComplaintDetailScreen> createState() =>
      _SellerComplaintDetailScreenState();
}

class _SellerComplaintDetailScreenState
    extends State<SellerComplaintDetailScreen> {
  final ComplaintService _service = ComplaintService();
  final _replyController = TextEditingController();
  Complaint? _complaint;
  bool _loading = true;
  bool _sending = false;

  int get _id => widget.complaintId;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final complaint = await _service.getComplaintDetail(_id);
    setState(() {
      _complaint = complaint;
      _loading = false;
    });
  }

  Future<void> _sendReply() async {
    if (_replyController.text.trim().isEmpty) return;
    setState(() => _sending = true);
    final result = await _service.addMessage(
      complaintId: _id,
      message: _replyController.text.trim(),
    );
    setState(() => _sending = false);

    if (result['success'] == true) {
      _replyController.clear();
      _load();
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result['message'] ?? 'Failed to send reply')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_complaint?.subject ?? 'Complaint')),
      body: Container(
        decoration: AppDecorations.gradientBackground,
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : Column(
                children: [
                  Expanded(
                    child: ListView(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      children: _complaint!.messages.map((m) {
                        final isMine = m.senderRole == 'complainant';
                        return Align(
                          alignment: isMine
                              ? Alignment.centerRight
                              : Alignment.centerLeft,
                          child: Container(
                            margin: const EdgeInsets.symmetric(
                              vertical: 4,
                              horizontal: 12,
                            ),
                            padding: const EdgeInsets.all(12),
                            constraints: BoxConstraints(
                              maxWidth:
                                  MediaQuery.of(context).size.width * 0.75,
                            ),
                            decoration: BoxDecoration(
                              color: isMine
                                  ? AppColors.golden.withOpacity(0.25)
                                  : AppColors.cream.withOpacity(0.35),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: AppColors.borderGold.withOpacity(0.4),
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  isMine ? 'You' : 'Super Admin',
                                  style: AppTextStyles.bodySmall.copyWith(
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(m.message, style: AppTextStyles.bodyLarge),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                  if (_complaint!.status != 'resolved')
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.cream.withOpacity(0.3),
                        border: Border(
                          top: BorderSide(
                            color: AppColors.borderGold.withOpacity(0.4),
                          ),
                        ),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _replyController,
                              decoration: const InputDecoration(
                                hintText: 'Type a reply...',
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          _sending
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              : IconButton(
                                  icon: Icon(
                                    Icons.send,
                                    color: AppColors.darkGreen,
                                  ),
                                  onPressed: _sendReply,
                                ),
                        ],
                      ),
                    )
                  else
                    Padding(
                      padding: const EdgeInsets.all(12),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.check_circle,
                            size: 16,
                            color: AppColors.success,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'This complaint has been resolved.',
                            style: AppTextStyles.bodySmall,
                          ),
                        ],
                      ),
                    ),
                ],
              ),
      ),
    );
  }
}
