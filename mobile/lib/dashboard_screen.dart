
import 'package:flutter/material.dart';

import 'products_screen.dart';
import 'stock_screen.dart';
import 'settings_screen.dart';
import 'business_profile_screen.dart';
import 'branches_screen.dart';
import 'users_screen.dart';
import 'categories_screen.dart';
import 'allocation_screen.dart';
import 'suppliers_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int selectedIndex = 0;

  static const Color background = Color(0xFF080B12);
  static const Color cardColor = Color(0xFF121D2D);
  static const Color blue = Color(0xFF5798FF);
  static const Color muted = Color(0xFF91A4BE);

  // BOTTOM NAVIGATION

  void _openPage(int index) {
    if (index == 0) {
      setState(() => selectedIndex = 0);
      Navigator.popUntil(context, (route) => route.isFirst);
      return;
    }

    setState(() => selectedIndex = index);

    Widget? page;

    switch (index) {
      case 1:
        page = const ProductsScreen();
        break;
      case 2:
        page = const StockScreen();
        break;
      case 3:
        page = const SalesPlaceholderScreen();
        break;
      case 4:
        page = const SettingsScreen();
        break;
    }

    if (page != null) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => page!),
      );
    }
  }

  // DRAWER NAVIGATION

  void _openMenuPage(String item, int? page) {
    Navigator.pop(context);

    if (page != null) {
      _openPage(page);
      return;
    }

    Widget? destination;

    switch (item) {
      case 'Business Profile':
        destination = const BusinessProfileScreen();
        break;

      case 'Branches':
        destination = const BranchesScreen();
        break;

      case 'Users':
        destination = const UsersScreen();
        break;

      case 'Categories':
        destination = const CategoriesScreen();
        break;

      case 'Allocation':
        destination = const AllocationScreen();
        break;

      case 'Suppliers':
        destination = const SuppliersScreen();
        break;
    }

    if (destination != null) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => destination!),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('$item will be added soon.')),
      );
    }
  }

  Widget _menuTile(String title, int? page) {
    return ListTile(
      dense: true,
      leading: const Icon(
        Icons.arrow_right,
        color: muted,
        size: 20,
      ),
      title: Text(
        title,
        style: const TextStyle(
          color: Colors.white70,
          fontSize: 13,
        ),
      ),
      onTap: () => _openMenuPage(title, page),
    );
  }

  Widget _menuGroup(
    String title,
    IconData icon,
    List<Widget> children,
  ) {
    return Theme(
      data: Theme.of(context).copyWith(
        dividerColor: Colors.transparent,
      ),
      child: ExpansionTile(
        leading: Icon(icon, color: blue),
        title: Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
        ),
        iconColor: blue,
        collapsedIconColor: muted,
        childrenPadding: const EdgeInsets.only(left: 16),
        children: children,
      ),
    );
  }

  // LEFT DRAWER

  Widget _buildDrawer() {
    return Drawer(
      backgroundColor: const Color(0xFF101927),
      width: 300,
      child: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(18),
              child: Row(
                children: [
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: const Color(0xFF263B5B),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.layers,
                      color: blue,
                      size: 25,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      'UNIVERSAL INVENTORY',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            Container(
              margin: const EdgeInsets.symmetric(horizontal: 14),
              padding: const EdgeInsets.all(13),
              decoration: BoxDecoration(
                color: const Color(0xFF1D293A),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Row(
                children: [
                  Icon(Icons.business, color: blue, size: 27),
                  SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Your Company',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 3),
                        Text(
                          'Business profile',
                          style: TextStyle(
                            color: muted,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(Icons.chevron_right, color: muted),
                ],
              ),
            ),

            const SizedBox(height: 12),

            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  _menuGroup(
                    'Company Details',
                    Icons.business_outlined,
                    [
                      _menuTile('Business Profile', null),
                      _menuTile('Branches', null),
                      _menuTile('Users', null),
                    ],
                  ),

                  _menuGroup(
                    'Product Master',
                    Icons.inventory_2_outlined,
                    [
                      _menuTile('Products', 1),
                      _menuTile('Categories', null),
                      _menuTile('Allocation', null),
                      _menuTile('Suppliers', null),
                    ],
                  ),

                  _menuGroup(
                    'Stock',
                    Icons.inventory_outlined,
                    [
                      _menuTile('Stock In', 2),
                      _menuTile('Stock Out', 2),
                      _menuTile('Transfers', null),
                      _menuTile('Adjustments', null),
                    ],
                  ),

                  _menuGroup(
                    'Sales',
                    Icons.shopping_cart_outlined,
                    [
                      _menuTile('Create Sale', 3),
                      _menuTile('Sales History', 3),
                      _menuTile('Customers', null),
                      _menuTile('Returns', null),
                    ],
                  ),

                  _menuGroup(
                    'Help',
                    Icons.help_outline,
                    [
                      _menuTile('User Guide', null),
                      _menuTile('FAQs', null),
                      _menuTile('Contact Support', null),
                    ],
                  ),
                ],
              ),
            ),

            const Divider(color: Color(0xFF26364D)),

            ListTile(
              leading: const Icon(
                Icons.settings_outlined,
                color: muted,
              ),
              title: const Text(
                'Settings',
                style: TextStyle(color: Colors.white),
              ),
              onTap: () => _openMenuPage('Settings', 4),
            ),

            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  // SUMMARY CARDS

  Widget _summaryCard({
    required String title,
    required String value,
    required String subtitle,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF26364D)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 25),
          const SizedBox(height: 13),
          Text(
            title,
            style: const TextStyle(
              color: muted,
              fontSize: 11,
            ),
          ),
          const SizedBox(height: 5),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 21,
              ),
            ),
          ),
          const SizedBox(height: 3),
          Text(
            subtitle,
            style: const TextStyle(
              color: muted,
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }

  // QUICK ACTIONS

  Widget _quickAction({
    required String title,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.all(13),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFF26364D)),
        ),
        child: Row(
          children: [
            Container(
              width: 37,
              height: 37,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.17),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color, size: 21),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sectionTitle(String title, {Widget? trailing}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        if (trailing != null) trailing,
      ],
    );
  }

  // SALES AND PURCHASE OVERVIEW

  Widget _overviewCard({
    required String title,
    required String period,
    required List<String> labels,
    required List<String> values,
    required List<double> chartValues,
    required bool isLine,
  }) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF26364D)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFF263B5B),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  period,
                  style: const TextStyle(
                    color: blue,
                    fontSize: 11,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 17),
          Row(
            children: List.generate(3, (index) {
              return Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      labels[index],
                      style: const TextStyle(
                        color: muted,
                        fontSize: 10,
                      ),
                    ),
                    const SizedBox(height: 5),
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        values[index],
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }),
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 125,
            width: double.infinity,
            child: CustomPaint(
              painter: isLine
                  ? _LineChartPainter(chartValues)
                  : _BarChartPainter(chartValues),
            ),
          ),
          const SizedBox(height: 8),
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Day 1', style: TextStyle(color: muted, fontSize: 10)),
              Text('Day 5', style: TextStyle(color: muted, fontSize: 10)),
              Text('Day 10', style: TextStyle(color: muted, fontSize: 10)),
              Text('Day 15', style: TextStyle(color: muted, fontSize: 10)),
              Text('Day 20', style: TextStyle(color: muted, fontSize: 10)),
              Text('Day 30', style: TextStyle(color: muted, fontSize: 10)),
            ],
          ),
        ],
      ),
    );
  }

  // LOW STOCK ALERTS

  Widget _stockAlert(String name, String sku, String quantity) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(13),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.warning_amber_rounded,
            color: Color(0xFFFFB454),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  sku,
                  style: const TextStyle(
                    color: muted,
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

  // RECENT ACTIVITY

  Widget _activityItem(
    IconData icon,
    Color color,
    String title,
    String subtitle,
    String time,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.13),
              borderRadius: BorderRadius.circular(11),
            ),
            child: Icon(icon, color: color),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(
                    color: muted,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          Text(
            time,
            style: const TextStyle(
              color: muted,
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }

  // MAIN DASHBOARD

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background,
      drawer: _buildDrawer(),

      appBar: AppBar(
        backgroundColor: background,
        elevation: 0,
        title: const Text(
          'Dashboard',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () => _openPage(4),
            icon: const Icon(
              Icons.notifications_none,
              color: Colors.white,
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),

      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
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
                "Here's what's happening with your business today.",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 22),

              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 1.22,
                children: [
                  _summaryCard(
                    title: 'Total Products',
                    value: '1,248',
                    subtitle: 'Registered products',
                    icon: Icons.inventory_2_outlined,
                    color: blue,
                  ),
                  _summaryCard(
                    title: 'Total Stock Quantity',
                    value: '8,450',
                    subtitle: 'Units available',
                    icon: Icons.all_inbox_outlined,
                    color: const Color(0xFF45C99A),
                  ),
                  _summaryCard(
                    title: 'Low Stock Items',
                    value: '18',
                    subtitle: 'Need attention',
                    icon: Icons.warning_amber_rounded,
                    color: const Color(0xFFFFB454),
                  ),
                  _summaryCard(
                    title: "Today's Sales",
                    value: 'Rs. 45,800',
                    subtitle: '12 orders today',
                    icon: Icons.trending_up,
                    color: const Color(0xFFB28AFF),
                  ),
                ],
              ),

              const SizedBox(height: 28),

              _sectionTitle('Quick Actions'),
              const SizedBox(height: 13),

              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                childAspectRatio: 2.35,
                children: [
                  _quickAction(
                    title: 'Add Product',
                    icon: Icons.add_box_outlined,
                    color: blue,
                    onTap: () => _openPage(1),
                  ),
                  _quickAction(
                    title: 'Stock In',
                    icon: Icons.call_received,
                    color: const Color(0xFF45C99A),
                    onTap: () => _openPage(2),
                  ),
                  _quickAction(
                    title: 'Stock Out',
                    icon: Icons.call_made,
                    color: const Color(0xFFFFB454),
                    onTap: () => _openPage(2),
                  ),
                  _quickAction(
                    title: 'Create Sale',
                    icon: Icons.shopping_cart_outlined,
                    color: const Color(0xFFB28AFF),
                    onTap: () => _openPage(3),
                  ),
                ],
              ),

              const SizedBox(height: 28),

              _overviewCard(
                title: 'Sales Overview',
                period: 'This Month',
                labels: ['Today', 'This Week', 'This Month'],
                values: ['Rs. 45.8K', 'Rs. 2.4L', 'Rs. 8.6L'],
                chartValues: [12, 18, 15, 28, 22, 36, 31, 45],
                isLine: true,
              ),

              const SizedBox(height: 18),

              _overviewCard(
                title: 'Purchase Overview',
                period: 'This Month',
                labels: ['Today', 'This Week', 'This Month'],
                values: ['Rs. 18K', 'Rs. 1.2L', 'Rs. 4.5L'],
                chartValues: [8, 15, 12, 24, 18, 30, 22, 18],
                isLine: false,
              ),

              const SizedBox(height: 28),

              _sectionTitle(
                'Low Stock Alerts',
                trailing: TextButton(
                  onPressed: () => _openPage(1),
                  child: const Text('View all'),
                ),
              ),
              const SizedBox(height: 8),

              _stockAlert('Wireless Mouse', 'SKU-00124', '4 left'),
              _stockAlert('USB Keyboard', 'SKU-00138', '3 left'),
              _stockAlert('HDMI Cable', 'SKU-00201', '2 left'),

              const SizedBox(height: 20),

              _sectionTitle('Recent Activity'),
              const SizedBox(height: 16),

              _activityItem(
                Icons.call_received,
                const Color(0xFF45C99A),
                'Stock Received',
                'Wireless Mouse • 20 units',
                '10:30 AM',
              ),
              _activityItem(
                Icons.shopping_cart,
                const Color(0xFFB28AFF),
                'Sale Recorded',
                'Order #1008 • Rs. 8,500',
                '10:00 AM',
              ),
              _activityItem(
                Icons.call_made,
                const Color(0xFFFFB454),
                'Stock Issued',
                'USB Keyboard • 5 units',
                '09:45 AM',
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
        onDestinationSelected: _openPage,
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
            icon: Icon(Icons.shopping_cart_outlined),
            label: 'Sales',
          ),
          NavigationDestination(
            icon: Icon(Icons.settings_outlined),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}

// SALES PLACEHOLDER

class SalesPlaceholderScreen extends StatelessWidget {
  const SalesPlaceholderScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF080B12),
      appBar: AppBar(
        backgroundColor: const Color(0xFF080B12),
        title: const Text('Sales'),
      ),
      body: const Center(
        child: Padding(
          padding: EdgeInsets.all(25),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.shopping_cart_outlined,
                color: Color(0xFF5798FF),
                size: 55,
              ),
              SizedBox(height: 16),
              Text(
                'Sales Management',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 8),
              Text(
                'We will build this section next.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Color(0xFF91A4BE),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// SALES LINE CHART

class _LineChartPainter extends CustomPainter {
  final List<double> values;

  _LineChartPainter(this.values);

  @override
  void paint(Canvas canvas, Size size) {
    final gridPaint = Paint()
      ..color = const Color(0xFF26364D)
      ..strokeWidth = 1;

    for (int i = 0; i < 4; i++) {
      final y = size.height * i / 3;
      canvas.drawLine(
        Offset(0, y),
        Offset(size.width, y),
        gridPaint,
      );
    }

    if (values.length < 2) return;

    final maxValue = values.reduce((a, b) => a > b ? a : b);
    final minValue = values.reduce((a, b) => a < b ? a : b);
    final range = (maxValue - minValue).abs() + 1;

    final points = <Offset>[];

    for (int i = 0; i < values.length; i++) {
      final x = size.width * i / (values.length - 1);
      final y = size.height -
          ((values[i] - minValue) / range * size.height * 0.8) -
          size.height * 0.1;

      points.add(Offset(x, y));
    }

    final linePaint = Paint()
      ..color = const Color(0xFF5798FF)
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final path = Path()
      ..moveTo(points.first.dx, points.first.dy);

    for (int i = 1; i < points.length; i++) {
      path.lineTo(points[i].dx, points[i].dy);
    }

    canvas.drawPath(path, linePaint);

    final dotPaint = Paint()
      ..color = const Color(0xFF5798FF)
      ..style = PaintingStyle.fill;

    for (final point in points) {
      canvas.drawCircle(point, 3.5, dotPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _LineChartPainter oldDelegate) {
    return oldDelegate.values != values;
  }
}

// PURCHASE BAR CHART

class _BarChartPainter extends CustomPainter {
  final List<double> values;

  _BarChartPainter(this.values);

  @override
  void paint(Canvas canvas, Size size) {
    final gridPaint = Paint()
      ..color = const Color(0xFF26364D)
      ..strokeWidth = 1;

    for (int i = 0; i < 4; i++) {
      final y = size.height * i / 3;
      canvas.drawLine(
        Offset(0, y),
        Offset(size.width, y),
        gridPaint,
      );
    }

    if (values.isEmpty) return;

    final maxValue = values.reduce((a, b) => a > b ? a : b);

    if (maxValue <= 0) return;

    final barWidth = size.width / (values.length * 1.7);

    final barPaint = Paint()
      ..color = const Color(0xFF45C99A)
      ..style = PaintingStyle.fill;

    for (int i = 0; i < values.length; i++) {
      final height = (values[i] / maxValue) * size.height * 0.85;
      final x = (i + 0.35) * size.width / values.length;

      final rect = RRect.fromRectAndRadius(
        Rect.fromLTWH(
          x,
          size.height - height,
          barWidth,
          height,
        ),
        const Radius.circular(5),
      );

      canvas.drawRRect(rect, barPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _BarChartPainter oldDelegate) {
    return oldDelegate.values != values;
  }
}
