import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'inventory_data.dart';
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
  static const Color muted = Color(0xFF91A4BE);

  final TextEditingController searchController =
      TextEditingController();

  String searchText = '';
  String selectedSort = 'newest';
  String selectedFilter = 'all';

  String paymentMethod = 'Cash';

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

  final List<String> paymentMethods = [
    'Cash',
    'QR',
    'Card',
    'Bank Transfer',
    'Credit',
  ];

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  String money(double value) =>
      'Rs. ${value.toStringAsFixed(2)}';

  String paymentStatus(SaleRecord sale) {
    if (sale.amountPaid >= sale.total) {
      return 'Paid';
    }

    if (sale.amountPaid > 0) {
      return 'Partially Paid';
    }

    return 'Unpaid';
  }

  Color statusColor(SaleRecord sale) {
    if (sale.amountPaid >= sale.total) {
      return Colors.greenAccent;
    }

    if (sale.amountPaid > 0) {
      return Colors.orangeAccent;
    }

    return Colors.redAccent;
  }

  List<SaleRecord> getSales(InventoryData inventory) {
    final query = searchText.trim().toLowerCase();

    final result = inventory.sales.where((sale) {
      final branch = inventory.findBranch(sale.branchId);

      final matchesSearch =
          query.isEmpty ||
          sale.invoiceNumber.toLowerCase().contains(query) ||
          sale.customerName.toLowerCase().contains(query) ||
          sale.customerPhone.toLowerCase().contains(query) ||
          sale.paymentMethod.toLowerCase().contains(query) ||
          (branch?.name.toLowerCase().contains(query) ?? false);

      final status = paymentStatus(sale);

      bool matchesFilter = true;

      switch (selectedFilter) {
        case 'paid':
          matchesFilter = status == 'Paid';
          break;
        case 'partial':
          matchesFilter = status == 'Partially Paid';
          break;
        case 'unpaid':
          matchesFilter = status == 'Unpaid';
          break;
      }

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

  // ============================================================
  // EDIT PAYMENT ONLY
  // ============================================================

  Future<void> editPayment(SaleRecord sale) async {
    final amountController = TextEditingController(
      text: sale.amountPaid.toStringAsFixed(2),
    );

    String selectedMethod = sale.paymentMethod;

    if (!paymentMethods.contains(selectedMethod)) {
      paymentMethods.add(selectedMethod);
    }

    await showDialog(
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
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Invoice: ${sale.invoiceNumber}',
                      style: const TextStyle(
                        color: blue,
                        fontWeight: FontWeight.bold,
                      ),
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

                    const SizedBox(height: 15),

                    const Text(
                      'Only payment information can be changed. '
                      'Invoice products, quantities, prices, discount '
                      'and tax will remain unchanged.',
                      style: TextStyle(
                        color: muted,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () =>
                      Navigator.pop(dialogContext),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: blue,
                    foregroundColor: Colors.white,
                  ),
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
                    } catch (e) {
                      showMessage(
                        e.toString().replaceFirst(
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
  // SALE DETAILS
  // ============================================================

  void showSaleDetails(SaleRecord sale) {
    final inventory = ref.read(inventoryProvider);
    final branch = inventory.findBranch(sale.branchId);

    showModalBottomSheet(
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
                  Center(
                    child: Container(
                      width: 42,
                      height: 4,
                      decoration: BoxDecoration(
                        color: muted,
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

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

                  const Divider(
                    color: Colors.white12,
                    height: 28,
                  ),

                  _detailRow(
                    'Date',
                    '${sale.date.day}/${sale.date.month}/${sale.date.year}',
                  ),

                  _detailRow(
                    'Time',
                    '${sale.date.hour.toString().padLeft(2, '0')}:'
                    '${sale.date.minute.toString().padLeft(2, '0')}',
                  ),

                  _detailRow(
                    'Branch',
                    branch?.name ?? 'Unknown branch',
                  ),

                  _detailRow(
                    'Customer',
                    sale.customerName.isEmpty
                        ? 'Walk-in Customer'
                        : sale.customerName,
                  ),

                  _detailRow(
                    'Phone',
                    sale.customerPhone,
                  ),

                  const Divider(
                    color: Colors.white12,
                    height: 28,
                  ),

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
                          const SizedBox(height: 5),
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
                            style: const TextStyle(
                              color: blue,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    );
                  }),

                  const Divider(
                    color: Colors.white12,
                    height: 28,
                  ),

                  _amountRow('Subtotal', sale.subtotal),
                  _amountRow('Discount', -sale.discount),
                  _amountRow('Tax', sale.tax),

                  const Divider(color: Colors.white12),

                  _amountRow(
                    'Invoice Total',
                    sale.total,
                    bold: true,
                  ),

                  _amountRow(
                    'Amount Received',
                    sale.amountPaid,
                  ),

                  _amountRow(
                    'Balance Due',
                    sale.balanceDue,
                    valueColor: sale.balanceDue > 0
                        ? Colors.orangeAccent
                        : Colors.greenAccent,
                  ),

                  if (sale.change > 0)
                    _amountRow(
                      'Change',
                      sale.change,
                      valueColor: Colors.greenAccent,
                    ),

                  const Divider(
                    color: Colors.white12,
                    height: 28,
                  ),

                  _detailRow(
                    'Payment Method',
                    sale.paymentMethod,
                  ),

                  _detailRow(
                    'Payment Status',
                    paymentStatus(sale),
                    valueColor: statusColor(sale),
                  ),

                  const SizedBox(height: 20),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () => editPayment(sale),
                      icon: const Icon(Icons.edit),
                      label: const Text('Edit Payment'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: blue,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.all(14),
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),
                ],
              ),
            ),
          ),
        );
      },
    );
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

  // ============================================================
  // SALE CARD
  // ============================================================

  Widget saleCard(SaleRecord sale, InventoryData inventory) {
    final branch = inventory.findBranch(sale.branchId);

    return Card(
      color: panel,
      margin: const EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(
          color: Colors.white.withOpacity(0.05),
        ),
      ),
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
            const SizedBox(height: 5),
            const Icon(
              Icons.chevron_right,
              color: muted,
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // SUMMARY
  // ============================================================

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
              child: sales.isEmpty
                  ? const Center(
                      child: Text(
                        'No sales records found.',
                        style: TextStyle(color: muted),
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.fromLTRB(
                        16,
                        0,
                        16,
                        20,
                      ),
                      itemCount: sales.length,
                      itemBuilder: (context, index) {
                        return saleCard(
                          sales[index],
                          inventory,
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}