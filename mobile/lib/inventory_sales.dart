part of 'inventory_data.dart';

extension InventorySales on InventoryData {
  // ==========================================================
  // SALES SUMMARY
  // ==========================================================

  double get totalSalesToday => todaySales;

  int get salesCountToday => todaySalesCount;

  // ==========================================================
  // FIND SALE
  // ==========================================================

  SaleRecord? findSale(String invoiceNumber) {
    return getSaleByInvoice(invoiceNumber);
  }

  // ==========================================================
  // CREATE SALE
  // ==========================================================

  SaleRecord createSale({
    required String branchId,
    required List<SalesCartItem> items,
    String customerName = '',
    String customerPhone = '',
    required String paymentMethod,
    double discount = 0,
    double tax = 0,
    double amountPaid = 0,
  }) {
    if (items.isEmpty) {
      throw Exception('The sales cart is empty.');
    }

    if (getBranchById(branchId) == null) {
      throw Exception('Branch not found.');
    }

    if (discount < 0 || tax < 0 || amountPaid < 0) {
      throw Exception('Amounts cannot be negative.');
    }

    final saleItems = <SaleLineItem>[];
    double subtotal = 0;

    // Validate everything before changing stock.
    for (final cartItem in items) {
      if (cartItem.quantity <= 0) {
        throw Exception('Quantity must be greater than zero.');
      }

      if (cartItem.unitPrice < 0) {
        throw Exception('Price cannot be negative.');
      }

      final product = getProductById(cartItem.productId);

      if (product == null) {
        throw Exception('A product in the cart was not found.');
      }

      final available =
          product.branchQuantities[branchId] ?? 0;

      if (available < cartItem.quantity) {
        throw Exception('Insufficient stock for ${product.name}.');
      }

      subtotal += cartItem.quantity * cartItem.unitPrice;

      saleItems.add(
        SaleLineItem(
          productId: product.id,
          productName: product.name,
          sku: product.sku,
          quantity: cartItem.quantity,
          unitPrice: cartItem.unitPrice,
          costPrice: product.costPrice,
        ),
      );
    }

    final total = subtotal - discount + tax;

    if (total < 0) {
      throw Exception('Sale total cannot be negative.');
    }

    // Deduct stock only after validation succeeds.
    for (final item in saleItems) {
      final product = getProductById(item.productId)!;

      product.branchQuantities[branchId] =
          (product.branchQuantities[branchId] ?? 0) -
              item.quantity;

      product.quantity =
          product.branchQuantities.values.fold<int>(
        0,
        (sum, value) => sum + value,
      );

      _recordMovement(
        product: product,
        type: 'Sale',
        quantity: item.quantity,
        branchId: branchId,
      );
    }

    final sale = SaleRecord(
      invoiceNumber: generateInvoiceCode(),
      branchId: branchId,
      customerName: customerName,
      customerPhone: customerPhone,
      paymentMethod: paymentMethod,
      items: saleItems,
      subtotal: subtotal,
      discount: discount,
      tax: tax,
      total: total,
      amountPaid: amountPaid > total ? total : amountPaid,
      date: DateTime.now(),
    );

    _sales.add(sale);
    notifyListeners();

    return sale;
  }

  // ==========================================================
  // UPDATE SALE PAYMENT
  // ==========================================================

  void updateSalePayment({
    required String invoiceNumber,
    required double amountPaid,
    required String paymentMethod,
  }) {
    if (amountPaid < 0) {
      throw Exception('Payment cannot be negative.');
    }

    final index = _sales.indexWhere(
      (sale) => sale.invoiceNumber == invoiceNumber,
    );

    if (index == -1) {
      throw Exception('Sale record not found.');
    }

    final oldSale = _sales[index];

    final updatedAmount =
        amountPaid > oldSale.total ? oldSale.total : amountPaid;

    _sales[index] = SaleRecord(
      invoiceNumber: oldSale.invoiceNumber,
      branchId: oldSale.branchId,
      customerName: oldSale.customerName,
      customerPhone: oldSale.customerPhone,
      paymentMethod: paymentMethod,
      items: oldSale.items,
      subtotal: oldSale.subtotal,
      discount: oldSale.discount,
      tax: oldSale.tax,
      total: oldSale.total,
      amountPaid: updatedAmount,
      date: oldSale.date,
    );

    notifyListeners();
  }
}