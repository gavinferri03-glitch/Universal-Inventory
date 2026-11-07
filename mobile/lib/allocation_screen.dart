
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'inventory_data.dart';
import 'list_tools.dart';

class AllocationScreen extends ConsumerStatefulWidget {
  const AllocationScreen({super.key});

  @override
  ConsumerState<AllocationScreen> createState() =>
      _AllocationScreenState();
}

class _AllocationScreenState extends ConsumerState<AllocationScreen> {
  final Color blue = const Color(0xFF5798FF);
  final Color panel = const Color(0xFF121D2D);
  final Color muted = const Color(0xFF91A4BE);

  final TextEditingController searchController = TextEditingController();

  String searchText = '';
  String selectedSort = 'name_az';
  String selectedFilter = 'all';

  final Map<String, String> sortOptions = {
    'name_az': 'Product: A–Z',
    'name_za': 'Product: Z–A',
    'stock_high': 'Highest total stock',
    'stock_low': 'Lowest total stock',
    'value_high': 'Highest stock value',
    'value_low': 'Lowest stock value',
  };

  final Map<String, String> filterOptions = {
    'all': 'All products',
    'in_stock': 'In stock',
    'out_stock': 'Out of stock',
    'low_stock': 'Low stock',
  };

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  List<InventoryProduct> getProducts(InventoryData inventory) {
    final query = searchText.trim().toLowerCase();

    final result = inventory.products.where((product) {
      final matchesSearch = query.isEmpty ||
          product.name.toLowerCase().contains(query) ||
          product.sku.toLowerCase().contains(query) ||
          product.category.toLowerCase().contains(query) ||
          product.barcode.toLowerCase().contains(query);

      bool matchesFilter;

      switch (selectedFilter) {
        case 'in_stock':
          matchesFilter = product.quantity > 0;
          break;
        case 'out_stock':
          matchesFilter = product.quantity <= 0;
          break;
        case 'low_stock':
          matchesFilter = product.quantity > 0 &&
              product.quantity <= product.minimumStock;
          break;
        default:
          matchesFilter = true;
      }

      return matchesSearch && matchesFilter;
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
            (b.quantity * b.costPrice)
                .compareTo(a.quantity * a.costPrice));
        break;
      case 'value_low':
        result.sort((a, b) =>
            (a.quantity * a.costPrice)
                .compareTo(b.quantity * b.costPrice));
        break;
    }

    return result;
  }

  void showTransferDialog(InventoryProduct product) {
    final inventory = ref.read(inventoryProvider);
    final activeBranches =
        inventory.branches.where((branch) => branch.active).toList();

    if (activeBranches.length < 2) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('You need at least two active branches.'),
        ),
      );
      return;
    }

    String fromBranchId = activeBranches.first.id;
    String toBranchId = activeBranches[1].id;
    final quantityController = TextEditingController();

    showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, refreshDialog) {
            final sourceStock = inventory.getBranchQuantity(
              product.id,
              fromBranchId,
            );

            return AlertDialog(
              backgroundColor: panel,
              title: const Text(
                'Transfer Stock',
                style: TextStyle(color: Colors.white),
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.name,
                      style: TextStyle(
                        color: blue,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text('From Branch', style: TextStyle(color: muted)),
                    const SizedBox(height: 6),
                    DropdownButtonFormField<String>(
                      value: fromBranchId,
                      dropdownColor: panel,
                      style: const TextStyle(color: Colors.white),
                      decoration: const InputDecoration(
                        filled: true,
                        fillColor: Color(0xFF080B12),
                        border: OutlineInputBorder(),
                      ),
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
                          if (toBranchId == value) {
                            toBranchId =
                                activeBranches.firstWhere(
                                  (branch) => branch.id != value,
                                ).id;
                          }
                        });
                      },
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Available stock: $sourceStock ${product.unit}',
                      style: TextStyle(color: muted, fontSize: 12),
                    ),
                    const SizedBox(height: 16),
                    Text('To Branch', style: TextStyle(color: muted)),
                    const SizedBox(height: 6),
                    DropdownButtonFormField<String>(
                      value: toBranchId,
                      dropdownColor: panel,
                      style: const TextStyle(color: Colors.white),
                      decoration: const InputDecoration(
                        filled: true,
                        fillColor: Color(0xFF080B12),
                        border: OutlineInputBorder(),
                      ),
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
                      decoration: InputDecoration(
                        labelText: 'Transfer Quantity',
                        labelStyle: TextStyle(color: muted),
                        filled: true,
                        fillColor: const Color(0xFF080B12),
                        border: const OutlineInputBorder(),
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext),
                  child: Text('Cancel', style: TextStyle(color: muted)),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: blue,
                    foregroundColor: Colors.white,
                  ),
                  onPressed: () {
                    final quantity =
                        int.tryParse(quantityController.text.trim());

                    if (quantity == null || quantity <= 0) {
                      ScaffoldMessenger.of(this.context).showSnackBar(
                        const SnackBar(
                          content: Text('Enter a valid quantity.'),
                        ),
                      );
                      return;
                    }

                    try {
                      inventory.transferStock(
                        productId: product.id,
                        fromBranchId: fromBranchId,
                        toBranchId: toBranchId,
                        quantity: quantity,
                      );

                      Navigator.pop(dialogContext);

                      setState(() {});

                      ScaffoldMessenger.of(this.context).showSnackBar(
                        const SnackBar(
                          content: Text('Stock transferred successfully.'),
                        ),
                      );
                    } catch (e) {
                      ScaffoldMessenger.of(this.context).showSnackBar(
                        SnackBar(content: Text(e.toString())),
                      );
                    }
                  },
                  child: const Text('Transfer'),
                ),
              ],
            );
          },
        );
      },
    ).then((_) => quantityController.dispose());
  }

  Widget _summaryCard(String title, String value, IconData icon) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: panel,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: blue, size: 22),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              title,
              style: TextStyle(color: muted, fontSize: 12),
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
    final branches = inventory.branches;
    final stockValue = product.quantity * product.costPrice;

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: panel,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.inventory_2_outlined, color: blue, size: 26),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '${product.sku} • ${product.category}',
                      style: TextStyle(color: muted, fontSize: 12),
                    ),
                  ],
                ),
              ),
              Text(
                '${product.quantity}',
                style: TextStyle(
                  color: product.quantity <= product.minimumStock
                      ? Colors.orangeAccent
                      : blue,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Text(
                  'Stock value: ${stockValue.toStringAsFixed(2)}',
                  style: TextStyle(color: muted, fontSize: 12),
                ),
              ),
              Text(
                product.quantity <= 0
                    ? 'Out of stock'
                    : product.quantity <= product.minimumStock
                        ? 'Low stock'
                        : 'In stock',
                style: TextStyle(
                  color: product.quantity <= 0
                      ? Colors.redAccent
                      : product.quantity <= product.minimumStock
                          ? Colors.orangeAccent
                          : Colors.greenAccent,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          const Divider(color: Colors.white12),
          const SizedBox(height: 8),
          Text(
            'Branch-wise Stock',
            style: TextStyle(
              color: muted,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 10),
          ...branches.map((branch) {
            final quantity = inventory.getBranchQuantity(
              product.id,
              branch.id,
            );

            return Padding(
              padding: const EdgeInsets.only(bottom: 9),
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
                      color: quantity > 0 ? Colors.greenAccent : muted,
                      fontWeight: FontWeight.w600,
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
              onPressed: () => showTransferDialog(product),
              icon: const Icon(Icons.swap_horiz),
              label: const Text('Transfer Stock'),
              style: ElevatedButton.styleFrom(
                backgroundColor: blue,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final inventory = ref.watch(inventoryProvider);
    final products = getProducts(inventory);

    final inStock = inventory.products
        .where((product) => product.quantity > 0)
        .length;
    final lowStock = inventory.products
        .where((product) =>
            product.quantity > 0 &&
            product.quantity <= product.minimumStock)
        .length;

    return Scaffold(
      backgroundColor: const Color(0xFF080B12),
      appBar: AppBar(
        backgroundColor: const Color(0xFF080B12),
        foregroundColor: Colors.white,
        title: const Text('Branch Stock Allocation'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Row(
                  children: [
                    _summaryCard(
                      'Products',
                      inventory.products.length.toString(),
                      Icons.inventory_2_outlined,
                    ),
                    const SizedBox(width: 12),
                    _summaryCard(
                      'Active Branches',
                      inventory.activeBranchCount.toString(),
                      Icons.store_outlined,
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    _summaryCard(
                      'In Stock',
                      inStock.toString(),
                      Icons.check_circle_outline,
                    ),
                    const SizedBox(width: 12),
                    _summaryCard(
                      'Low Stock',
                      lowStock.toString(),
                      Icons.warning_amber_outlined,
                    ),
                  ],
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: InventoryListToolbar(
              searchController: searchController,
              searchHint: 'Search product, SKU, category or barcode...',
              onSearchChanged: (value) {
                setState(() => searchText = value);
              },
              sortOptions: sortOptions,
              selectedSort: selectedSort,
              onSortChanged: (value) {
                setState(() => selectedSort = value);
              },
              filterOptions: filterOptions,
              selectedFilter: selectedFilter,
              onFilterChanged: (value) {
                setState(() => selectedFilter = value);
              },
            ),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: products.isEmpty
                ? Center(
                    child: Text(
                      'No products found.',
                      style: TextStyle(color: muted),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: products.length,
                    itemBuilder: (context, index) {
                      return _productCard(inventory, products[index]);
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
