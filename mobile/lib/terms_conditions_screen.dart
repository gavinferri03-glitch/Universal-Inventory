
import 'package:flutter/material.dart';

class TermsConditionsScreen extends StatelessWidget {
  const TermsConditionsScreen({super.key});

  static const Color blue = Color(0xFF5798FF);
  static const Color panel = Color(0xFF121D2D);
  static const Color muted = Color(0xFF91A4BE);

  static const List<Map<String, String>> sections = [
    {
      'title': '1. Acceptance of Terms',
      'body':
          'By accessing or using Universal Inventory, you agree to these Terms and Conditions. If you do not agree, you should stop using the application.'
    },
    {
      'title': '2. Purpose and Permitted Use',
      'body':
          'Universal Inventory is designed to help businesses manage products, categories, suppliers, branches, stock movements, sales, payments and related business records. You may use the application only for lawful business purposes.'
    },
    {
      'title': '3. Accounts and User Responsibility',
      'body':
          'You are responsible for keeping your account credentials confidential and for activities performed through your account. Business owners and administrators are responsible for granting appropriate access to employees and reviewing their activities.'
    },
    {
      'title': '4. Accuracy of Business Records',
      'body':
          'You are responsible for ensuring that product details, stock quantities, purchase costs, selling prices, sales, payments, returns and branch transfers are accurate. You should review important entries before confirming them. The application does not independently verify the accuracy of information entered by users.'
    },
    {
      'title': '5. Stock Movements and Transfers',
      'body':
          'Stock-in, stock-out and branch-transfer operations should reflect actual business activities. Users must select the correct products, branches and quantities. You are responsible for checking that recorded movements match your physical inventory.'
    },
    {
      'title': '6. Sales, Payments and Returns',
      'body':
          'Users are responsible for entering correct sales information and payment status. Changes to payment records and sales returns should be made only by authorized users and should reflect genuine transactions. Keep supporting receipts and financial records separately where required.'
    },
    {
      'title': '7. Branches and Employees',
      'body':
          'Each business is responsible for managing its branches, employees, permissions and access. You must ensure that users are authorized to view or change the business information available to them.'
    },
    {
      'title': '8. Data, Privacy and Storage',
      'body':
          'Business information entered into the application is used to provide its inventory-management functions. The current prototype does not provide a permanent cloud database or guaranteed cloud synchronization. Data may be stored temporarily in application memory and may be lost when the application closes, restarts or its data is cleared. Do not enter confidential or critical information unless you understand these limitations.'
    },
    {
      'title': '9. Backups and Record Keeping',
      'body':
          'Until reliable permanent storage and backup features are available, you must maintain independent copies of important business, inventory and financial records. Do not rely on this prototype as the sole record of your business.'
    },
    {
      'title': '10. Availability and Prototype Limitations',
      'body':
          'Universal Inventory is currently under development. Features may change, be unavailable, contain errors or behave differently as development continues. The application is provided on an as-is and as-available basis, without a guarantee of uninterrupted operation or error-free performance.'
    },
    {
      'title': '11. Limitation of Liability',
      'body':
          'To the extent permitted by applicable law, the developers are not responsible for losses arising from inaccurate user entries, lost data, interrupted service, unauthorized access caused by failure to protect account credentials, or reliance on prototype features. Nothing in these terms excludes liability that cannot legally be excluded.'
    },
    {
      'title': '12. Lawful Use',
      'body':
          'You must not use the application for unlawful activities, attempt to gain unauthorized access, interfere with its operation, or misuse another person’s business information.'
    },
    {
      'title': '13. Changes to These Terms',
      'body':
          'These Terms and Conditions may be updated as the application develops. Updated terms should be reviewed when they are published. Continued use after an update takes effect may constitute acceptance where permitted by law.'
    },
    {
      'title': '14. Contact and Business Information',
      'body':
          'For questions about these terms, contact the application provider using the official contact details published by the provider. Business-specific contact information may be added when the application is prepared for release.'
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Terms & Conditions',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(18, 18, 18, 32),
        children: [
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: panel,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: const Color(0xFF26364D)),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.gavel_outlined,
                  color: blue,
                  size: 34,
                ),
                SizedBox(height: 12),
                Text(
                  'Universal Inventory',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 7),
                Text(
                  'Terms governing the use of the application.',
                  style: TextStyle(color: muted, fontSize: 13),
                ),
                SizedBox(height: 14),
                Text(
                  'DRAFT — DEVELOPMENT VERSION',
                  style: TextStyle(
                    color: Color(0xFFFFC46B),
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'Please read these terms carefully before using the application.',
            style: TextStyle(
              color: muted,
              fontSize: 13,
              height: 1.6,
            ),
          ),
          const SizedBox(height: 18),
          ...sections.map(
            (section) => Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: panel,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFF26364D)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    section['title']!,
                    style: const TextStyle(
                      color: blue,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 9),
                  Text(
                    section['body']!,
                    style: const TextStyle(
                      color: muted,
                      fontSize: 13,
                      height: 1.65,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(
              color: const Color(0xFF302719),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFF735A32)),
            ),
            child: const Text(
              'Important: These terms are an initial product draft, not legal advice. They must be reviewed and adapted by a qualified legal professional before Universal Inventory is publicly released, including for compliance with applicable laws in Nepal and other intended markets.',
              style: TextStyle(
                color: Color(0xFFFFD99A),
                fontSize: 12,
                height: 1.6,
              ),
            ),
          ),
          const SizedBox(height: 18),
          const Center(
            child: Text(
              'Universal Inventory • Version 0.1.0',
              style: TextStyle(
                color: Color(0xFF52647D),
                fontSize: 11,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
