
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'inventory_data.dart';

class TransferScreen extends ConsumerStatefulWidget {
  const TransferScreen({super.key});

  @override
  ConsumerState<TransferScreen> createState() => _TransferScreenState();
}

class _TransferScreenState extends ConsumerState<TransferScreen> {
  static const Color background = Color(0xFF080B12);
  static const Color panel = Color(0xFF121D2D);
  static const Color blue = Color(0xFF5798FF);
  static const Color green = Color(0xFF45C99A);
  static const Color orange = Color(0xFFFFB454);
  static const Color muted = Color(0xFF91A4BE);

  final TextEditingController searchController = TextEditingController();

  String searchText = '';
  String selectedSort = 'name_az';
  String historySort = 'newest';

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  List<InventoryProduct> _filteredProducts(InventoryData inventory) {
    final query = searchText.trim().toLowerCase();

    final result = inventory.products.where((product) {
      return query.isEmpty ||
          product.name.toLowerCase().contains(query) ||
          product.sku.toLowerCase().contains(query) ||
          product.category.toLowerCase().contains(query) ||
          product.barcode.toLowerCase().contains(query);
    }).toList();

    switch (selectedSort) {
      case 'name_az':
        result.sort((a, b) =>
            a.name.toLowerCase().compareTo(b.name.toLowerCase()));
        break;
      case 'name_za':
        result.sort((a, b) =>
            b.name.toLowerCase().compareTo(a.name.toLowerCase()));
        break;
      case 'stock_high':
        result.sort((a, b) => b.quantity.compareTo(a.quantity));
        break;
      case 'stock_low':
        result.sort((a, b) => a.quantity.compareTo(b.quantity));
        break;
      case 'value_high':
        result.sort((a, b) =>
            (b.quantity * b.costPrice).compareTo(a.quantity * a.costPrice));
        break;
      case 'value_low':
        result.sort((a, b) =>
            (a.quantity * a.costPrice).compareTo(b.quantity * b.costPrice));
        break;
    }

    return result;
  }

  void _showMessage(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  Future<void> _showTransferDialog({
    String? initialProductId,
  }) async {
    final inventory = ref.read(inventoryProvider);

    final products = inventory.products;
    final activeBranches =
        inventory.branches.where((branch) => branch.active).toList();

    if (products.isEmpty) {
      _showMessage('Add a product before creating a transfer.');
      return;
    }

    if (activeBranches.length < 2) {
      _showMessage('You need at least two active branches.');
      return;
    }

    String productId = initialProductId ?? products.first.id;
    String fromBranchId = activeBranches.first.id;
    String toBranchId = activeBranches[1].id;

    final quantityController = TextEditingController();

    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (dialogContext, refreshDialog) {
            final product = inventory.findProduct(productId);

            if (product == null) {
              return const AlertDialog(
                content: Text('Selected product could not be found.'),
              );
            }

            final sourceQuantity = inventory.getBranchQuantity(
              productId,
              fromBranchId,
            );

            InputDecoration decoration(String label) {
              return InputDecoration(
                labelText: label,
                labelStyle: const TextStyle(color: muted),
                filled: true,
                fillColor: background,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Colors.white12),
                ),
              );
            }

            return AlertDialog(
              backgroundColor: panel,
              title: const Text(
                'Create Branch Transfer',
                style: TextStyle(color: Colors.white),
              ),
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
                      items: products.map((item) {
                        return DropdownMenuItem(
                          value: item.id,
                          child: Text('${item.name} (${item.sku})'),
                        );
                      }).toList(),
                      onChanged: (value) {
                        if (value != null) {
                          refreshDialog(() => productId = value);
                        }
                      },
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      value: fromBranchId,
                      isExpanded: true,
                      dropdownColor: panel,
                      style: const TextStyle(color: Colors.white),
                      decoration: decoration('From Branch'),
                      items: activeBranches.map((branch) {
                        return DropdownMenuItem(
                          value: branch.id,
                          child: Text(branch.name),
                        );
                      }).toList(),
                      onChanged: (value) {
                        if (value == null) return;

                        refreshDialog(() {
                          fromBranchId = value;

                          if (toBranchId == fromBranchId) {
                            toBranchId = activeBranches
                                .firstWhere(
                                  (branch) => branch.id != fromBranchId,
                                )
                                .id;
                          }
                        });
                      },
                    ),
                    const SizedBox(height: 8),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Available stock: $sourceQuantity ${product.unit}',
                        style: const TextStyle(
                          color: muted,
                          fontSize: 12,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      value: toBranchId,
                      isExpanded: true,
                      dropdownColor: panel,
                      style: const TextStyle(color: Colors.white),
                      decoration: decoration('To Branch'),
                      items: activeBranches
                          .where((branch) => branch.id != fromBranchId)
                          .map((branch) {
                        return DropdownMenuItem(
                          value: branch.id,
                          child: Text(branch.name),
                        );
                      }).toList(),
                      onChanged: (value) {
                        if (value != null) {
                          refreshDialog(() => toBranchId = value);
                        }
                      },
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: quantityController,
                      keyboardType: TextInputType.number,
                      style: const TextStyle(color: Colors.white),
                      decoration: decoration('Transfer Quantity'),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext),
                  child: const Text(
                    'Cancel',
                    style: TextStyle(color: muted),
                  ),
                ),
                ElevatedButton.icon(
                  icon: const Icon(Icons.swap_horiz),
                  label: const Text('Transfer'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: blue,
                    foregroundColor: Colors.white,
                  ),
                  onPressed: () {
                    final quantity =
                        int.tryParse(quantityController.text.trim());

                    if (quantity == null || quantity <= 0) {
                      _showMessage('Enter a valid transfer quantity.');
                      return;
                    }

                    try {
                      inventory.transferStock(
                        productId: productId,
                        fromBranchId: fromBranchId,
                        toBranchId: toBranchId,
                        quantity: quantity,
                      );

                      Navigator.pop(dialogContext);
                      _showMessage('Stock transferred successfully.');
                    } catch (error) {
                      _showMessage(
                        error.toString().replaceFirst('Exception: ', ''),
                      );
                    }
                  },
                ),
              ],
            );
          },
        );
      },
    );

    quantityController.dispose();
  }

  List<StockMovement> _transferHistory(InventoryData inventory) {
    final result = inventory.movements
        .where(
          (movement) =>
              movement.type == 'Transfer Out' &&
              movement.transferCode != null,
        )
        .toList();

    switch (historySort) {
      case 'newest':
        result.sort((a, b) => b.date.compareTo(a.date));
        break;
      case 'oldest':
        result.sort((a, b) => a.date.compareTo(b.date));
        break;
      case 'quantity_high':
        result.sort((a, b) => b.quantity.compareTo(a.quantity));
        break;
      case 'quantity_low':
        result.sort((a, b) => a.quantity.compareTo(b.quantity));
        break;
      case 'product_az':
        result.sort((a, b) =>
            a.productName.toLowerCase().compareTo(
                  b.productName.toLowerCase(),
                ));
        break;
    }

    return result;
  }

  Widget _summaryCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: panel,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.white10),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 23),
            const SizedBox(height: 10),
            Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 21,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 3),
            Text(
              title,
              style: const TextStyle(color: muted, fontSize: 11),
            ),
          ],
        ),
      ),
    );
  }

  Widget _productCard(
    InventoryData inventory,
    InventoryProduct product,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: panel,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.inventory_2_outlined, color: blue, size: 25),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '${product.sku} • ${product.category}',
                      style: const TextStyle(color: muted, fontSize: 11),
                    ),
                  ],
                ),
              ),
              Text(
                '${product.quantity}',
                style: const TextStyle(
                  color: blue,
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
            ],
          ),
          const Divider(color: Colors.white12, height: 24),
          const Text(
            'Branch-wise stock',
            style: TextStyle(
              color: muted,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 10),
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
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (!branch.active)
                    const Padding(
                      padding: EdgeInsets.only(left: 6),
                      child: Text(
                        'Inactive',
                        style: TextStyle(
                          color: orange,
                          fontSize: 10,
                        ),
                      ),
                    ),
                ],
              ),
            );
          }),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => _showTransferDialog(
                initialProductId: product.id,
              ),
              icon: const Icon(Icons.swap_horiz),
              label: const Text('Transfer This Product'),
              style: ElevatedButton.styleFrom(
                backgroundColor: blue,
                foregroundColor: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _historyCard(
    InventoryData inventory,
    StockMovement movement,
  ) {
    StockMovement? incoming;

    for (final item in inventory.movements) {
      if (item.type == 'Transfer In' &&
          item.transferCode == movement.transferCode) {
        incoming = item;
        break;
      }
    }

    final fromBranch = inventory.findBranch(movement.branchId);
    final toBranch = incoming == null
        ? null
        : inventory.findBranch(incoming.branchId);

    final date = movement.date;
    final dateText =
        '${date.year}-${date.month.toString().padLeft(2, '0')}-'
        '${date.day.toString().padLeft(2, '0')} '
        '${date.hour.toString().padLeft(2, '0')}:'
        '${date.minute.toString().padLeft(2, '0')}';

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: panel,
        borderRadius: BorderRadius.circular(13),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.swap_horiz, color: blue),
              const SizedBox(width: 9),
              Expanded(
                child: Text(
                  movement.productName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Text(
                '${movement.quantity}',
                style: const TextStyle(
                  color: blue,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            'From: ${fromBranch?.name ?? "Unknown branch"}',
            style: const TextStyle(color: muted, fontSize: 12),
          ),
          const SizedBox(height: 4),
          Text(
            'To: ${toBranch?.name ?? "Unknown branch"}',
            style: const TextStyle(color: muted, fontSize: 12),
          ),
          const SizedBox(height: 8),
          Text(
            'Reference: ${movement.transferCode ?? "-"}',
            style: const TextStyle(color: muted, fontSize: 11),
          ),
          Text(
            dateText,
            style: const TextStyle(color: muted, fontSize: 11),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final inventory = ref.watch(inventoryProvider);
    final products = _filteredProducts(inventory);
    final history = _transferHistory(inventory);

    final totalTransfers = history.length;
    final totalUnitsTransferred = history.fold<int>(
      0,
      (total, movement) => total + movement.quantity,
    );

    return Scaffold(
      backgroundColor: background,
      appBar: AppBar(
        backgroundColor: background,
        foregroundColor: Colors.white,
        title: const Text(
          'Branch Transfers',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            tooltip: 'Create transfer',
            onPressed: () => _showTransferDialog(),
            icon: const Icon(Icons.add_circle_outline),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showTransferDialog(),
        backgroundColor: blue,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.swap_horiz),
        label: const Text('New Transfer'),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 90),
          children: [
            Row(
              children: [
                _summaryCard(
                  'Active branches',
                  '${inventory.activeBranchCount}',
                  Icons.store_outlined,
                  blue,
                ),
                const SizedBox(width: 10),
                _summaryCard(
                  'Transfers',
                  '$totalTransfers',
                  Icons.swap_horiz,
                  green,
                ),
              ],
            ),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: panel,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.white10),
              ),
              child: Row(
                children: [
                  const Icon(Icons.inventory_2_outlined, color: orange),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      'Total units transferred',
                      style: TextStyle(color: muted, fontSize: 12),
                    ),
                  ),
                  Text(
                    '$totalUnitsTransferred',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Products available for transfer',
              style: TextStyle(
                color: Colors.white,
                fontSize: 17,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: searchController,
              onChanged: (value) => setState(() => searchText = value),
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Search product, SKU or category...',
                hintStyle: const TextStyle(color: muted),
                prefixIcon: const Icon(Icons.search, color: muted),
                suffixIcon: searchText.isEmpty
                    ? null
                    : IconButton(
                        onPressed: () {
                          searchController.clear();
                          setState(() => searchText = '');
                        },
                        icon: const Icon(Icons.close, color: muted),
                      ),
                filled: true,
                fillColor: panel,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(13),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 10),
            DropdownButtonFormField<String>(
              value: selectedSort,
              dropdownColor: panel,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: 'Sort products',
                labelStyle: const TextStyle(color: muted),
                filled: true,
                fillColor: panel,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(13),
                ),
              ),
              items: const [
                DropdownMenuItem(
                  value: 'name_az',
                  child: Text('Name: A–Z'),
                ),
                DropdownMenuItem(
                  value: 'name_za',
                  child: Text('Name: Z–A'),
                ),
                DropdownMenuItem(
                  value: 'stock_high',
                  child: Text('Highest stock'),
                ),
                DropdownMenuItem(
                  value: 'stock_low',
                  child: Text('Lowest stock'),
                ),
                DropdownMenuItem(
                  value: 'value_high',
                  child: Text('Highest stock value'),
                ),
                DropdownMenuItem(
                  value: 'value_low',
                  child: Text('Lowest stock value'),
                ),
              ],
              onChanged: (value) {
                if (value != null) {
                  setState(() => selectedSort = value);
                }
              },
            ),
            const SizedBox(height: 14),
            if (products.isEmpty)
              const Padding(
                padding: EdgeInsets.all(20),
                child: Center(
                  child: Text(
                    'No products found.',
                    style: TextStyle(color: muted),
                  ),
                ),
              )
            else
              ...products.map(
                (product) => _productCard(inventory, product),
              ),
            const SizedBox(height: 20),
            const Divider(color: Colors.white12),
            const SizedBox(height: 12),
            const Text(
              'Transfer History',
              style: TextStyle(
                color: Colors.white,
                fontSize: 17,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            DropdownButtonFormField<String>(
              value: historySort,
              dropdownColor: panel,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: 'Sort transfer history',
                labelStyle: const TextStyle(color: muted),
                filled: true,
                fillColor: panel,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(13),
                ),
              ),
              items: const [
                DropdownMenuItem(
                  value: 'newest',
                  child: Text('Newest first'),
                ),
                DropdownMenuItem(
                  value: 'oldest',
                  child: Text('Oldest first'),
                ),
                DropdownMenuItem(
                  value: 'quantity_high',
                  child: Text('Highest quantity'),
                ),
                DropdownMenuItem(
                  value: 'quantity_low',
                  child: Text('Lowest quantity'),
                ),
                DropdownMenuItem(
                  value: 'product_az',
                  child: Text('Product: A–Z'),
                ),
              ],
              onChanged: (value) {
                if (value != null) {
                  setState(() => historySort = value);
                }
              },
            ),
            const SizedBox(height: 12),
            if (history.isEmpty)
              const Padding(
                padding: EdgeInsets.all(20),
                child: Center(
                  child: Text(
                    'No branch transfers recorded yet.',
                    style: TextStyle(color: muted),
                  ),
                ),
              )
            else
              ...history.map(
                (movement) => _historyCard(inventory, movement),
              ),
          ],
        ),
      ),
    );
  }
}
