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

  submit() async {
    setState(() => loading = true);

    final result = await ReviewService().submitReview(
      orderItemId: widget.orderItemId,

      rating: rating,

      review: controller.text,
    );

    setState(() => loading = false);

    if (result) {
      Navigator.pop(context);

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Review submitted")));
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
              ? const CircularProgressIndicator()
              : const Text("Submit"),
        ),
      ],
    );
  }
}
