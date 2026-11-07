
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'inventory_data.dart';
import 'inventory_models.dart';
import 'inventory_purchase_data.dart';
import 'inventory_purchase_provider.dart';
import 'inventory_invoice_pdf.dart';

class StockScreen extends ConsumerWidget {
  const StockScreen({super.key});

  static const Color blue = Color(0xFF5798FF);
  static const Color green = Color(0xFF45C99A);
  static const Color orange = Color(0xFFFFB454);
  static const Color panel = Color(0xFF121D2D);
  static const Color muted = Color(0xFF91A4BE);

  void _message(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  Future<void> _purchase(BuildContext context, WidgetRef ref) async {
    final inventory = ref.read(inventoryProvider);
    final data = ref.read(inventoryPurchaseProvider);
    final branches = inventory.branches.where((b) => b.active).toList();

    if (inventory.products.isEmpty || branches.isEmpty) {
      _message(context, 'Add products and an active branch first.');
      return;
    }

    final supplier = TextEditingController();
    final phone = TextEditingController();
    final address = TextEditingController();
    final supplierInvoice = TextEditingController();
    final discount = TextEditingController(text: '0');
    final tax = TextEditingController(text: '0');
    final paid = TextEditingController(text: '0');
    final notes = TextEditingController();

    String branchId = branches.first.id;
    String paymentMethod = 'Cash';

    final lines = <_PurchaseLineInput>[
      _PurchaseLineInput(inventory.products.first.id),
    ];

    final result = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, refresh) {
          InputDecoration field(String label) => InputDecoration(
            labelText: label,
            filled: true,
            fillColor: const Color(0xFF080B12),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          );

          Widget textField(
            TextEditingController controller,
            String label, {
            bool number = false,
          }) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: TextField(
                controller: controller,
                keyboardType: number
                    ? const TextInputType.numberWithOptions(decimal: true)
                    : TextInputType.text,
                decoration: field(label),
              ),
            );
          }

          return AlertDialog(
            backgroundColor: panel,
            title: const Text(
              'New Purchase Order',
              style: TextStyle(color: Colors.white),
            ),
            content: SizedBox(
              width: 520,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    textField(supplier, 'Supplier name *'),
                    textField(phone, 'Supplier phone'),
                    textField(address, 'Supplier address'),
                    textField(supplierInvoice, 'Supplier invoice number (optional)'),
                    DropdownButtonFormField<String>(
                      value: branchId,
                      isExpanded: true,
                      dropdownColor: panel,
                      decoration: field('Receiving branch'),
                      items: branches.map((b) => DropdownMenuItem(
                        value: b.id,
                        child: Text(b.name),
                      )).toList(),
                      onChanged: (v) {
                        if (v != null) refresh(() => branchId = v);
                      },
                    ),
                    const SizedBox(height: 18),
                    const Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Products',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    ...lines.asMap().entries.map((entry) {
                      final index = entry.key;
                      final line = entry.value;
                      final product = inventory.products.firstWhere(
                        (p) => p.id == line.productId,
                      );

                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: const Color(0xFF080B12),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: DropdownButtonFormField<String>(
                                    value: line.productId,
                                    isExpanded: true,
                                    dropdownColor: panel,
                                    decoration: field('Product'),
                                    items: inventory.products.map((p) =>
                                      DropdownMenuItem(
                                        value: p.id,
                                        child: Text(p.name),
                                      ),
                                    ).toList(),
                                    onChanged: (v) {
                                      if (v != null) {
                                        refresh(() => line.productId = v);
                                      }
                                    },
                                  ),
                                ),
                                IconButton(
                                  onPressed: lines.length == 1
                                      ? null
                                      : () => refresh(() => lines.removeAt(index)),
                                  icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Expanded(
                                  child: TextField(
                                    controller: line.quantity,
                                    keyboardType: TextInputType.number,
                                    decoration: field('Quantity'),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: TextField(
                                    controller: line.cost,
                                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                    decoration: field('Unit cost'),
                                  ),
                                ),
                              ],
                            ),
                            Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                'Unit: ${product.unit}  •  SKU: ${product.sku}',
                                style: const TextStyle(color: muted, fontSize: 11),
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
                    TextButton.icon(
                      onPressed: () => refresh(() {
                        lines.add(_PurchaseLineInput(inventory.products.first.id));
                      }),
                      icon: const Icon(Icons.add),
                      label: const Text('Add another product'),
                    ),
                    const Divider(color: Colors.white24),
                    textField(discount, 'Discount amount', number: true),
                    textField(tax, 'Tax amount', number: true),
                    textField(paid, 'Amount paid', number: true),
                    DropdownButtonFormField<String>(
                      value: paymentMethod,
                      dropdownColor: panel,
                      decoration: field('Payment method'),
                      items: ['Cash', 'Bank Transfer', 'Card', 'Credit', 'Other']
                          .map((v) => DropdownMenuItem(value: v, child: Text(v)))
                          .toList(),
                      onChanged: (v) {
                        if (v != null) refresh(() => paymentMethod = v);
                      },
                    ),
                    const SizedBox(height: 10),
                    textField(notes, 'Notes'),
                    const Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Purchase order number is generated automatically.',
                        style: TextStyle(color: green, fontSize: 12),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext, false),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () async {
                  try {
                    final purchaseLines = lines.map((line) {
                      final product = inventory.getProductById(line.productId)!;
                      return PurchaseOrderLine(
                        productId: product.id,
                        productName: product.name,
                        sku: product.sku,
                        unit: product.unit,
                        quantity: int.parse(line.quantity.text.trim()),
                        unitCost: double.parse(line.cost.text.trim()),
                      );
                    }).toList();

                    await data.createPurchaseOrder(
                      inventory: inventory,
                      supplierName: supplier.text,
                      supplierPhone: phone.text,
                      supplierAddress: address.text,
                      supplierInvoiceNumber: supplierInvoice.text,
                      branchId: branchId,
                      items: purchaseLines,
                      discount: double.parse(discount.text),
                      tax: double.parse(tax.text),
                      amountPaid: double.parse(paid.text),
                      paymentMethod: paymentMethod,
                      notes: notes.text,
                    );

                    if (dialogContext.mounted) {
                      Navigator.pop(dialogContext, true);
                    }
                  } catch (e) {
                    _message(context, e.toString().replaceFirst('Exception: ', ''));
                  }
                },
                child: const Text('Save Purchase'),
              ),
            ],
          );
        },
      ),
    );

    supplier.dispose();
    phone.dispose();
    address.dispose();
    supplierInvoice.dispose();
    discount.dispose();
    tax.dispose();
    paid.dispose();
    notes.dispose();
    for (final line in lines) {
      line.dispose();
    }

    if (result == true && context.mounted) {
      _message(context, 'Purchase saved and stock received.');
    }
  }

  Future<void> _supplierReturn(BuildContext context, WidgetRef ref) async {
    final inventory = ref.read(inventoryProvider);
    final data = ref.read(inventoryPurchaseProvider);

    if (data.purchaseOrders.isEmpty) {
      _message(context, 'Create a purchase order before recording a supplier return.');
      return;
    }

    PurchaseOrderRecord selected = data.purchaseOrders.first;
    final reason = TextEditingController();
    final notes = TextEditingController();
    String settlement = 'Supplier Credit';
    final quantities = <String, TextEditingController>{};

    final result = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, refresh) {
          final returned = data.supplierReturns
              .where((r) => r.originalPurchaseOrderNumber == selected.purchaseOrderNumber)
              .expand((r) => r.items)
              .fold<Map<String, int>>({}, (map, item) {
                map[item.productId] = (map[item.productId] ?? 0) + item.quantity;
                return map;
              });

          final uniqueItems = <String, PurchaseOrderLine>{};
          for (final item in selected.items) {
            uniqueItems[item.productId] = item;
          }

          return AlertDialog(
            backgroundColor: panel,
            title: const Text('Supplier Return', style: TextStyle(color: Colors.white)),
            content: SizedBox(
              width: 500,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    DropdownButtonFormField<String>(
                      value: selected.purchaseOrderNumber,
                      isExpanded: true,
                      dropdownColor: panel,
                      decoration: const InputDecoration(
                        labelText: 'Original purchase',
                        border: OutlineInputBorder(),
                      ),
                      items: data.purchaseOrders.map((p) =>
                        DropdownMenuItem(
                          value: p.purchaseOrderNumber,
                          child: Text('${p.purchaseOrderNumber} • ${p.supplierName}'),
                        ),
                      ).toList(),
                      onChanged: (v) {
                        if (v != null) {
                          refresh(() {
                            selected = data.purchaseOrders.firstWhere(
                              (p) => p.purchaseOrderNumber == v,
                            );
                          });
                        }
                      },
                    ),
                    const SizedBox(height: 12),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Supplier: ${selected.supplierName}\nBranch: ${inventory.getBranchById(selected.branchId)?.name ?? selected.branchId}',
                        style: const TextStyle(color: muted),
                      ),
                    ),
                    const SizedBox(height: 12),
                    ...uniqueItems.values.map((item) {
                      final product = inventory.getProductById(item.productId);
                      final already = returned[item.productId] ?? 0;
                      final remaining = item.quantity - already;
                      final controller = quantities.putIfAbsent(
                        item.productId,
                        () => TextEditingController(),
                      );

                      return Container(
                        margin: const EdgeInsets.only(bottom: 10),
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: const Color(0xFF080B12),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(item.productName, style: const TextStyle(color: Colors.white)),
                            Text(
                              'Purchased: ${item.quantity}  •  Already returned: $already  •  Remaining: $remaining',
                              style: const TextStyle(color: muted, fontSize: 11),
                            ),
                            TextField(
                              controller: controller,
                              keyboardType: TextInputType.number,
                              decoration: const InputDecoration(
                                labelText: 'Quantity to return (leave blank to skip)',
                              ),
                            ),
                            Text(
                              'Current branch stock: ${inventory.getBranchQuantity(item.productId, selected.branchId)} ${product?.unit ?? item.unit}',
                              style: const TextStyle(color: muted, fontSize: 11),
                            ),
                          ],
                        ),
                      );
                    }),
                    TextField(
                      controller: reason,
                      decoration: const InputDecoration(
                        labelText: 'Reason for return *',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 10),
                    DropdownButtonFormField<String>(
                      value: settlement,
                      decoration: const InputDecoration(
                        labelText: 'Settlement',
                        border: OutlineInputBorder(),
                      ),
                      dropdownColor: panel,
                      items: ['Supplier Credit', 'Refund', 'Replacement']
                          .map((v) => DropdownMenuItem(value: v, child: Text(v)))
                          .toList(),
                      onChanged: (v) {
                        if (v != null) refresh(() => settlement = v);
                      },
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: notes,
                      decoration: const InputDecoration(
                        labelText: 'Notes',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Supplier return number is generated automatically.',
                      style: TextStyle(color: green, fontSize: 12),
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext, false),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () async {
                  try {
                    final items = <SupplierReturnLine>[];
                    for (final item in uniqueItems.values) {
                      final quantity = int.tryParse(
                        quantities[item.productId]?.text.trim() ?? '',
                      ) ?? 0;
                      if (quantity <= 0) continue;

                      items.add(SupplierReturnLine(
                        productId: item.productId,
                        productName: item.productName,
                        sku: item.sku,
                        unit: item.unit,
                        quantity: quantity,
                        unitCost: item.unitCost,
                      ));
                    }

                    await data.createSupplierReturn(
                      inventory: inventory,
                      originalPurchaseOrderNumber: selected.purchaseOrderNumber,
                      items: items,
                      reason: reason.text,
                      settlementType: settlement,
                      notes: notes.text,
                    );

                    if (dialogContext.mounted) {
                      Navigator.pop(dialogContext, true);
                    }
                  } catch (e) {
                    _message(context, e.toString().replaceFirst('Exception: ', ''));
                  }
                },
                child: const Text('Save Return'),
              ),
            ],
          );
        },
      ),
    );

    reason.dispose();
    notes.dispose();
    for (final controller in quantities.values) {
      controller.dispose();
    }

    if (result == true && context.mounted) {
      _message(context, 'Supplier return saved and stock updated.');
    }
  }

  Future<void> _adjust(BuildContext context, WidgetRef ref) async {
    final inventory = ref.read(inventoryProvider);
    if (inventory.products.isEmpty || inventory.branches.isEmpty) {
      _message(context, 'Add a product and branch first.');
      return;
    }

    final quantity = TextEditingController();
    final reason = TextEditingController();
    String productId = inventory.products.first.id;
    String branchId = inventory.branches.first.id;
    String direction = 'Add';

    final saved = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, refresh) => AlertDialog(
          backgroundColor: panel,
          title: const Text('Manual Stock Adjustment'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<String>(
                  value: productId,
                  isExpanded: true,
                  decoration: const InputDecoration(labelText: 'Product'),
                  items: inventory.products.map((p) => DropdownMenuItem(
                    value: p.id,
                    child: Text(p.name),
                  )).toList(),
                  onChanged: (v) {
                    if (v != null) refresh(() => productId = v);
                  },
                ),
                DropdownButtonFormField<String>(
                  value: branchId,
                  isExpanded: true,
                  decoration: const InputDecoration(labelText: 'Branch'),
                  items: inventory.branches.map((b) => DropdownMenuItem(
                    value: b.id,
                    child: Text(b.name),
                  )).toList(),
                  onChanged: (v) {
                    if (v != null) refresh(() => branchId = v);
                  },
                ),
                DropdownButtonFormField<String>(
                  value: direction,
                  decoration: const InputDecoration(labelText: 'Adjustment type'),
                  items: ['Add', 'Remove'].map((v) => DropdownMenuItem(
                    value: v,
                    child: Text(v),
                  )).toList(),
                  onChanged: (v) {
                    if (v != null) refresh(() => direction = v);
                  },
                ),
                TextField(
                  controller: quantity,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Quantity'),
                ),
                TextField(
                  controller: reason,
                  decoration: const InputDecoration(labelText: 'Reason'),
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
              onPressed: () {
                try {
                  final amount = int.parse(quantity.text.trim());
                  if (amount <= 0 || reason.text.trim().isEmpty) {
                    throw Exception('Enter a quantity and reason.');
                  }
                  inventory.adjustStock(
                    productId: productId,
                    branchId: branchId,
                    quantity: direction == 'Add' ? amount : -amount,
                    reason: reason.text.trim(),
                  );
                  Navigator.pop(dialogContext, true);
                } catch (e) {
                  _message(context, e.toString().replaceFirst('Exception: ', ''));
                }
              },
              child: const Text('Save Adjustment'),
            ),
          ],
        ),
      ),
    );

    quantity.dispose();
    reason.dispose();

    if (saved == true && context.mounted) {
      _message(context, 'Stock adjustment saved.');
    }
  }

  Future<void> _purchaseDetails(
    BuildContext context,
    PurchaseOrderRecord order,
    InventoryData inventory,
  ) async {
    final branch = inventory.getBranchById(order.branchId)?.name ?? order.branchId;

    await showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: panel,
        title: Text(order.purchaseOrderNumber),
        content: SizedBox(
          width: 450,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Supplier: ${order.supplierName}'),
                Text('Supplier invoice: ${order.supplierInvoiceNumber.isEmpty ? 'Not provided' : order.supplierInvoiceNumber}'),
                Text('Branch: $branch'),
                Text('Date: ${order.date}'),
                const Divider(),
                ...order.items.map((item) => ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(item.productName),
                  subtitle: Text('${item.quantity} ${item.unit} × ${item.unitCost.toStringAsFixed(2)}'),
                  trailing: Text(item.total.toStringAsFixed(2)),
                )),
                const Divider(),
                Text('Subtotal: ${order.subtotal.toStringAsFixed(2)}'),
                Text('Discount: ${order.discount.toStringAsFixed(2)}'),
                Text('Tax: ${order.tax.toStringAsFixed(2)}'),
                Text('Total: ${order.total.toStringAsFixed(2)}'),
                Text('Paid: ${order.amountPaid.toStringAsFixed(2)}'),
                Text('Balance: ${order.balanceDue.toStringAsFixed(2)}'),
                Text('Payment status: ${order.paymentStatus}'),
                Text('Payment method: ${order.paymentMethod}'),
                if (order.notes.isNotEmpty) Text('Notes: ${order.notes}'),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () async {
              await InventoryInvoicePdf.sharePurchaseOrder(order, branchName: branch);
            },
            child: const Text('Share PDF'),
          ),
          ElevatedButton(
            onPressed: () async {
              await InventoryInvoicePdf.printPurchaseOrder(order, branchName: branch);
            },
            child: const Text('Print PDF'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Future<void> _returnDetails(
    BuildContext context,
    SupplierReturnRecord record,
    InventoryData inventory,
  ) async {
    final branch = inventory.getBranchById(record.branchId)?.name ?? record.branchId;

    await showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: panel,
        title: Text(record.returnNumber),
        content: SizedBox(
          width: 450,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Supplier: ${record.supplierName}'),
                Text('Original purchase: ${record.originalPurchaseOrderNumber}'),
                Text('Branch: $branch'),
                Text('Date: ${record.date}'),
                const Divider(),
                ...record.items.map((item) => ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(item.productName),
                  subtitle: Text('${item.quantity} ${item.unit} × ${item.unitCost.toStringAsFixed(2)}'),
                  trailing: Text(item.total.toStringAsFixed(2)),
                )),
                const Divider(),
                Text('Total: ${record.total.toStringAsFixed(2)}'),
                Text('Reason: ${record.reason}'),
                Text('Settlement: ${record.settlementType}'),
                if (record.notes.isNotEmpty) Text('Notes: ${record.notes}'),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () async {
              await InventoryInvoicePdf.shareSupplierReturn(record, branchName: branch);
            },
            child: const Text('Share PDF'),
          ),
          ElevatedButton(
            onPressed: () async {
              await InventoryInvoicePdf.printSupplierReturn(record, branchName: branch);
            },
            child: const Text('Print PDF'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _action(
    String title,
    String subtitle,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: panel,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFF26364D)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, color: color, size: 27),
              const SizedBox(height: 10),
              Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              Text(subtitle, style: const TextStyle(color: muted, fontSize: 11)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _summary(String title, String value, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: panel,
          borderRadius: BorderRadius.circular(13),
          border: Border.all(color: const Color(0xFF26364D)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(value, style: TextStyle(color: color, fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text(title, style: const TextStyle(color: muted, fontSize: 11)),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final inventory = ref.watch(inventoryProvider);
    final purchaseData = ref.watch(inventoryPurchaseProvider);
    final initialized = ref.watch(inventoryPurchaseInitializationProvider);

    return Scaffold(
      backgroundColor: const Color(0xFF080B12),
      appBar: AppBar(
        title: const Text('Stock Management'),
        backgroundColor: const Color(0xFF080B12),
        foregroundColor: Colors.white,
      ),
      body: initialized.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Text('Could not load purchase records: $error'),
        ),
        data: (_) => ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const Text(
              'Stock Overview',
              style: TextStyle(color: Colors.white, fontSize: 23, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                _summary('Total stock units', inventory.totalUnitsInStock.toString(), blue),
                const SizedBox(width: 10),
                _summary('Products', inventory.products.length.toString(), green),
              ],
            ),
            const SizedBox(height: 22),
            const Text('Stock Actions', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Row(
              children: [
                _action('Purchase Order', 'Receive stock', Icons.add_shopping_cart, green, () => _purchase(context, ref)),
                const SizedBox(width: 10),
                _action('Supplier Return', 'Return to supplier', Icons.assignment_return, orange, () => _supplierReturn(context, ref)),
              ],
            ),
            const SizedBox(height: 10),
            _action('Manual Adjustment', 'Correct stock quantities', Icons.tune, blue, () => _adjust(context, ref)),
            const SizedBox(height: 24),
            const Text('Purchase History', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            if (purchaseData.purchaseOrders.isEmpty)
              const Text('No purchase orders yet.', style: TextStyle(color: muted))
            else
              ...purchaseData.purchaseOrders.map((order) => Card(
                color: panel,
                child: ListTile(
                  onTap: () => _purchaseDetails(context, order, inventory),
                  title: Text(order.purchaseOrderNumber, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  subtitle: Text('${order.supplierName} • ${order.date.day}/${order.date.month}/${order.date.year}\nTotal: ${order.total.toStringAsFixed(2)} • ${order.paymentStatus}', style: const TextStyle(color: muted)),
                  isThreeLine: true,
                  trailing: const Icon(Icons.chevron_right, color: blue),
                ),
              )),
            const SizedBox(height: 20),
            const Text('Supplier Return History', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            if (purchaseData.supplierReturns.isEmpty)
              const Text('No supplier returns yet.', style: TextStyle(color: muted))
            else
              ...purchaseData.supplierReturns.map((record) => Card(
                color: panel,
                child: ListTile(
                  onTap: () => _returnDetails(context, record, inventory),
                  title: Text(record.returnNumber, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  subtitle: Text('${record.supplierName} • Original: ${record.originalPurchaseOrderNumber}\nTotal: ${record.total.toStringAsFixed(2)}', style: const TextStyle(color: muted)),
                  isThreeLine: true,
                  trailing: const Icon(Icons.chevron_right, color: blue),
                ),
              )),
            const SizedBox(height: 20),
            const Text('Branch-wise Stock', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            ...inventory.products.map((product) => Card(
              color: panel,
              child: ExpansionTile(
                title: Text(product.name, style: const TextStyle(color: Colors.white)),
                subtitle: Text('${product.sku} • Total: ${product.quantity} ${product.unit}', style: const TextStyle(color: muted)),
                children: inventory.branches.map((branch) => ListTile(
                  dense: true,
                  title: Text(branch.name, style: const TextStyle(color: muted)),
                  trailing: Text(
                    '${inventory.getBranchQuantity(product.id, branch.id)} ${product.unit}',
                    style: const TextStyle(color: green, fontWeight: FontWeight.bold),
                  ),
                )).toList(),
              ),
            )),
            const SizedBox(height: 24),
            const Text('Recent Stock Movements', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            if (inventory.movements.isEmpty)
              const Text('No stock movements recorded.', style: TextStyle(color: muted))
            else
              ...inventory.movements.reversed.take(30).map((movement) => Card(
                color: panel,
                child: ListTile(
                  title: Text(movement.productName, style: const TextStyle(color: Colors.white)),
                  subtitle: Text('${movement.type} • ${movement.date.day}/${movement.date.month}/${movement.date.year}\n${movement.referenceCode}', style: const TextStyle(color: muted)),
                  isThreeLine: true,
                  trailing: Text(
                    movement.quantity.toString(),
                    style: const TextStyle(color: blue, fontWeight: FontWeight.bold),
                  ),
                ),
              )),
          ],
        ),
      ),
    );
  }
}

class _PurchaseLineInput {
  _PurchaseLineInput(this.productId);

  String productId;
  final TextEditingController quantity = TextEditingController(text: '1');
  final TextEditingController cost = TextEditingController(text: '0');

  void dispose() {
    quantity.dispose();
    cost.dispose();
  }
}
