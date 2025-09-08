import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Privacy Policy'),
        leading: IconButton(
          onPressed: () => context.go('/profile'),
          icon: const Icon(Icons.arrow_back),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Privacy Policy',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Last updated: ${DateTime.now().year}',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 24),

            _PolicySection(
              title: '1. Information We Collect',
              content: '''
We collect information you provide directly to us, such as when you:
• Create an account
• Book services
• Communicate with technicians
• Contact customer support
• Provide reviews and ratings

This may include your name, email address, phone number, location, payment information, and profile photos.
''',
            ),

            _PolicySection(
              title: '2. How We Use Your Information',
              content: '''
We use the information we collect to:
• Provide and maintain our services
• Process bookings and payments
• Communicate with you about your account and services
• Send you technical notices and support messages
• Respond to your comments and questions
• Improve our services and develop new features
• Comply with legal obligations
''',
            ),

            _PolicySection(
              title: '3. Information Sharing',
              content: '''
We may share your information in the following situations:
• With beauty technicians to facilitate bookings
• With service providers who assist us in operating our platform
• When required by law or to protect our rights
• In connection with a business transaction (merger, acquisition, etc.)

We do not sell your personal information to third parties.
''',
            ),

            _PolicySection(
              title: '4. Data Security',
              content: '''
We implement appropriate security measures to protect your personal information against unauthorized access, alteration, disclosure, or destruction. However, no method of transmission over the internet is 100% secure.
''',
            ),

            _PolicySection(
              title: '5. Data Retention',
              content: '''
We retain your personal information for as long as necessary to provide our services and fulfill the purposes outlined in this policy, unless a longer retention period is required by law.
''',
            ),

            _PolicySection(
              title: '6. Your Rights',
              content: '''
You have the right to:
• Access and update your personal information
• Delete your account and personal data
• Opt out of marketing communications
• Request a copy of your data
• Object to certain processing of your data

To exercise these rights, please contact us at privacy@beautyconnect.com.
''',
            ),

            _PolicySection(
              title: '7. Cookies and Tracking',
              content: '''
We use cookies and similar tracking technologies to improve your experience on our platform. You can control cookie settings through your browser preferences.
''',
            ),

            _PolicySection(
              title: '8. Third-Party Services',
              content: '''
Our app may contain links to third-party websites or services. We are not responsible for the privacy practices of these third parties. We encourage you to read their privacy policies.
''',
            ),

            _PolicySection(
              title: '9. Children\'s Privacy',
              content: '''
Our services are not intended for children under 13 years of age. We do not knowingly collect personal information from children under 13.
''',
            ),

            _PolicySection(
              title: '10. International Data Transfers',
              content: '''
Your information may be transferred to and processed in countries other than your own. We ensure appropriate safeguards are in place to protect your data.
''',
            ),

            _PolicySection(
              title: '11. Changes to This Policy',
              content: '''
We may update this privacy policy from time to time. We will notify you of any changes by posting the new policy on this page and updating the "Last updated" date.
''',
            ),

            _PolicySection(
              title: '12. Contact Us',
              content: '''
If you have any questions about this privacy policy, please contact us at:

Email: privacy@beautyconnect.com
Phone: +1 (555) 123-4567
Address: 123 Beauty Street, City, State 12345

We will respond to your inquiry within 30 days.
''',
            ),

            const SizedBox(height: 32),

            // Agreement Section
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Your Consent',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'By using Beauty Connect, you consent to the collection and use of your information as described in this privacy policy.',
                    style: TextStyle(
                      color: Colors.grey[700],
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}

class _PolicySection extends StatelessWidget {
  final String title;
  final String content;

  const _PolicySection({
    required this.title,
    required this.content,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            content,
            style: TextStyle(
              color: Colors.grey[700],
              fontSize: 14,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}