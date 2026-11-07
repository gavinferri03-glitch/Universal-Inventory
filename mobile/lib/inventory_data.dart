
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'notifications_data.dart';

// ============================================================
// PRODUCT MODEL
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
// CATEGORY MODEL
// ============================================================

class InventoryCategory {
  final String id;
  final String name;
  final String code;
  final String description;
  bool active;

  InventoryCategory({
    required this.id,
    required this.name,
    required this.code,
    required this.description,
    required this.active,
  });
}

// ============================================================
// STOCK MOVEMENT MODEL
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
// BRANCH MODEL
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
      items.fold(0.0, (sum, item) => sum + item.profit);
}

// ============================================================
// INVENTORY DATA
// ============================================================

class InventoryData extends ChangeNotifier {
  // ----------------------------------------------------------
  // NOTIFICATIONS
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
  // CATEGORIES
  // ----------------------------------------------------------

  final List<InventoryCategory> _categories = [
    InventoryCategory(
      id: 'CAT-ID-001',
      name: 'Electronics',
      code: 'CAT-001',
      description: 'Electronic devices and equipment',
      active: true,
    ),
    InventoryCategory(
      id: 'CAT-ID-002',
      name: 'Accessories',
      code: 'CAT-002',
      description: 'Computer and mobile accessories',
      active: true,
    ),
    InventoryCategory(
      id: 'CAT-ID-003',
      name: 'Furniture',
      code: 'CAT-003',
      description: 'Office and home furniture',
      active: true,
    ),
    InventoryCategory(
      id: 'CAT-ID-004',
      name: 'Other',
      code: 'CAT-004',
      description: 'Miscellaneous products',
      active: true,
    ),
  ];

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

  // ==========================================================
  // PUBLIC DATA
  // ==========================================================

  List<InventoryProduct> get products =>
      List.unmodifiable(_products);

  List<InventoryCategory> get categories =>
      List.unmodifiable(_categories);

  List<StockMovement> get movements =>
      List.unmodifiable(_movements);

  List<InventoryBranch> get branches =>
      List.unmodifiable(_branches);

  List<SaleRecord> get sales =>
      List.unmodifiable(_sales);

  int get totalStock =>
      _products.fold(0, (total, product) => total + product.quantity);

  int get lowStockCount => _products
      .where((product) => product.quantity <= product.minimumStock)
      .length;

  int get activeBranchCount =>
      _branches.where((branch) => branch.active).length;

  int get activeCategoryCount =>
      _categories.where((category) => category.active).length;

  double get totalSales =>
      _sales.fold(0.0, (total, sale) => total + sale.total);

  double get totalOutstanding =>
      _sales.fold(0.0, (total, sale) => total + sale.balanceDue);

  double get totalSalesToday {
    final now = DateTime.now();

    return _sales
        .where((sale) =>
            sale.date.year == now.year &&
            sale.date.month == now.month &&
            sale.date.day == now.day)
        .fold(0.0, (total, sale) => total + sale.total);
  }

  int get salesCountToday {
    final now = DateTime.now();

    return _sales.where((sale) =>
        sale.date.year == now.year &&
        sale.date.month == now.month &&
        sale.date.day == now.day).length;
  }

  // ==========================================================
  // FINDERS
  // ==========================================================

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

  InventoryCategory? findCategory(String categoryId) {
    for (final category in _categories) {
      if (category.id == categoryId) return category;
    }
    return null;
  }

  InventoryCategory? findCategoryByName(String name) {
    final cleanName = name.trim().toLowerCase();

    for (final category in _categories) {
      if (category.name.trim().toLowerCase() == cleanName) {
        return category;
      }
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

  int getCategoryProductCount(String categoryId) {
    final category = findCategory(categoryId);
    if (category == null) return 0;

    return _products
        .where((product) => product.category == category.name)
        .length;
  }

  List<InventoryProduct> getProductsByCategory(String categoryName) {
    return List.unmodifiable(
      _products.where(
        (product) => product.category == categoryName,
      ),
    );
  }

  // ==========================================================
  // CATEGORY MANAGEMENT
  // ==========================================================

  void addCategory({
    required String name,
    required String code,
    String description = '',
  }) {
    final cleanName = name.trim();
    final cleanCode = code.trim();

    if (cleanName.isEmpty || cleanCode.isEmpty) {
      throw Exception('Category name and code are required.');
    }

    final duplicateName = _categories.any(
      (category) =>
          category.name.toLowerCase() == cleanName.toLowerCase(),
    );

    if (duplicateName) {
      throw Exception('A category with this name already exists.');
    }

    final duplicateCode = _categories.any(
      (category) =>
          category.code.toLowerCase() == cleanCode.toLowerCase(),
    );

    if (duplicateCode) {
      throw Exception('This category code already exists.');
    }

    _categories.add(
      InventoryCategory(
        id: DateTime.now().microsecondsSinceEpoch.toString(),
        name: cleanName,
        code: cleanCode,
        description: description.trim(),
        active: true,
      ),
    );

    notifyListeners();
  }

  void updateCategory({
    required String categoryId,
    required String name,
    required String description,
  }) {
    final category = findCategory(categoryId);

    if (category == null) {
      throw Exception('Category not found.');
    }

    final cleanName = name.trim();

    if (cleanName.isEmpty) {
      throw Exception('Category name is required.');
    }

    final duplicateName = _categories.any(
      (item) =>
          item.id != categoryId &&
          item.name.toLowerCase() == cleanName.toLowerCase(),
    );

    if (duplicateName) {
      throw Exception('A category with this name already exists.');
    }

    final oldName = category.name;

    final index = _categories.indexOf(category);

    _categories[index] = InventoryCategory(
      id: category.id,
      name: cleanName,
      code: category.code,
      description: description.trim(),
      active: category.active,
    );

    // Update every product linked to the renamed category.
    for (var i = 0; i < _products.length; i++) {
      final product = _products[i];

      if (product.category == oldName) {
        _products[i] = _copyProduct(
          product,
          category: cleanName,
        );
      }
    }

    notifyListeners();
  }

  void toggleCategoryStatus(String categoryId) {
    final category = findCategory(categoryId);

    if (category == null) {
      throw Exception('Category not found.');
    }

    category.active = !category.active;
    notifyListeners();
  }

  void deleteCategory(String categoryId) {
    final category = findCategory(categoryId);

    if (category == null) {
      throw Exception('Category not found.');
    }

    final isUsed = _products.any(
      (product) => product.category == category.name,
    );

    if (isUsed) {
      throw Exception(
        'This category is assigned to products. '
        'Move those products to another category before deleting it.',
      );
    }

    _categories.removeWhere(
      (item) => item.id == categoryId,
    );

    notifyListeners();
  }

  // ==========================================================
  // PRODUCT COPY HELPER
  // ==========================================================

  InventoryProduct _copyProduct(
    InventoryProduct product, {
    String? name,
    String? category,
    String? barcode,
    String? description,
    double? costPrice,
    double? sellingPrice,
    String? unit,
    int? minimumStock,
    String? supplier,
  }) {
    return InventoryProduct(
      id: product.id,
      name: name ?? product.name,
      sku: product.sku,
      category: category ?? product.category,
      barcode: barcode ?? product.barcode,
      description: description ?? product.description,
      costPrice: costPrice ?? product.costPrice,
      sellingPrice: sellingPrice ?? product.sellingPrice,
      unit: unit ?? product.unit,
      minimumStock: minimumStock ?? product.minimumStock,
      supplier: supplier ?? product.supplier,
      quantity: product.quantity,
      branchQuantities:
          Map<String, int>.from(product.branchQuantities),
    );
  }

  // ==========================================================
  // STOCK ALERTS
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
    final cleanName = name.trim();
    final cleanSku = sku.trim();
    final cleanCategory = category.trim();

    if (cleanName.isEmpty || cleanSku.isEmpty) {
      throw Exception('Product name and SKU are required.');
    }

    if (cleanCategory.isEmpty) {
      throw Exception('Product category is required.');
    }

    final selectedCategory = findCategoryByName(cleanCategory);

    if (selectedCategory == null) {
      throw Exception('Please select a valid category.');
    }

    if (!selectedCategory.active) {
      throw Exception('This category is inactive.');
    }

    if (sellingPrice < 0 ||
        costPrice < 0 ||
        openingQuantity < 0 ||
        minimumStock < 0) {
      throw Exception('Prices and quantities cannot be negative.');
    }

    final duplicate = _products.any(
      (product) =>
          product.sku.trim().toLowerCase() == cleanSku.toLowerCase(),
    );

    if (duplicate) {
      throw Exception('A product with this SKU already exists.');
    }

    if (findBranch(initialBranchId) == null) {
      throw Exception('Selected branch was not found.');
    }

    final product = InventoryProduct(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      name: cleanName,
      sku: cleanSku,
      category: selectedCategory.name,
      barcode: barcode.trim(),
      description: description.trim(),
      costPrice: costPrice,
      sellingPrice: sellingPrice,
      unit: unit.trim().isEmpty ? 'Pieces' : unit.trim(),
      minimumStock: minimumStock,
      supplier: supplier.trim(),
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

  // ----------------------------------------------------------
  // UPDATE PRODUCT DETAILS
  // ----------------------------------------------------------

  void updateProduct({
    required String productId,
    required String name,
    required String category,
    required double costPrice,
    required double sellingPrice,
    required String barcode,
    required String description,
    required String unit,
    required int minimumStock,
    required String supplier,
  }) {
    final index = _products.indexWhere(
      (product) => product.id == productId,
    );

    if (index == -1) {
      throw Exception('Product not found.');
    }

    final oldProduct = _products[index];
    final cleanName = name.trim();
    final cleanCategory = category.trim();

    if (cleanName.isEmpty) {
      throw Exception('Product name is required.');
    }

    final selectedCategory = findCategoryByName(cleanCategory);

    if (selectedCategory == null) {
      throw Exception('Please select a valid category.');
    }

    if (!selectedCategory.active) {
      throw Exception('This category is inactive.');
    }

    if (costPrice < 0 ||
        sellingPrice < 0 ||
        minimumStock < 0) {
      throw Exception('Prices and minimum stock cannot be negative.');
    }

    _products[index] = _copyProduct(
      oldProduct,
      name: cleanName,
      category: selectedCategory.name,
      barcode: barcode.trim(),
      description: description.trim(),
      costPrice: costPrice,
      sellingPrice: sellingPrice,
      unit: unit.trim().isEmpty ? oldProduct.unit : unit.trim(),
      minimumStock: minimumStock,
      supplier: supplier.trim(),
    );

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

    if (type != 'Stock In' && type != 'Stock Out') {
      throw Exception('Invalid stock movement type.');
    }

    final product = findProduct(productId);
    if (product == null) throw Exception('Product not found.');

    final branch = findBranch(branchId);
    if (branch == null) throw Exception('Branch not found.');

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

    // Combine quantities for repeated products.
    final requiredQuantities = <String, int>{};

    for (final item in items) {
      if (item.quantity <= 0 || item.unitPrice < 0) {
        throw Exception('Invalid product quantity or price.');
      }

      requiredQuantities[item.productId] =
          (requiredQuantities[item.productId] ?? 0) + item.quantity;
    }

    // Validate all stock before making changes.
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

    notificationCenter.add(
      title: 'New Sale',
      message:
          'Sale ${sale.invoiceNumber} completed at ${branch.name}. Total: ${sale.total.toStringAsFixed(2)}.',
      category: NotificationCategory.sales,
      relatedId: sale.invoiceNumber,
      action: 'sale',
    );

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
    final cleanName = name.trim();
    final cleanCode = code.trim();

    if (cleanName.isEmpty || cleanCode.isEmpty) {
      throw Exception('Branch name and code are required.');
    }

    final duplicate = _branches.any(
      (branch) =>
          branch.code.trim().toLowerCase() == cleanCode.toLowerCase(),
    );

    if (duplicate) {
      throw Exception('This branch code already exists.');
    }

    _branches.add(
      InventoryBranch(
        id: DateTime.now().microsecondsSinceEpoch.toString(),
        name: cleanName,
        code: cleanCode,
        city: city.trim(),
        address: address.trim(),
        phone: phone.trim(),
        email: email.trim(),
        manager: manager.trim(),
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

    if (index == -1) {
      throw Exception('Branch not found.');
    }

    final cleanName = name.trim();
    final cleanCode = code.trim();

    if (cleanName.isEmpty || cleanCode.isEmpty) {
      throw Exception('Branch name and code are required.');
    }

    final duplicate = _branches.any(
      (branch) =>
          branch.code.trim().toLowerCase() == cleanCode.toLowerCase() &&
          branch.id != id,
    );

    if (duplicate) {
      throw Exception('This branch code already exists.');
    }

    final oldBranch = _branches[index];

    _branches[index] = InventoryBranch(
      id: oldBranch.id,
      name: cleanName,
      code: cleanCode,
      city: city.trim(),
      address: address.trim(),
      phone: phone.trim(),
      email: email.trim(),
      manager: manager.trim(),
      active: oldBranch.active,
    );

    notifyListeners();
  }

  void toggleBranchStatus(String id) {
    final index = _branches.indexWhere((branch) => branch.id == id);

    if (index == -1) {
      throw Exception('Branch not found.');
    }

    _branches[index].active = !_branches[index].active;

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
