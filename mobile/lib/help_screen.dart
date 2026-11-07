
import 'package:flutter/material.dart';

class HelpScreen extends StatelessWidget {
  const HelpScreen({super.key});

  static const Color background = Color(0xFF080B12);
  static const Color panel = Color(0xFF121D2D);
  static const Color blue = Color(0xFF5798FF);
  static const Color muted = Color(0xFF91A4BE);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background,
      appBar: AppBar(
        backgroundColor: background,
        elevation: 0,
        title: const Text(
          'Help & Support',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: panel,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: Colors.white10),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.support_agent, color: blue, size: 38),
                SizedBox(height: 14),
                Text(
                  'How can we help you?',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 21,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Find guidance on managing your products, '
                  'branches, stock and sales.',
                  style: TextStyle(color: muted, height: 1.5),
                ),
              ],
            ),
          ),

          const SizedBox(height: 25),
          const _SectionTitle(title: 'USER GUIDE'),

          _HelpTile(
            icon: Icons.business,
            title: 'Company Details',
            subtitle: 'Manage your business information.',
            details:
                'Open Company Details to view or update your business '
                'name and other company information.',
          ),
          _HelpTile(
            icon: Icons.inventory_2,
            title: 'Product Master',
            subtitle: 'Add and manage products.',
            details:
                'Create products with a name, SKU, barcode, category, '
                'purchase price, selling price, unit, supplier and '
                'minimum stock level. You can also view product details '
                'and branch-wise stock.',
          ),
          _HelpTile(
            icon: Icons.warehouse,
            title: 'Stock Management',
            subtitle: 'Record stock in and stock out.',
            details:
                'Use Stock In when new stock arrives. Use Stock Out '
                'when stock is removed. Select the product and branch, '
                'then enter the quantity. Stock movements are recorded '
                'in the movement history.',
          ),
          _HelpTile(
            icon: Icons.account_tree,
            title: 'Branches',
            subtitle: 'Manage your business locations.',
            details:
                'Add branches and maintain their contact and manager '
                'information. You can activate or deactivate branches. '
                'Only active branches are available for new operations.',
          ),
          _HelpTile(
            icon: Icons.swap_horiz,
            title: 'Stock Allocation',
            subtitle: 'Move stock between branches.',
            details:
                'Choose a source branch and destination branch, select '
                'a product and enter the quantity. A transfer reduces '
                'stock at the source and increases stock at the '
                'destination without changing total company stock.',
          ),
          _HelpTile(
            icon: Icons.point_of_sale,
            title: 'Sales',
            subtitle: 'Create invoices and record payments.',
            details:
                'Select a branch, add products to the cart, enter '
                'customer information and apply discounts or tax. '
                'Choose a payment method and enter the amount paid. '
                'Completing a sale deducts stock from the selected '
                'branch and adds the transaction to Sales History.',
          ),
          _HelpTile(
            icon: Icons.people,
            title: 'Users',
            subtitle: 'Manage users and branch access.',
            details:
                'Use the Users page to manage user information and '
                'their assigned branch. Available branch choices '
                'come from your active branches.',
          ),
          _HelpTile(
            icon: Icons.local_shipping,
            title: 'Suppliers',
            subtitle: 'Maintain supplier information.',
            details:
                'Use the Suppliers section to maintain information '
                'about the suppliers who provide your products.',
          ),

          const SizedBox(height: 25),
          const _SectionTitle(title: 'FREQUENTLY ASKED QUESTIONS'),

          _HelpTile(
            icon: Icons.help_outline,
            title: 'Why is a product showing low stock?',
            subtitle: 'Understanding stock alerts.',
            details:
                'A product is marked as low stock when its total '
                'quantity reaches or falls below its minimum stock '
                'alert level. Check its branch-wise quantities before '
                'restocking.',
          ),
          _HelpTile(
            icon: Icons.sync,
            title: 'Does transferring stock change total stock?',
            subtitle: 'Understanding branch transfers.',
            details:
                'No. A transfer only moves stock between branches. '
                'The company-wide quantity remains unchanged.',
          ),
          _HelpTile(
            icon: Icons.receipt_long,
            title: 'Where can I find previous sales?',
            subtitle: 'Finding sales records.',
            details:
                'Open the Sales page and look under Sales History. '
                'Select a transaction to view its invoice details.',
          ),
          _HelpTile(
            icon: Icons.storage,
            title: 'Is my data permanently saved?',
            subtitle: 'Important information about data storage.',
            details:
                'The current prototype stores data temporarily in '
                'the app memory. Data may reset when the app restarts '
                'or is reinstalled. A permanent database and backup '
                'system still need to be implemented.',
          ),

          const SizedBox(height: 25),
          const _SectionTitle(title: 'APP INFORMATION'),

          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: panel,
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Universal Inventory',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Version 0.1.0',
                  style: TextStyle(color: muted),
                ),
                SizedBox(height: 12),
                Text(
                  'A universal inventory management system '
                  'for managing products, branches, stock and sales.',
                  style: TextStyle(color: muted, height: 1.5),
                ),
              ],
            ),
          ),
          const SizedBox(height: 30),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;

  const _SectionTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: const TextStyle(
          color: HelpScreen.blue,
          fontSize: 12,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.3,
        ),
      ),
    );
  }
}

class _HelpTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final String details;

  const _HelpTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.details,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: HelpScreen.panel,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white10),
      ),
      child: ExpansionTile(
        iconColor: HelpScreen.blue,
        collapsedIconColor: HelpScreen.muted,
        leading: Icon(icon, color: HelpScreen.blue),
        title: Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: const TextStyle(
            color: HelpScreen.muted,
            fontSize: 12,
          ),
        ),
        childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              details,
              style: const TextStyle(
                color: HelpScreen.muted,
                height: 1.6,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
