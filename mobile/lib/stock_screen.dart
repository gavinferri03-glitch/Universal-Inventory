
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'inventory_data.dart';
import 'inventory_models.dart';
import 'inventory_purchase_data.dart';
import 'inventory_purchase_provider.dart';
import 'inventory_invoice_pdf.dart';

class StockScreen extends ConsumerWidget {
  const StockScreen({super.key});

  static const Color background = Color(0xFF080B12);
  static const Color panel = Color(0xFF121D2D);
  static const Color blue = Color(0xFF5798FF);
  static const Color green = Color(0xFF45C99A);
  static const Color orange = Color(0xFFFFB454);
  static const Color muted = Color(0xFF91A4BE);
  static const Color borderColor = Color(0xFF26364D);

  void _message(BuildContext context, String message) {
    if (!context.mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  String _money(double value) => 'Rs. ${value.toStringAsFixed(2)}';

  String _date(DateTime value) {
    return '${value.day.toString().padLeft(2, '0')}/'
        '${value.month.toString().padLeft(2, '0')}/'
        '${value.year}';
  }

  InputDecoration _decoration(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: muted),
      filled: true,
      fillColor: background,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: borderColor),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: blue),
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12, top: 8),
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

  Widget _summaryCard(String title, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: panel,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 23,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 5),
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

  Widget _actionCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: panel,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: borderColor),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 27),
            const SizedBox(height: 10),
            Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: const TextStyle(
                color: muted,
                fontSize: 11,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _historyCard({
    required String title,
    required String subtitle,
    required String trailing,
    required VoidCallback onTap,
  }) {
    return Card(
      color: panel,
      margin: const EdgeInsets.only(bottom: 9),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(13),
        side: const BorderSide(color: borderColor),
      ),
      child: ListTile(
        onTap: onTap,
        title: Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 13,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: const TextStyle(
            color: muted,
            fontSize: 11,
          ),
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              trailing,
              style: const TextStyle(
                color: blue,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
            const Icon(
              Icons.chevron_right,
              color: muted,
              size: 18,
            ),
          ],
        ),
        isThreeLine: true,
      ),
    );
  }

  // ============================================================
  // PURCHASE ORDER
  // ============================================================

  Future<void> _purchase(
    BuildContext context,
    WidgetRef ref,
  ) async {
    final inventory = ref.read(inventoryProvider);
    final data = ref.read(inventoryPurchaseProvider);

    final products = inventory.products;
    final branches = inventory.branches.where((b) => b.active).toList();

    if (products.isEmpty) {
      _message(context, 'Add products before creating a purchase.');
      return;
    }

    if (branches.isEmpty) {
      _message(context, 'Create an active branch first.');
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

    final lines = <_PurchaseLineInput>[
      _PurchaseLineInput(products.first.id),
    ];

    String branchId = branches.first.id;
    String paymentMethod = 'Cash';

    final result = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, refresh) {
            double subtotal = 0;

            for (final line in lines) {
              final quantity =
                  int.tryParse(line.quantity.text.trim()) ?? 0;
              final cost =
                  double.tryParse(line.cost.text.trim()) ?? 0;
              subtotal += quantity * cost;
            }

            final discountValue =
                double.tryParse(discount.text.trim()) ?? 0;
            final taxValue =
                double.tryParse(tax.text.trim()) ?? 0;
            final total = subtotal - discountValue + taxValue;

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
                      TextField(
                        controller: supplier,
                        style: const TextStyle(color: Colors.white),
                        decoration: _decoration('Supplier name *'),
                      ),
                      const SizedBox(height: 10),
                      TextField(
                        controller: phone,
                        style: const TextStyle(color: Colors.white),
                        keyboardType: TextInputType.phone,
                        decoration: _decoration('Supplier phone'),
                      ),
                      const SizedBox(height: 10),
                      TextField(
                        controller: address,
                        style: const TextStyle(color: Colors.white),
                        decoration: _decoration('Supplier address'),
                      ),
                      const SizedBox(height: 10),
                      TextField(
                        controller: supplierInvoice,
                        style: const TextStyle(color: Colors.white),
                        decoration: _decoration(
                          'Supplier invoice number',
                        ),
                      ),
                      const SizedBox(height: 12),
                      DropdownButtonFormField<String>(
                        value: branchId,
                        isExpanded: true,
                        dropdownColor: panel,
                        decoration: _decoration('Receiving branch'),
                        items: branches.map((branch) {
                          return DropdownMenuItem(
                            value: branch.id,
                            child: Text(
                              branch.name,
                              style: const TextStyle(
                                color: Colors.white,
                              ),
                            ),
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
                          'Purchase Items',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      ...lines.asMap().entries.map((entry) {
                        final index = entry.key;
                        final line = entry.value;

                        final product = products.firstWhere(
                          (p) => p.id == line.productId,
                        );

                        return Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: background,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: borderColor),
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
                                      decoration: _decoration('Product'),
                                      items: products.map((p) {
                                        return DropdownMenuItem(
                                          value: p.id,
                                          child: Text(
                                            p.name,
                                            style: const TextStyle(
                                              color: Colors.white,
                                            ),
                                          ),
                                        );
                                      }).toList(),
                                      onChanged: (value) {
                                        if (value != null) {
                                          refresh(() {
                                            line.productId = value;
                                          });
                                        }
                                      },
                                    ),
                                  ),
                                  IconButton(
                                    onPressed: lines.length <= 1
                                        ? null
                                        : () {
                                            final removed =
                                                lines.removeAt(index);
                                            removed.dispose();
                                            refresh(() {});
                                          },
                                    icon: const Icon(
                                      Icons.delete_outline,
                                      color: Colors.redAccent,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  Expanded(
                                    child: TextField(
                                      controller: line.quantity,
                                      keyboardType:
                                          TextInputType.number,
                                      style: const TextStyle(
                                        color: Colors.white,
                                      ),
                                      decoration: _decoration('Quantity'),
                                      onChanged: (_) => refresh(() {}),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: TextField(
                                      controller: line.cost,
                                      keyboardType:
                                          const TextInputType.numberWithOptions(
                                        decimal: true,
                                      ),
                                      style: const TextStyle(
                                        color: Colors.white,
                                      ),
                                      decoration: _decoration('Unit cost'),
                                      onChanged: (_) => refresh(() {}),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 5),
                              Align(
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  '${product.unit} • ${product.sku}',
                                  style: const TextStyle(
                                    color: muted,
                                    fontSize: 11,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      }),
                      TextButton.icon(
                        onPressed: () {
                          refresh(() {
                            lines.add(
                              _PurchaseLineInput(products.first.id),
                            );
                          });
                        },
                        icon: const Icon(Icons.add),
                        label: const Text('Add another product'),
                      ),
                      const Divider(color: borderColor),
                      TextField(
                        controller: discount,
                        keyboardType:
                            const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        style: const TextStyle(color: Colors.white),
                        decoration: _decoration('Discount amount'),
                        onChanged: (_) => refresh(() {}),
                      ),
                      const SizedBox(height: 10),
                      TextField(
                        controller: tax,
                        keyboardType:
                            const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        style: const TextStyle(color: Colors.white),
                        decoration: _decoration('Tax amount'),
                        onChanged: (_) => refresh(() {}),
                      ),
                      const SizedBox(height: 10),
                      TextField(
                        controller: paid,
                        keyboardType:
                            const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        style: const TextStyle(color: Colors.white),
                        decoration: _decoration('Amount paid'),
                      ),
                      const SizedBox(height: 10),
                      DropdownButtonFormField<String>(
                        value: paymentMethod,
                        dropdownColor: panel,
                        decoration: _decoration('Payment method'),
                        items: [
                          'Cash',
                          'Bank Transfer',
                          'Card',
                          'Credit',
                          'Other',
                        ].map((value) {
                          return DropdownMenuItem(
                            value: value,
                            child: Text(
                              value,
                              style: const TextStyle(
                                color: Colors.white,
                              ),
                            ),
                          );
                        }).toList(),
                        onChanged: (value) {
                          if (value != null) {
                            refresh(() => paymentMethod = value);
                          }
                        },
                      ),
                      const SizedBox(height: 10),
                      TextField(
                        controller: notes,
                        style: const TextStyle(color: Colors.white),
                        maxLines: 2,
                        decoration: _decoration('Notes'),
                      ),
                      const SizedBox(height: 14),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: background,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Column(
                          children: [
                            _totalRow('Subtotal', _money(subtotal)),
                            _totalRow(
                              'Discount',
                              _money(discountValue),
                            ),
                            _totalRow('Tax', _money(taxValue)),
                            const Divider(color: borderColor),
                            _totalRow(
                              'Grand Total',
                              _money(total),
                              highlight: true,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(dialogContext, false);
                  },
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    try {
                      if (supplier.text.trim().isEmpty) {
                        throw Exception('Enter the supplier name.');
                      }

                      final purchaseLines = <PurchaseOrderLine>[];

                      for (final line in lines) {
                        final quantity = int.tryParse(
                          line.quantity.text.trim(),
                        );
                        final cost = double.tryParse(
                          line.cost.text.trim(),
                        );

                        if (quantity == null ||
                            quantity <= 0 ||
                            cost == null ||
                            !cost.isFinite ||
                            cost < 0) {
                          throw Exception(
                            'Enter valid quantities and unit costs.',
                          );
                        }

                        final product = inventory.getProductById(
                          line.productId,
                        );

                        if (product == null) {
                          throw Exception('A product was not found.');
                        }

                        purchaseLines.add(
                          PurchaseOrderLine(
                            productId: product.id,
                            productName: product.name,
                            sku: product.sku,
                            unit: product.unit,
                            quantity: quantity,
                            unitCost: cost,
                          ),
                        );
                      }

                      final discountAmount = double.tryParse(
                        discount.text.trim(),
                      );
                      final taxAmount = double.tryParse(
                        tax.text.trim(),
                      );
                      final paidAmount = double.tryParse(
                        paid.text.trim(),
                      );

                      if (discountAmount == null ||
                          taxAmount == null ||
                          paidAmount == null ||
                          !discountAmount.isFinite ||
                          !taxAmount.isFinite ||
                          !paidAmount.isFinite) {
                        throw Exception('Enter valid payment amounts.');
                      }

                      await data.createPurchaseOrder(
                        inventory: inventory,
                        supplierName: supplier.text,
                        supplierPhone: phone.text,
                        supplierAddress: address.text,
                        supplierInvoiceNumber: supplierInvoice.text,
                        branchId: branchId,
                        items: purchaseLines,
                        discount: discountAmount,
                        tax: taxAmount,
                        amountPaid: paidAmount,
                        paymentMethod: paymentMethod,
                        notes: notes.text,
                      );

                      if (dialogContext.mounted) {
                        Navigator.pop(dialogContext, true);
                      }
                    } catch (error) {
                      _message(
                        context,
                        error.toString().replaceFirst(
                          'Exception: ',
                          '',
                        ),
                      );
                    }
                  },
                  child: const Text('Save Purchase'),
                ),
              ],
            );
          },
        );
      },
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

  Widget _totalRow(
    String label,
    String value, {
    bool highlight = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              color: highlight ? Colors.white : muted,
              fontWeight: highlight ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              color: highlight ? green : Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // SUPPLIER RETURN
  // ============================================================

  Future<void> _supplierReturn(
    BuildContext context,
    WidgetRef ref,
  ) async {
    final inventory = ref.read(inventoryProvider);
    final data = ref.read(inventoryPurchaseProvider);

    if (data.purchaseOrders.isEmpty) {
      _message(
        context,
        'Create a purchase order before recording a supplier return.',
      );
      return;
    }

    PurchaseOrderRecord selected = data.purchaseOrders.first;

    final reason = TextEditingController();
    final notes = TextEditingController();
    final quantities = <String, TextEditingController>{};

    String settlement = 'Supplier Credit';

    final result = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, refresh) {
            final returned = <String, int>{};

            for (final record in data.supplierReturns.where(
              (r) =>
                  r.originalPurchaseOrderNumber ==
                  selected.purchaseOrderNumber,
            )) {
              for (final item in record.items) {
                returned[item.productId] =
                    (returned[item.productId] ?? 0) + item.quantity;
              }
            }

            final uniqueItems = <String, PurchaseOrderLine>{};

            for (final item in selected.items) {
              uniqueItems[item.productId] = item;
            }

            return AlertDialog(
              backgroundColor: panel,
              title: const Text(
                'Supplier Return',
                style: TextStyle(color: Colors.white),
              ),
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
                        decoration: _decoration('Original purchase'),
                        items: data.purchaseOrders.map((order) {
                          return DropdownMenuItem(
                            value: order.purchaseOrderNumber,
                            child: Text(
                              '${order.purchaseOrderNumber} • ${order.supplierName}',
                              style: const TextStyle(
                                color: Colors.white,
                              ),
                            ),
                          );
                        }).toList(),
                        onChanged: (value) {
                          if (value == null) return;

                          refresh(() {
                            selected = data.purchaseOrders.firstWhere(
                              (order) =>
                                  order.purchaseOrderNumber == value,
                            );
                          });
                        },
                      ),
                      const SizedBox(height: 12),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Supplier: ${selected.supplierName}\n'
                          'Branch: ${inventory.getBranchById(selected.branchId)?.name ?? selected.branchId}',
                          style: const TextStyle(
                            color: muted,
                            height: 1.5,
                          ),
                        ),
                      ),
                      const SizedBox(height: 14),
                      ...uniqueItems.values.map((item) {
                        final alreadyReturned =
                            returned[item.productId] ?? 0;
                        final remaining =
                            item.quantity - alreadyReturned;

                        final controller = quantities.putIfAbsent(
                          item.productId,
                          () => TextEditingController(),
                        );

                        final product = inventory.getProductById(
                          item.productId,
                        );

                        final available = inventory.getBranchQuantity(
                          item.productId,
                          selected.branchId,
                        );

                        return Container(
                          width: double.infinity,
                          margin: const EdgeInsets.only(bottom: 10),
                          padding: const EdgeInsets.all(11),
                          decoration: BoxDecoration(
                            color: background,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: borderColor),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item.productName,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 5),
                              Text(
                                'Purchased: ${item.quantity} ${item.unit}',
                                style: const TextStyle(
                                  color: muted,
                                  fontSize: 11,
                                ),
                              ),
                              Text(
                                'Already returned: $alreadyReturned',
                                style: const TextStyle(
                                  color: muted,
                                  fontSize: 11,
                                ),
                              ),
                              Text(
                                'Remaining returnable: $remaining',
                                style: const TextStyle(
                                  color: green,
                                  fontSize: 11,
                                ),
                              ),
                              Text(
                                'Current branch stock: $available ${product?.unit ?? item.unit}',
                                style: const TextStyle(
                                  color: muted,
                                  fontSize: 11,
                                ),
                              ),
                              const SizedBox(height: 8),
                              TextField(
                                controller: controller,
                                keyboardType: TextInputType.number,
                                style: const TextStyle(
                                  color: Colors.white,
                                ),
                                decoration: _decoration(
                                  'Quantity to return (blank to skip)',
                                ),
                              ),
                            ],
                          ),
                        );
                      }),
                      const SizedBox(height: 8),
                      TextField(
                        controller: reason,
                        style: const TextStyle(color: Colors.white),
                        decoration: _decoration('Return reason *'),
                      ),
                      const SizedBox(height: 10),
                      DropdownButtonFormField<String>(
                        value: settlement,
                        dropdownColor: panel,
                        decoration: _decoration('Settlement'),
                        items: [
                          'Supplier Credit',
                          'Refund',
                          'Replacement',
                        ].map((value) {
                          return DropdownMenuItem(
                            value: value,
                            child: Text(
                              value,
                              style: const TextStyle(
                                color: Colors.white,
                              ),
                            ),
                          );
                        }).toList(),
                        onChanged: (value) {
                          if (value != null) {
                            refresh(() => settlement = value);
                          }
                        },
                      ),
                      const SizedBox(height: 10),
                      TextField(
                        controller: notes,
                        style: const TextStyle(color: Colors.white),
                        maxLines: 2,
                        decoration: _decoration('Additional notes'),
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(dialogContext, false);
                  },
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    try {
                      if (reason.text.trim().isEmpty) {
                        throw Exception('Enter a return reason.');
                      }

                      final items = <SupplierReturnLine>[];

                      for (final item in uniqueItems.values) {
                        final raw =
                            quantities[item.productId]?.text.trim() ?? '';

                        if (raw.isEmpty) continue;

                        final quantity = int.tryParse(raw);

                        if (quantity == null || quantity <= 0) {
                          throw Exception(
                            'Enter a valid return quantity for ${item.productName}.',
                          );
                        }

                        final alreadyReturned =
                            returned[item.productId] ?? 0;
                        final remaining =
                            item.quantity - alreadyReturned;

                        if (quantity > remaining) {
                          throw Exception(
                            'Return quantity for ${item.productName} exceeds the remaining purchased quantity.',
                          );
                        }

                        items.add(
                          SupplierReturnLine(
                            productId: item.productId,
                            productName: item.productName,
                            sku: item.sku,
                            unit: item.unit,
                            quantity: quantity,
                            unitCost: item.unitCost,
                          ),
                        );
                      }

                      if (items.isEmpty) {
                        throw Exception(
                          'Enter at least one quantity to return.',
                        );
                      }

                      await data.createSupplierReturn(
                        inventory: inventory,
                        originalPurchaseOrderNumber:
                            selected.purchaseOrderNumber,
                        items: items,
                        reason: reason.text,
                        settlementType: settlement,
                        notes: notes.text,
                      );

                      if (dialogContext.mounted) {
                        Navigator.pop(dialogContext, true);
                      }
                    } catch (error) {
                      _message(
                        context,
                        error.toString().replaceFirst(
                          'Exception: ',
                          '',
                        ),
                      );
                    }
                  },
                  child: const Text('Save Return'),
                ),
              ],
            );
          },
        );
      },
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

  // ============================================================
  // MANUAL STOCK ADJUSTMENT
  // ============================================================

  Future<void> _adjust(
    BuildContext context,
    WidgetRef ref,
  ) async {
    final inventory = ref.read(inventoryProvider);

    final products = inventory.products;
    final branches = inventory.branches.where((b) => b.active).toList();

    if (products.isEmpty || branches.isEmpty) {
      _message(context, 'Add a product and active branch first.');
      return;
    }

    final quantity = TextEditingController();
    final reason = TextEditingController();

    String productId = products.first.id;
    String branchId = branches.first.id;
    String direction = 'Add';

    final saved = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, refresh) {
            final current = inventory.getBranchQuantity(
              productId,
              branchId,
            );

            return AlertDialog(
              backgroundColor: panel,
              title: const Text(
                'Manual Stock Adjustment',
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
                      decoration: _decoration('Product'),
                      items: products.map((product) {
                        return DropdownMenuItem(
                          value: product.id,
                          child: Text(
                            product.name,
                            style: const TextStyle(
                              color: Colors.white,
                            ),
                          ),
                        );
                      }).toList(),
                      onChanged: (value) {
                        if (value != null) {
                          refresh(() => productId = value);
                        }
                      },
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      value: branchId,
                      isExpanded: true,
                      dropdownColor: panel,
                      decoration: _decoration('Branch'),
                      items: branches.map((branch) {
                        return DropdownMenuItem(
                          value: branch.id,
                          child: Text(
                            branch.name,
                            style: const TextStyle(
                              color: Colors.white,
                            ),
                          ),
                        );
                      }).toList(),
                      onChanged: (value) {
                        if (value != null) {
                          refresh(() => branchId = value);
                        }
                      },
                    ),
                    const SizedBox(height: 12),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: background,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        'Current branch quantity: $current',
                        style: const TextStyle(
                          color: green,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      value: direction,
                      dropdownColor: panel,
                      decoration: _decoration('Adjustment type'),
                      items: ['Add', 'Remove'].map((value) {
                        return DropdownMenuItem(
                          value: value,
                          child: Text(
                            value,
                            style: const TextStyle(
                              color: Colors.white,
                            ),
                          ),
                        );
                      }).toList(),
                      onChanged: (value) {
                        if (value != null) {
                          refresh(() => direction = value);
                        }
                      },
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: quantity,
                      keyboardType: TextInputType.number,
                      style: const TextStyle(color: Colors.white),
                      decoration: _decoration('Quantity'),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: reason,
                      style: const TextStyle(color: Colors.white),
                      maxLines: 2,
                      decoration: _decoration('Reason *'),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(dialogContext, false);
                  },
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () {
                    try {
                      final amount = int.tryParse(
                        quantity.text.trim(),
                      );

                      if (amount == null || amount <= 0) {
                        throw Exception(
                          'Enter a quantity greater than zero.',
                        );
                      }

                      if (reason.text.trim().isEmpty) {
                        throw Exception('Enter an adjustment reason.');
                      }

                      inventory.adjustStock(
                        productId: productId,
                        branchId: branchId,
                        quantity:
                            direction == 'Add' ? amount : -amount,
                        reason: reason.text.trim(),
                      );

                      Navigator.pop(dialogContext, true);
                    } catch (error) {
                      _message(
                        context,
                        error.toString().replaceFirst(
                          'Exception: ',
                          '',
                        ),
                      );
                    }
                  },
                  child: const Text('Save Adjustment'),
                ),
              ],
            );
          },
        );
      },
    );

    quantity.dispose();
    reason.dispose();

    if (saved == true && context.mounted) {
      _message(context, 'Stock adjustment saved.');
    }
  }

  // ============================================================
  // PURCHASE DETAILS
  // ============================================================

  Future<void> _purchaseDetails(
    BuildContext context,
    PurchaseOrderRecord order,
    InventoryData inventory,
  ) async {
    final branch =
        inventory.getBranchById(order.branchId)?.name ??
        order.branchId;

    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: panel,
          title: Text(
            order.purchaseOrderNumber,
            style: const TextStyle(color: Colors.white),
          ),
          content: SizedBox(
            width: 450,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  _detailRow('Supplier', order.supplierName),
                  _detailRow('Phone', order.supplierPhone),
                  _detailRow('Address', order.supplierAddress),
                  _detailRow(
                    'Supplier Invoice',
                    order.supplierInvoiceNumber,
                  ),
                  _detailRow('Branch', branch),
                  _detailRow('Date', _date(order.date)),
                  _detailRow('Status', order.status),
                  _detailRow('Payment', order.paymentStatus),
                  _detailRow('Method', order.paymentMethod),
                  const Divider(color: borderColor),
                  const Text(
                    'Purchased Items',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ...order.items.map((item) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 9),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              '${item.productName}\n'
                              '${item.quantity} ${item.unit} × ${_money(item.unitCost)}',
                              style: const TextStyle(
                                color: muted,
                                fontSize: 12,
                              ),
                            ),
                          ),
                          Text(
                            _money(item.total),
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                  const Divider(color: borderColor),
                  _detailRow('Subtotal', _money(order.subtotal)),
                  _detailRow('Discount', _money(order.discount)),
                  _detailRow('Tax', _money(order.tax)),
                  _detailRow('Total', _money(order.total)),
                  _detailRow('Paid', _money(order.amountPaid)),
                  _detailRow('Balance', _money(order.balanceDue)),
                  if (order.notes.isNotEmpty)
                    _detailRow('Notes', order.notes),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () async {
                try {
                  await InventoryInvoicePdf.sharePurchaseOrder(
                    order,
                    branchName: branch,
                  );
                } catch (error) {
                  _message(context, 'Could not share PDF: $error');
                }
              },
              child: const Text('Share PDF'),
            ),
            TextButton(
              onPressed: () async {
                try {
                  await InventoryInvoicePdf.printPurchaseOrder(
                    order,
                    branchName: branch,
                  );
                } catch (error) {
                  _message(context, 'Could not print PDF: $error');
                }
              },
              child: const Text('Print PDF'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  // ============================================================
  // SUPPLIER RETURN DETAILS
  // ============================================================

  Future<void> _returnDetails(
    BuildContext context,
    SupplierReturnRecord record,
    InventoryData inventory,
  ) async {
    final branch =
        inventory.getBranchById(record.branchId)?.name ??
        record.branchId;

    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: panel,
          title: Text(
            record.returnNumber,
            style: const TextStyle(color: Colors.white),
          ),
          content: SizedBox(
            width: 450,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  _detailRow('Supplier', record.supplierName),
                  _detailRow('Phone', record.supplierPhone),
                  _detailRow(
                    'Original Purchase',
                    record.originalPurchaseOrderNumber,
                  ),
                  _detailRow('Branch', branch),
                  _detailRow('Date', _date(record.date)),
                  _detailRow('Reason', record.reason),
                  _detailRow('Settlement', record.settlementType),
                  const Divider(color: borderColor),
                  const Text(
                    'Returned Items',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ...record.items.map((item) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 9),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              '${item.productName}\n'
                              '${item.quantity} ${item.unit} × ${_money(item.unitCost)}',
                              style: const TextStyle(
                                color: muted,
                                fontSize: 12,
                              ),
                            ),
                          ),
                          Text(
                            _money(item.total),
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                  const Divider(color: borderColor),
                  _detailRow('Total Units', '${record.totalUnits}'),
                  _detailRow('Return Total', _money(record.total)),
                  if (record.notes.isNotEmpty)
                    _detailRow('Notes', record.notes),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () async {
                try {
                  await InventoryInvoicePdf.shareSupplierReturn(
                    record,
                    branchName: branch,
                  );
                } catch (error) {
                  _message(context, 'Could not share PDF: $error');
                }
              },
              child: const Text('Share PDF'),
            ),
            TextButton(
              onPressed: () async {
                try {
                  await InventoryInvoicePdf.printSupplierReturn(
                    record,
                    branchName: branch,
                  );
                } catch (error) {
                  _message(context, 'Could not print PDF: $error');
                }
              },
              child: const Text('Print PDF'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 115,
            child: Text(
              label,
              style: const TextStyle(
                color: muted,
                fontSize: 12,
              ),
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

  // ============================================================
  // BRANCH STOCK
  // ============================================================

  Widget _branchStock(
    InventoryProduct product,
    InventoryData inventory,
  ) {
    return Card(
      color: panel,
      margin: const EdgeInsets.only(bottom: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: borderColor),
      ),
      child: ExpansionTile(
        iconColor: blue,
        collapsedIconColor: muted,
        title: Text(
          product.name,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Text(
          '${product.sku} • Total: ${product.quantity} ${product.unit}',
          style: const TextStyle(
            color: muted,
            fontSize: 11,
          ),
        ),
        children: inventory.branches.map((branch) {
          final quantity = inventory.getBranchQuantity(
            product.id,
            branch.id,
          );

          return ListTile(
            dense: true,
            title: Text(
              branch.name,
              style: const TextStyle(
                color: muted,
                fontSize: 12,
              ),
            ),
            trailing: Text(
              '$quantity ${product.unit}',
              style: const TextStyle(
                color: green,
                fontWeight: FontWeight.bold,
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  // ============================================================
  // RECENT MOVEMENTS
  // ============================================================

  Widget _movementCard(
    StockMovement movement,
    InventoryData inventory,
  ) {
    final isIn = movement.type == 'Stock In' ||
        movement.type == 'Stock Added' ||
        movement.type == 'Transfer In';

    final isOut = movement.type == 'Stock Out' ||
        movement.type == 'Stock Removed' ||
        movement.type == 'Transfer Out';

    final color = isIn
        ? green
        : isOut
            ? orange
            : blue;

    final branch =
        inventory.getBranchById(movement.branchId)?.name ??
        movement.branchId;

    return Card(
      color: panel,
      margin: const EdgeInsets.only(bottom: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: borderColor),
      ),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color.withValues(alpha: 0.15),
          child: Icon(
            isIn
                ? Icons.call_received
                : isOut
                    ? Icons.call_made
                    : Icons.swap_horiz,
            color: color,
          ),
        ),
        title: Text(
          movement.productName,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 13,
          ),
        ),
        subtitle: Text(
          '${movement.type} • ${_date(movement.date)}\n'
          '$branch • ${movement.referenceCode}',
          style: const TextStyle(
            color: muted,
            fontSize: 10,
          ),
        ),
        trailing: Text(
          '${isOut ? '-' : '+'}${movement.quantity}',
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.bold,
            fontSize: 15,
          ),
        ),
        isThreeLine: true,
      ),
    );
  }

  // ============================================================
  // MAIN SCREEN
  // ============================================================

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final inventory = ref.watch(inventoryProvider);
    final purchaseData = ref.watch(inventoryPurchaseProvider);
    final initialized =
        ref.watch(inventoryPurchaseInitializationProvider);

    final lowStock = inventory.products
        .where((product) =>
            product.quantity <= product.minimumStock)
        .length;

    final movements = inventory.movements.reversed.take(30).toList();

    return Scaffold(
      backgroundColor: background,
      appBar: AppBar(
        backgroundColor: background,
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Stock Management',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: initialized.when(
        loading: () => const Center(
          child: CircularProgressIndicator(color: blue),
        ),
        error: (error, stack) => Center(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Text(
              'Could not load purchase records.\n$error',
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.redAccent),
            ),
          ),
        ),
        data: (_) {
          return RefreshIndicator(
            color: blue,
            backgroundColor: panel,
            onRefresh: () async {
              await ref
                  .read(inventoryPurchaseProvider)
                  .initialize();
            },
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 30),
              children: [
                const Text(
                  'Stock Overview',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 23,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 14),

                // Summary cards
                Row(
                  children: [
                    Expanded(
                      child: _summaryCard(
                        'Total stock units',
                        inventory.totalStock.toString(),
                        blue,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _summaryCard(
                        'Products',
                        inventory.products.length.toString(),
                        green,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: _summaryCard(
                        'Low stock products',
                        lowStock.toString(),
                        orange,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _summaryCard(
                        'Out of stock',
                        inventory.outOfStockCount.toString(),
                        Colors.redAccent,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 24),
                _sectionTitle('Stock Actions'),

                // Action cards: Expanded belongs to the Row,
                // never inside the card builder.
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: _actionCard(
                        title: 'Purchase Order',
                        subtitle: 'Receive stock',
                        icon: Icons.add_shopping_cart,
                        color: green,
                        onTap: () => _purchase(context, ref),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _actionCard(
                        title: 'Supplier Return',
                        subtitle: 'Return to supplier',
                        icon: Icons.assignment_return,
                        color: orange,
                        onTap: () => _supplierReturn(context, ref),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                _actionCard(
                  title: 'Manual Adjustment',
                  subtitle: 'Correct stock quantities',
                  icon: Icons.tune,
                  color: blue,
                  onTap: () => _adjust(context, ref),
                ),

                const SizedBox(height: 24),
                _sectionTitle('Purchase History'),

                if (purchaseData.purchaseOrders.isEmpty)
                  _emptyMessage('No purchase orders recorded yet.')
                else
                  ...purchaseData.purchaseOrders.map((order) {
                    return _historyCard(
                      title: order.purchaseOrderNumber,
                      subtitle:
                          '${order.supplierName} • ${_date(order.date)}\n'
                          'Payment: ${order.paymentStatus}',
                      trailing: _money(order.total),
                      onTap: () => _purchaseDetails(
                        context,
                        order,
                        inventory,
                      ),
                    );
                  }),

                const SizedBox(height: 18),
                _sectionTitle('Supplier Return History'),

                if (purchaseData.supplierReturns.isEmpty)
                  _emptyMessage('No supplier returns recorded yet.')
                else
                  ...purchaseData.supplierReturns.map((record) {
                    return _historyCard(
                      title: record.returnNumber,
                      subtitle:
                          '${record.supplierName} • ${_date(record.date)}\n'
                          'Original: ${record.originalPurchaseOrderNumber}',
                      trailing: _money(record.total),
                      onTap: () => _returnDetails(
                        context,
                        record,
                        inventory,
                      ),
                    );
                  }),

                const SizedBox(height: 18),
                _sectionTitle('Branch-wise Stock'),

                if (inventory.products.isEmpty)
                  _emptyMessage('No products available.')
                else
                  ...inventory.products.map(
                    (product) => _branchStock(product, inventory),
                  ),

                const SizedBox(height: 18),
                _sectionTitle('Recent Stock Movements'),

                if (movements.isEmpty)
                  _emptyMessage('No stock movements recorded yet.')
                else
                  ...movements.map(
                    (movement) =>
                        _movementCard(movement, inventory),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _emptyMessage(String message) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: panel,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor),
      ),
      child: Text(
        message,
        style: const TextStyle(
          color: muted,
          fontSize: 12,
        ),
      ),
    );
  }
}

// ============================================================
// PURCHASE LINE INPUT
// ============================================================

class _PurchaseLineInput {
  _PurchaseLineInput(this.productId);

  String productId;

  final TextEditingController quantity =
      TextEditingController(text: '1');

  final TextEditingController cost =
      TextEditingController(text: '0');

  void dispose() {
    quantity.dispose();
    cost.dispose();
  }
}
