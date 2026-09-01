import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/services/complaint_service.dart';
import '../../../core/utils/themes.dart';

IconData _categoryIcon(String category) {
  switch (category) {
    case 'payment':
      return Icons.payments_outlined;
    case 'order':
      return Icons.shopping_bag_outlined;
    case 'account':
      return Icons.person_outline;
    default:
      return Icons.help_outline;
  }
}

String _categoryLabel(String category) {
  switch (category) {
    case 'payment':
      return 'Payment Issue';
    case 'order':
      return 'Order Issue';
    case 'account':
      return 'Account Issue';
    default:
      return 'Other';
  }
}

// FIX: this was previously an undefined `attachmentUrl(...)` call — the
// file wouldn't compile as given. Using the same base-URL pattern already
// used elsewhere in the admin screens (ApprovedShopDetailScreen,
// PaymentScreen) for consistency.
const String _imageBaseUrl = "http://ricemart.sandbox.pk";

String _attachmentUrl(String path) => "$_imageBaseUrl/storage/$path";

// ─────────────────────────────────────────────────────────
// ZOOM VIEWER — opens full-screen pinch-to-zoom image
// ─────────────────────────────────────────────────────────
void _showZoomableImage(BuildContext context, String imageUrl) {
  Navigator.of(context).push(
    PageRouteBuilder(
      opaque: false,
      barrierColor: Colors.black.withOpacity(0.95),
      pageBuilder: (_, __, ___) => _ZoomableImagePage(imageUrl: imageUrl),
      transitionsBuilder: (_, animation, __, child) {
        return FadeTransition(opacity: animation, child: child);
      },
    ),
  );
}

class _ZoomableImagePage extends StatelessWidget {
  final String imageUrl;
  const _ZoomableImagePage({required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          Positioned.fill(
            child: GestureDetector(
              onTap: () => Navigator.of(context).pop(),
              child: InteractiveViewer(
                minScale: 1,
                maxScale: 5,
                child: Center(
                  child: Hero(
                    tag: imageUrl,
                    child: Image.network(
                      imageUrl,
                      fit: BoxFit.contain,
                      loadingBuilder: (context, child, progress) {
                        if (progress == null) return child;
                        return const Center(
                          child: CircularProgressIndicator(color: Colors.white),
                        );
                      },
                      errorBuilder: (context, error, stackTrace) =>
                          const Center(
                            child: Icon(
                              Icons.broken_image_outlined,
                              color: Colors.white54,
                              size: 48,
                            ),
                          ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            top: 40,
            right: 16,
            child: SafeArea(
              child: IconButton(
                icon: const Icon(Icons.close, color: Colors.white, size: 28),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────
// ATTACHMENT THUMBNAIL — tappable image inside chat bubble
// ─────────────────────────────────────────────────────────
class _AttachmentThumbnail extends StatelessWidget {
  final String imageUrl;
  const _AttachmentThumbnail({required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _showZoomableImage(context, imageUrl),
      child: Hero(
        tag: imageUrl,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxHeight: 180, minWidth: 120),
            child: Stack(
              alignment: Alignment.bottomRight,
              children: [
                Image.network(
                  imageUrl,
                  fit: BoxFit.cover,
                  width: double.infinity,
                  loadingBuilder: (context, child, progress) {
                    if (progress == null) return child;
                    return Container(
                      height: 120,
                      width: 160,
                      color: Colors.black12,
                      child: const Center(
                        child: SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      ),
                    );
                  },
                  errorBuilder: (context, error, stackTrace) => Container(
                    height: 120,
                    width: 160,
                    color: Colors.black12,
                    child: const Icon(
                      Icons.broken_image_outlined,
                      color: Colors.black38,
                    ),
                  ),
                ),
                Container(
                  margin: const EdgeInsets.all(6),
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.45),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.zoom_in,
                    color: Colors.white,
                    size: 16,
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

// ─────────────────────────────────────────────────────────
// MAIN SCREEN
// ─────────────────────────────────────────────────────────
class AdminComplaintDetailScreen extends StatefulWidget {
  // Kept optional for backward compatibility with direct instantiation
  // (notifications_screen.dart's admin branch is being converted to the
  // named route in this same pass, but kept nullable here defensively).
  final int? complaintId;

  const AdminComplaintDetailScreen({super.key, this.complaintId});

  int get _resolvedId => complaintId ?? (Get.arguments as int? ?? 0);

  @override
  State<AdminComplaintDetailScreen> createState() =>
      _AdminComplaintDetailScreenState();
}

class _AdminComplaintDetailScreenState
    extends State<AdminComplaintDetailScreen> {
  final ComplaintService _service = ComplaintService();
  final _replyController = TextEditingController();
  Complaint? _complaint;
  bool _loading = true;
  bool _sending = false;
  bool _updatingStatus = false;

  int get _id => widget._resolvedId;

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

  Future<void> _changeStatus(String status) async {
    setState(() => _updatingStatus = true);
    await _service.updateStatus(complaintId: _id, status: status);
    setState(() => _updatingStatus = false);
    _load();
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'resolved':
        return AppColors.success;
      case 'in_progress':
        return AppColors.info;
      default:
        return AppColors.warning;
    }
  }

  Color _roleColor(String role) =>
      role == 'seller' ? AppColors.golden : AppColors.lightGreen;

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
                  // ── Requester info card ──
                  Container(
                    margin: const EdgeInsets.fromLTRB(16, 12, 16, 6),
                    padding: const EdgeInsets.all(14),
                    decoration: AppDecorations.card,
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: AppColors.golden.withOpacity(0.16),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            _categoryIcon(_complaint!.category),
                            color: AppColors.darkGreen,
                            size: 22,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Flexible(
                                    child: Text(
                                      _complaint!.userName ?? 'Unknown user',
                                      style: AppTextStyles.label,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  // ── Role badge ──
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 2,
                                    ),
                                    decoration: BoxDecoration(
                                      color: _roleColor(
                                        _complaint!.role,
                                      ).withOpacity(0.18),
                                      borderRadius: BorderRadius.circular(20),
                                      border: Border.all(
                                        color: _roleColor(
                                          _complaint!.role,
                                        ).withOpacity(0.5),
                                      ),
                                    ),
                                    child: Text(
                                      _complaint!.role == 'seller'
                                          ? 'Seller'
                                          : 'Customer',
                                      style: AppTextStyles.bodySmall.copyWith(
                                        color: AppColors.darkGreen,
                                        fontWeight: FontWeight.w700,
                                        fontSize: 10.5,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 3),
                              Text(
                                _categoryLabel(_complaint!.category),
                                style: AppTextStyles.bodySmall,
                              ),
                              if (_complaint!.userEmail != null)
                                Text(
                                  _complaint!.userEmail!,
                                  style: AppTextStyles.bodySmall,
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  // ── Status changer ──
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 2,
                      ),
                      decoration: AppDecorations.inputField,
                      child: Row(
                        children: [
                          Icon(
                            Icons.flag_outlined,
                            size: 18,
                            color: AppColors.iconMuted,
                          ),
                          const SizedBox(width: 8),
                          Text('Status:', style: AppTextStyles.bodyMedium),
                          const SizedBox(width: 8),
                          Expanded(
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<String>(
                                value: _complaint!.status,
                                isExpanded: true,
                                items: const [
                                  DropdownMenuItem(
                                    value: 'open',
                                    child: Text('Open'),
                                  ),
                                  DropdownMenuItem(
                                    value: 'in_progress',
                                    child: Text('In Progress'),
                                  ),
                                  DropdownMenuItem(
                                    value: 'resolved',
                                    child: Text('Resolved'),
                                  ),
                                ],
                                onChanged: _updatingStatus
                                    ? null
                                    : (val) {
                                        if (val != null) _changeStatus(val);
                                      },
                              ),
                            ),
                          ),
                          if (_updatingStatus)
                            const SizedBox(
                              height: 16,
                              width: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),

                  // ── Message thread ──
                  Expanded(
                    child: ListView(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      children: _complaint!.messages.map((m) {
                        final isMine = m.senderRole == 'super_admin';
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
                                  isMine
                                      ? 'You (Super Admin)'
                                      : (_complaint!.userName ?? 'User'),
                                  style: AppTextStyles.bodySmall.copyWith(
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(m.message, style: AppTextStyles.bodyLarge),
                                // ── Attachment (screenshot) preview + tap-to-zoom ──
                                if (m.attachmentPath != null) ...[
                                  const SizedBox(height: 8),
                                  _AttachmentThumbnail(
                                    imageUrl: _attachmentUrl(m.attachmentPath!),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),

                  // ── Reply box ──
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
                  ),
                ],
              ),
      ),
    );
  }
}
