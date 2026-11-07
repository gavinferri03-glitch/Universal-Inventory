
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'inventory_data.dart';
import 'inventory_models.dart';
import 'inventory_invoice_pdf.dart';
import 'list_tools.dart';

class SalesHistoryScreen extends ConsumerStatefulWidget {
  const SalesHistoryScreen({super.key});

  @override
  ConsumerState<SalesHistoryScreen> createState() =>
      _SalesHistoryScreenState();
}

class _SalesHistoryScreenState
    extends ConsumerState<SalesHistoryScreen> {
  static const Color background = Color(0xFF080B12);
  static const Color panel = Color(0xFF121D2D);
  static const Color blue = Color(0xFF5798FF);
  static const Color green = Color(0xFF45C99A);
  static const Color orange = Color(0xFFFFB454);
  static const Color muted = Color(0xFF91A4BE);

  final TextEditingController searchController =
      TextEditingController();

  String searchText = '';
  String selectedSort = 'newest';
  String selectedFilter = 'all';

  final List<String> paymentMethods = [
    'Cash',
    'QR',
    'Card',
    'Bank Transfer',
    'Credit',
  ];

  final Map<String, String> sortOptions = {
    'newest': 'Newest first',
    'oldest': 'Oldest first',
    'total_high': 'Highest sale value',
    'total_low': 'Lowest sale value',
    'invoice_az': 'Invoice A–Z',
    'invoice_za': 'Invoice Z–A',
  };

  final Map<String, String> filterOptions = {
    'all': 'All sales',
    'paid': 'Fully paid',
    'partial': 'Partially paid',
    'unpaid': 'Unpaid',
  };

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  String money(double value) =>
      'Rs. ${value.toStringAsFixed(2)}';

  String paymentStatus(SaleRecord sale) {
    if (sale.amountPaid >= sale.total) return 'Paid';
    if (sale.amountPaid > 0) return 'Partially Paid';
    return 'Unpaid';
  }

  Color statusColor(SaleRecord sale) {
    if (sale.amountPaid >= sale.total) return green;
    if (sale.amountPaid > 0) return orange;
    return Colors.redAccent;
  }

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

  Future<void> runPdf(Future<void> Function() action) async {
    try {
      await action();
    } catch (error) {
      showMessage(
        'PDF operation failed: ${error.toString()}',
        error: true,
      );
    }
  }

  List<SaleRecord> getSales(InventoryData inventory) {
    final query = searchText.trim().toLowerCase();

    final result = inventory.sales.where((sale) {
      final branch = inventory.findBranch(sale.branchId);

      final matchesSearch = query.isEmpty ||
          sale.invoiceNumber.toLowerCase().contains(query) ||
          sale.customerName.toLowerCase().contains(query) ||
          sale.customerPhone.toLowerCase().contains(query) ||
          sale.paymentMethod.toLowerCase().contains(query) ||
          (branch?.name.toLowerCase().contains(query) ?? false);

      final status = paymentStatus(sale);

      final matchesFilter = selectedFilter == 'all' ||
          (selectedFilter == 'paid' && status == 'Paid') ||
          (selectedFilter == 'partial' &&
              status == 'Partially Paid') ||
          (selectedFilter == 'unpaid' && status == 'Unpaid');

      return matchesSearch && matchesFilter;
    }).toList();

    switch (selectedSort) {
      case 'newest':
        result.sort((a, b) => b.date.compareTo(a.date));
        break;
      case 'oldest':
        result.sort((a, b) => a.date.compareTo(b.date));
        break;
      case 'total_high':
        result.sort((a, b) => b.total.compareTo(a.total));
        break;
      case 'total_low':
        result.sort((a, b) => a.total.compareTo(b.total));
        break;
      case 'invoice_az':
        result.sort(
          (a, b) => a.invoiceNumber.compareTo(b.invoiceNumber),
        );
        break;
      case 'invoice_za':
        result.sort(
          (a, b) => b.invoiceNumber.compareTo(a.invoiceNumber),
        );
        break;
    }

    return result;
  }

  // ============================================================
  // EDIT PAYMENT
  // ============================================================

  Future<void> editPayment(SaleRecord sale) async {
    final amountController = TextEditingController(
      text: sale.amountPaid.toStringAsFixed(2),
    );

    String selectedMethod = sale.paymentMethod;

    if (!paymentMethods.contains(selectedMethod)) {
      paymentMethods.add(selectedMethod);
    }

    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, updateDialog) {
            return AlertDialog(
              backgroundColor: panel,
              title: const Text(
                'Edit Payment',
                style: TextStyle(color: Colors.white),
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Invoice: ${sale.invoiceNumber}',
                      style: const TextStyle(color: blue),
                    ),
                    const SizedBox(height: 15),
                    Text(
                      'Invoice Total: ${money(sale.total)}',
                      style: const TextStyle(color: Colors.white),
                    ),
                    const SizedBox(height: 15),
                    TextField(
                      controller: amountController,
                      keyboardType:
                          const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      style: const TextStyle(color: Colors.white),
                      decoration: const InputDecoration(
                        labelText: 'Total Amount Received',
                        prefixText: 'Rs. ',
                      ),
                    ),
                    const SizedBox(height: 15),
                    DropdownButtonFormField<String>(
                      value: selectedMethod,
                      dropdownColor: panel,
                      decoration: const InputDecoration(
                        labelText: 'Payment Method',
                      ),
                      items: paymentMethods.map((method) {
                        return DropdownMenuItem(
                          value: method,
                          child: Text(method),
                        );
                      }).toList(),
                      onChanged: (value) {
                        if (value != null) {
                          updateDialog(() {
                            selectedMethod = value;
                          });
                        }
                      },
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
                    final amount = double.tryParse(
                      amountController.text.trim(),
                    );

                    if (amount == null || amount < 0) {
                      showMessage(
                        'Enter a valid payment amount.',
                        error: true,
                      );
                      return;
                    }

                    try {
                      ref.read(inventoryProvider).updateSalePayment(
                            invoiceNumber: sale.invoiceNumber,
                            amountPaid: amount,
                            paymentMethod: selectedMethod,
                          );

                      Navigator.pop(dialogContext);
                      showMessage('Payment updated successfully.');
                    } catch (error) {
                      showMessage(
                        error.toString().replaceFirst(
                              'Exception: ',
                              '',
                            ),
                        error: true,
                      );
                    }
                  },
                  child: const Text('Save Payment'),
                ),
              ],
            );
          },
        );
      },
    );

    amountController.dispose();
  }

  // ============================================================
  // SALES INVOICE DETAILS
  // ============================================================

  void showSaleDetails(SaleRecord sale) {
    final inventory = ref.read(inventoryProvider);
    final branch =
        inventory.findBranch(sale.branchId)?.name ?? 'Unknown branch';

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
                    'Sale Details',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 21,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    sale.invoiceNumber,
                    style: const TextStyle(
                      color: blue,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Divider(color: Colors.white12, height: 28),
                  _detailRow('Date', dateText(sale.date)),
                  _detailRow('Branch', branch),
                  _detailRow(
                    'Customer',
                    sale.customerName.isEmpty
                        ? 'Walk-in Customer'
                        : sale.customerName,
                  ),
                  _detailRow('Phone', sale.customerPhone),
                  const Divider(color: Colors.white12, height: 28),
                  const Text(
                    'Products',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  ...sale.items.map((item) {
                    return Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: background,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.productName,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            'SKU: ${item.sku}',
                            style: const TextStyle(
                              color: muted,
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            '${item.quantity} × ${money(item.unitPrice)}'
                            ' = ${money(item.total)}',
                            style: const TextStyle(color: blue),
                          ),
                        ],
                      ),
                    );
                  }),
                  const Divider(color: Colors.white12, height: 28),
                  _amountRow('Subtotal', sale.subtotal),
                  _amountRow('Discount', -sale.discount),
                  _amountRow('Tax', sale.tax),
                  _amountRow('Invoice Total', sale.total, bold: true),
                  _amountRow('Amount Received', sale.amountPaid),
                  _amountRow(
                    'Balance Due',
                    sale.balanceDue,
                    valueColor:
                        sale.balanceDue > 0 ? orange : green,
                  ),
                  if (sale.change > 0)
                    _amountRow(
                      'Change',
                      sale.change,
                      valueColor: green,
                    ),
                  const Divider(color: Colors.white12, height: 28),
                  _detailRow('Payment Method', sale.paymentMethod),
                  _detailRow(
                    'Payment Status',
                    paymentStatus(sale),
                    valueColor: statusColor(sale),
                  ),
                  const SizedBox(height: 18),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            runPdf(() =>
                                InventoryInvoicePdf.printSalesInvoice(
                                  sale,
                                  branchName: branch,
                                ));
                          },
                          icon: const Icon(Icons.print),
                          label: const Text('Print PDF'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: blue,
                            foregroundColor: Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            runPdf(() =>
                                InventoryInvoicePdf.shareSalesInvoice(
                                  sale,
                                  branchName: branch,
                                ));
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
                  const SizedBox(height: 10),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () {
                        Navigator.pop(sheetContext);
                        editPayment(sale);
                      },
                      icon: const Icon(Icons.edit),
                      label: const Text('Edit Payment'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // ============================================================
  // CUSTOMER SALES RETURN DETAILS
  // ============================================================

  void showSalesReturnDetails(SalesReturnRecord record) {
    final inventory = ref.read(inventoryProvider);
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
                    'Customer Sales Return',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 21,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    record.returnNumber,
                    style: const TextStyle(
                      color: orange,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Divider(color: Colors.white12, height: 28),
                  _detailRow('Date', dateText(record.date)),
                  _detailRow('Customer', record.customerName),
                  _detailRow(
                    'Original Invoice',
                    record.originalInvoiceNumber,
                  ),
                  _detailRow('Branch', branch),
                  _detailRow('Reason', record.reason),
                  const Divider(color: Colors.white12, height: 28),
                  const Text(
                    'Returned Products',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  ...record.items.map((item) {
                    return Container(
                      margin: const EdgeInsets.only(bottom: 9),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: background,
                        borderRadius: BorderRadius.circular(10),
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
                          Text(
                            'SKU: ${item.sku}',
                            style: const TextStyle(
                              color: muted,
                              fontSize: 12,
                            ),
                          ),
                          Text(
                            '${item.quantity} × ${money(item.unitPrice)}'
                            ' = ${money(item.total)}',
                            style: const TextStyle(color: orange),
                          ),
                        ],
                      ),
                    );
                  }),
                  const Divider(color: Colors.white12, height: 28),
                  _amountRow(
                    'Total Returned',
                    record.total,
                    bold: true,
                    valueColor: orange,
                  ),
                  const SizedBox(height: 18),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            runPdf(() =>
                                InventoryInvoicePdf.printSalesReturn(
                                  record,
                                  branchName: branch,
                                ));
                          },
                          icon: const Icon(Icons.print),
                          label: const Text('Print PDF'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: blue,
                            foregroundColor: Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            runPdf(() =>
                                InventoryInvoicePdf.shareSalesReturn(
                                  record,
                                  branchName: branch,
                                ));
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

  // ============================================================
  // REUSABLE DISPLAY WIDGETS
  // ============================================================

  String dateText(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year} '
        '${date.hour.toString().padLeft(2, '0')}:'
        '${date.minute.toString().padLeft(2, '0')}';
  }

  Widget _detailRow(
    String label,
    String value, {
    Color? valueColor,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 7),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 115,
            child: Text(
              label,
              style: const TextStyle(
                color: muted,
                fontSize: 13,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value.isEmpty ? 'Not provided' : value,
              style: TextStyle(
                color: valueColor ?? Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _amountRow(
    String label,
    double value, {
    bool bold = false,
    Color? valueColor,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              color: bold ? Colors.white : muted,
              fontWeight:
                  bold ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          Text(
            money(value),
            style: TextStyle(
              color: valueColor ??
                  (bold ? Colors.white : muted),
              fontWeight:
                  bold ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }

  Widget saleCard(SaleRecord sale, InventoryData inventory) {
    final branch = inventory.findBranch(sale.branchId);

    return Card(
      color: panel,
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        onTap: () => showSaleDetails(sale),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 9,
        ),
        title: Text(
          sale.invoiceNumber,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 7),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                sale.customerName.isEmpty
                    ? 'Walk-in Customer'
                    : sale.customerName,
                style: const TextStyle(color: muted),
              ),
              const SizedBox(height: 4),
              Text(
                '${sale.items.length} product line(s) • '
                '${branch?.name ?? 'Unknown branch'}',
                style: const TextStyle(
                  color: muted,
                  fontSize: 11,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                paymentStatus(sale),
                style: TextStyle(
                  color: statusColor(sale),
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              money(sale.total),
              style: const TextStyle(
                color: blue,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Icon(Icons.chevron_right, color: muted),
          ],
        ),
      ),
    );
  }

  Widget salesReturnCard(SalesReturnRecord record) {
    return Card(
      color: panel,
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        onTap: () => showSalesReturnDetails(record),
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
          '${record.customerName} • '
          'Original: ${record.originalInvoiceNumber}',
          style: const TextStyle(color: muted, fontSize: 12),
        ),
        trailing: Text(
          money(record.total),
          style: const TextStyle(
            color: orange,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget summaryCard(
    String title,
    String value,
    IconData icon,
  ) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: panel,
          borderRadius: BorderRadius.circular(13),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: blue, size: 21),
            const SizedBox(height: 9),
            Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 17,
                fontWeight: FontWeight.bold,
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
      ),
    );
  }

  // ============================================================
  // MAIN SCREEN
  // ============================================================

  @override
  Widget build(BuildContext context) {
    final inventory = ref.watch(inventoryProvider);
    final sales = getSales(inventory);

    final paidCount = inventory.sales
        .where((sale) => paymentStatus(sale) == 'Paid')
        .length;

    final unpaidCount = inventory.sales
        .where((sale) => paymentStatus(sale) == 'Unpaid')
        .length;

    final salesReturns = List<SalesReturnRecord>.from(
      inventory.salesReturns,
    )..sort((a, b) => b.date.compareTo(a.date));

    return Scaffold(
      backgroundColor: background,
      appBar: AppBar(
        backgroundColor: background,
        foregroundColor: Colors.white,
        title: const Text('Sales History'),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  summaryCard(
                    'Total Sales',
                    inventory.sales.length.toString(),
                    Icons.receipt_long,
                  ),
                  const SizedBox(width: 9),
                  summaryCard(
                    'Paid',
                    paidCount.toString(),
                    Icons.check_circle_outline,
                  ),
                  const SizedBox(width: 9),
                  summaryCard(
                    'Unpaid',
                    unpaidCount.toString(),
                    Icons.pending_actions,
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: InventoryListToolbar(
                searchController: searchController,
                searchHint: 'Search invoice, customer or branch...',
                onSearchChanged: (value) {
                  setState(() => searchText = value);
                },
                sortOptions: sortOptions,
                selectedSort: selectedSort,
                onSortChanged: (value) {
                  setState(() => selectedSort = value);
                },
                filterOptions: filterOptions,
                selectedFilter: selectedFilter,
                onFilterChanged: (value) {
                  setState(() => selectedFilter = value);
                },
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
                children: [
                  const Text(
                    'Sales Invoices',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  if (sales.isEmpty)
                    const Padding(
                      padding: EdgeInsets.all(12),
                      child: Text(
                        'No sales records found.',
                        style: TextStyle(color: muted),
                      ),
                    ),
                  ...sales.map((sale) => saleCard(sale, inventory)),
                  const SizedBox(height: 22),
                  Row(
                    children: [
                      const Expanded(
                        child: Text(
                          'Customer Sales Returns',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Text(
                        '${salesReturns.length} records',
                        style: const TextStyle(
                          color: muted,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  if (salesReturns.isEmpty)
                    const Padding(
                      padding: EdgeInsets.all(12),
                      child: Text(
                        'No customer sales returns recorded yet.',
                        style: TextStyle(color: muted),
                      ),
                    ),
                  ...salesReturns.map(salesReturnCard),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
