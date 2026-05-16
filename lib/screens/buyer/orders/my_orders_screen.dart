import 'package:flutter/material.dart';
import 'package:frontend/screens/buyer/orders/order_details_screen.dart';
import '../../../core/services/order_service.dart';
import '../../../core/utils/themes.dart';

class MyOrdersScreen extends StatefulWidget {
  const MyOrdersScreen({super.key});

  @override
  State<MyOrdersScreen> createState() => _MyOrdersScreenState();
}

class _MyOrdersScreenState extends State<MyOrdersScreen> {
  List orders = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchOrders();
  }

  // =========================
  // FETCH ORDERS
  // =========================
  Future<void> fetchOrders() async {
    final data = await OrderService().getMyOrders();

    setState(() {
      orders = data;
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: AppDecorations.gradientBackground,

      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(title: const Text("My Orders")),

        body: isLoading
            ? const Center(child: CircularProgressIndicator())
            : orders.isEmpty
            ? const Center(child: Text("No orders found"))
            : ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: orders.length,
                itemBuilder: (context, index) {
                  final order = orders[index];

                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => OrderDetailsScreen(order: order),
                        ),
                      );
                    },

                    child: Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      padding: const EdgeInsets.all(16),
                      decoration: AppDecorations.card,

                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // ORDER ID
                          Text(
                            "Order #${order["id"]}",
                            style: AppTextStyles.heading4,
                          ),

                          const SizedBox(height: 10),

                          // STATUS
                          Text(
                            "Status: ${order["status"]}",
                            style: AppTextStyles.bodyLarge,
                          ),

                          const SizedBox(height: 10),

                          // TOTAL
                          Text(
                            "Total: Rs ${order["total_price"]}",
                            style: AppTextStyles.heading4,
                          ),

                          const SizedBox(height: 10),

                          // ITEMS COUNT
                          Text(
                            "Items: ${order["items"].length}",
                            style: AppTextStyles.bodyLarge,
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
      ),
    );
  }
}
