
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'inventory_data.dart';

class StockInScreen extends ConsumerWidget {
  const StockInScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return const StockMovementScreen(isStockIn: true);
  }
}

class StockOutScreen extends ConsumerWidget {
  const StockOutScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return const StockMovementScreen(isStockIn: false);
  }
}

class StockMovementScreen extends ConsumerStatefulWidget {
  final bool isStockIn;

  const StockMovementScreen({
    super.key,
    required this.isStockIn,
  });

  @override
  ConsumerState<StockMovementScreen> createState() =>
      _StockMovementScreenState();
}

class _StockMovementScreenState
    extends ConsumerState<StockMovementScreen> {
  static const Color background = Color(0xFF080B12);
  static const Color panel = Color(0xFF121D2D);
  static const Color blue = Color(0xFF5798FF);
  static const Color green = Color(0xFF45C99A);
  static const Color orange = Color(0xFFFFB454);
  static const Color muted = Color(0xFF91A4BE);

  String? selectedProductId;
  String? selectedBranchId;

  final TextEditingController quantityController =
      TextEditingController();

  @override
  void dispose() {
    quantityController.dispose();
    super.dispose();
  }

  bool get isStockIn => widget.isStockIn;

  Color get accent => isStockIn ? green : orange;

  String get movementType => isStockIn ? 'Stock In' : 'Stock Out';

  void showMessage(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  Future<void> saveMovement() async {
    final inventory = ref.read(inventoryProvider);

    if (selectedProductId == null || selectedBranchId == null) {
      showMessage('Please select a product and branch.');
      return;
    }

    final quantity = int.tryParse(quantityController.text.trim());

    if (quantity == null || quantity <= 0) {
      showMessage('Enter a valid quantity greater than zero.');
      return;
    }

    final product = inventory.getProductById(selectedProductId!);

    if (product == null) {
      showMessage('Selected product could not be found.');
      return;
    }

    try {
      inventory.recordStockMovement(
        productId: selectedProductId!,
        type: movementType,
        quantity: quantity,
        branchId: selectedBranchId!,
      );

      quantityController.clear();

      setState(() {});

      showMessage(
        isStockIn
            ? 'Stock received successfully.'
            : 'Stock issued successfully.',
      );
    } catch (error) {
      showMessage(
        error.toString().replaceFirst('Exception: ', ''),
      );
    }
  }

  Widget panelCard({
    required Widget child,
    EdgeInsets padding = const EdgeInsets.all(16),
  }) {
    return Container(
      width: double.infinity,
      padding: padding,
      decoration: BoxDecoration(
        color: panel,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white10),
      ),
      child: child,
    );
  }

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

  @override
  Widget build(BuildContext context) {
    final inventory = ref.watch(inventoryProvider);

    final products = inventory.products;
    final branches =
        inventory.branches.where((branch) => branch.active).toList();

    if (products.isNotEmpty &&
        (selectedProductId == null ||
            !products.any((p) => p.id == selectedProductId))) {
      selectedProductId = products.first.id;
    }

    if (branches.isNotEmpty &&
        (selectedBranchId == null ||
            !branches.any((b) => b.id == selectedBranchId))) {
      selectedBranchId = branches.first.id;
    }

    final selectedProduct = products.isEmpty
        ? null
        : inventory.getProductById(selectedProductId!);

    final currentQuantity = selectedProduct == null ||
            selectedBranchId == null
        ? 0
        : inventory.getBranchQuantity(
            selectedProduct.id,
            selectedBranchId!,
          );

    final history = inventory.movements.where((movement) {
      return movement.type == movementType;
    }).toList()
      ..sort((a, b) => b.date.compareTo(a.date));

    final totalMoved = history.fold<int>(
      0,
      (total, movement) => total + movement.quantity,
    );

    return Scaffold(
      backgroundColor: background,
      appBar: AppBar(
        backgroundColor: background,
        foregroundColor: Colors.white,
        title: Text(isStockIn ? 'Stock In' : 'Stock Out'),
      ),
      body: SafeArea(
        child: products.isEmpty || branches.isEmpty
            ? Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Text(
                    products.isEmpty
                        ? 'Add products before recording stock movements.'
                        : 'Create an active branch before recording stock movements.',
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: muted),
                  ),
                ),
              )
            : ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  panelCard(
                    child: Row(
                      children: [
                        Container(
                          width: 52,
                          height: 52,
                          decoration: BoxDecoration(
                            color: accent.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Icon(
                            isStockIn
                                ? Icons.add_box_outlined
                                : Icons.outbox_outlined,
                            color: accent,
                            size: 28,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                isStockIn
                                    ? 'Receive Inventory'
                                    : 'Issue Inventory',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 17,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                isStockIn
                                    ? 'Add products to a branch.'
                                    : 'Remove products from a branch.',
                                style: const TextStyle(
                                  color: muted,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  Row(
                    children: [
                      Expanded(
                        child: _summary(
                          'Current Stock',
                          '$currentQuantity',
                          Icons.inventory_2_outlined,
                          blue,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _summary(
                          'Total $movementType',
                          '$totalMoved',
                          isStockIn
                              ? Icons.south_west
                              : Icons.north_east,
                          accent,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  const Text(
                    'Movement Details',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 17,
                    ),
                  ),

                  const SizedBox(height: 12),

                  panelCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        DropdownButtonFormField<String>(
                          value: selectedProductId,
                          isExpanded: true,
                          dropdownColor: panel,
                          style: const TextStyle(color: Colors.white),
                          decoration: decoration('Select Product'),
                          items: products.map((product) {
                            return DropdownMenuItem(
                              value: product.id,
                              child: Text(
                                '${product.name} (${product.sku})',
                                overflow: TextOverflow.ellipsis,
                              ),
                            );
                          }).toList(),
                          onChanged: (value) {
                            if (value != null) {
                              setState(() {
                                selectedProductId = value;
                              });
                            }
                          },
                        ),

                        const SizedBox(height: 14),

                        DropdownButtonFormField<String>(
                          value: selectedBranchId,
                          isExpanded: true,
                          dropdownColor: panel,
                          style: const TextStyle(color: Colors.white),
                          decoration: decoration('Select Branch'),
                          items: branches.map((branch) {
                            return DropdownMenuItem(
                              value: branch.id,
                              child: Text(branch.name),
                            );
                          }).toList(),
                          onChanged: (value) {
                            if (value != null) {
                              setState(() {
                                selectedBranchId = value;
                              });
                            }
                          },
                        ),

                        const SizedBox(height: 14),

                        Text(
                          'Available quantity: $currentQuantity ${selectedProduct?.unit ?? ''}',
                          style: const TextStyle(
                            color: muted,
                            fontSize: 12,
                          ),
                        ),

                        const SizedBox(height: 14),

                        TextField(
                          controller: quantityController,
                          keyboardType: TextInputType.number,
                          style: const TextStyle(color: Colors.white),
                          decoration: decoration(
                            'Quantity to ${isStockIn ? 'receive' : 'issue'}',
                          ),
                        ),

                        const SizedBox(height: 20),

                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton.icon(
                            onPressed: saveMovement,
                            icon: Icon(
                              isStockIn
                                  ? Icons.add_circle_outline
                                  : Icons.remove_circle_outline,
                            ),
                            label: Text(
                              isStockIn
                                  ? 'RECEIVE STOCK'
                                  : 'ISSUE STOCK',
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: accent,
                              foregroundColor: background,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Movement History',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 17,
                        ),
                      ),
                      Text(
                        '${history.length} records',
                        style: const TextStyle(
                          color: muted,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  if (history.isEmpty)
                    panelCard(
                      child: const Center(
                        child: Padding(
                          padding: EdgeInsets.all(12),
                          child: Text(
                            'No stock movements recorded yet.',
                            style: TextStyle(color: muted),
                          ),
                        ),
                      ),
                    )
                  else
                    ...history.map((movement) {
                      final branch =
                          inventory.getBranchById(movement.branchId);

                      return Container(
                        margin: const EdgeInsets.only(bottom: 10),
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: panel,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: Colors.white10),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              isStockIn
                                  ? Icons.south_west
                                  : Icons.north_east,
                              color: accent,
                              size: 23,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    movement.productName,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '${movement.referenceCode} • ${branch?.name ?? movement.branchId}',
                                    style: const TextStyle(
                                      color: muted,
                                      fontSize: 11,
                                    ),
                                  ),
                                  const SizedBox(height: 3),
                                  Text(
                                    movement.date.toLocal().toString().substring(0, 16),
                                    style: const TextStyle(
                                      color: muted,
                                      fontSize: 10,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Text(
                              '${isStockIn ? '+' : '-'}${movement.quantity}',
                              style: TextStyle(
                                color: accent,
                                fontWeight: FontWeight.bold,
                                fontSize: 17,
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

  Widget _summary(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: panel,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(height: 10),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 21,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: const TextStyle(
              color: muted,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }
}
