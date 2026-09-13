import 'package:flutter/material.dart';
import '../../../core/services/review_service.dart';

class ShopReviewDialog extends StatefulWidget {
  final int orderItemId;

  const ShopReviewDialog({super.key, required this.orderItemId});

  @override
  State<ShopReviewDialog> createState() => _ShopReviewDialogState();
}

class _ShopReviewDialogState extends State<ShopReviewDialog> {
  int rating = 5;

  final controller = TextEditingController();

  bool loading = false;
  String? errorText;

  submit() async {
    setState(() {
      loading = true;
      errorText = null;
    });

    final result = await ReviewService().submitReview(
      orderItemId: widget.orderItemId,
      rating: rating,
      review: controller.text,
    );

    if (!mounted) return;

    setState(() => loading = false);

    if (result["success"] == true) {
      Navigator.pop(context, true);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result["message"] ?? "Review submitted")),
      );
    } else {
      // Stay open, show the reason inline (e.g. "You already reviewed
      // this shop for this order") instead of silently doing nothing.
      setState(() => errorText = result["message"]);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Rate Shop"),

      content: Column(
        mainAxisSize: MainAxisSize.min,

        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,

            children: List.generate(5, (index) {
              return IconButton(
                icon: Icon(
                  index < rating ? Icons.star : Icons.star_border,

                  color: Colors.orange,
                ),

                onPressed: () {
                  setState(() => rating = index + 1);
                },
              );
            }),
          ),

          TextField(
            controller: controller,

            maxLines: 3,

            decoration: const InputDecoration(
              hintText: "Write review (optional)",
            ),
          ),

          if (errorText != null) ...[
            const SizedBox(height: 8),
            Text(
              errorText!,
              style: const TextStyle(color: Colors.red, fontSize: 13),
            ),
          ],
        ],
      ),

      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),

          child: const Text("Cancel"),
        ),

        ElevatedButton(
          onPressed: loading ? null : submit,

          child: loading
              ? const SizedBox(
                  height: 18,
                  width: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text("Submit"),
        ),
      ],
    );
  }
}
