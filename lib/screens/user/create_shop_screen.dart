// ignore_for_file: deprecated_member_use
import 'package:flutter/material.dart';

class CreateShopScreen extends StatefulWidget {
  const CreateShopScreen({super.key});

  @override
  State<CreateShopScreen> createState() => _CreateShopScreenState();
}

class _CreateShopScreenState extends State<CreateShopScreen> {
  final cnicNoC = TextEditingController();
  final shopNameC = TextEditingController();
  final ownerNameC = TextEditingController();
  final phoneC = TextEditingController();
  final addressC = TextEditingController();
  final descriptionC = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF5A8A6E), Color(0xFF9D7E3F)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // ── Header ──────────────────────────────────
              Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 20, vertical: 16),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: const Color(0xFFD4C9A8).withOpacity(0.25),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                              color:
                                  const Color(0xFFB8A97A).withOpacity(0.50)),
                        ),
                        child: const Icon(Icons.arrow_back,
                            color: Color(0xFF1A2820), size: 22),
                      ),
                    ),
                    const Expanded(
                      child: Center(
                        child: Text('Create Shop',
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1A2820),
                            )),
                      ),
                    ),
                    const SizedBox(width: 40),
                  ],
                ),
              ),

              // ── Form ─────────────────────────────────────
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ── CNIC Section ─────────────────────
                      _sectionTitle('CNIC Information'),
                      const SizedBox(height: 10),

                      _buildField(
                        controller: cnicNoC,
                        hint: '12345-1234567-1',
                        icon: Icons.badge_outlined,
                        keyboardType: TextInputType.number,
                      ),
                      const SizedBox(height: 12),

                      // CNIC Image Upload
                      GestureDetector(
                        onTap: () {},
                        child: Container(
                          width: double.infinity,
                          height: 120,
                          decoration: BoxDecoration(
                            color: const Color(0xFFD4C9A8).withOpacity(0.22),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                                color: const Color(0xFFB8A97A)
                                    .withOpacity(0.55)),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.upload_file,
                                  size: 36,
                                  color: const Color(0xFF1A2820)
                                      .withOpacity(0.55)),
                              const SizedBox(height: 8),
                              Text('Upload CNIC Image',
                                  style: TextStyle(
                                    fontFamily: 'Poppins',
                                    fontSize: 14,
                                    color: const Color(0xFF1A2820)
                                        .withOpacity(0.65),
                                  )),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // ── Shop Section ──────────────────────
                      _sectionTitle('Shop Information'),
                      const SizedBox(height: 10),

                      _buildField(
                        controller: shopNameC,
                        hint: 'Shop Name',
                        icon: Icons.storefront_outlined,
                      ),
                      const SizedBox(height: 12),

                      _buildField(
                        controller: ownerNameC,
                        hint: 'Owner Name',
                        icon: Icons.person_outline,
                      ),
                      const SizedBox(height: 12),

                      _buildField(
                        controller: phoneC,
                        hint: 'Phone',
                        icon: Icons.phone_outlined,
                        keyboardType: TextInputType.phone,
                      ),
                      const SizedBox(height: 12),

                      _buildField(
                        controller: addressC,
                        hint: 'Address',
                        icon: Icons.location_on_outlined,
                      ),
                      const SizedBox(height: 12),

                      // Description
                      Container(
                        decoration: BoxDecoration(
                          color: const Color(0xFFD4C9A8).withOpacity(0.22),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                              color:
                                  const Color(0xFFB8A97A).withOpacity(0.55)),
                        ),
                        child: TextField(
                          controller: descriptionC,
                          maxLines: 4,
                          style: const TextStyle(
                              color: Color(0xFF1A2820), fontSize: 14),
                          decoration: InputDecoration(
                            hintText: 'Description',
                            hintStyle: TextStyle(
                                color: const Color(0xFF1A2820)
                                    .withOpacity(0.60),
                                fontSize: 14),
                            prefixIcon: Padding(
                              padding: const EdgeInsets.only(bottom: 60),
                              child: Icon(Icons.info_outline,
                                  color: const Color(0xFF1A2820)
                                      .withOpacity(0.75)),
                            ),
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.all(16),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // ── Create Shop Button ────────────────
                      GestureDetector(
                        onTap: () {},
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: const Color(0xFFD4C9A8).withOpacity(0.35),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                                color: const Color(0xFFB8A97A)
                                    .withOpacity(0.70)),
                          ),
                          child: const Center(
                            child: Text('Create Shop',
                                style: TextStyle(
                                  fontFamily: 'Poppins',
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF1A2820),
                                )),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Text(title,
        style: const TextStyle(
          fontFamily: 'Poppins',
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Color(0xFF1A2820),
        ));
  }

  Widget _buildField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFD4C9A8).withOpacity(0.22),
        borderRadius: BorderRadius.circular(12),
        border:
            Border.all(color: const Color(0xFFB8A97A).withOpacity(0.55)),
      ),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        style: const TextStyle(color: Color(0xFF1A2820), fontSize: 14),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(
              color: const Color(0xFF1A2820).withOpacity(0.60),
              fontSize: 14),
          prefixIcon:
              Icon(icon, color: const Color(0xFF1A2820).withOpacity(0.75)),
          border: InputBorder.none,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
        ),
      ),
    );
  }
}