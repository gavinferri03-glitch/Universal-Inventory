
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'inventory_data.dart';
import 'inventory_models.dart';
import 'inventory_invoice_pdf.dart';

class SalesReturnScreen extends ConsumerStatefulWidget {
  const SalesReturnScreen({super.key});

  @override
  ConsumerState<SalesReturnScreen> createState() =>
      _SalesReturnScreenState();
}

class _SalesReturnScreenState
    extends ConsumerState<SalesReturnScreen> {
  static const Color background = Color(0xFF080B12);
  static const Color panel = Color(0xFF121D2D);
  static const Color blue = Color(0xFF5798FF);
  static const Color orange = Color(0xFFFFB454);
  static const Color green = Color(0xFF45C99A);
  static const Color muted = Color(0xFF91A4BE);

  final TextEditingController invoiceController =
      TextEditingController();

  final TextEditingController reasonController =
      TextEditingController();

  SaleRecord? selectedSale;

  final Map<String, int> returnQuantities = {};

  bool isSaving = false;

  @override
  void dispose() {
    invoiceController.dispose();
    reasonController.dispose();
    super.dispose();
  }

  String money(double value) =>
      'Rs. ${value.toStringAsFixed(2)}';

  void showMessage(String message, {bool error = false}) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor:
            error ? Colors.red.shade700 : const Color(0xFF263B5B),
      ),
    );
  }

  int alreadyReturned(
    InventoryData inventory,
    String invoiceNumber,
    String productId,
  ) {
    int quantity = 0;

    for (final record in inventory.salesReturns) {
      if (record.originalInvoiceNumber != invoiceNumber) {
        continue;
      }

      for (final item in record.items) {
        if (item.productId == productId) {
          quantity += item.quantity;
        }
      }
    }

    return quantity;
  }

  List<SaleLineItem> getGroupedItems(SaleRecord sale) {
    final Map<String, List<SaleLineItem>> grouped = {};

    for (final item in sale.items) {
      grouped.putIfAbsent(item.productId, () => []);
      grouped[item.productId]!.add(item);
    }

    return grouped.values.map((items) {
      final first = items.first;
      final quantity =
          items.fold<int>(0, (sum, item) => sum + item.quantity);

      final totalValue = items.fold<double>(
        0,
        (sum, item) => sum + item.total,
      );

      final totalCost = items.fold<double>(
        0,
        (sum, item) => sum + item.costPrice * item.quantity,
      );

      return SaleLineItem(
        productId: first.productId,
        productName: first.productName,
        sku: first.sku,
        quantity: quantity,
        unitPrice: quantity > 0 ? totalValue / quantity : 0,
        costPrice: quantity > 0 ? totalCost / quantity : 0,
      );
    }).toList();
  }

  void findInvoice(InventoryData inventory) {
    final invoice = invoiceController.text.trim();

    if (invoice.isEmpty) {
      showMessage('Enter an invoice number.', error: true);
      return;
    }

    final sale = inventory.findSale(invoice);

    if (sale == null) {
      setState(() {
        selectedSale = null;
        returnQuantities.clear();
      });

      showMessage('Invoice not found.', error: true);
      return;
    }

    setState(() {
      selectedSale = sale;
      returnQuantities.clear();
    });

    showMessage('Original sale found.');
  }

  double get returnTotal {
    if (selectedSale == null) return 0;

    final items = getGroupedItems(selectedSale!);

    return items.fold<double>(0, (sum, item) {
      final quantity = returnQuantities[item.productId] ?? 0;
      return sum + quantity * item.unitPrice;
    });
  }

  int get totalReturnUnits =>
      returnQuantities.values.fold(0, (sum, value) => sum + value);

  Future<void> saveReturn(InventoryData inventory) async {
    final sale = selectedSale;

    if (sale == null) {
      showMessage('Find an original invoice first.', error: true);
      return;
    }

    if (totalReturnUnits <= 0) {
      showMessage('Select at least one item to return.', error: true);
      return;
    }

    final reason = reasonController.text.trim();

    if (reason.isEmpty) {
      showMessage('Enter a reason for the return.', error: true);
      return;
    }

    final returnItems = <SalesReturnLine>[];

    for (final item in getGroupedItems(sale)) {
      final quantity = returnQuantities[item.productId] ?? 0;

      if (quantity <= 0) continue;

      returnItems.add(
        SalesReturnLine(
          productId: item.productId,
          productName: item.productName,
          sku: item.sku,
          quantity: quantity,
          unitPrice: item.unitPrice,
        ),
      );
    }

    setState(() => isSaving = true);

    try {
      inventory.createSalesReturn(
        originalInvoiceNumber: sale.invoiceNumber,
        items: returnItems,
        reason: reason,
      );

      final record = inventory.salesReturns.last;

      setState(() {
        selectedSale = null;
        returnQuantities.clear();
        invoiceController.clear();
        reasonController.clear();
      });

      showMessage('Sales return ${record.returnNumber} saved successfully.');

      if (!mounted) return;

      showReturnReceipt(record, inventory);
    } catch (error) {
      showMessage(
        'Could not save return: ${error.toString()}',
        error: true,
      );
    } finally {
      if (mounted) {
        setState(() => isSaving = false);
      }
    }
  }

  Future<void> runPdf(
    Future<void> Function() action,
  ) async {
    try {
      await action();
    } catch (error) {
      showMessage(
        'PDF operation failed: $error',
        error: true,
      );
    }
  }

  void showReturnReceipt(
    SalesReturnRecord record,
    InventoryData inventory,
  ) {
    final branch =
        inventory.findBranch(record.branchId)?.name ?? 'Unknown branch';

    showModalBottomSheet<void>(
      context: context,
      backgroundColor: panel,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(22),
        ),
      ),
      builder: (sheetContext) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Return Saved Successfully',
                    style: TextStyle(
                      color: green,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  detailRow('Return Number', record.returnNumber),
                  detailRow(
                    'Original Invoice',
                    record.originalInvoiceNumber,
                  ),
                  detailRow('Customer', record.customerName),
                  detailRow('Branch', branch),
                  detailRow('Reason', record.reason),
                  const Divider(color: Colors.white12, height: 28),
                  ...record.items.map(
                    (item) => detailRow(
                      item.productName,
                      '${item.quantity} × ${money(item.unitPrice)}',
                    ),
                  ),
                  const Divider(color: Colors.white12, height: 28),
                  detailRow(
                    'Total Refund',
                    money(record.total),
                    highlight: true,
                  ),
                  const SizedBox(height: 18),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            runPdf(
                              () => InventoryInvoicePdf.printSalesReturn(
                                record,
                                branchName: branch,
                              ),
                            );
                          },
                          icon: const Icon(Icons.print),
                          label: const Text('Print PDF'),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            runPdf(
                              () => InventoryInvoicePdf.shareSalesReturn(
                                record,
                                branchName: branch,
                              ),
                            );
                          },
                          icon: const Icon(Icons.share),
                          label: const Text('Share PDF'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: green,
                            foregroundColor: Colors.black,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget detailRow(
    String label,
    String value, {
    bool highlight = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              label,
              style: const TextStyle(color: muted, fontSize: 13),
            ),
          ),
          const SizedBox(width: 10),
          Text(
            value,
            style: TextStyle(
              color: highlight ? orange : Colors.white,
              fontWeight:
                  highlight ? FontWeight.bold : FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget buildReturnProduct(
    InventoryData inventory,
    SaleLineItem item,
    SaleRecord sale,
  ) {
    final already = alreadyReturned(
      inventory,
      sale.invoiceNumber,
      item.productId,
    );

    final remaining = item.quantity - already;
    final selected = returnQuantities[item.productId] ?? 0;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: panel,
        borderRadius: BorderRadius.circular(13),
        border: Border.all(color: const Color(0xFF26364D)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            item.productName,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            'SKU: ${item.sku}',
            style: const TextStyle(color: muted, fontSize: 11),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: Text(
                  'Sold: ${item.quantity}  •  '
                  'Previously returned: $already  •  '
                  'Available: $remaining',
                  style: const TextStyle(
                    color: muted,
                    fontSize: 11,
                  ),
                ),
              ),
              Text(
                money(item.unitPrice),
                style: const TextStyle(
                  color: blue,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Return Quantity',
                  style: TextStyle(color: Colors.white70),
                ),
              ),
              IconButton(
                onPressed: selected > 0
                    ? () {
                        setState(() {
                          returnQuantities[item.productId] =
                              selected - 1;
                        });
                      }
                    : null,
                icon: const Icon(
                  Icons.remove_circle_outline,
                  color: orange,
                ),
              ),
              Text(
                '$selected',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 17,
                ),
              ),
              IconButton(
                onPressed: selected < remaining
                    ? () {
                        setState(() {
                          returnQuantities[item.productId] =
                              selected + 1;
                        });
                      }
                    : null,
                icon: const Icon(
                  Icons.add_circle_outline,
                  color: green,
                ),
              ),
            ],
          ),
          if (selected > 0)
            Align(
              alignment: Alignment.centerRight,
              child: Text(
                'Refund: ${money(selected * item.unitPrice)}',
                style: const TextStyle(
                  color: orange,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget buildHistory(InventoryData inventory) {
    final records = List<SalesReturnRecord>.from(
      inventory.salesReturns,
    )..sort((a, b) => b.date.compareTo(a.date));

    if (records.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(18),
        child: Text(
          'No sales returns recorded yet.',
          style: TextStyle(color: muted),
        ),
      );
    }

    return Column(
      children: records.map((record) {
        return Card(
          color: panel,
          margin: const EdgeInsets.only(bottom: 9),
          child: ListTile(
            leading: const Icon(
              Icons.assignment_return_outlined,
              color: orange,
            ),
            title: Text(
              record.returnNumber,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            subtitle: Text(
              '${record.customerName.isEmpty ? 'Walk-in Customer' : record.customerName}\n'
              'Invoice: ${record.originalInvoiceNumber}',
              style: const TextStyle(color: muted, fontSize: 12),
            ),
            isThreeLine: true,
            trailing: Text(
              money(record.total),
              style: const TextStyle(
                color: orange,
                fontWeight: FontWeight.bold,
              ),
            ),
            onTap: () => showReturnReceipt(record, inventory),
          ),
        );
      }).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final inventory = ref.watch(inventoryProvider);

    final groupedItems = selectedSale == null
        ? <SaleLineItem>[]
        : getGroupedItems(selectedSale!);

    final branch = selectedSale == null
        ? ''
        : inventory.findBranch(selectedSale!.branchId)?.name ??
            'Unknown branch';

    return Scaffold(
      backgroundColor: background,
      appBar: AppBar(
        backgroundColor: background,
        foregroundColor: Colors.white,
        title: const Text('Sales Returns'),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: panel,
                borderRadius: BorderRadius.circular(15),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Find Original Sale',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: invoiceController,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: 'Enter invoice number',
                      hintStyle: const TextStyle(color: muted),
                      filled: true,
                      fillColor: background,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      prefixIcon: const Icon(
                        Icons.receipt_long,
                        color: blue,
                      ),
                    ),
                    onSubmitted: (_) => findInvoice(inventory),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () => findInvoice(inventory),
                      icon: const Icon(Icons.search),
                      label: const Text('Find Invoice'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: blue,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            if (selectedSale != null) ...[
              const SizedBox(height: 20),
              const Text(
                'Original Sale Details',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: panel,
                  borderRadius: BorderRadius.circular(13),
                ),
                child: Column(
                  children: [
                    detailRow(
                      'Invoice Number',
                      selectedSale!.invoiceNumber,
                    ),
                    detailRow(
                      'Customer',
                      selectedSale!.customerName.isEmpty
                          ? 'Walk-in Customer'
                          : selectedSale!.customerName,
                    ),
                    detailRow('Phone', selectedSale!.customerPhone),
                    detailRow('Branch', branch),
                    detailRow(
                      'Sale Date',
                      '${selectedSale!.date.day}/'
                      '${selectedSale!.date.month}/'
                      '${selectedSale!.date.year}',
                    ),
                    detailRow(
                      'Original Total',
                      money(selectedSale!.total),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),
              const Text(
                'Select Returned Products',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),

              ...groupedItems.map(
                (item) => buildReturnProduct(
                  inventory,
                  item,
                  selectedSale!,
                ),
              ),

              const SizedBox(height: 14),
              const Text(
                'Return Reason',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: reasonController,
                maxLines: 3,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: 'Enter reason for returning products',
                  hintStyle: const TextStyle(color: muted),
                  filled: true,
                  fillColor: panel,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),

              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: panel,
                  borderRadius: BorderRadius.circular(13),
                  border: Border.all(color: const Color(0xFF26364D)),
                ),
                child: Column(
                  children: [
                    detailRow(
                      'Total Return Units',
                      '$totalReturnUnits',
                    ),
                    detailRow(
                      'Total Refund',
                      money(returnTotal),
                      highlight: true,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton.icon(
                  onPressed: isSaving
                      ? null
                      : () => saveReturn(inventory),
                  icon: isSaving
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                          ),
                        )
                      : const Icon(Icons.check_circle_outline),
                  label: Text(
                    isSaving ? 'Saving Return...' : 'Save Sales Return',
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: green,
                    foregroundColor: Colors.black,
                  ),
                ),
              ),
            ],

            const SizedBox(height: 30),
            const Divider(color: Colors.white12),
            const SizedBox(height: 12),

            const Text(
              'Sales Return History',
              style: TextStyle(
                color: Colors.white,
                fontSize: 19,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),

            buildHistory(inventory),
          ],
        ),
      ),
    );
  }
}
