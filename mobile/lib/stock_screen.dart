
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'inventory_data.dart';

class StockScreen extends ConsumerStatefulWidget {
  const StockScreen({super.key});

  @override
  ConsumerState<StockScreen> createState() => _StockScreenState();
}

class _StockScreenState extends ConsumerState<StockScreen> {
  static const Color blue = Color(0xFF5798FF);
  static const Color green = Color(0xFF45C99A);
  static const Color orange = Color(0xFFFFB454);

  String selectedFilter = 'All';

  String formatDate(DateTime date) {
    final hour = date.hour % 12 == 0 ? 12 : date.hour % 12;
    final minute = date.minute.toString().padLeft(2, '0');
    final period = date.hour >= 12 ? 'PM' : 'AM';

    return '${date.day}/${date.month}/${date.year}  $hour:$minute $period';
  }

  Future<void> _addMovement(String type) async {
    final inventory = ref.read(inventoryProvider);
    final products = inventory.products;

    if (products.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Add a product before recording stock.'),
        ),
      );
      return;
    }

    final quantityController = TextEditingController();
    String selectedProductId = products.first.id;

    final movement = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, dialogSetState) {
            final selectedProduct =
                products.firstWhere(
              (product) => product.id == selectedProductId,
            );

            return AlertDialog(
              backgroundColor: const Color(0xFF121D2D),
              title: Text(
                type,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Select Product',
                      style: TextStyle(color: Color(0xFF91A4BE)),
                    ),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      value: selectedProductId,
                      isExpanded: true,
                      dropdownColor: const Color(0xFF121D2D),
                      decoration: _inputDecoration(),
                      items: products.map((product) {
                        return DropdownMenuItem(
                          value: product.id,
                          child: Text(
                            '${product.name} (${product.quantity} units)',
                            overflow: TextOverflow.ellipsis,
                          ),
                        );
                      }).toList(),
                      onChanged: (value) {
                        if (value != null) {
                          dialogSetState(() {
                            selectedProductId = value;
                          });
                        }
                      },
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Current quantity: ${selectedProduct.quantity}',
                      style: const TextStyle(
                        color: Color(0xFF91A4BE),
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 18),
                    const Text(
                      'Quantity',
                      style: TextStyle(color: Color(0xFF91A4BE)),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: quantityController,
                      keyboardType: TextInputType.number,
                      style: const TextStyle(color: Colors.white),
                      decoration: _inputDecoration(
                        hint: 'Enter quantity',
                      ),
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
                    final quantity = int.tryParse(
                      quantityController.text.trim(),
                    );

                    if (quantity == null || quantity <= 0) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Please enter a valid quantity.',
                          ),
                        ),
                      );
                      return;
                    }

                    try {
                      inventory.recordStockMovement(
                        productId: selectedProductId,
                        type: type,
                        quantity: quantity,
                      );

                      Navigator.pop(dialogContext, true);
                    } catch (error) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            error.toString().replaceFirst(
                              'Exception: ',
                              '',
                            ),
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

    if (!mounted || movement != true) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$type recorded successfully.'),
      ),
    );
  }

  InputDecoration _inputDecoration({String? hint}) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: Color(0xFF71849E)),
      filled: true,
      fillColor: const Color(0xFF080B12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFF26364D)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFF26364D)),
      ),
    );
  }

  void _showInfo() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF121D2D),
        title: const Text('Stock Management'),
        content: const Text(
          'Record incoming and outgoing stock movements. '
          'Every movement updates the shared product quantity '
          'and appears in the movement history.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final inventory = ref.watch(inventoryProvider);
    final movements = inventory.movements;

    final totalReceived = movements
        .where((item) => item.type == 'Stock In')
        .fold<int>(0, (sum, item) => sum + item.quantity);

    final totalIssued = movements
        .where((item) => item.type == 'Stock Out')
        .fold<int>(0, (sum, item) => sum + item.quantity);

    final filteredMovements = selectedFilter == 'All'
        ? movements
        : movements
            .where((item) => item.type == selectedFilter)
            .toList();

    return Scaffold(
      backgroundColor: const Color(0xFF080B12),
      appBar: AppBar(
        backgroundColor: const Color(0xFF080B12),
        title: const Text(
          'Stock Management',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            onPressed: _showInfo,
            icon: const Icon(Icons.info_outline),
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
                'Manage your inventory',
                style: TextStyle(
                  color: Color(0xFF91A4BE),
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 5),
              const Text(
                'Stock Overview',
                style: TextStyle(
                  fontSize: 25,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 22),

              Row(
                children: [
                  Expanded(
                    child: _SummaryCard(
                      title: 'Stock In',
                      value: totalReceived.toString(),
                      icon: Icons.call_received,
                      color: green,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _SummaryCard(
                      title: 'Stock Out',
                      value: totalIssued.toString(),
                      icon: Icons.call_made,
                      color: orange,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              _SummaryCard(
                title: 'Net Movement',
                value: (totalReceived - totalIssued).toString(),
                icon: Icons.swap_horiz_rounded,
                color: blue,
                wide: true,
              ),

              const SizedBox(height: 28),

              const Text(
                'Stock Actions',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 14),

              Row(
                children: [
                  Expanded(
                    child: _ActionButton(
                      title: 'Stock In',
                      subtitle: 'Receive products',
                      icon: Icons.add_circle_outline,
                      color: green,
                      onTap: () => _addMovement('Stock In'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _ActionButton(
                      title: 'Stock Out',
                      subtitle: 'Issue products',
                      icon: Icons.remove_circle_outline,
                      color: orange,
                      onTap: () => _addMovement('Stock Out'),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 30),

              const Text(
                'Current Product Quantities',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),

              if (inventory.products.isEmpty)
                const Text(
                  'No products have been added yet.',
                  style: TextStyle(color: Color(0xFF91A4BE)),
                )
              else
                ...inventory.products.map(
                  (product) => Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: const Color(0xFF121D2D),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: const Color(0xFF26364D),
                      ),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.inventory_2_outlined,
                          color: blue,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                product.name,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              Text(
                                product.sku,
                                style: const TextStyle(
                                  color: Color(0xFF91A4BE),
                                  fontSize: 11,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Text(
                          '${product.quantity} units',
                          style: TextStyle(
                            color: product.quantity <= 5
                                ? orange
                                : green,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

              const SizedBox(height: 22),

              const Text(
                'Movement History',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 14),

              Wrap(
                spacing: 8,
                children: ['All', 'Stock In', 'Stock Out'].map((filter) {
                  final selected = selectedFilter == filter;

                  return ChoiceChip(
                    label: Text(filter),
                    selected: selected,
                    onSelected: (_) {
                      setState(() {
                        selectedFilter = filter;
                      });
                    },
                    selectedColor: blue.withValues(alpha: 0.2),
                    backgroundColor: const Color(0xFF121D2D),
                    side: BorderSide(
                      color: selected
                          ? blue
                          : const Color(0xFF26364D),
                    ),
                    labelStyle: TextStyle(
                      color: selected ? blue : Colors.white70,
                      fontWeight: FontWeight.w600,
                    ),
                  );
                }).toList(),
              ),

              const SizedBox(height: 16),

              if (filteredMovements.isEmpty)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(30),
                    child: Text(
                      'No stock movements found.',
                      style: TextStyle(
                        color: Color(0xFF91A4BE),
                      ),
                    ),
                  ),
                )
              else
                ...filteredMovements.map(
                  (movement) => _MovementCard(
                    movement: movement,
                    dateText: formatDate(movement.date),
                  ),
                ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
    this.wide = false,
  });

  final String title;
  final String value;
  final IconData icon;
  final Color color;
  final bool wide;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: wide ? double.infinity : null,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF121D2D),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF26364D)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 27),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  title,
                  style: const TextStyle(
                    color: Color(0xFF91A4BE),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(15),
      child: Container(
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: const Color(0xFF121D2D),
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: const Color(0xFF26364D)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 14),
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: const TextStyle(
                color: Color(0xFF91A4BE),
                fontSize: 11,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MovementCard extends StatelessWidget {
  const _MovementCard({
    required this.movement,
    required this.dateText,
  });

  final StockMovement movement;
  final String dateText;

  @override
  Widget build(BuildContext context) {
    final isStockIn = movement.type == 'Stock In';
    final color = isStockIn
        ? const Color(0xFF45C99A)
        : const Color(0xFFFFB454);

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: const Color(0xFF121D2D),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFF26364D)),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              isStockIn ? Icons.call_received : Icons.call_made,
              color: color,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  movement.productName,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 5),
                Text(
                  dateText,
                  style: const TextStyle(
                    color: Color(0xFF91A4BE),
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${isStockIn ? '+' : '-'}${movement.quantity}',
                style: TextStyle(
                  color: color,
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                movement.type,
                style: TextStyle(color: color, fontSize: 10),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
