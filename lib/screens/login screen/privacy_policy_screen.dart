import 'package:flutter/material.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  final List<Map<String, String>> _sections = [
    {
      'title': '1. Information We Collect',
      'body':
          'We collect information you provide directly, such as your name, email address, and profile details when you register. We also collect usage data, device information, and images you upload for rice detection purposes.',
    },
    {
      'title': '2. How We Use Your Information',
      'body':
          'Your information is used to provide and improve our services, authenticate your account, process AI-based rice detection, send important notifications, and respond to your inquiries and support requests.',
    },
    {
      'title': '3. AI & Image Data',
      'body':
          'Images you submit for rice detection are processed by our AI system. These images may be temporarily stored to improve model accuracy. We do not sell or share your images with third parties for advertising purposes.',
    },
    {
      'title': '4. Data Sharing',
      'body':
          'We do not sell your personal information. We may share data with trusted service providers who assist in operating our app (e.g., cloud hosting, analytics) under strict confidentiality agreements.',
    },
    {
      'title': '5. Data Security',
      'body':
          'We implement industry-standard security measures including encryption and secure token authentication (Laravel Sanctum) to protect your data. However, no method of transmission over the internet is 100% secure.',
    },
    {
      'title': '6. Social Login',
      'body':
          'If you choose to sign in using Google, Facebook, or Twitter, we receive basic profile information from those platforms as permitted by your privacy settings on those services.',
    },
    {
      'title': '7. Your Rights',
      'body':
          'You have the right to access, update, or delete your personal information at any time through your account settings. You may also request a copy of the data we hold about you.',
    },
    {
      'title': '8. Cookies & Storage',
      'body':
          'Rice Mart uses local secure storage to maintain your session and preferences. No tracking cookies are used for advertising purposes.',
    },
    {
      'title': '9. Children\'s Privacy',
      'body':
          'Our app is not directed at children under the age of 13. We do not knowingly collect personal information from children. If you believe a child has provided us with information, please contact us.',
    },
    {
      'title': '10. Contact Us',
      'body':
          'For any privacy-related questions or concerns, please reach out to us at privacy@ricemart.app. We are committed to addressing your concerns promptly.',
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
                      'Privacy Policy',
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

              // Divider
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
                                  Icons.privacy_tip_outlined,
                                  color: Color(0xFF1A2820),
                                  size: 18,
                                ),
                                SizedBox(width: 8),
                                Text(
                                  'Rice Mart — Privacy Policy',
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
                              'Your privacy matters to us. This policy explains how we collect, use, and protect your information.',
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
