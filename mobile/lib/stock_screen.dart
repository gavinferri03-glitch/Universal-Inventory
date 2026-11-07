
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'inventory_data.dart';
import 'list_tools.dart';

class StockScreen extends ConsumerStatefulWidget {
  const StockScreen({super.key});

  @override
  ConsumerState<StockScreen> createState() => _StockScreenState();
}

class _StockScreenState extends ConsumerState<StockScreen> {
  static const Color blue = Color(0xFF5798FF);
  static const Color green = Color(0xFF45C99A);
  static const Color orange = Color(0xFFFFB454);
  static const Color panel = Color(0xFF121D2D);
  static const Color muted = Color(0xFF91A4BE);

  final TextEditingController movementSearchController =
      TextEditingController();
  final TextEditingController productSearchController =
      TextEditingController();

  String movementSearch = '';
  String productSearch = '';
  String selectedFilter = 'All';
  String movementSort = 'newest';
  String productSort = 'name_az';

  final Map<String, String> movementSortOptions = {
    'newest': 'Newest first',
    'oldest': 'Oldest first',
    'quantity_high': 'Highest quantity',
    'quantity_low': 'Lowest quantity',
    'product_az': 'Product A–Z',
    'product_za': 'Product Z–A',
  };

  final Map<String, String> movementFilterOptions = {
    'All': 'All movements',
    'Stock In': 'Stock In',
    'Stock Out': 'Stock Out',
    'Transfers': 'Transfers',
  };

  final Map<String, String> productSortOptions = {
    'name_az': 'Product name A–Z',
    'name_za': 'Product name Z–A',
    'stock_high': 'Highest stock first',
    'stock_low': 'Lowest stock first',
  };

  final Map<String, String> productFilterOptions = {
    'all': 'All products',
    'in_stock': 'In-stock products',
    'out_stock': 'Out-of-stock products',
  };

  String productFilter = 'all';

  @override
  void dispose() {
    movementSearchController.dispose();
    productSearchController.dispose();
    super.dispose();
  }

  String formatDate(DateTime date) {
    final hour = date.hour % 12 == 0 ? 12 : date.hour % 12;
    final minute = date.minute.toString().padLeft(2, '0');
    final period = date.hour >= 12 ? 'PM' : 'AM';
    return '${date.day}/${date.month}/${date.year}  $hour:$minute $period';
  }

  InputDecoration decoration(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: muted),
      filled: true,
      fillColor: const Color(0xFF080B12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    );
  }

  Future<void> addMovement(String type) async {
    final inventory = ref.read(inventoryProvider);
    final products = inventory.products;
    final branches = inventory.branches.where((b) => b.active).toList();

    if (products.isEmpty || branches.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Add a product and active branch first.'),
        ),
      );
      return;
    }

    final quantityController = TextEditingController();
    String productId = products.first.id;
    String branchId = branches.first.id;

    final saved = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, refresh) {
            final product = products.firstWhere((p) => p.id == productId);
            final branchStock =
                inventory.getBranchQuantity(productId, branchId);

            return AlertDialog(
              backgroundColor: panel,
              title: Text(type, style: const TextStyle(color: Colors.white)),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    DropdownButtonFormField<String>(
                      value: productId,
                      isExpanded: true,
                      dropdownColor: panel,
                      style: const TextStyle(color: Colors.white),
                      decoration: decoration('Product'),
                      items: products.map((p) {
                        return DropdownMenuItem(
                          value: p.id,
                          child: Text('${p.name} (${p.sku})'),
                        );
                      }).toList(),
                      onChanged: (value) {
                        if (value != null) {
                          refresh(() => productId = value);
                        }
                      },
                    ),
                    const SizedBox(height: 14),
                    DropdownButtonFormField<String>(
                      value: branchId,
                      isExpanded: true,
                      dropdownColor: panel,
                      style: const TextStyle(color: Colors.white),
                      decoration: decoration('Branch'),
                      items: branches.map((b) {
                        return DropdownMenuItem(
                          value: b.id,
                          child: Text(b.name),
                        );
                      }).toList(),
                      onChanged: (value) {
                        if (value != null) {
                          refresh(() => branchId = value);
                        }
                      },
                    ),
                    const SizedBox(height: 10),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Available at this branch: $branchStock ${product.unit}',
                        style: const TextStyle(color: muted, fontSize: 12),
                      ),
                    ),
                    const SizedBox(height: 14),
                    TextField(
                      controller: quantityController,
                      keyboardType: TextInputType.number,
                      style: const TextStyle(color: Colors.white),
                      decoration: decoration('Quantity'),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext, false),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: type == 'Stock In' ? green : orange,
                    foregroundColor: Colors.black,
                  ),
                  onPressed: () {
                    final quantity =
                        int.tryParse(quantityController.text.trim());

                    if (quantity == null || quantity <= 0) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Enter a valid quantity.'),
                        ),
                      );
                      return;
                    }

                    try {
                      inventory.recordStockMovement(
                        productId: productId,
                        type: type,
                        quantity: quantity,
                        branchId: branchId,
                      );
                      Navigator.pop(dialogContext, true);
                    } catch (error) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            error.toString().replaceFirst('Exception: ', ''),
                          ),
                        ),
                      );
                    }
                  },
                  child: const Text('Save Movement'),
                ),
              ],
            );
          },
        );
      },
    );

    quantityController.dispose();

    if (!mounted || saved != true) return;

    ScaffoldMessenger.of(this.context).showSnackBar(
      SnackBar(content: Text('$type recorded successfully.')),
    );
  }

  Widget summaryCard(
    String title,
    int value,
    Color color, {
    bool wide = false,
  }) {
    return Container(
      width: wide ? double.infinity : null,
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: panel,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFF26364D)),
      ),
      child: Row(
        children: [
          Icon(Icons.inventory_2_outlined, color: color, size: 25),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value.toString(),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 21,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(title, style: const TextStyle(color: muted, fontSize: 12)),
            ],
          ),
        ],
      ),
    );
  }

  Widget actionButton(
    String title,
    String subtitle,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: panel,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFF26364D)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 27),
            const SizedBox(height: 12),
            Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              subtitle,
              style: const TextStyle(color: muted, fontSize: 11),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final inventory = ref.watch(inventoryProvider);
    final movements = inventory.movements;

    final totalReceived = movements
        .where((m) => m.type == 'Stock In')
        .fold<int>(0, (sum, m) => sum + m.quantity);

    final totalIssued = movements
        .where((m) => m.type == 'Stock Out')
        .fold<int>(0, (sum, m) => sum + m.quantity);

    final visibleProducts = inventory.products.where((product) {
      final query = productSearch.trim().toLowerCase();

      final matchesSearch = query.isEmpty ||
          product.name.toLowerCase().contains(query) ||
          product.sku.toLowerCase().contains(query);

      final quantity = product.quantity;
      final matchesFilter = productFilter == 'all' ||
          (productFilter == 'in_stock' && quantity > 0) ||
          (productFilter == 'out_stock' && quantity <= 0);

      return matchesSearch && matchesFilter;
    }).toList();

    switch (productSort) {
      case 'name_az':
        visibleProducts.sort((a, b) => a.name.toLowerCase().compareTo(
              b.name.toLowerCase(),
            ));
        break;
      case 'name_za':
        visibleProducts.sort((a, b) => b.name.toLowerCase().compareTo(
              a.name.toLowerCase(),
            ));
        break;
      case 'stock_high':
        visibleProducts.sort((a, b) => b.quantity.compareTo(a.quantity));
        break;
      case 'stock_low':
        visibleProducts.sort((a, b) => a.quantity.compareTo(b.quantity));
        break;
    }

    final visibleMovements = movements.where((movement) {
      final branch = inventory.findBranch(movement.branchId);
      final query = movementSearch.trim().toLowerCase();

      final matchesSearch = query.isEmpty ||
          movement.productName.toLowerCase().contains(query) ||
          movement.type.toLowerCase().contains(query) ||
          (branch?.name.toLowerCase().contains(query) ?? false);

      final matchesFilter = selectedFilter == 'All' ||
          (selectedFilter == 'Transfers'
              ? movement.type.startsWith('Transfer')
              : movement.type == selectedFilter);

      return matchesSearch && matchesFilter;
    }).toList();

    switch (movementSort) {
      case 'newest':
        visibleMovements.sort((a, b) => b.date.compareTo(a.date));
        break;
      case 'oldest':
        visibleMovements.sort((a, b) => a.date.compareTo(b.date));
        break;
      case 'quantity_high':
        visibleMovements.sort((a, b) => b.quantity.compareTo(a.quantity));
        break;
      case 'quantity_low':
        visibleMovements.sort((a, b) => a.quantity.compareTo(b.quantity));
        break;
      case 'product_az':
        visibleMovements.sort((a, b) =>
            a.productName.toLowerCase().compareTo(
                  b.productName.toLowerCase(),
                ));
        break;
      case 'product_za':
        visibleMovements.sort((a, b) =>
            b.productName.toLowerCase().compareTo(
                  a.productName.toLowerCase(),
                ));
        break;
    }

    return Scaffold(
      backgroundColor: const Color(0xFF080B12),
      appBar: AppBar(
        backgroundColor: const Color(0xFF080B12),
        title: const Text('Stock Management'),
        foregroundColor: Colors.white,
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(18),
          children: [
            const Text(
              'Stock Overview',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: summaryCard('Stock In', totalReceived, green),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: summaryCard('Stock Out', totalIssued, orange),
                ),
              ],
            ),
            const SizedBox(height: 12),
            summaryCard(
              'Total Current Stock',
              inventory.totalStock,
              blue,
              wide: true,
            ),
            const SizedBox(height: 26),
            const Text(
              'Stock Actions',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: actionButton(
                    'Stock In',
                    'Receive products',
                    Icons.add_circle_outline,
                    green,
                    () => addMovement('Stock In'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: actionButton(
                    'Stock Out',
                    'Issue products',
                    Icons.remove_circle_outline,
                    orange,
                    () => addMovement('Stock Out'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 26),
            const Text(
              'Branch-wise Stock',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            InventoryListToolbar(
              searchController: productSearchController,
              searchHint: 'Search products by name or SKU...',
              onSearchChanged: (value) {
                setState(() => productSearch = value);
              },
              sortOptions: productSortOptions,
              selectedSort: productSort,
              onSortChanged: (value) {
                setState(() => productSort = value);
              },
              filterOptions: productFilterOptions,
              selectedFilter: productFilter,
              onFilterChanged: (value) {
                setState(() => productFilter = value);
              },
            ),
            const SizedBox(height: 12),
            if (visibleProducts.isEmpty)
              const Padding(
                padding: EdgeInsets.all(20),
                child: Center(
                  child: Text(
                    'No products found.',
                    style: TextStyle(color: muted),
                  ),
                ),
              ),
            ...visibleProducts.map((product) {
              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: panel,
                  borderRadius: BorderRadius.circular(13),
                  border: Border.all(color: const Color(0xFF26364D)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                    Text(
                      '${product.sku} • Total: ${product.quantity} ${product.unit}',
                      style: const TextStyle(color: muted, fontSize: 12),
                    ),
                    const Divider(color: Colors.white12, height: 22),
                    ...inventory.branches.map((branch) {
                      final quantity = inventory.getBranchQuantity(
                        product.id,
                        branch.id,
                      );

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                branch.name,
                                style: const TextStyle(color: Colors.white70),
                              ),
                            ),
                            Text(
                              '$quantity ${product.unit}',
                              style: TextStyle(
                                color: quantity > 0 ? green : muted,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
                  ],
                ),
              );
            }),
            const SizedBox(height: 18),
            const Text(
              'Movement History',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            InventoryListToolbar(
              searchController: movementSearchController,
              searchHint: 'Search product, branch or movement...',
              onSearchChanged: (value) {
                setState(() => movementSearch = value);
              },
              sortOptions: movementSortOptions,
              selectedSort: movementSort,
              onSortChanged: (value) {
                setState(() => movementSort = value);
              },
              filterOptions: movementFilterOptions,
              selectedFilter: selectedFilter,
              onFilterChanged: (value) {
                setState(() => selectedFilter = value);
              },
            ),
            const SizedBox(height: 12),
            if (visibleMovements.isEmpty)
              const Padding(
                padding: EdgeInsets.all(20),
                child: Center(
                  child: Text(
                    'No movements found.',
                    style: TextStyle(color: muted),
                  ),
                ),
              ),
            ...visibleMovements.map((movement) {
              final branch = inventory.findBranch(movement.branchId);
              final isIn = movement.type == 'Stock In';
              final isTransfer = movement.type.startsWith('Transfer');
              final color = isIn
                  ? green
                  : isTransfer
                      ? blue
                      : orange;

              final isPositive =
                  isIn || movement.type == 'Transfer In';

              return Container(
                margin: const EdgeInsets.only(bottom: 9),
                padding: const EdgeInsets.all(13),
                decoration: BoxDecoration(
                  color: panel,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Icon(
                      isIn
                          ? Icons.call_received
                          : isTransfer
                              ? Icons.swap_horiz
                              : Icons.call_made,
                      color: color,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            movement.productName,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            '${movement.type} • ${branch?.name ?? "Unknown branch"}',
                            style: const TextStyle(
                              color: muted,
                              fontSize: 11,
                            ),
                          ),
                          Text(
                            formatDate(movement.date),
                            style: const TextStyle(
                              color: muted,
                              fontSize: 10,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      '${isPositive ? "+" : "-"}${movement.quantity}',
                      style: TextStyle(
                        color: color,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}
