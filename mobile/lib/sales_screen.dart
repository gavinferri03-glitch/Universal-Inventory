
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'inventory_data.dart';

class SalesScreen extends ConsumerStatefulWidget {
  const SalesScreen({super.key});

  @override
  ConsumerState<SalesScreen> createState() => _SalesScreenState();
}

class _SalesScreenState extends ConsumerState<SalesScreen> {
  static const Color background = Color(0xFF080B12);
  static const Color panel = Color(0xFF121D2D);
  static const Color blue = Color(0xFF5798FF);
  static const Color muted = Color(0xFF91A4BE);

  String? selectedBranchId;
  final List<SalesCartItem> cart = [];

  final customerController = TextEditingController();
  final phoneController = TextEditingController();
  final discountController = TextEditingController(text: '0');
  final taxController = TextEditingController(text: '0');
  final paidController = TextEditingController(text: '0');

  String paymentMethod = 'Cash';

  @override
  void dispose() {
    customerController.dispose();
    phoneController.dispose();
    discountController.dispose();
    taxController.dispose();
    paidController.dispose();
    super.dispose();
  }

  double get subtotal =>
      cart.fold(0, (sum, item) => sum + item.quantity * item.unitPrice);

  double get discount => double.tryParse(discountController.text) ?? 0;

  double get tax => double.tryParse(taxController.text) ?? 0;

  double get total => subtotal - discount + tax;

  String money(double value) => 'Rs. ${value.toStringAsFixed(2)}';

  void showMessage(String message, {bool error = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: error ? Colors.red.shade700 : const Color(0xFF263B5B),
      ),
    );
  }

  void addProductDialog(InventoryData inventory) {
    if (inventory.products.isEmpty) {
      showMessage('No products available.', error: true);
      return;
    }

    String productId = inventory.products.first.id;
    final quantityController = TextEditingController(text: '1');

    showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, updateDialog) {
            final product = inventory.findProduct(productId);

            final available = product == null || selectedBranchId == null
                ? 0
                : inventory.getBranchQuantity(
                    product.id,
                    selectedBranchId!,
                  );

            return AlertDialog(
              backgroundColor: panel,
              title: const Text(
                'Add Product',
                style: TextStyle(color: Colors.white),
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    DropdownButtonFormField<String>(
                      value: productId,
                      dropdownColor: panel,
                      decoration: const InputDecoration(
                        labelText: 'Product',
                      ),
                      items: inventory.products.map((item) {
                        return DropdownMenuItem(
                          value: item.id,
                          child: Text(
                            '${item.name} (${item.sku})',
                            overflow: TextOverflow.ellipsis,
                          ),
                        );
                      }).toList(),
                      onChanged: (value) {
                        if (value != null) {
                          updateDialog(() => productId = value);
                        }
                      },
                    ),
                    const SizedBox(height: 15),
                    TextField(
                      controller: quantityController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Quantity',
                      ),
                    ),
                    const SizedBox(height: 12),
                    if (product != null) ...[
                      Text(
                        'Selling price: ${money(product.sellingPrice)}',
                        style: const TextStyle(color: Colors.white),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Available at selected branch: $available ${product.unit}',
                        style: const TextStyle(color: muted),
                      ),
                    ],
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () {
                    final quantity =
                        int.tryParse(quantityController.text.trim());

                    if (product == null ||
                        quantity == null ||
                        quantity <= 0) {
                      showMessage('Enter a valid quantity.', error: true);
                      return;
                    }

                    if (selectedBranchId == null) {
                      showMessage('Select a branch first.', error: true);
                      return;
                    }

                    if (quantity > available) {
                      showMessage(
                        'Not enough stock at this branch.',
                        error: true,
                      );
                      return;
                    }

                    setState(() {
                      final index = cart.indexWhere(
                        (item) => item.productId == product.id,
                      );

                      if (index >= 0) {
                        final updatedQuantity =
                            cart[index].quantity + quantity;

                        cart[index] = SalesCartItem(
                          productId: product.id,
                          quantity: updatedQuantity,
                          unitPrice: cart[index].unitPrice,
                        );
                      } else {
                        cart.add(
                          SalesCartItem(
                            productId: product.id,
                            quantity: quantity,
                            unitPrice: product.sellingPrice,
                          ),
                        );
                      }
                    });

                    Navigator.pop(dialogContext);
                  },
                  child: const Text('Add to Sale'),
                ),
              ],
            );
          },
        );
      },
    ).then((_) => quantityController.dispose());
  }

  void removeCartItem(int index) {
    setState(() => cart.removeAt(index));
  }

  void completeSale(InventoryData inventory) {
    if (selectedBranchId == null) {
      showMessage('Please select a branch.', error: true);
      return;
    }

    if (cart.isEmpty) {
      showMessage('Please add products to the sale.', error: true);
      return;
    }

    final discountValue = double.tryParse(discountController.text) ?? -1;
    final taxValue = double.tryParse(taxController.text) ?? -1;
    final paidValue = double.tryParse(paidController.text) ?? -1;

    if (discountValue < 0 || taxValue < 0 || paidValue < 0) {
      showMessage('Enter valid discount, tax and payment amounts.',
          error: true);
      return;
    }

    try {
      final sale = inventory.createSale(
        branchId: selectedBranchId!,
        items: List.from(cart),
        customerName: customerController.text,
        customerPhone: phoneController.text,
        paymentMethod: paymentMethod,
        discount: discountValue,
        tax: taxValue,
        amountPaid: paidValue,
      );

      setState(() {
        cart.clear();
        customerController.clear();
        phoneController.clear();
        discountController.text = '0';
        taxController.text = '0';
        paidController.text = '0';
      });

      showMessage('Sale completed. Invoice: ${sale.invoiceNumber}');
    } catch (e) {
      showMessage(e.toString().replaceFirst('Exception: ', ''),
          error: true);
    }
  }

  Widget sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 13),
      child: Text(
        title,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget panelCard({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: panel,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: const Color(0xFF26364D)),
      ),
      child: child,
    );
  }

  Widget textField(
    String label,
    TextEditingController controller, {
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: muted),
        filled: true,
        fillColor: const Color(0xFF0B1421),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  Widget totalRow(String label, double value, {bool bold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              color: bold ? Colors.white : muted,
              fontWeight: bold ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          Text(
            money(value),
            style: TextStyle(
              color: bold ? blue : Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget buildCart(InventoryData inventory) {
    if (cart.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 22),
        child: Center(
          child: Text(
            'No products added yet.',
            style: TextStyle(color: muted),
          ),
        ),
      );
    }

    return Column(
      children: List.generate(cart.length, (index) {
        final item = cart[index];
        final product = inventory.findProduct(item.productId);

        if (product == null) return const SizedBox.shrink();

        return Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.all(11),
          decoration: BoxDecoration(
            color: const Color(0xFF0B1421),
            borderRadius: BorderRadius.circular(11),
          ),
          child: Row(
            children: [
              const Icon(
                Icons.inventory_2_outlined,
                color: blue,
                size: 25,
              ),
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
                    const SizedBox(height: 4),
                    Text(
                      '${item.quantity} × ${money(item.unitPrice)}',
                      style: const TextStyle(color: muted, fontSize: 12),
                    ),
                  ],
                ),
              ),
              Text(
                money(item.quantity * item.unitPrice),
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              IconButton(
                onPressed: () => removeCartItem(index),
                icon: const Icon(
                  Icons.delete_outline,
                  color: Colors.redAccent,
                ),
              ),
            ],
          ),
        );
      }),
    );
  }

  Widget saleHistoryCard(SaleRecord sale, InventoryData inventory) {
    final branch = inventory.findBranch(sale.branchId);

    return Container(
      margin: const EdgeInsets.only(bottom: 11),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: panel,
        borderRadius: BorderRadius.circular(13),
        border: Border.all(color: const Color(0xFF26364D)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.receipt_long, color: blue),
              const SizedBox(width: 9),
              Expanded(
                child: Text(
                  sale.invoiceNumber,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Text(
                money(sale.total),
                style: const TextStyle(
                  color: blue,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 9),
          Text(
            'Branch: ${branch?.name ?? "Unknown"}',
            style: const TextStyle(color: muted, fontSize: 12),
          ),
          const SizedBox(height: 4),
          Text(
            'Customer: ${sale.customerName.isEmpty ? "Walk-in customer" : sale.customerName}',
            style: const TextStyle(color: muted, fontSize: 12),
          ),
          const SizedBox(height: 4),
          Text(
            'Payment: ${sale.paymentMethod}  •  ${sale.items.length} product line(s)',
            style: const TextStyle(color: muted, fontSize: 12),
          ),
          const SizedBox(height: 9),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                sale.balanceDue > 0
                    ? 'Due: ${money(sale.balanceDue)}'
                    : sale.change > 0
                        ? 'Change: ${money(sale.change)}'
                        : 'Paid',
                style: TextStyle(
                  color: sale.balanceDue > 0
                      ? Colors.orangeAccent
                      : Colors.greenAccent,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
              TextButton(
                onPressed: () => showSaleDetails(sale),
                child: const Text('Details'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void showSaleDetails(SaleRecord sale) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: panel,
        title: Text(
          sale.invoiceNumber,
          style: const TextStyle(color: Colors.white),
        ),
        content: SizedBox(
          width: double.maxFinite,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Customer: ${sale.customerName.isEmpty ? "Walk-in customer" : sale.customerName}',
                  style: const TextStyle(color: muted),
                ),
                const SizedBox(height: 12),
                ...sale.items.map(
                  (item) => Padding(
                    padding: const EdgeInsets.only(bottom: 9),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            '${item.productName} × ${item.quantity}',
                            style: const TextStyle(color: Colors.white),
                          ),
                        ),
                        Text(
                          money(item.total),
                          style: const TextStyle(color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                ),
                const Divider(color: Color(0xFF26364D)),
                totalRow('Subtotal', sale.subtotal),
                totalRow('Discount', sale.discount),
                totalRow('Tax', sale.tax),
                totalRow('Total', sale.total, bold: true),
                totalRow('Paid', sale.amountPaid),
                totalRow('Balance due', sale.balanceDue),
              ],
            ),
          ),
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
    final activeBranches =
        inventory.branches.where((branch) => branch.active).toList();

    if (selectedBranchId == null && activeBranches.isNotEmpty) {
      selectedBranchId = activeBranches.first.id;
    }

    return Scaffold(
      backgroundColor: background,
      appBar: AppBar(
        backgroundColor: background,
        title: const Text(
          'Sales Management',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Row(
              children: [
                Expanded(
                  child: panelCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.currency_rupee, color: blue),
                        const SizedBox(height: 9),
                        const Text(
                          "Today's Sales",
                          style: TextStyle(color: muted, fontSize: 12),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          money(inventory.totalSalesToday),
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 17,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: panelCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.receipt_long, color: Colors.greenAccent),
                        const SizedBox(height: 9),
                        const Text(
                          "Today's Orders",
                          style: TextStyle(color: muted, fontSize: 12),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          '${inventory.salesCountToday}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 17,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 25),
            sectionTitle('Create New Sale'),

            panelCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  DropdownButtonFormField<String>(
                    value: selectedBranchId,
                    dropdownColor: panel,
                    decoration: const InputDecoration(
                      labelText: 'Selling Branch',
                    ),
                    items: activeBranches.map((branch) {
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

                  const SizedBox(height: 15),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Products',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      ElevatedButton.icon(
                        onPressed: activeBranches.isEmpty
                            ? null
                            : () => addProductDialog(inventory),
                        icon: const Icon(Icons.add),
                        label: const Text('Add Product'),
                      ),
                    ],
                  ),

                  const SizedBox(height: 10),
                  buildCart(inventory),

                  const Divider(color: Color(0xFF26364D)),
                  totalRow('Subtotal', subtotal),

                  const SizedBox(height: 12),
                  textField(
                    'Discount (Rs.)',
                    discountController,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                  ),

                  const SizedBox(height: 12),
                  textField(
                    'Tax (Rs.)',
                    taxController,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                  ),

                  const SizedBox(height: 12),
                  totalRow('Total', total, bold: true),

                  const SizedBox(height: 18),
                  const Text(
                    'Customer Information',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),

                  textField('Customer Name', customerController),
                  const SizedBox(height: 12),
                  textField(
                    'Phone Number',
                    phoneController,
                    keyboardType: TextInputType.phone,
                  ),

                  const SizedBox(height: 18),
                  const Text(
                    'Payment Information',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),

                  DropdownButtonFormField<String>(
                    value: paymentMethod,
                    dropdownColor: panel,
                    decoration: const InputDecoration(
                      labelText: 'Payment Method',
                    ),
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

                  const SizedBox(height: 12),
                  textField(
                    'Amount Paid (Rs.)',
                    paidController,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                  ),

                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton.icon(
                      onPressed: () => completeSale(inventory),
                      icon: const Icon(Icons.check_circle_outline),
                      label: const Text(
                        'Complete Sale',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: blue,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 28),
            sectionTitle('Sales History'),

            if (inventory.sales.isEmpty)
              panelCard(
                child: const Center(
                  child: Padding(
                    padding: EdgeInsets.all(15),
                    child: Text(
                      'No sales recorded yet.',
                      style: TextStyle(color: muted),
                    ),
                  ),
                ),
              )
            else
              ...inventory.sales.map(
                (sale) => saleHistoryCard(sale, inventory),
              ),

            const SizedBox(height: 25),
          ],
        ),
      ),
    );
  }
}
