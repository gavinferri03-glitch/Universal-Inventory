
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'inventory_data.dart';

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

  String searchText = '';

  void showTransferDialog(InventoryProduct product) {
    final inventory = ref.read(inventoryProvider);
    final activeBranches =
        inventory.branches.where((b) => b.active).toList();

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

                    Text(
                      'From Branch',
                      style: TextStyle(color: muted),
                    ),
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
                            toBranchId = activeBranches
                                .firstWhere((b) => b.id != value)
                                .id;
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
                    Text(
                      'To Branch',
                      style: TextStyle(color: muted),
                    ),
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
                          .where((b) => b.id != fromBranchId)
                          .map((branch) {
                        return DropdownMenuItem(
                          value: branch.id,
                          child: Text(branch.name),
                        );
                      }).toList(),
                      onChanged: (value) {
                        if (value == null) return;
                        refreshDialog(() => toBranchId = value);
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
                      ScaffoldMessenger.of(context).showSnackBar(
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

                      ScaffoldMessenger.of(this.context).showSnackBar(
                        const SnackBar(
                          content: Text('Stock transferred successfully.'),
                        ),
                      );
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
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
    );
  }

  @override
  Widget build(BuildContext context) {
    final inventory = ref.watch(inventoryProvider);
    final products = inventory.products.where((product) {
      return product.name.toLowerCase().contains(
                searchText.toLowerCase(),
              ) ||
          product.sku.toLowerCase().contains(
                searchText.toLowerCase(),
              );
    }).toList();

    final branches = inventory.branches;

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
                    Expanded(
                      child: _summaryCard(
                        'Products',
                        inventory.products.length.toString(),
                        Icons.inventory_2_outlined,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _summaryCard(
                        'Branches',
                        inventory.activeBranchCount.toString(),
                        Icons.store_outlined,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                TextField(
                  onChanged: (value) {
                    setState(() => searchText = value);
                  },
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: 'Search product or SKU...',
                    hintStyle: TextStyle(color: muted),
                    prefixIcon: Icon(Icons.search, color: muted),
                    filled: true,
                    fillColor: panel,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ],
            ),
          ),

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
                      final product = products[index];

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
                                Icon(
                                  Icons.inventory_2_outlined,
                                  color: blue,
                                  size: 26,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
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
                                        style: TextStyle(
                                          color: muted,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Text(
                                  '${product.quantity}',
                                  style: TextStyle(
                                    color: blue,
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
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
                              final quantity =
                                  inventory.getBranchQuantity(
                                product.id,
                                branch.id,
                              );

                              return Padding(
                                padding:
                                    const EdgeInsets.only(bottom: 9),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        branch.name,
                                        style: const TextStyle(
                                          color: Colors.white70,
                                        ),
                                      ),
                                    ),
                                    Text(
                                      '$quantity ${product.unit}',
                                      style: TextStyle(
                                        color: quantity > 0
                                            ? Colors.greenAccent
                                            : muted,
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
                                onPressed: () =>
                                    showTransferDialog(product),
                                icon: const Icon(
                                  Icons.swap_horiz,
                                ),
                                label: const Text('Transfer Stock'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: blue,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 12,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _summaryCard(
    String title,
    String value,
    IconData icon,
  ) {
    return Container(
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
    );
  }
}
