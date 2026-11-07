
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'notifications_data.dart';

// ============================================================
// PRODUCT
// ============================================================

class InventoryProduct {
  final String id;
  final String name;
  final String sku;
  final String category;
  final String barcode;
  final String description;
  final double costPrice;
  final double sellingPrice;
  final String unit;
  final int minimumStock;
  final String supplier;

  int quantity;

  // Branch ID -> quantity held at that branch.
  final Map<String, int> branchQuantities;

  InventoryProduct({
    required this.id,
    required this.name,
    required this.sku,
    required this.category,
    this.barcode = '',
    this.description = '',
    this.costPrice = 0,
    required this.sellingPrice,
    this.unit = 'Pieces',
    this.minimumStock = 5,
    this.supplier = '',
    required this.quantity,
    Map<String, int>? branchQuantities,
  }) : branchQuantities = branchQuantities ?? {};

  double get profitPerUnit => sellingPrice - costPrice;

  double get profitMargin {
    if (sellingPrice <= 0) return 0;
    return (profitPerUnit / sellingPrice) * 100;
  }
}

// ============================================================
// STOCK MOVEMENT
// ============================================================

class StockMovement {
  final String productId;
  final String productName;
  final String type;
  final int quantity;
  final DateTime date;
  final String branchId;

  StockMovement({
    required this.productId,
    required this.productName,
    required this.type,
    required this.quantity,
    required this.date,
    this.branchId = '1',
  });
}

// ============================================================
// BRANCH
// ============================================================

class InventoryBranch {
  final String id;
  final String name;
  final String code;
  final String city;
  final String address;
  final String phone;
  final String email;
  final String manager;
  bool active;

  InventoryBranch({
    required this.id,
    required this.name,
    required this.code,
    required this.city,
    required this.address,
    required this.phone,
    required this.email,
    required this.manager,
    required this.active,
  });
}

// ============================================================
// SALES MODELS
// ============================================================

class SalesCartItem {
  final String productId;
  final int quantity;
  final double unitPrice;

  SalesCartItem({
    required this.productId,
    required this.quantity,
    required this.unitPrice,
  });
}

class SaleLineItem {
  final String productId;
  final String productName;
  final String sku;
  final int quantity;
  final double unitPrice;
  final double costPrice;

  SaleLineItem({
    required this.productId,
    required this.productName,
    required this.sku,
    required this.quantity,
    required this.unitPrice,
    required this.costPrice,
  });

  double get total => quantity * unitPrice;

  double get profit => (unitPrice - costPrice) * quantity;
}

class SaleRecord {
  final String invoiceNumber;
  final String branchId;
  final String customerName;
  final String customerPhone;
  final String paymentMethod;
  final List<SaleLineItem> items;
  final double subtotal;
  final double discount;
  final double tax;
  final double total;
  final double amountPaid;
  final DateTime date;

  SaleRecord({
    required this.invoiceNumber,
    required this.branchId,
    required this.customerName,
    required this.customerPhone,
    required this.paymentMethod,
    required this.items,
    required this.subtotal,
    required this.discount,
    required this.tax,
    required this.total,
    required this.amountPaid,
    required this.date,
  });

  double get balanceDue =>
      (total - amountPaid).clamp(0, double.infinity).toDouble();

  double get change =>
      (amountPaid - total).clamp(0, double.infinity).toDouble();

  double get profit =>
      items.fold(0, (sum, item) => sum + item.profit);
}

// ============================================================
// INVENTORY DATA
// ============================================================

class InventoryData extends ChangeNotifier {
  // ----------------------------------------------------------
  // SHARED NOTIFICATION CENTER
  // ----------------------------------------------------------

  final NotificationCenter notificationCenter = NotificationCenter();

  InventoryData() {
    notificationCenter.addListener(notifyListeners);
  }

  @override
  void dispose() {
    notificationCenter.removeListener(notifyListeners);
    notificationCenter.dispose();
    super.dispose();
  }

  // ----------------------------------------------------------
  // SAMPLE PRODUCTS
  // ----------------------------------------------------------

  final List<InventoryProduct> _products = [
    InventoryProduct(
      id: '1',
      name: 'Wireless Mouse',
      sku: 'ELE-001',
      category: 'Electronics',
      sellingPrice: 850,
      costPrice: 600,
      quantity: 20,
      minimumStock: 5,
      branchQuantities: {'1': 20},
    ),
    InventoryProduct(
      id: '2',
      name: 'USB Keyboard',
      sku: 'ACC-002',
      category: 'Accessories',
      sellingPrice: 1200,
      costPrice: 900,
      quantity: 8,
      minimumStock: 5,
      branchQuantities: {'1': 8},
    ),
    InventoryProduct(
      id: '3',
      name: 'HDMI Cable',
      sku: 'ACC-003',
      category: 'Accessories',
      sellingPrice: 450,
      costPrice: 250,
      quantity: 5,
      minimumStock: 5,
      branchQuantities: {'1': 5},
    ),
    InventoryProduct(
      id: '4',
      name: 'Bluetooth Speaker',
      sku: 'ELE-004',
      category: 'Electronics',
      sellingPrice: 2500,
      costPrice: 1800,
      quantity: 35,
      minimumStock: 5,
      branchQuantities: {'1': 35},
    ),
  ];

  // ----------------------------------------------------------
  // STOCK MOVEMENTS
  // ----------------------------------------------------------

  final List<StockMovement> _movements = [];

  // ----------------------------------------------------------
  // BRANCHES
  // ----------------------------------------------------------

  final List<InventoryBranch> _branches = [
    InventoryBranch(
      id: '1',
      name: 'Main Branch',
      code: 'BR-001',
      city: 'Kathmandu',
      address: 'New Road, Kathmandu',
      phone: '9800000001',
      email: 'kathmandu@example.com',
      manager: 'Branch Manager',
      active: true,
    ),
    InventoryBranch(
      id: '2',
      name: 'Pokhara Branch',
      code: 'BR-002',
      city: 'Pokhara',
      address: 'Lakeside, Pokhara',
      phone: '9800000002',
      email: 'pokhara@example.com',
      manager: 'Branch Manager',
      active: true,
    ),
    InventoryBranch(
      id: '3',
      name: 'Lalitpur Branch',
      code: 'BR-003',
      city: 'Lalitpur',
      address: 'Jawalakhel, Lalitpur',
      phone: '9800000003',
      email: 'lalitpur@example.com',
      manager: 'Branch Manager',
      active: false,
    ),
  ];

  // ----------------------------------------------------------
  // SALES RECORDS
  // ----------------------------------------------------------

  final List<SaleRecord> _sales = [];

  // ----------------------------------------------------------
  // PUBLIC DATA
  // ----------------------------------------------------------

  List<InventoryProduct> get products =>
      List.unmodifiable(_products);

  List<StockMovement> get movements =>
      List.unmodifiable(_movements);

  List<InventoryBranch> get branches =>
      List.unmodifiable(_branches);

  List<SaleRecord> get sales =>
      List.unmodifiable(_sales);

  int get totalStock =>
      _products.fold(0, (total, product) => total + product.quantity);

  int get lowStockCount =>
      _products.where(
        (product) => product.quantity <= product.minimumStock,
      ).length;

  int get activeBranchCount =>
      _branches.where((branch) => branch.active).length;

  double get totalSales =>
      _sales.fold(0, (total, sale) => total + sale.total);

  double get totalOutstanding =>
      _sales.fold(0, (total, sale) => total + sale.balanceDue);

  double get totalSalesToday {
    final now = DateTime.now();

    return _sales
        .where((sale) =>
            sale.date.year == now.year &&
            sale.date.month == now.month &&
            sale.date.day == now.day)
        .fold(0, (total, sale) => total + sale.total);
  }

  int get salesCountToday {
    final now = DateTime.now();

    return _sales.where((sale) =>
        sale.date.year == now.year &&
        sale.date.month == now.month &&
        sale.date.day == now.day).length;
  }

  // ----------------------------------------------------------
  // FINDERS
  // ----------------------------------------------------------

  InventoryProduct? findProduct(String productId) {
    for (final product in _products) {
      if (product.id == productId) return product;
    }
    return null;
  }

  InventoryBranch? findBranch(String branchId) {
    for (final branch in _branches) {
      if (branch.id == branchId) return branch;
    }
    return null;
  }

  SaleRecord? findSale(String invoiceNumber) {
    for (final sale in _sales) {
      if (sale.invoiceNumber == invoiceNumber) return sale;
    }
    return null;
  }

  int getBranchQuantity(String productId, String branchId) {
    final product = findProduct(productId);
    if (product == null) return 0;

    return product.branchQuantities[branchId] ?? 0;
  }

  // ==========================================================
  // AUTOMATIC STOCK ALERTS
  // ==========================================================

  void _checkStockAlerts(
    InventoryProduct product,
    int previousQuantity,
  ) {
    if (previousQuantity > 0 && product.quantity == 0) {
      notificationCenter.add(
        title: 'Out of Stock',
        message: '${product.name} is now out of stock.',
        category: NotificationCategory.inventory,
        relatedId: product.id,
        action: 'product',
      );
    } else if (previousQuantity > product.minimumStock &&
        product.quantity <= product.minimumStock) {
      notificationCenter.add(
        title: 'Low Stock',
        message:
            '${product.name} has only ${product.quantity} ${product.unit} remaining.',
        category: NotificationCategory.inventory,
        relatedId: product.id,
        action: 'product',
      );
    }
  }

  // ==========================================================
  // PRODUCT MANAGEMENT
  // ==========================================================

  void addProduct({
    required String name,
    required String sku,
    required String category,
    required double sellingPrice,
    required int openingQuantity,
    double costPrice = 0,
    String barcode = '',
    String description = '',
    String unit = 'Pieces',
    int minimumStock = 5,
    String supplier = '',
    String initialBranchId = '1',
  }) {
    if (name.trim().isEmpty || sku.trim().isEmpty) {
      throw Exception('Product name and SKU are required.');
    }

    if (sellingPrice < 0 || costPrice < 0 || openingQuantity < 0) {
      throw Exception('Prices and quantity cannot be negative.');
    }

    final duplicate = _products.any(
      (product) => product.sku.toLowerCase() == sku.toLowerCase(),
    );

    if (duplicate) {
      throw Exception('A product with this SKU already exists.');
    }

    if (findBranch(initialBranchId) == null) {
      throw Exception('Selected branch was not found.');
    }

    final product = InventoryProduct(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      name: name.trim(),
      sku: sku.trim(),
      category: category,
      barcode: barcode,
      description: description,
      costPrice: costPrice,
      sellingPrice: sellingPrice,
      unit: unit,
      minimumStock: minimumStock,
      supplier: supplier,
      quantity: openingQuantity,
      branchQuantities: {initialBranchId: openingQuantity},
    );

    _products.add(product);

    if (openingQuantity > 0) {
      _movements.insert(
        0,
        StockMovement(
          productId: product.id,
          productName: product.name,
          type: 'Stock In',
          quantity: openingQuantity,
          date: DateTime.now(),
          branchId: initialBranchId,
        ),
      );
    }

    notifyListeners();
  }

  // ==========================================================
  // STOCK ALLOCATION
  // ==========================================================

  void allocateStockToBranch({
    required String productId,
    required String branchId,
    required int quantity,
  }) {
    if (quantity <= 0) {
      throw Exception('Quantity must be greater than zero.');
    }

    final product = findProduct(productId);

    if (product == null) throw Exception('Product not found.');

    final branch = findBranch(branchId);
    if (branch == null) throw Exception('Branch not found.');

    product.branchQuantities[branchId] =
        (product.branchQuantities[branchId] ?? 0) + quantity;

    product.quantity += quantity;

    _movements.insert(
      0,
      StockMovement(
        productId: product.id,
        productName: product.name,
        type: 'Stock In',
        quantity: quantity,
        date: DateTime.now(),
        branchId: branchId,
      ),
    );

    notificationCenter.add(
      title: 'Stock In',
      message:
          '$quantity ${product.unit} of ${product.name} allocated to ${branch.name}.',
      category: NotificationCategory.stock,
      relatedId: product.id,
      action: 'stock',
    );

    notifyListeners();
  }

  // ==========================================================
  // STOCK TRANSFER
  // ==========================================================

  void transferStock({
    required String productId,
    required String fromBranchId,
    required String toBranchId,
    required int quantity,
  }) {
    if (quantity <= 0) {
      throw Exception('Quantity must be greater than zero.');
    }

    if (fromBranchId == toBranchId) {
      throw Exception('Choose two different branches.');
    }

    final product = findProduct(productId);

    if (product == null) throw Exception('Product not found.');

    final fromBranch = findBranch(fromBranchId);
    final toBranch = findBranch(toBranchId);

    if (fromBranch == null || toBranch == null) {
      throw Exception('Branch not found.');
    }

    final sourceQuantity =
        product.branchQuantities[fromBranchId] ?? 0;

    if (sourceQuantity < quantity) {
      throw Exception('Not enough stock at the source branch.');
    }

    product.branchQuantities[fromBranchId] =
        sourceQuantity - quantity;

    product.branchQuantities[toBranchId] =
        (product.branchQuantities[toBranchId] ?? 0) + quantity;

    _movements.insertAll(0, [
      StockMovement(
        productId: product.id,
        productName: product.name,
        type: 'Transfer Out',
        quantity: quantity,
        date: DateTime.now(),
        branchId: fromBranchId,
      ),
      StockMovement(
        productId: product.id,
        productName: product.name,
        type: 'Transfer In',
        quantity: quantity,
        date: DateTime.now(),
        branchId: toBranchId,
      ),
    ]);

    notificationCenter.add(
      title: 'Branch Transfer',
      message:
          '$quantity ${product.unit} of ${product.name} transferred from ${fromBranch.name} to ${toBranch.name}.',
      category: NotificationCategory.stock,
      relatedId: product.id,
      action: 'stock',
    );

    notifyListeners();
  }

  // ==========================================================
  // STOCK IN / STOCK OUT
  // ==========================================================

  void recordStockMovement({
    required String productId,
    required String type,
    required int quantity,
    String branchId = '1',
  }) {
    if (quantity <= 0) {
      throw Exception('Quantity must be greater than zero.');
    }

    final product = findProduct(productId);

    if (product == null) throw Exception('Product not found.');

    final branch = findBranch(branchId);
    if (branch == null) throw Exception('Branch not found.');

    if (type != 'Stock In' && type != 'Stock Out') {
      throw Exception('Invalid stock movement type.');
    }

    final branchStock = product.branchQuantities[branchId] ?? 0;
    final previousQuantity = product.quantity;

    if (type == 'Stock Out' && branchStock < quantity) {
      throw Exception('Not enough stock available at this branch.');
    }

    if (type == 'Stock In') {
      product.branchQuantities[branchId] = branchStock + quantity;
      product.quantity += quantity;
    } else {
      product.branchQuantities[branchId] = branchStock - quantity;
      product.quantity -= quantity;
    }

    _movements.insert(
      0,
      StockMovement(
        productId: product.id,
        productName: product.name,
        type: type,
        quantity: quantity,
        date: DateTime.now(),
        branchId: branchId,
      ),
    );

    notificationCenter.add(
      title: type,
      message:
          '$quantity ${product.unit} of ${product.name} recorded at ${branch.name}.',
      category: NotificationCategory.stock,
      relatedId: product.id,
      action: 'stock',
    );

    _checkStockAlerts(product, previousQuantity);

    notifyListeners();
  }

  // ==========================================================
  // SALES PROCESSING
  // ==========================================================

  SaleRecord createSale({
    required String branchId,
    required List<SalesCartItem> items,
    String customerName = '',
    String customerPhone = '',
    String paymentMethod = 'Cash',
    double discount = 0,
    double tax = 0,
    double amountPaid = 0,
  }) {
    final branch = findBranch(branchId);

    if (branch == null || !branch.active) {
      throw Exception('Please select an active branch.');
    }

    if (items.isEmpty) {
      throw Exception('Add at least one product to the sale.');
    }

    if (discount < 0 || tax < 0 || amountPaid < 0) {
      throw Exception('Discount, tax and payment cannot be negative.');
    }

    // Validate and combine quantities for repeated products.
    final requiredQuantities = <String, int>{};

    for (final item in items) {
      if (item.quantity <= 0 || item.unitPrice < 0) {
        throw Exception('Invalid product quantity or price.');
      }

      requiredQuantities[item.productId] =
          (requiredQuantities[item.productId] ?? 0) + item.quantity;
    }

    // Check all products and stock before changing anything.
    for (final entry in requiredQuantities.entries) {
      final product = findProduct(entry.key);

      if (product == null) {
        throw Exception('A product in this sale was not found.');
      }

      final available = product.branchQuantities[branchId] ?? 0;

      if (available < entry.value) {
        throw Exception(
          'Not enough ${product.name} stock at ${branch.name}. '
          'Available: $available',
        );
      }
    }

    final saleItems = <SaleLineItem>[];

    for (final item in items) {
      final product = findProduct(item.productId)!;

      saleItems.add(
        SaleLineItem(
          productId: product.id,
          productName: product.name,
          sku: product.sku,
          quantity: item.quantity,
          unitPrice: item.unitPrice,
          costPrice: product.costPrice,
        ),
      );
    }

    final subtotal =
        saleItems.fold(0.0, (sum, item) => sum + item.total);

    if (discount > subtotal) {
      throw Exception('Discount cannot exceed the subtotal.');
    }

    final total = subtotal - discount + tax;

    final sale = SaleRecord(
      invoiceNumber:
          'INV-${DateTime.now().microsecondsSinceEpoch}',
      branchId: branchId,
      customerName: customerName.trim(),
      customerPhone: customerPhone.trim(),
      paymentMethod: paymentMethod,
      items: List.unmodifiable(saleItems),
      subtotal: subtotal,
      discount: discount,
      tax: tax,
      total: total,
      amountPaid: amountPaid,
      date: DateTime.now(),
    );

    // Deduct stock once per product.
    for (final entry in requiredQuantities.entries) {
      final product = findProduct(entry.key)!;
      final quantity = entry.value;
      final previousQuantity = product.quantity;

      product.branchQuantities[branchId] =
          (product.branchQuantities[branchId] ?? 0) - quantity;

      product.quantity -= quantity;

      _movements.insert(
        0,
        StockMovement(
          productId: product.id,
          productName: product.name,
          type: 'Stock Out',
          quantity: quantity,
          date: sale.date,
          branchId: branchId,
        ),
      );

      notificationCenter.add(
        title: 'Stock Out',
        message:
            '$quantity ${product.unit} of ${product.name} sold at ${branch.name}.',
        category: NotificationCategory.stock,
        relatedId: product.id,
        action: 'stock',
      );

      _checkStockAlerts(product, previousQuantity);
    }

    _sales.insert(0, sale);

    // New sale notification.
    notificationCenter.add(
      title: 'New Sale',
      message:
          'Sale ${sale.invoiceNumber} completed at ${branch.name}. Total: ${sale.total.toStringAsFixed(2)}.',
      category: NotificationCategory.sales,
      relatedId: sale.invoiceNumber,
      action: 'sale',
    );

    // Pending payment notification.
    if (sale.balanceDue > 0) {
      notificationCenter.add(
        title: 'Payment Due',
        message:
            'Payment of ${sale.balanceDue.toStringAsFixed(2)} is pending for invoice ${sale.invoiceNumber}.',
        category: NotificationCategory.sales,
        relatedId: sale.invoiceNumber,
        action: 'sale',
      );
    }

    notifyListeners();

    return sale;
  }

  // ==========================================================
  // BRANCH MANAGEMENT
  // ==========================================================

  void addBranch({
    required String name,
    required String code,
    required String city,
    required String address,
    required String phone,
    required String email,
    required String manager,
  }) {
    final duplicate = _branches.any(
      (branch) => branch.code.toLowerCase() == code.toLowerCase(),
    );

    if (duplicate) {
      throw Exception('This branch code already exists.');
    }

    _branches.add(
      InventoryBranch(
        id: DateTime.now().microsecondsSinceEpoch.toString(),
        name: name,
        code: code,
        city: city,
        address: address,
        phone: phone,
        email: email,
        manager: manager,
        active: true,
      ),
    );

    notifyListeners();
  }

  void updateBranch({
    required String id,
    required String name,
    required String code,
    required String city,
    required String address,
    required String phone,
    required String email,
    required String manager,
  }) {
    final index = _branches.indexWhere((branch) => branch.id == id);

    if (index == -1) throw Exception('Branch not found.');

    final duplicate = _branches.any(
      (branch) =>
          branch.code.toLowerCase() == code.toLowerCase() &&
          branch.id != id,
    );

    if (duplicate) {
      throw Exception('This branch code already exists.');
    }

    final oldBranch = _branches[index];

    _branches[index] = InventoryBranch(
      id: oldBranch.id,
      name: name,
      code: code,
      city: city,
      address: address,
      phone: phone,
      email: email,
      manager: manager,
      active: oldBranch.active,
    );

    notifyListeners();
  }

  void toggleBranchStatus(String id) {
    final branch = _branches.firstWhere(
      (branch) => branch.id == id,
      orElse: () => throw Exception('Branch not found.'),
    );

    branch.active = !branch.active;
    notifyListeners();
  }
}

// ============================================================
// SHARED INVENTORY PROVIDER
// ============================================================

final inventoryProvider =
    ChangeNotifierProvider<InventoryData>((ref) {
  return InventoryData();
});
