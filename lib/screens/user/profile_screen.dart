// ignore_for_file: deprecated_member_use
import 'package:flutter/material.dart';
import 'create_shop_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: MediaQuery.of(context).padding.top + kToolbarHeight,
        ),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              children: [
                // ── Profile Card ─────────────────────────
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: const Color(0xFFD4C9A8).withOpacity(0.22),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                        color: const Color(0xFFB8A97A).withOpacity(0.45)),
                  ),
                  child: Column(
                    children: [
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          color: const Color(0xFF1A2820).withOpacity(0.15),
                          shape: BoxShape.circle,
                          border: Border.all(
                              color: const Color(0xFFB8A97A), width: 2),
                        ),
                        child: const Icon(Icons.person,
                            size: 45, color: Color(0xFF1A2820)),
                      ),
                      const SizedBox(height: 12),
                      const Text('Marketplace User',
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1A2820),
                          )),
                      const SizedBox(height: 4),
                      const Text('USER',
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 13,
                            color: Color(0xFF9D7E3F),
                            fontWeight: FontWeight.w500,
                          )),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // ── My Orders ────────────────────────────
                Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFFD4C9A8).withOpacity(0.22),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                        color: const Color(0xFFB8A97A).withOpacity(0.45)),
                  ),
                  child: ListTile(
                    leading: const Icon(Icons.receipt_long_outlined,
                        color: Color(0xFF1A2820)),
                    title: const Text('My Orders',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF1A2820),
                        )),
                    trailing: const Icon(Icons.arrow_forward_ios,
                        size: 16, color: Color(0xFF1A2820)),
                    onTap: () {},
                  ),
                ),
                const SizedBox(height: 12),

                // ── Become Seller ─────────────────────────
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const CreateShopScreen()),
                    );
                  },
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFF9D7E3F).withOpacity(0.85),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                          color: const Color(0xFFB8A97A).withOpacity(0.60)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Icon(Icons.storefront_outlined,
                            color: Color(0xFF1A2820), size: 22),
                        SizedBox(width: 10),
                        Text('Become Seller',
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF1A2820),
                            )),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                // ── Logout ────────────────────────────────
                GestureDetector(
                  onTap: () {},
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFD32F2F).withOpacity(0.85),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Icon(Icons.logout, color: Colors.white, size: 22),
                        SizedBox(width: 10),
                        Text('Logout',
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            )),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ],
    );
  }
}