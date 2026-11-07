
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'inventory_data.dart';
import 'inventory_models.dart';
import 'sales_history_screen.dart';

class SalesScreen extends ConsumerStatefulWidget {
  const SalesScreen({super.key});

  @override
  ConsumerState<SalesScreen> createState() => _SalesScreenState();
}

class _SalesScreenState extends ConsumerState<SalesScreen> {
  static const Color background = Color(0xFF080B12);
  static const Color panel = Color(0xFF121D2D);
  static const Color blue = Color(0xFF5798FF);
  static const Color green = Color(0xFF45C99A);
  static const Color muted = Color(0xFF91A4BE);

  String? selectedBranchId;
  String? selectedProductId;
  String paymentMethod = 'Cash';

  final List<SalesCartItem> cart = [];

  final customerController = TextEditingController();
  final phoneController = TextEditingController();
  final quantityController = TextEditingController(text: '1');
  final priceController = TextEditingController();
  final discountController = TextEditingController(text: '0');
  final taxController = TextEditingController(text: '0');
  final paidController = TextEditingController(text: '0');

  @override
  void dispose() {
    customerController.dispose();
    phoneController.dispose();
    quantityController.dispose();
    priceController.dispose();
    discountController.dispose();
    taxController.dispose();
    paidController.dispose();
    super.dispose();
  }

  double get subtotal =>
      cart.fold(0, (sum, item) => sum + item.quantity * item.unitPrice);

  double get discount =>
      double.tryParse(discountController.text) ?? 0;

  double get tax => double.tryParse(taxController.text) ?? 0;

  double get total => subtotal - discount + tax;

  String money(double value) => value.toStringAsFixed(2);

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
        borderSide: const BorderSide(color: Color(0xFF26364D)),
      ),
    );
  }

  void showMessage(String message, {bool error = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: error ? Colors.red.shade700 : panel,
      ),
    );
  }

  void addItem(InventoryData inventory) {
    if (selectedBranchId == null || selectedProductId == null) {
      showMessage('Select a branch and product first.', error: true);
      return;
    }

    final product = inventory.getProductById(selectedProductId!);
    if (product == null) {
      showMessage('Product not found.', error: true);
      return;
    }

    final quantity = int.tryParse(quantityController.text) ?? 0;
    final price = double.tryParse(priceController.text) ??
        product.sellingPrice;

    if (quantity <= 0 || price < 0) {
      showMessage('Enter a valid quantity and price.', error: true);
      return;
    }

    final available = inventory.getBranchQuantity(
      product.id,
      selectedBranchId!,
    );

    final alreadyInCart = cart
        .where((item) => item.productId == product.id)
        .fold<int>(0, (sum, item) => sum + item.quantity);

    if (quantity + alreadyInCart > available) {
      showMessage(
        'Only ${available - alreadyInCart} ${product.unit} available.',
        error: true,
      );
      return;
    }

    setState(() {
      cart.add(
        SalesCartItem(
          productId: product.id,
          quantity: quantity,
          unitPrice: price,
        ),
      );
      quantityController.text = '1';
      priceController.text = product.sellingPrice.toString();
    });
  }

  void removeItem(int index) {
    setState(() => cart.removeAt(index));
  }

  void completeSale(InventoryData inventory) {
    if (selectedBranchId == null) {
      showMessage('Select a branch.', error: true);
      return;
    }

    if (cart.isEmpty) {
      showMessage('Add at least one product.', error: true);
      return;
    }

    final paid = double.tryParse(paidController.text) ?? 0;

    if (discount < 0 || tax < 0 || paid < 0 || total < 0) {
      showMessage('Check the discount, tax and payment amounts.',
          error: true);
      return;
    }

    try {
      final sale = inventory.createSale(
        branchId: selectedBranchId!,
        items: List<SalesCartItem>.from(cart),
        customerName: customerController.text.trim(),
        customerPhone: phoneController.text.trim(),
        paymentMethod: paymentMethod,
        discount: discount,
        tax: tax,
        amountPaid: paid,
      );

      setState(() {
        cart.clear();
        customerController.clear();
        phoneController.clear();
        discountController.text = '0';
        taxController.text = '0';
        paidController.text = '0';
        quantityController.text = '1';
      });

      showMessage('Sale completed. Invoice: ${sale.invoiceNumber}');
    } catch (error) {
      showMessage(
        error.toString().replaceFirst('Exception: ', ''),
        error: true,
      );
    }
  }

  Widget field(
    String label,
    TextEditingController controller, {
    TextInputType keyboardType = TextInputType.text,
    VoidCallback? onChanged,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      style: const TextStyle(color: Colors.white),
      onChanged: (_) {
        if (onChanged != null) onChanged();
      },
      decoration: decoration(label),
    );
  }

  Widget sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 17,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget totalRow(String label, double value, {bool highlight = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: muted)),
          Text(
            'Rs. ${money(value)}',
            style: TextStyle(
              color: highlight ? green : Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: highlight ? 17 : 14,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final inventory = ref.watch(inventoryProvider);
    final initialization = ref.watch(inventoryInitializationProvider);

    if (initialization.isLoading) {
      return const Scaffold(
        backgroundColor: background,
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (initialization.hasError) {
      return Scaffold(
        backgroundColor: background,
        appBar: AppBar(
          backgroundColor: background,
          title: const Text('Sales'),
        ),
        body: Center(
          child: Text(
            'Could not load inventory:\n${initialization.error}',
            style: const TextStyle(color: Colors.white),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    final branches = inventory.branches.where((b) => b.active).toList();
    final products = inventory.products;

    if (selectedBranchId == null && branches.isNotEmpty) {
      selectedBranchId = branches.first.id;
    }

    if (selectedProductId == null && products.isNotEmpty) {
      selectedProductId = products.first.id;
      priceController.text = products.first.sellingPrice.toString();
    }

    return Scaffold(
      backgroundColor: background,
      appBar: AppBar(
        backgroundColor: background,
        foregroundColor: Colors.white,
        title: const Text('Sales'),
        actions: [
          IconButton(
            tooltip: 'Sales history',
            icon: const Icon(Icons.history),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const SalesHistoryScreen(),
                ),
              );
            },
          ),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: panel,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFF26364D)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  sectionTitle('New Sales Invoice'),
                  DropdownButtonFormField<String>(
                    value: selectedBranchId,
                    isExpanded: true,
                    dropdownColor: panel,
                    style: const TextStyle(color: Colors.white),
                    decoration: decoration('Sales branch'),
                    items: branches.map((branch) {
                      return DropdownMenuItem(
                        value: branch.id,
                        child: Text(branch.name),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        selectedBranchId = value;
                        cart.clear();
                      });
                    },
                  ),
                  const SizedBox(height: 12),
                  field('Customer name', customerController),
                  const SizedBox(height: 12),
                  field(
                    'Customer phone',
                    phoneController,
                    keyboardType: TextInputType.phone,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: panel,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFF26364D)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  sectionTitle('Add Products'),
                  if (products.isEmpty)
                    const Text(
                      'Add products before creating a sale.',
                      style: TextStyle(color: muted),
                    )
                  else ...[
                    DropdownButtonFormField<String>(
                      value: selectedProductId,
                      isExpanded: true,
                      dropdownColor: panel,
                      style: const TextStyle(color: Colors.white),
                      decoration: decoration('Product'),
                      items: products.map((product) {
                        final available = selectedBranchId == null
                            ? 0
                            : inventory.getBranchQuantity(
                                product.id,
                                selectedBranchId!,
                              );
                        return DropdownMenuItem(
                          value: product.id,
                          child: Text(
                            '${product.name} • ${product.sku} • Stock: $available',
                            overflow: TextOverflow.ellipsis,
                          ),
                        );
                      }).toList(),
                      onChanged: (value) {
                        if (value == null) return;
                        final product =
                            inventory.getProductById(value);
                        setState(() {
                          selectedProductId = value;
                          priceController.text =
                              product?.sellingPrice.toString() ?? '0';
                        });
                      },
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: field(
                            'Quantity',
                            quantityController,
                            keyboardType: TextInputType.number,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: field(
                            'Unit price',
                            priceController,
                            keyboardType:
                                const TextInputType.numberWithOptions(
                              decimal: true,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () => addItem(inventory),
                        icon: const Icon(Icons.add),
                        label: const Text('Add to Invoice'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: blue,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.all(14),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: panel,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFF26364D)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  sectionTitle('Invoice Items'),
                  if (cart.isEmpty)
                    const Text(
                      'No products added yet.',
                      style: TextStyle(color: muted),
                    ),
                  ...cart.asMap().entries.map((entry) {
                    final index = entry.key;
                    final item = entry.value;
                    final product =
                        inventory.getProductById(item.productId);

                    return ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(
                        product?.name ?? 'Product',
                        style: const TextStyle(color: Colors.white),
                      ),
                      subtitle: Text(
                        '${item.quantity} × Rs. ${money(item.unitPrice)}',
                        style: const TextStyle(color: muted),
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Rs. ${money(item.quantity * item.unitPrice)}',
                            style: const TextStyle(
                              color: green,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          IconButton(
                            onPressed: () => removeItem(index),
                            icon: const Icon(
                              Icons.delete_outline,
                              color: Colors.redAccent,
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: panel,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFF26364D)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  sectionTitle('Payment Details'),
                  field(
                    'Discount (Rs.)',
                    discountController,
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    onChanged: () => setState(() {}),
                  ),
                  const SizedBox(height: 10),
                  field(
                    'Tax (Rs.)',
                    taxController,
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    onChanged: () => setState(() {}),
                  ),
                  const SizedBox(height: 10),
                  DropdownButtonFormField<String>(
                    value: paymentMethod,
                    dropdownColor: panel,
                    style: const TextStyle(color: Colors.white),
                    decoration: decoration('Payment method'),
                    items: const [
                      'Cash',
                      'QR',
                      'Card',
                      'Bank Transfer',
                      'Credit',
                    ].map((method) {
                      return DropdownMenuItem(
                        value: method,
                        child: Text(method),
                      );
                    }).toList(),
                    onChanged: (value) {
                      if (value != null) {
                        setState(() => paymentMethod = value);
                      }
                    },
                  ),
                  const SizedBox(height: 10),
                  field(
                    'Amount received (Rs.)',
                    paidController,
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                  ),
                  const Divider(color: Colors.white24, height: 25),
                  totalRow('Subtotal', subtotal),
                  totalRow('Discount', discount),
                  totalRow('Tax', tax),
                  totalRow('Grand total', total, highlight: true),
                  totalRow(
                    'Balance due',
                    (total -
                            (double.tryParse(paidController.text) ?? 0))
                        .clamp(0, double.infinity)
                        .toDouble(),
                  ),
                  const SizedBox(height: 15),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () => completeSale(inventory),
                      icon: const Icon(Icons.check_circle_outline),
                      label: const Text('Complete Sale'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: green,
                        foregroundColor: background,
                        padding: const EdgeInsets.all(16),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const SalesHistoryScreen(),
                          ),
                        );
                      },
                      icon: const Icon(Icons.receipt_long),
                      label: const Text('View Sales History'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: blue,
                        side: const BorderSide(color: blue),
                        padding: const EdgeInsets.all(14),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
