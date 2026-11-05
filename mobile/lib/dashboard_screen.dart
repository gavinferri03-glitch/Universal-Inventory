
import 'package:flutter/material.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int selectedIndex = 0;

  static const Color blue = Color(0xFF5798FF);
  static const Color panel = Color(0xFF121D2D);
  static const Color muted = Color(0xFF91A4BE);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF080B12),
      appBar: AppBar(
        backgroundColor: const Color(0xFF080B12),
        title: const Text(
          'Dashboard',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.notifications_none),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Good morning!',
                style: TextStyle(
                  color: muted,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 5),
              const Text(
                'Business Overview',
                style: TextStyle(
                  fontSize: 25,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 22),

              // SUMMARY CARDS

              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 1.35,
                children: const [
                  _SummaryCard(
                    title: 'Total Products',
                    value: '1,248',
                    icon: Icons.inventory_2_outlined,
                    color: blue,
                  ),
                  _SummaryCard(
                    title: 'Stock Value',
                    value: 'Rs. 8.5L',
                    icon: Icons.account_balance_wallet_outlined,
                    color: Color(0xFF45C99A),
                  ),
                  _SummaryCard(
                    title: 'Low Stock Items',
                    value: '18',
                    icon: Icons.warning_amber_rounded,
                    color: Color(0xFFFFB454),
                  ),
                  _SummaryCard(
                    title: "Today's Movements",
                    value: '36',
                    icon: Icons.swap_horiz_rounded,
                    color: Color(0xFFB28AFF),
                  ),
                ],
              ),

              const SizedBox(height: 28),

              // QUICK ACTIONS

              const Text(
                'Quick Actions',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 14),

              Row(
                children: [
                  _QuickAction(
                    icon: Icons.add_box_outlined,
                    label: 'Add Product',
                    onTap: () => _message('Add Product'),
                  ),
                  const SizedBox(width: 10),
                  _QuickAction(
                    icon: Icons.call_received,
                    label: 'Stock In',
                    onTap: () => _message('Stock In'),
                  ),
                  const SizedBox(width: 10),
                  _QuickAction(
                    icon: Icons.call_made,
                    label: 'Stock Out',
                    onTap: () => _message('Stock Out'),
                  ),
                ],
              ),

              const SizedBox(height: 28),

              // LOW STOCK

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Low Stock Alerts',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  TextButton(
                    onPressed: () => _message('All low stock items'),
                    child: const Text('View all'),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              _StockAlert(
                name: 'Wireless Mouse',
                sku: 'SKU-00124',
                quantity: '3 left',
              ),
              _StockAlert(
                name: 'USB Keyboard',
                sku: 'SKU-00138',
                quantity: '5 left',
              ),
              _StockAlert(
                name: 'HDMI Cable',
                sku: 'SKU-00201',
                quantity: '2 left',
              ),

              const SizedBox(height: 28),

              // RECENT ACTIVITY

              const Text(
                'Recent Activity',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 14),

              _ActivityItem(
                icon: Icons.call_received,
                color: const Color(0xFF45C99A),
                title: 'Stock Received',
                subtitle: 'Wireless Mouse • 20 units',
                time: 'Today, 10:30 AM',
              ),
              _ActivityItem(
                icon: Icons.call_made,
                color: const Color(0xFFFFB454),
                title: 'Stock Issued',
                subtitle: 'USB Keyboard • 5 units',
                time: 'Today, 09:45 AM',
              ),
              _ActivityItem(
                icon: Icons.add_box_outlined,
                color: blue,
                title: 'New Product Added',
                subtitle: 'Bluetooth Speaker',
                time: 'Yesterday',
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),

      // BOTTOM NAVIGATION

      bottomNavigationBar: NavigationBar(
        backgroundColor: const Color(0xFF101927),
        indicatorColor: blue.withValues(alpha: 0.18),
        selectedIndex: selectedIndex,
        onDestinationSelected: (index) {
          setState(() => selectedIndex = index);
          if (index != 0) {
            _message(
              ['Dashboard', 'Products', 'Stock', 'Warehouses', 'Settings']
                  [index],
            );
          }
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.dashboard_outlined),
            selectedIcon: Icon(Icons.dashboard),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.inventory_2_outlined),
            label: 'Products',
          ),
          NavigationDestination(
            icon: Icon(Icons.swap_horiz),
            label: 'Stock',
          ),
          NavigationDestination(
            icon: Icon(Icons.warehouse_outlined),
            label: 'Warehouses',
          ),
          NavigationDestination(
            icon: Icon(Icons.settings_outlined),
            label: 'Settings',
          ),
        ],
      ),
    );
  }

  void _message(String action) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$action will be available soon.')),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  final String title;
  final String value;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: const Color(0xFF121D2D),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF26364D)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Icon(icon, color: color, size: 25),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: const TextStyle(
                  fontSize: 21,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                title,
                style: const TextStyle(
                  color: Color(0xFF91A4BE),
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _QuickAction extends StatelessWidget {
  const _QuickAction({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          height: 88,
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: const Color(0xFF121D2D),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFF26364D)),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: const Color(0xFF79AFFF), size: 24),
              const SizedBox(height: 8),
              Text(
                label,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 11),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StockAlert extends StatelessWidget {
  const _StockAlert({
    required this.name,
    required this.sku,
    required this.quantity,
  });

  final String name;
  final String sku;
  final String quantity;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF121D2D),
        borderRadius: BorderRadius.circular(13),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.inventory_2_outlined,
            color: Color(0xFFFFB454),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 4),
                Text(
                  sku,
                  style: const TextStyle(
                    color: Color(0xFF91A4BE),
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          Text(
            quantity,
            style: const TextStyle(
              color: Color(0xFFFFB454),
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

class _ActivityItem extends StatelessWidget {
  const _ActivityItem({
    required this.icon,
    required this.color,
    required this.title,
    required this.subtitle,
    required this.time,
  });

  final IconData icon;
  final Color color;
  final String title;
  final String subtitle;
  final String time;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 17),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 21),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(
                    color: Color(0xFF91A4BE),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Text(
            time,
            style: const TextStyle(
              color: Color(0xFF71849E),
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }
}
