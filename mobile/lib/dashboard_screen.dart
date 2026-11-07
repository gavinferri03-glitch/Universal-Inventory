
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'inventory_data.dart';
import 'notification_screen.dart';
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
import 'transfer_screen.dart';
import 'customers_screen.dart';
import 'sales_history_screen.dart';
import 'stock_movement_screens.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() =>
      _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  int selectedIndex = 0;

  String _companyName = 'Your Company';
  String? _companyLogoPath;

  static const Color background = Color(0xFF080B12);
  static const Color cardColor = Color(0xFF121D2D);
  static const Color blue = Color(0xFF5798FF);
  static const Color muted = Color(0xFF91A4BE);
  static const Color green = Color(0xFF45C99A);
  static const Color orange = Color(0xFFFFB454);
  static const Color purple = Color(0xFFB28AFF);

  @override
  void initState() {
    super.initState();
    _loadCompanyIdentity();
  }

  Future<void> _loadCompanyIdentity() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedName = prefs.getString('company_name');
      final savedLogo = prefs.getString('company_logo_path');

      String? validLogo;

      if (savedLogo != null && await File(savedLogo).exists()) {
        validLogo = savedLogo;
      }

      if (!mounted) return;

      setState(() {
        _companyName = savedName == null || savedName.trim().isEmpty
            ? 'Your Company'
            : savedName.trim();
        _companyLogoPath = validLogo;
      });
    } catch (e) {
      debugPrint('Could not load company identity: $e');
    }
  }

  Future<void> _openNotifications() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const NotificationScreen(),
      ),
    );
  }

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

    if (mounted) setState(() => selectedIndex = 0);
  }

  Future<void> _openDestination(Widget destination) async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => destination),
    );

    if (mounted) {
      setState(() => selectedIndex = 0);
      await _loadCompanyIdentity();
    }
  }

  Future<void> _openMenuPage(String item, int? page) async {
    Navigator.pop(context);

    if (item == 'Sales History') {
      await _openDestination(const SalesHistoryScreen());
      return;
    }

    if (item == 'Stock In') {
      await _openDestination(const StockInScreen());
      return;
    }

    if (item == 'Stock Out') {
      await _openDestination(const StockOutScreen());
      return;
    }

    if (item == 'Customers') {
      await _openDestination(const CustomersScreen());
      return;
    }

    if (page != null) {
      await _openPage(page);
      return;
    }

    switch (item) {
      case 'Business Profile':
        await _openDestination(const BusinessProfileScreen());
        break;
      case 'Branches':
        await _openDestination(const BranchesScreen());
        break;
      case 'Users':
        await _openDestination(const UsersScreen());
        break;
      case 'Categories':
        await _openDestination(const CategoriesScreen());
        break;
      case 'Allocation':
        await _openDestination(const AllocationScreen());
        break;
      case 'Suppliers':
        await _openDestination(const SuppliersScreen());
        break;
      case 'Transfers':
        await _openDestination(const TransferScreen());
        break;
      case 'Help':
        await _openDestination(const HelpScreen());
        break;
      default:
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

            InkWell(
              onTap: () => _openMenuPage('Business Profile', null),
              borderRadius: BorderRadius.circular(12),
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 14),
                padding: const EdgeInsets.all(13),
                decoration: BoxDecoration(
                  color: const Color(0xFF1D293A),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: const Color(0xFF263B5B),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: _companyLogoPath != null
                          ? Image.file(
                              File(_companyLogoPath!),
                              fit: BoxFit.contain,
                              errorBuilder: (_, __, ___) => const Icon(
                                Icons.business,
                                color: blue,
                                size: 27,
                              ),
                            )
                          : const Icon(
                              Icons.business,
                              color: blue,
                              size: 27,
                            ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _companyName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 3),
                          const Text(
                            'Business profile',
                            style: TextStyle(
                              color: muted,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Icon(Icons.chevron_right, color: muted),
                  ],
                ),
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
                      _menuTile('Stock In', null),
                      _menuTile('Stock Out', null),
                      _menuTile('Transfers', null),
                    ],
                  ),
                  _menuGroup(
                    'Sales',
                    Icons.shopping_cart_outlined,
                    [
                      _menuTile('Create Sale', 3),
                      _menuTile('Sales History', null),
                      _menuTile('Customers', null),
                      _menuTile('Returns', null),
                    ],
                  ),
                  _menuGroup(
                    'Reports',
                    Icons.analytics_outlined,
                    [
                      _menuTile('Dashboard Summary Report', null),
                      _menuTile('Daily Sales Report', null),
                      _menuTile('Monthly Sales Report', null),
                      _menuTile('Sales Detail Report', null),
                      _menuTile('Sales by Product Report', null),
                      _menuTile('Sales by Customer Report', null),
                      _menuTile('Sales by Branch Report', null),
                      _menuTile('Sales Returns Report', null),
                      _menuTile('Purchase Summary Report', null),
                      _menuTile('Purchase Detail Report', null),
                      _menuTile('Supplier Performance Report', null),
                      _menuTile('Supplier Returns Report', null),
                      _menuTile('Stock Summary Report', null),
                      _menuTile('Stock Movement Report', null),
                      _menuTile('Stock In Report', null),
                      _menuTile('Stock Out Report', null),
                      _menuTile('Low Stock Report', null),
                      _menuTile('Out of Stock Report', null),
                      _menuTile('Inventory Valuation Report', null),
                      _menuTile('Product Performance Report', null),
                      _menuTile('Profit and Margin Report', null),
                      _menuTile('Customer Balance Report', null),
                      _menuTile('Supplier Balance Report', null),
                      _menuTile('Branch Comparison Report', null),
                      _menuTile('Payment Method Report', null),
                      _menuTile('Tax Summary Report', null),
                    ],
                  ),
                  ListTile(
                    leading: const Icon(
                      Icons.help_outline,
                      color: blue,
                    ),
                    title: const Text(
                      'Help',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                    onTap: () => _openMenuPage('Help', null),
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
          const Icon(Icons.warning_amber_rounded, color: orange),
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
                  style: const TextStyle(color: muted, fontSize: 11),
                ),
              ],
            ),
          ),
          Text(
            '${product.quantity} left',
            style: const TextStyle(
              color: orange,
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
        ? green
        : movement.type == 'Stock Out'
            ? orange
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
    final unreadCount = inventory.notificationCenter.unreadCount;

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
          Padding(
            padding: const EdgeInsets.only(right: 10),
            child: IconButton(
              tooltip: 'Notifications',
              onPressed: _openNotifications,
              icon: Stack(
                clipBehavior: Clip.none,
                children: [
                  const Icon(
                    Icons.notifications_none_rounded,
                    color: Colors.white,
                    size: 27,
                  ),
                  if (unreadCount > 0)
                    Positioned(
                      right: -7,
                      top: -5,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 5,
                          vertical: 2,
                        ),
                        constraints: const BoxConstraints(
                          minWidth: 17,
                          minHeight: 17,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.redAccent,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: background,
                            width: 1.5,
                          ),
                        ),
                        child: Text(
                          unreadCount > 99 ? '99+' : '$unreadCount',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
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
                    color: green,
                  ),
                  _summaryCard(
                    title: 'Low Stock Items',
                    value: '${inventory.lowStockCount}',
                    subtitle: 'Need attention',
                    icon: Icons.warning_amber_rounded,
                    color: orange,
                  ),
                  _summaryCard(
                    title: "Today's Sales",
                    value:
                        'Rs. ${inventory.totalSalesToday.toStringAsFixed(0)}',
                    subtitle: '${inventory.salesCountToday} orders today',
                    icon: Icons.trending_up,
                    color: purple,
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
                    color: green,
                    onTap: () =>
                        _openDestination(const StockInScreen()),
                  ),
                  _quickAction(
                    title: 'Stock Out',
                    icon: Icons.call_made,
                    color: orange,
                    onTap: () =>
                        _openDestination(const StockOutScreen()),
                  ),
                  _quickAction(
                    title: 'Create Sale',
                    icon: Icons.shopping_cart_outlined,
                    color: purple,
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
