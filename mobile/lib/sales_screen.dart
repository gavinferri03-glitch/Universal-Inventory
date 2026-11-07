import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'inventory_data.dart';
import 'inventory_models.dart';
import 'inventory_purchase_data.dart';
import 'inventory_purchase_provider.dart';

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

  final supplierController = TextEditingController();
  final phoneController = TextEditingController();
  final addressController = TextEditingController();
  final invoiceController = TextEditingController();
  final discountController = TextEditingController(text: '0');
  final taxController = TextEditingController(text: '0');
  final paidController = TextEditingController(text: '0');
  final purchaseNotesController = TextEditingController();

  final returnReasonController = TextEditingController();
  final returnNotesController = TextEditingController();

  String purchasePaymentMethod = 'Cash';
  String returnSettlement = 'Supplier Credit';

  final List<PurchaseOrderLine> purchaseItems = [];
  final List<SupplierReturnLine> returnItems = [];

  String formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/${date.year} '
        '${date.hour.toString().padLeft(2, '0')}:'
        '${date.minute.toString().padLeft(2, '0')}';
  }

  String money(double value) => 'Rs. ${value.toStringAsFixed(2)}';

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

  void showMessage(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  void dispose() {
    supplierController.dispose();
    phoneController.dispose();
    addressController.dispose();
    invoiceController.dispose();
    discountController.dispose();
    taxController.dispose();
    paidController.dispose();
    purchaseNotesController.dispose();
    returnReasonController.dispose();
    returnNotesController.dispose();
    super.dispose();
  }

  Future<void> addPurchaseItem(
    InventoryData inventory,
    String branchId,
  ) async {
    final products = inventory.products;
    if (products.isEmpty) return;

    String productId = products.first.id;
    final quantityController = TextEditingController(text: '1');
    final costController = TextEditingController(
      text: products.first.costPrice.toString(),
    );

    final result = await showDialog<PurchaseOrderLine>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, refresh) {
            final product =
                products.firstWhere((p) => p.id == productId);

            return AlertDialog(
              backgroundColor: panel,
              title: const Text(
                'Add purchase item',
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
                      items: products.map((p) {
                        return DropdownMenuItem(
                          value: p.id,
                          child: Text('${p.name} (${p.sku})'),
                        );
                      }).toList(),
                      onChanged: (value) {
                        if (value != null) {
                          refresh(() {
                            productId = value;
                            costController.text =
                                products.firstWhere(
                                  (p) => p.id == value,
                                ).costPrice.toString();
                          });
                        }
                      },
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: quantityController,
                      keyboardType: TextInputType.number,
                      style: const TextStyle(color: Colors.white),
                      decoration: decoration('Quantity'),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: costController,
                      keyboardType:
                          const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      style: const TextStyle(color: Colors.white),
                      decoration: decoration('Unit purchase cost (Rs.)'),
                    ),
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
                    final cost =
                        double.tryParse(costController.text.trim());

                    if (quantity == null ||
                        quantity <= 0 ||
                        cost == null ||
                        cost < 0) {
                      showMessage('Enter a valid quantity and cost.');
                      return;
                    }

                    Navigator.pop(
                      dialogContext,
                      PurchaseOrderLine(
                        productId: product.id,
                        productName: product.name,
                        sku: product.sku,
                        unit: product.unit,
                        quantity: quantity,
                        unitCost: cost,
                      ),
                    );
                  },
                  child: const Text('Add item'),
                ),
              ],
            );
          },
        );
      },
    );

    quantityController.dispose();
    costController.dispose();

    if (result != null && mounted) {
      setState(() => purchaseItems.add(result));
    }
  }

  Future<void> createPurchaseOrder(
    InventoryData inventory,
    InventoryPurchaseData purchaseData,
  ) async {
    final branches =
        inventory.branches.where((b) => b.active).toList();

    if (inventory.products.isEmpty || branches.isEmpty) {
      showMessage('Add products and an active branch first.');
      return;
    }

    supplierController.clear();
    phoneController.clear();
    addressController.clear();
    invoiceController.clear();
    discountController.text = '0';
    taxController.text = '0';
    paidController.text = '0';
    purchaseNotesController.clear();
    purchaseItems.clear();
    purchasePaymentMethod = 'Cash';

    String branchId = branches.first.id;

    final saved = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, refresh) {
            final subtotal = purchaseItems.fold<double>(
              0,
              (sum, item) => sum + item.total,
            );
            final discount =
                double.tryParse(discountController.text) ?? 0;
            final tax = double.tryParse(taxController.text) ?? 0;
            final total = subtotal - discount + tax;

            return AlertDialog(
              backgroundColor: panel,
              title: const Text(
                'New Purchase Order',
                style: TextStyle(color: Colors.white),
              ),
              content: SizedBox(
                width: 420,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextField(
                        controller: supplierController,
                        style: const TextStyle(color: Colors.white),
                        decoration: decoration('Supplier name *'),
                      ),
                      const SizedBox(height: 10),
                      TextField(
                        controller: phoneController,
                        keyboardType: TextInputType.phone,
                        style: const TextStyle(color: Colors.white),
                        decoration: decoration('Supplier phone'),
                      ),
                      const SizedBox(height: 10),
                      TextField(
                        controller: addressController,
                        style: const TextStyle(color: Colors.white),
                        decoration: decoration('Supplier address'),
                      ),
                      const SizedBox(height: 10),
                      TextField(
                        controller: invoiceController,
                        style: const TextStyle(color: Colors.white),
                        decoration:
                            decoration('Supplier invoice number'),
                      ),
                      const SizedBox(height: 12),
                      DropdownButtonFormField<String>(
                        value: branchId,
                        isExpanded: true,
                        dropdownColor: panel,
                        style: const TextStyle(color: Colors.white),
                        decoration: decoration('Receiving branch'),
                        items: branches.map((branch) {
                          return DropdownMenuItem(
                            value: branch.id,
                            child: Text(branch.name),
                          );
                        }).toList(),
                        onChanged: (value) {
                          if (value != null) {
                            refresh(() => branchId = value);
                          }
                        },
                      ),
                      const SizedBox(height: 18),
                      const Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Purchase items',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      ...purchaseItems.map((item) {
                        return Container(
                          margin: const EdgeInsets.only(bottom: 7),
                          padding: const EdgeInsets.all(9),
                          decoration: BoxDecoration(
                            color: const Color(0xFF080B12),
                            borderRadius: BorderRadius.circular(9),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  '${item.productName}\n'
                                  '${item.quantity} ${item.unit} × '
                                  '${money(item.unitCost)}',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                              Text(
                                money(item.total),
                                style: const TextStyle(color: green),
                              ),
                              IconButton(
                                onPressed: () {
                                  refresh(() {
                                    purchaseItems.remove(item);
                                  });
                                },
                                icon: const Icon(
                                  Icons.delete_outline,
                                  color: orange,
                                ),
                              ),
                            ],
                          ),
                        );
                      }),
                      OutlinedButton.icon(
                        onPressed: () async {
                          await addPurchaseItem(inventory, branchId);
                          refresh(() {});
                        },
                        icon: const Icon(Icons.add),
                        label: const Text('Add product'),
                      ),
                      const SizedBox(height: 10),
                      TextField(
                        controller: discountController,
                        keyboardType:
                            const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        style: const TextStyle(color: Colors.white),
                        decoration: decoration('Discount (Rs.)'),
                        onChanged: (_) => refresh(() {}),
                      ),
                      const SizedBox(height: 10),
                      TextField(
                        controller: taxController,
                        keyboardType:
                            const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        style: const TextStyle(color: Colors.white),
                        decoration: decoration('Tax (Rs.)'),
                        onChanged: (_) => refresh(() {}),
                      ),
                      const SizedBox(height: 10),
                      TextField(
                        controller: paidController,
                        keyboardType:
                            const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        style: const TextStyle(color: Colors.white),
                        decoration: decoration('Amount paid (Rs.)'),
                      ),
                      const SizedBox(height: 10),
                      DropdownButtonFormField<String>(
                        value: purchasePaymentMethod,
                        dropdownColor: panel,
                        style: const TextStyle(color: Colors.white),
                        decoration: decoration('Payment method'),
                        items: const [
                          'Cash',
                          'Bank Transfer',
                          'Card',
                          'Cheque',
                          'Credit',
                          'Other',
                        ].map((value) {
                          return DropdownMenuItem(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                        onChanged: (value) {
                          if (value != null) {
                            refresh(
                              () => purchasePaymentMethod = value,
                            );
                          }
                        },
                      ),
                      const SizedBox(height: 10),
                      TextField(
                        controller: purchaseNotesController,
                        maxLines: 2,
                        style: const TextStyle(color: Colors.white),
                        decoration: decoration('Notes'),
                      ),
                      const Divider(color: Colors.white24, height: 25),
                      _totalRow('Subtotal', money(subtotal)),
                      _totalRow('Grand total', money(total),
                          valueColor: green),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () =>
                      Navigator.pop(dialogContext, false),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: green,
                    foregroundColor: Colors.black,
                  ),
                  onPressed: () async {
                    final paid =
                        double.tryParse(paidController.text.trim()) ?? 0;

                    if (supplierController.text.trim().isEmpty) {
                      showMessage('Enter the supplier name.');
                      return;
                    }

                    if (purchaseItems.isEmpty) {
                      showMessage('Add at least one product.');
                      return;
                    }

                    try {
                      await purchaseData.createPurchaseOrder(
                        inventory: inventory,
                        supplierName: supplierController.text,
                        supplierPhone: phoneController.text,
                        supplierAddress: addressController.text,
                        supplierInvoiceNumber: invoiceController.text,
                        branchId: branchId,
                        items: List.from(purchaseItems),
                        discount: discount,
                        tax: tax,
                        amountPaid: paid,
                        paymentMethod: purchasePaymentMethod,
                        notes: purchaseNotesController.text,
                      );

                      if (dialogContext.mounted) {
                        Navigator.pop(dialogContext, true);
                      }
                    } catch (error) {
                      showMessage(
                        error.toString().replaceFirst('Exception: ', ''),
                      );
                    }
                  },
                  child: const Text('Receive & Save'),
                ),
              ],
            );
          },
        );
      },
    );

    if (saved == true && mounted) {
      showMessage('Purchase order saved and stock received.');
    }
  }

  Future<void> addReturnItem(
    PurchaseOrderRecord purchase,
    InventoryData inventory,
  ) async {
    final quantityController = TextEditingController(text: '1');

    String productId = purchase.items.first.productId;

    final result = await showDialog<SupplierReturnLine>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, refresh) {
            final purchased = purchase.items
                .where((item) => item.productId == productId)
                .first;

            return AlertDialog(
              backgroundColor: panel,
              title: const Text(
                'Add return item',
                style: TextStyle(color: Colors.white),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DropdownButtonFormField<String>(
                    value: productId,
                    isExpanded: true,
                    dropdownColor: panel,
                    style: const TextStyle(color: Colors.white),
                    decoration: decoration('Purchased product'),
                    items: purchase.items.map((item) {
                      return DropdownMenuItem(
                        value: item.productId,
                        child: Text(item.productName),
                      );
                    }).toList(),
                    onChanged: (value) {
                      if (value != null) {
                        refresh(() => productId = value);
                      }
                    },
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: quantityController,
                    keyboardType: TextInputType.number,
                    style: const TextStyle(color: Colors.white),
                    decoration: decoration('Quantity to return'),
                  ),
                ],
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

                    if (quantity == null || quantity <= 0) {
                      showMessage('Enter a valid return quantity.');
                      return;
                    }

                    Navigator.pop(
                      dialogContext,
                      SupplierReturnLine(
                        productId: purchased.productId,
                        productName: purchased.productName,
                        sku: purchased.sku,
                        unit: purchased.unit,
                        quantity: quantity,
                        unitCost: purchased.unitCost,
                      ),
                    );
                  },
                  child: const Text('Add item'),
                ),
              ],
            );
          },
        );
      },
    );

    quantityController.dispose();

    if (result != null && mounted) {
      setState(() => returnItems.add(result));
    }
  }

  Future<void> createSupplierReturn(
    InventoryData inventory,
    InventoryPurchaseData purchaseData,
  ) async {
    if (purchaseData.purchaseOrders.isEmpty) {
      showMessage('There are no purchase orders to return against.');
      return;
    }

    returnItems.clear();
    returnReasonController.clear();
    returnNotesController.clear();
    returnSettlement = 'Supplier Credit';

    PurchaseOrderRecord selectedPurchase =
        purchaseData.purchaseOrders.first;

    final saved = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, refresh) {
            final total = returnItems.fold<double>(
              0,
              (sum, item) => sum + item.total,
            );

            return AlertDialog(
              backgroundColor: panel,
              title: const Text(
                'Supplier Return',
                style: TextStyle(color: Colors.white),
              ),
              content: SizedBox(
                width: 420,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      DropdownButtonFormField<String>(
                        value: selectedPurchase.purchaseOrderNumber,
                        isExpanded: true,
                        dropdownColor: panel,
                        style: const TextStyle(color: Colors.white),
                        decoration: decoration('Original purchase order'),
                        items: purchaseData.purchaseOrders.map((order) {
                          return DropdownMenuItem(
                            value: order.purchaseOrderNumber,
                            child: Text(
                              '${order.purchaseOrderNumber} • '
                              '${order.supplierName}',
                            ),
                          );
                        }).toList(),
                        onChanged: (value) {
                          if (value != null) {
                            refresh(() {
                              selectedPurchase =
                                  purchaseData.purchaseOrders.firstWhere(
                                (order) =>
                                    order.purchaseOrderNumber == value,
                              );
                              returnItems.clear();
                            });
                          }
                        },
                      ),
                      const SizedBox(height: 10),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Supplier: ${selectedPurchase.supplierName}\n'
                          'Branch: ${inventory.getBranchById(selectedPurchase.branchId)?.name ?? "Unknown"}',
                          style: const TextStyle(
                            color: muted,
                            fontSize: 12,
                          ),
                        ),
                      ),
                      const SizedBox(height: 14),
                      const Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Products to return',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      ...returnItems.map((item) {
                        return Container(
                          margin: const EdgeInsets.only(bottom: 7),
                          padding: const EdgeInsets.all(9),
                          decoration: BoxDecoration(
                            color: const Color(0xFF080B12),
                            borderRadius: BorderRadius.circular(9),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  '${item.productName}\n'
                                  '${item.quantity} ${item.unit} × '
                                  '${money(item.unitCost)}',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                              Text(
                                money(item.total),
                                style: const TextStyle(color: orange),
                              ),
                              IconButton(
                                onPressed: () {
                                  refresh(() => returnItems.remove(item));
                                },
                                icon: const Icon(
                                  Icons.delete_outline,
                                  color: orange,
                                ),
                              ),
                            ],
                          ),
                        );
                      }),
                      OutlinedButton.icon(
                        onPressed: () async {
                          await addReturnItem(selectedPurchase, inventory);
                          refresh(() {});
                        },
                        icon: const Icon(Icons.add),
                        label: const Text('Add return product'),
                      ),
                      const SizedBox(height: 10),
                      TextField(
                        controller: returnReasonController,
                        maxLines: 2,
                        style: const TextStyle(color: Colors.white),
                        decoration: decoration('Reason for return *'),
                      ),
                      const SizedBox(height: 10),
                      DropdownButtonFormField<String>(
                        value: returnSettlement,
                        dropdownColor: panel,
                        style: const TextStyle(color: Colors.white),
                        decoration: decoration('Settlement type'),
                        items: const [
                          'Supplier Credit',
                          'Refund',
                          'Replacement',
                          'Pending',
                        ].map((value) {
                          return DropdownMenuItem(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                        onChanged: (value) {
                          if (value != null) {
                            refresh(() => returnSettlement = value);
                          }
                        },
                      ),
                      const SizedBox(height: 10),
                      TextField(
                        controller: returnNotesController,
                        maxLines: 2,
                        style: const TextStyle(color: Colors.white),
                        decoration: decoration('Additional notes'),
                      ),
                      const Divider(color: Colors.white24, height: 25),
                      _totalRow(
                        'Return value',
                        money(total),
                        valueColor: orange,
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () =>
                      Navigator.pop(dialogContext, false),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: orange,
                    foregroundColor: Colors.black,
                  ),
                  onPressed: () async {
                    if (returnItems.isEmpty) {
                      showMessage('Add at least one product to return.');
                      return;
                    }

                    try {
                      await purchaseData.createSupplierReturn(
                        inventory: inventory,
                        originalPurchaseOrderNumber:
                            selectedPurchase.purchaseOrderNumber,
                        items: List.from(returnItems),
                        reason: returnReasonController.text,
                        settlementType: returnSettlement,
                        notes: returnNotesController.text,
                      );

                      if (dialogContext.mounted) {
                        Navigator.pop(dialogContext, true);
                      }
                    } catch (error) {
                      showMessage(
                        error.toString().replaceFirst('Exception: ', ''),
                      );
                    }
                  },
                  child: const Text('Save Supplier Return'),
                ),
              ],
            );
          },
        );
      },
    );

    if (saved == true && mounted) {
      showMessage('Supplier return saved and stock reduced.');
    }
  }

  Widget _totalRow(
    String label,
    String value, {
    Color valueColor = Colors.white,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: const TextStyle(color: muted),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              color: valueColor,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget summaryCard(String title, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: panel,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFF26364D)),
      ),
      child: Row(
        children: [
          Icon(Icons.inventory_2_outlined, color: color, size: 25),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 21,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  title,
                  style: const TextStyle(color: muted, fontSize: 12),
                ),
              ],
            ),
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
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: panel,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFF26364D)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 28),
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

  void showPurchaseDetails(
    PurchaseOrderRecord order,
    InventoryData inventory,
  ) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        final branch =
            inventory.getBranchById(order.branchId)?.name ?? 'Unknown';

        return AlertDialog(
          backgroundColor: panel,
          title: Text(
            'PURCHASE INVOICE\n${order.purchaseOrderNumber}',
            style: const TextStyle(color: Colors.white, fontSize: 17),
          ),
          content: SizedBox(
            width: 420,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  _detail('Date', formatDate(order.date)),
                  _detail('Supplier', order.supplierName),
                  _detail('Phone', order.supplierPhone),
                  _detail('Address', order.supplierAddress),
                  _detail('Supplier invoice', order.supplierInvoiceNumber),
                  _detail('Receiving branch', branch),
                  const Divider(color: Colors.white24),
                  const Text(
                    'ITEM DETAILS',
                    style: TextStyle(
                      color: blue,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ...order.items.map((item) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Text(
                        '${item.productName} (${item.sku})\n'
                        '${item.quantity} ${item.unit} × '
                        '${money(item.unitCost)} = ${money(item.total)}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                        ),
                      ),
                    );
                  }),
                  const Divider(color: Colors.white24),
                  _detail('Subtotal', money(order.subtotal)),
                  _detail('Discount', money(order.discount)),
                  _detail('Tax', money(order.tax)),
                  _detail('Grand total', money(order.total)),
                  _detail('Amount paid', money(order.amountPaid)),
                  _detail('Balance due', money(order.balanceDue)),
                  _detail('Payment method', order.paymentMethod),
                  _detail('Payment status', order.paymentStatus),
                  _detail('Order status', order.status),
                  if (order.notes.isNotEmpty) ...[
                    const Divider(color: Colors.white24),
                    _detail('Notes', order.notes),
                  ],
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  void showReturnDetails(
    SupplierReturnRecord record,
    InventoryData inventory,
  ) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        final branch =
            inventory.getBranchById(record.branchId)?.name ?? 'Unknown';

        return AlertDialog(
          backgroundColor: panel,
          title: Text(
            'SUPPLIER RETURN NOTE\n${record.returnNumber}',
            style: const TextStyle(color: Colors.white, fontSize: 17),
          ),
          content: SizedBox(
            width: 420,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  _detail('Date', formatDate(record.date)),
                  _detail('Supplier', record.supplierName),
                  _detail('Phone', record.supplierPhone),
                  _detail('Original purchase', record.originalPurchaseOrderNumber),
                  _detail('Branch', branch),
                  const Divider(color: Colors.white24),
                  const Text(
                    'RETURNED ITEMS',
                    style: TextStyle(
                      color: orange,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ...record.items.map((item) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Text(
                        '${item.productName} (${item.sku})\n'
                        '${item.quantity} ${item.unit} × '
                        '${money(item.unitCost)} = ${money(item.total)}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                        ),
                      ),
                    );
                  }),
                  const Divider(color: Colors.white24),
                  _detail('Total return value', money(record.total)),
                  _detail('Reason', record.reason),
                  _detail('Settlement', record.settlementType),
                  if (record.notes.isNotEmpty)
                    _detail('Notes', record.notes),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  Widget _detail(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 115,
            child: Text(
              label,
              style: const TextStyle(color: muted, fontSize: 12),
            ),
          ),
          Expanded(
            child: Text(
              value.isEmpty ? '-' : value,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget transactionCard({
    required String title,
    required String subtitle,
    required String amount,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        margin: const EdgeInsets.only(bottom: 9),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: panel,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFF26364D)),
        ),
        child: Row(
          children: [
            Icon(Icons.receipt_long_outlined, color: color, size: 25),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
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
            Text(
              amount,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(width: 5),
            const Icon(Icons.chevron_right, color: muted),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final inventory = ref.watch(inventoryProvider);
    final purchaseData = ref.watch(inventoryPurchaseProvider);
    final initialization =
        ref.watch(inventoryPurchaseInitializationProvider);

    if (initialization.isLoading) {
      return const Scaffold(
        backgroundColor: Color(0xFF080B12),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (initialization.hasError) {
      return Scaffold(
        backgroundColor: const Color(0xFF080B12),
        appBar: AppBar(
          backgroundColor: const Color(0xFF080B12),
          title: const Text('Stock Management'),
        ),
        body: Center(
          child: Text(
            'Could not load purchase records:\n${initialization.error}',
            style: const TextStyle(color: Colors.white),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    final movements = inventory.movements;
    final totalReceived = movements
        .where((m) => m.type == 'Stock In')
        .fold<int>(0, (sum, m) => sum + m.quantity);
    final totalReturned = movements
        .where((m) => m.type == 'Stock Out')
        .fold<int>(0, (sum, m) => sum + m.quantity);

    return Scaffold(
      backgroundColor: const Color(0xFF080B12),
      appBar: AppBar(
        backgroundColor: const Color(0xFF080B12),
        foregroundColor: Colors.white,
        title: const Text('Stock Management'),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(18),
          children: [
            const Text(
              'Stock Overview',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 15),
            Row(
              children: [
                Expanded(
                  child: summaryCard(
                    'Goods received',
                    totalReceived.toString(),
                    green,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: summaryCard(
                    'Supplier returns',
                    totalReturned.toString(),
                    orange,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            summaryCard(
              'Total current stock',
              inventory.totalStock.toString(),
              blue,
            ),
            const SizedBox(height: 25),
            const Text(
              'Stock Actions',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: actionButton(
                    'Purchase Order',
                    'Receive goods from supplier',
                    Icons.add_shopping_cart,
                    green,
                    () => createPurchaseOrder(inventory, purchaseData),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: actionButton(
                    'Supplier Return',
                    'Return goods to supplier',
                    Icons.assignment_return,
                    orange,
                    () => createSupplierReturn(inventory, purchaseData),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 25),
            const Text(
              'Purchase Order History',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            if (purchaseData.purchaseOrders.isEmpty)
              const Padding(
                padding: EdgeInsets.all(15),
                child: Text(
                  'No purchase orders yet.',
                  style: TextStyle(color: muted),
                ),
              ),
            ...purchaseData.purchaseOrders.map((order) {
              final branch =
                  inventory.getBranchById(order.branchId)?.name ??
                      'Unknown branch';

              return transactionCard(
                title: '${order.purchaseOrderNumber} • ${order.supplierName}',
                subtitle:
                    '${formatDate(order.date)} • $branch • ${order.paymentStatus}',
                amount: money(order.total),
                color: green,
                onTap: () => showPurchaseDetails(order, inventory),
              );
            }),
            const SizedBox(height: 20),
            const Text(
              'Supplier Return History',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            if (purchaseData.supplierReturns.isEmpty)
              const Padding(
                padding: EdgeInsets.all(15),
                child: Text(
                  'No supplier returns yet.',
                  style: TextStyle(color: muted),
                ),
              ),
            ...purchaseData.supplierReturns.map((record) {
              return transactionCard(
                title: '${record.returnNumber} • ${record.supplierName}',
                subtitle:
                    '${formatDate(record.date)} • ${record.settlementType}',
                amount: money(record.total),
                color: orange,
                onTap: () => showReturnDetails(record, inventory),
              );
            }),
            const SizedBox(height: 20),
            const Text(
              'Branch-wise Stock',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            if (inventory.products.isEmpty)
              const Text(
                'No products added yet.',
                style: TextStyle(color: muted),
              ),
            ...inventory.products.map((product) {
              return Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: panel,
                  borderRadius: BorderRadius.circular(12),
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
                      ),
                    ),
                    Text(
                      '${product.sku} • Total: '
                      '${product.quantity} ${product.unit}',
                      style: const TextStyle(
                        color: muted,
                        fontSize: 12,
                      ),
                    ),
                    const Divider(color: Colors.white12, height: 20),
                    ...inventory.branches.map((branch) {
                      final quantity = inventory.getBranchQuantity(
                        product.id,
                        branch.id,
                      );

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 7),
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
          ],
        ),
      ),
    );
  }
}