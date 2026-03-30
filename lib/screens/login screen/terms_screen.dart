import 'package:flutter/material.dart';

class TermsScreen extends StatelessWidget {
  final List<Map<String, String>> _sections = [
    {
      'title': '1. Acceptance of Terms',
      'body':
          'By downloading, installing, or using Rice Mart, you agree to be bound by these Terms and Conditions. If you do not agree to these terms, please do not use our application.',
    },
    {
      'title': '2. Use of the App',
      'body':
          'Rice Mart is designed for personal, non-commercial use. You agree not to misuse the app, attempt to gain unauthorized access, reverse-engineer, or use the app for any unlawful purpose.',
    },
    {
      'title': '3. Account Responsibility',
      'body':
          'You are responsible for maintaining the confidentiality of your account credentials. Any activity that occurs under your account is your responsibility. Notify us immediately of any unauthorized use.',
    },
    {
      'title': '4. AI-Based Rice Detection',
      'body':
          'The rice detection and suggestion features are powered by artificial intelligence. Results are provided for informational purposes and may not always be 100% accurate. We do not guarantee the completeness or accuracy of AI-generated suggestions.',
    },
    {
      'title': '5. Intellectual Property',
      'body':
          'All content, logos, designs, and features within Rice Mart are the intellectual property of Rice Mart and its developers. You may not copy, reproduce, or distribute any content without prior written permission.',
    },
    {
      'title': '6. Limitation of Liability',
      'body':
          'Rice Mart and its developers shall not be liable for any direct, indirect, incidental, or consequential damages arising from your use of the app, including but not limited to data loss or inaccurate AI results.',
    },
    {
      'title': '7. Changes to Terms',
      'body':
          'We reserve the right to modify these Terms and Conditions at any time. Continued use of the app after changes are posted constitutes acceptance of the new terms.',
    },
    {
      'title': '8. Contact Us',
      'body':
          'If you have any questions about these Terms and Conditions, please contact us at support@ricemart.app',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF5A8A6E), Color(0xFF9D7E3F)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        padding: EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Color(0xFFD4C9A8).withOpacity(0.30),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: Color(0xFFB8A97A).withOpacity(0.5),
                          ),
                        ),
                        child: Icon(
                          Icons.arrow_back_ios_new_rounded,
                          color: Color(0xFF1A2820),
                          size: 18,
                        ),
                      ),
                    ),
                    SizedBox(width: 16),
                    Text(
                      'Terms & Conditions',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1A2820),
                        letterSpacing: 0.3,
                      ),
                    ),
                  ],
                ),
              ),

              // Divider line
              Container(
                height: 1,
                margin: EdgeInsets.symmetric(horizontal: 28),
                color: Color(0xFF1A2820).withOpacity(0.15),
              ),

              // Content
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.symmetric(horizontal: 28, vertical: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Intro card
                      Container(
                        width: double.infinity,
                        padding: EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Color(0xFFD4C9A8).withOpacity(0.30),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Color(0xFFB8A97A).withOpacity(0.55),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.description_outlined,
                                  color: Color(0xFF1A2820),
                                  size: 18,
                                ),
                                SizedBox(width: 8),
                                Text(
                                  'Rice Mart — Terms of Use',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF1A2820),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 8),
                            Text(
                              'Last updated: January 2025',
                              style: TextStyle(
                                fontSize: 12,
                                color: Color(0xFF1A2820).withOpacity(0.65),
                              ),
                            ),
                            SizedBox(height: 6),
                            Text(
                              'Please read these terms carefully before using our application.',
                              style: TextStyle(
                                fontSize: 13,
                                color: Color(0xFF1A2820).withOpacity(0.80),
                                height: 1.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 20),

                      // Sections
                      ..._sections.map(
                        (section) => _buildSection(
                          title: section['title']!,
                          body: section['body']!,
                        ),
                      ),

                      SizedBox(height: 10),
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

  Widget _buildSection({required String title, required String body}) {
    return Padding(
      padding: EdgeInsets.only(bottom: 16),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Color(0xFFD4C9A8).withOpacity(0.20),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Color(0xFFB8A97A).withOpacity(0.40)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 13.5,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1A2820),
              ),
            ),
            SizedBox(height: 8),
            Text(
              body,
              style: TextStyle(
                fontSize: 13,
                color: Color(0xFF1A2820).withOpacity(0.80),
                height: 1.6,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
