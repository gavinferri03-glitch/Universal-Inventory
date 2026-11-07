
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'inventory_data.dart';
import 'products_screen.dart';
import 'stock_screen.dart';
import 'sales_screen.dart';
import 'settings_screen.dart';
import 'business_profile_screen.dart';
import 'branches_screen.dart';
import 'users_screen.dart';
import 'categories_screen.dart';
import 'allocation_screen.dart';
import 'suppliers_screen.dart';
import 'help_screen.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() =>
      _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  int selectedIndex = 0;

  static const Color background = Color(0xFF080B12);
  static const Color cardColor = Color(0xFF121D2D);
  static const Color blue = Color(0xFF5798FF);
  static const Color muted = Color(0xFF91A4BE);

  Future<void> _openPage(int index) async {
    if (index == 0) {
      Navigator.popUntil(context, (route) => route.isFirst);
      if (mounted) setState(() => selectedIndex = 0);
      return;
    }

    Widget? page;

    switch (index) {
      case 1:
        page = const ProductsScreen();
        break;
      case 2:
        page = const StockScreen();
        break;
      case 3:
        page = const SalesScreen();
        break;
      case 4:
        page = const SettingsScreen();
        break;
    }

    if (page == null) return;

    setState(() => selectedIndex = index);

    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => page!),
    );

    if (mounted) {
      setState(() => selectedIndex = 0);
    }
  }

  Future<void> _openMenuPage(String item, int? page) async {
    Navigator.pop(context);

    if (page != null) {
      await _openPage(page);
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
      case 'User Guide':
      case 'FAQs':
      case 'Contact Support':
        destination = const HelpScreen();
        break;
    }

    if (destination != null) {
      await Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => destination!),
      );

      if (mounted) {
        setState(() => selectedIndex = 0);
      }
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
            style: const TextStyle(color: muted, fontSize: 11),
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
            style: const TextStyle(color: muted, fontSize: 10),
          ),
        ],
      ),
    );
  }

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

  Widget _salesOverview(InventoryData inventory) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF26364D)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Sales Overview',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Today's Sales",
                style: TextStyle(color: muted, fontSize: 12),
              ),
              Text(
                'Rs. ${inventory.totalSalesToday.toStringAsFixed(2)}',
                style: const TextStyle(
                  color: blue,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Today's Orders",
                style: TextStyle(color: muted, fontSize: 12),
              ),
              Text(
                '${inventory.salesCountToday}',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Total Recorded Sales',
                style: TextStyle(color: muted, fontSize: 12),
              ),
              Text(
                'Rs. ${inventory.totalSales.toStringAsFixed(2)}',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _stockAlert(InventoryProduct product) {
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
                  product.name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  product.sku,
                  style: const TextStyle(
                    color: muted,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          Text(
            '${product.quantity} left',
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

  Widget _activityItem(
    StockMovement movement,
    InventoryData inventory,
  ) {
    final isIn = movement.type == 'Stock In' ||
        movement.type == 'Transfer In';

    final color = isIn
        ? const Color(0xFF45C99A)
        : movement.type == 'Stock Out'
            ? const Color(0xFFFFB454)
            : blue;

    final icon = isIn
        ? Icons.call_received
        : movement.type == 'Stock Out'
            ? Icons.call_made
            : Icons.swap_horiz;

    final branch = inventory.findBranch(movement.branchId);
    final date = movement.date;

    final time =
        '${date.hour.toString().padLeft(2, '0')}:'
        '${date.minute.toString().padLeft(2, '0')}';

    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
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
                  movement.type,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${movement.productName} • '
                  '${movement.quantity} units • '
                  '${branch?.name ?? "Unknown branch"}',
                  style: const TextStyle(
                    color: muted,
                    fontSize: 10,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          Text(
            time,
            style: const TextStyle(color: muted, fontSize: 10),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final inventory = ref.watch(inventoryProvider);

    final lowStockProducts = inventory.products
        .where(
          (product) => product.quantity <= product.minimumStock,
        )
        .toList();

    final recentMovements = inventory.movements.take(5).toList();

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
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Welcome back!',
                style: TextStyle(color: muted, fontSize: 14),
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
                    value: '${inventory.products.length}',
                    subtitle: 'Registered products',
                    icon: Icons.inventory_2_outlined,
                    color: blue,
                  ),
                  _summaryCard(
                    title: 'Total Stock Quantity',
                    value: '${inventory.totalStock}',
                    subtitle: 'Units available',
                    icon: Icons.all_inbox_outlined,
                    color: const Color(0xFF45C99A),
                  ),
                  _summaryCard(
                    title: 'Low Stock Items',
                    value: '${inventory.lowStockCount}',
                    subtitle: 'Need attention',
                    icon: Icons.warning_amber_rounded,
                    color: const Color(0xFFFFB454),
                  ),
                  _summaryCard(
                    title: "Today's Sales",
                    value:
                        'Rs. ${inventory.totalSalesToday.toStringAsFixed(0)}',
                    subtitle: '${inventory.salesCountToday} orders today',
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
              _salesOverview(inventory),
              const SizedBox(height: 28),
              _sectionTitle(
                'Low Stock Alerts',
                trailing: TextButton(
                  onPressed: () => _openPage(1),
                  child: const Text('View products'),
                ),
              ),
              const SizedBox(height: 8),
              if (lowStockProducts.isEmpty)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    color: cardColor,
                    borderRadius: BorderRadius.circular(13),
                  ),
                  child: const Text(
                    'No low stock products.',
                    style: TextStyle(color: muted),
                  ),
                )
              else
                ...lowStockProducts.take(5).map(_stockAlert),
              const SizedBox(height: 20),
              _sectionTitle('Recent Activity'),
              const SizedBox(height: 16),
              if (recentMovements.isEmpty)
                const Text(
                  'No stock activity recorded yet.',
                  style: TextStyle(color: muted),
                )
              else
                ...recentMovements.map(
                  (movement) => _activityItem(movement, inventory),
                ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
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
