
import 'package:flutter/material.dart';

class StockScreen extends StatefulWidget {
  const StockScreen({super.key});

  @override
  State<StockScreen> createState() => _StockScreenState();
}

class _StockScreenState extends State<StockScreen> {
  static const Color blue = Color(0xFF5798FF);
  static const Color green = Color(0xFF45C99A);
  static const Color orange = Color(0xFFFFB454);

  String selectedFilter = 'All';

  final List<String> products = [
    'Wireless Mouse',
    'USB Keyboard',
    'HDMI Cable',
    'Bluetooth Speaker',
  ];

  final List<_StockMovement> movements = [
    _StockMovement(
      product: 'Wireless Mouse',
      type: 'Stock In',
      quantity: 20,
      date: 'Today, 10:30 AM',
    ),
    _StockMovement(
      product: 'USB Keyboard',
      type: 'Stock Out',
      quantity: 5,
      date: 'Today, 09:45 AM',
    ),
    _StockMovement(
      product: 'HDMI Cable',
      type: 'Stock In',
      quantity: 15,
      date: 'Yesterday',
    ),
    _StockMovement(
      product: 'Bluetooth Speaker',
      type: 'Stock Out',
      quantity: 3,
      date: 'Yesterday',
    ),
  ];

  int get totalReceived => movements
      .where((item) => item.type == 'Stock In')
      .fold(0, (sum, item) => sum + item.quantity);

  int get totalIssued => movements
      .where((item) => item.type == 'Stock Out')
      .fold(0, (sum, item) => sum + item.quantity);

  List<_StockMovement> get filteredMovements {
    if (selectedFilter == 'All') {
      return movements;
    }

    return movements
        .where((item) => item.type == selectedFilter)
        .toList();
  }

  @override
  Widget build(BuildContext context) {
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
            onPressed: () => _showInfo(),
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

              // STOCK SUMMARY

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

              // STOCK ACTIONS

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

              // MOVEMENT HISTORY

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
                  ),
                ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _addMovement(String type) async {
    final quantityController = TextEditingController();
    String selectedProduct = products.first;

    final movement = await showDialog<_StockMovement>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, dialogSetState) {
            return AlertDialog(
              backgroundColor: const Color(0xFF121D2D),
              title: Text(
                type,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Select Product',
                    style: TextStyle(color: Color(0xFF91A4BE)),
                  ),
                  const SizedBox(height: 8),

                  DropdownButtonFormField<String>(
                    value: selectedProduct,
                    dropdownColor: const Color(0xFF121D2D),
                    decoration: _inputDecoration(),
                    items: products.map((product) {
                      return DropdownMenuItem(
                        value: product,
                        child: Text(product),
                      );
                    }).toList(),
                    onChanged: (value) {
                      if (value != null) {
                        dialogSetState(() {
                          selectedProduct = value;
                        });
                      }
                    },
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
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(dialogContext);
                  },
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        type == 'Stock In' ? green : orange,
                    foregroundColor: Colors.black,
                  ),
                  onPressed: () {
                    final quantity =
                        int.tryParse(quantityController.text.trim());

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

                    Navigator.pop(
                      dialogContext,
                      _StockMovement(
                        product: selectedProduct,
                        type: type,
                        quantity: quantity,
                        date: 'Just now',
                      ),
                    );
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

    if (!mounted || movement == null) return;

    setState(() {
      movements.insert(0, movement);
    });

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
          'Record incoming and outgoing stock movements '
          'and review your movement history.',
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
}

class _StockMovement {
  const _StockMovement({
    required this.product,
    required this.type,
    required this.quantity,
    required this.date,
  });

  final String product;
  final String type;
  final int quantity;
  final String date;
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
  });

  final _StockMovement movement;

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
              isStockIn
                  ? Icons.call_received
                  : Icons.call_made,
              color: color,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  movement.product,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  movement.date,
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
                style: TextStyle(
                  color: color,
                  fontSize: 10,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
