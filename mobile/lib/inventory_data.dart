
import 'package:flutter/foundation.dart';
import 'inventory_storage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'notifications_data.dart';
import 'code_generator.dart';

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
  final String referenceCode;
  final String productId;
  final String productName;
  final String type;
  final int quantity;
  final DateTime date;
  final String branchId;
  final String? transferCode;

  StockMovement({
    required this.referenceCode,
    required this.productId,
    required this.productName,
    required this.type,
    required this.quantity,
    required this.date,
    this.branchId = '1',
    this.transferCode,
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
// CUSTOMER MODEL
// ============================================================

class InventoryCustomer {
  final String id;
  final String code;
  final String name;
  final String phone;
  final String email;
  final String address;
  final String city;
  final String country;
  final String notes;
  final DateTime createdAt;

  bool active;

  InventoryCustomer({
    required this.id,
    required this.code,
    required this.name,
    this.phone = '',
    this.email = '',
    this.address = '',
    this.city = '',
    this.country = 'Nepal',
    this.notes = '',
    required this.createdAt,
    this.active = true,
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

  String get paymentStatus {
    if (amountPaid <= 0) return 'Unpaid';
    if (amountPaid >= total) return 'Paid';
    return 'Partially Paid';
  }
}

// ============================================================
// SALES RETURN MODELS
// ============================================================

class SalesReturnLine {
  final String productId;
  final String productName;
  final String sku;
  final int quantity;
  final double unitPrice;

  SalesReturnLine({
    required this.productId,
    required this.productName,
    required this.sku,
    required this.quantity,
    required this.unitPrice,
  });

  double get total => quantity * unitPrice;
}

class SalesReturnRecord {
  final String returnNumber;
  final String originalInvoiceNumber;
  final String branchId;
  final String customerName;
  final List<SalesReturnLine> items;
  final double total;
  final String reason;
  final DateTime date;

  SalesReturnRecord({
    required this.returnNumber,
    required this.originalInvoiceNumber,
    required this.branchId,
    required this.customerName,
    required this.items,
    required this.total,
    required this.reason,
    required this.date,
  });
}

// ============================================================
// INVENTORY DATA
// ============================================================

class InventoryData extends ChangeNotifier {
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

  // ==========================================================
  // CATEGORIES
  // ==========================================================

  final List<InventoryCategory> _categories = [
    InventoryCategory(
      id: 'CAT-ID-001',
      name: 'Electronics',
      code: 'CAT-0001',
      description: 'Electronic devices and equipment',
      active: true,
    ),
    InventoryCategory(
      id: 'CAT-ID-002',
      name: 'Accessories',
      code: 'CAT-0002',
      description: 'Computer and mobile accessories',
      active: true,
    ),
    InventoryCategory(
      id: 'CAT-ID-003',
      name: 'Furniture',
      code: 'CAT-0003',
      description: 'Office and home furniture',
      active: true,
    ),
    InventoryCategory(
      id: 'CAT-ID-004',
      name: 'Other',
      code: 'CAT-0004',
      description: 'Miscellaneous products',
      active: true,
    ),
  ];

  // ==========================================================
  // PRODUCTS
  // ==========================================================

  final List<InventoryProduct> _products = [
    InventoryProduct(
      id: '1',
      name: 'Wireless Mouse',
      sku: 'PR-0001',
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
      sku: 'PR-0002',
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
      sku: 'PR-0003',
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
      sku: 'PR-0004',
      category: 'Electronics',
      sellingPrice: 2500,
      costPrice: 1800,
      quantity: 35,
      minimumStock: 5,
      branchQuantities: {'1': 35},
    ),
  ];

  // ==========================================================
  // STOCK MOVEMENTS
  // ==========================================================

  final List<StockMovement> _movements = [];

  // ==========================================================
  // BRANCHES
  // ==========================================================

  final List<InventoryBranch> _branches = [
    InventoryBranch(
      id: '1',
      name: 'Main Branch',
      code: 'BR-0001',
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
      code: 'BR-0002',
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
      code: 'BR-0003',
      city: 'Lalitpur',
      address: 'Jawalakhel, Lalitpur',
      phone: '9800000003',
      email: 'lalitpur@example.com',
      manager: 'Branch Manager',
      active: false,
    ),
  ];

  // ==========================================================
  // CUSTOMERS
  // ==========================================================

  final List<InventoryCustomer> _customers = [];

  // ==========================================================
  // SALES RECORDS
  // ==========================================================

  final List<SaleRecord> _sales = [];
  final List<SalesReturnRecord> _salesReturns = [];

  // ==========================================================
  // CODE GENERATION
  // ==========================================================

  String generateProductCode() =>
      CodeGenerator.nextProduct(_products.map((e) => e.sku));

  String generateCategoryCode() =>
      CodeGenerator.nextCategory(_categories.map((e) => e.code));

  String generateBranchCode() =>
      CodeGenerator.nextBranch(_branches.map((e) => e.code));

  String generateCustomerCode() =>
      CodeGenerator.nextCustomer(_customers.map((e) => e.code));

  String generateStockMovementCode() =>
      CodeGenerator.nextStockMovement(
        _movements.map((e) => e.referenceCode),
      );

  String generateTransferCode() =>
      CodeGenerator.nextTransfer(
        _movements
            .where((e) => e.transferCode != null)
            .map((e) => e.transferCode!),
      );

  String generateInvoiceCode() =>
      CodeGenerator.nextInvoice(_sales.map((e) => e.invoiceNumber));

  String generateReturnCode() {
    final existing = _salesReturns.map((e) => e.returnNumber).toSet();
    var number = _salesReturns.length + 1;
    var code = 'RET-${number.toString().padLeft(4, '0')}';

    while (existing.contains(code)) {
      number++;
      code = 'RET-${number.toString().padLeft(4, '0')}';
    }

    return code;
  }

  // ==========================================================
  // PUBLIC DATA
  // ==========================================================

  List<InventoryProduct> get products => List.unmodifiable(_products);

  List<InventoryCategory> get categories =>
      List.unmodifiable(_categories);

  List<StockMovement> get movements => List.unmodifiable(_movements);

  List<InventoryBranch> get branches => List.unmodifiable(_branches);

  List<InventoryCustomer> get customers =>
      List.unmodifiable(_customers);

  List<SaleRecord> get sales => List.unmodifiable(_sales);

  List<SalesReturnRecord> get salesReturns =>
      List.unmodifiable(_salesReturns);

  int get totalStock =>
      _products.fold(0, (total, product) => total + product.quantity);

  int get lowStockCount => _products
      .where((product) => product.quantity <= product.minimumStock)
      .length;

  int get activeBranchCount =>
      _branches.where((branch) => branch.active).length;

  int get activeCategoryCount =>
      _categories.where((category) => category.active).length;

  int get activeCustomerCount =>
      _customers.where((customer) => customer.active).length;

  int get totalCustomerCount => _customers.length;

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

    return _sales
        .where((sale) =>
            sale.date.year == now.year &&
            sale.date.month == now.month &&
            sale.date.day == now.day)
        .length;
  }

  int returnedQuantityFor(
    String invoiceNumber,
    String productId,
  ) {
    return _salesReturns
        .where(
          (record) =>
              record.originalInvoiceNumber == invoiceNumber,
        )
        .expand((record) => record.items)
        .where((item) => item.productId == productId)
        .fold(0, (total, item) => total + item.quantity);
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

  InventoryCustomer? findCustomer(String customerId) {
    for (final customer in _customers) {
      if (customer.id == customerId) return customer;
    }
    return null;
  }

  InventoryCustomer? findCustomerByCode(String code) {
    final cleanCode = code.trim().toLowerCase();

    for (final customer in _customers) {
      if (customer.code.toLowerCase() == cleanCode) {
        return customer;
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
      _products.where((product) => product.category == categoryName),
    );
  }

  // ==========================================================
  // CUSTOMER MANAGEMENT
  // ==========================================================

  void addCustomer({
    required String name,
    String? code,
    String phone = '',
    String email = '',
    String address = '',
    String city = '',
    String country = 'Nepal',
    String notes = '',
  }) {
    final cleanName = name.trim();

    if (cleanName.isEmpty) {
      throw Exception('Customer name is required.');
    }

    final cleanPhone = phone.trim();
    final cleanEmail = email.trim();

    if (cleanPhone.isEmpty && cleanEmail.isEmpty) {
      throw Exception('Enter at least a phone number or email address.');
    }

    if (cleanEmail.isNotEmpty &&
        !RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(cleanEmail)) {
      throw Exception('Enter a valid email address.');
    }

    if (cleanPhone.isNotEmpty &&
        _customers.any((customer) =>
            customer.phone.trim() == cleanPhone)) {
      throw Exception('A customer with this phone number already exists.');
    }

    final cleanCode = code?.trim().isNotEmpty == true
        ? code!.trim()
        : generateCustomerCode();

    if (_customers.any((customer) =>
        customer.code.toLowerCase() == cleanCode.toLowerCase())) {
      throw Exception('This customer code already exists.');
    }

    _customers.add(
      InventoryCustomer(
        id: DateTime.now().microsecondsSinceEpoch.toString(),
        code: cleanCode,
        name: cleanName,
        phone: cleanPhone,
        email: cleanEmail,
        address: address.trim(),
        city: city.trim(),
        country: country.trim().isEmpty ? 'Nepal' : country.trim(),
        notes: notes.trim(),
        createdAt: DateTime.now(),
      ),
    );

    notifyListeners();
  }

  void updateCustomer({
    required String customerId,
    required String name,
    required String phone,
    required String email,
    required String address,
    required String city,
    required String country,
    required String notes,
  }) {
    final customer = findCustomer(customerId);

    if (customer == null) {
      throw Exception('Customer not found.');
    }

    final cleanName = name.trim();
    final cleanPhone = phone.trim();
    final cleanEmail = email.trim();

    if (cleanName.isEmpty) {
      throw Exception('Customer name is required.');
    }

    if (cleanPhone.isEmpty && cleanEmail.isEmpty) {
      throw Exception('Enter at least a phone number or email address.');
    }

    if (cleanEmail.isNotEmpty &&
        !RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(cleanEmail)) {
      throw Exception('Enter a valid email address.');
    }

    final duplicatePhone = _customers.any((item) =>
        item.id != customerId &&
        cleanPhone.isNotEmpty &&
        item.phone.trim() == cleanPhone);

    if (duplicatePhone) {
      throw Exception('Another customer already uses this phone number.');
    }

    final index = _customers.indexOf(customer);

    _customers[index] = InventoryCustomer(
      id: customer.id,
      code: customer.code,
      name: cleanName,
      phone: cleanPhone,
      email: cleanEmail,
      address: address.trim(),
      city: city.trim(),
      country: country.trim().isEmpty ? 'Nepal' : country.trim(),
      notes: notes.trim(),
      createdAt: customer.createdAt,
      active: customer.active,
    );

    notifyListeners();
  }

  void toggleCustomerStatus(String customerId) {
    final customer = findCustomer(customerId);

    if (customer == null) {
      throw Exception('Customer not found.');
    }

    customer.active = !customer.active;
    notifyListeners();
  }

  void deleteCustomer(String customerId) {
    final customer = findCustomer(customerId);

    if (customer == null) {
      throw Exception('Customer not found.');
    }

    final hasSales = _sales.any((sale) =>
        sale.customerName.trim().toLowerCase() ==
            customer.name.trim().toLowerCase() &&
        sale.customerPhone.trim() == customer.phone.trim());

    if (hasSales) {
      throw Exception(
        'This customer has sales history. Deactivate the customer instead.',
      );
    }

    _customers.remove(customer);
    notifyListeners();
  }

  List<InventoryCustomer> searchCustomers(String query) {
    final q = query.trim().toLowerCase();

    if (q.isEmpty) return List.unmodifiable(_customers);

    return List.unmodifiable(_customers.where((customer) {
      return customer.name.toLowerCase().contains(q) ||
          customer.code.toLowerCase().contains(q) ||
          customer.phone.toLowerCase().contains(q) ||
          customer.email.toLowerCase().contains(q) ||
          customer.city.toLowerCase().contains(q) ||
          customer.address.toLowerCase().contains(q);
    }));
  }

  // ==========================================================
  // CATEGORY MANAGEMENT
  // ==========================================================

  void addCategory({
    required String name,
    String? code,
    String description = '',
  }) {
    final cleanName = name.trim();

    if (cleanName.isEmpty) {
      throw Exception('Category name is required.');
    }

    if (_categories.any((category) =>
        category.name.toLowerCase() == cleanName.toLowerCase())) {
      throw Exception('A category with this name already exists.');
    }

    final cleanCode = code?.trim().isNotEmpty == true
        ? code!.trim()
        : generateCategoryCode();

    if (_categories.any((category) =>
        category.code.toLowerCase() == cleanCode.toLowerCase())) {
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

    if (_categories.any((item) =>
        item.id != categoryId &&
        item.name.toLowerCase() == cleanName.toLowerCase())) {
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

    for (var i = 0; i < _products.length; i++) {
      final product = _products[i];

      if (product.category == oldName) {
        _products[i] = _copyProduct(product, category: cleanName);
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

    if (_products.any((product) => product.category == category.name)) {
      throw Exception(
        'This category is assigned to products. '
        'Move those products before deleting it.',
      );
    }

    _categories.removeWhere((item) => item.id == categoryId);
    notifyListeners();
  }

  // ==========================================================
  // PRODUCT HELPERS
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
      branchQuantities: Map<String, int>.from(
        product.branchQuantities,
      ),
    );
  }

  void _checkStockAlerts(
    InventoryProduct product,
    int previousQuantity,
  ) {
    if (previousQuantity > 0 && product.quantity == 0) {
      notificationCenter.add(
        title: 'Out of Stock',
        message: '${product.name} is now out of stock.',
        category: NotificationCategory.inventory,
        action: 'product',
        relatedId: product.id,
      );
    } else if (previousQuantity > product.minimumStock &&
        product.quantity <= product.minimumStock) {
      notificationCenter.add(
        title: 'Low Stock',
        message:
            '${product.name} has reached its minimum stock level.',
        category: NotificationCategory.inventory,
        action: 'product',
        relatedId: product.id,
      );
    }
  }

  StockMovement _createMovement({
    required String productId,
    required String productName,
    required String type,
    required int quantity,
    required String branchId,
    String? transferCode,
    DateTime? date,
  }) {
    return StockMovement(
      referenceCode: generateStockMovementCode(),
      productId: productId,
      productName: productName,
      type: type,
      quantity: quantity,
      date: date ?? DateTime.now(),
      branchId: branchId,
      transferCode: transferCode,
    );
  }

  // ==========================================================
  // PRODUCT MANAGEMENT
  // ==========================================================

  void addProduct({
    required String name,
    String? sku,
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
    if (name.trim().isEmpty) {
      throw Exception('Product name is required.');
    }

    if (category.trim().isEmpty) {
      throw Exception('Please select a category.');
    }

    final selectedCategory = findCategory(category);

    if (selectedCategory == null || !selectedCategory.active) {
      throw Exception('Selected category is unavailable.');
    }

    if (sellingPrice < 0 ||
        costPrice < 0 ||
        openingQuantity < 0 ||
        minimumStock < 0) {
      throw Exception('Prices and quantities cannot be negative.');
    }

    final productSku = sku?.trim().isNotEmpty == true
        ? sku!.trim()
        : generateProductCode();

    if (_products.any(
      (product) => product.sku.toLowerCase() == productSku.toLowerCase(),
    )) {
      throw Exception('A product with this code already exists.');
    }

    final branchExists = _branches.any(
      (branch) => branch.id == initialBranchId && branch.active,
    );

    if (!branchExists) {
      throw Exception('Please select a valid active branch.');
    }

    final product = InventoryProduct(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      name: name.trim(),
      sku: productSku,
      category: category,
      barcode: barcode.trim(),
      description: description.trim(),
      costPrice: costPrice,
      sellingPrice: sellingPrice,
      unit: unit,
      minimumStock: minimumStock,
      supplier: supplier.trim(),
      quantity: openingQuantity,
      branchQuantities: {
        initialBranchId: openingQuantity,
      },
    );

    _products.add(product);

    if (openingQuantity > 0) {
      _movements.insert(
        0,
        _createMovement(
          productId: product.id,
          productName: product.name,
          type: 'Stock In',
          quantity: openingQuantity,
          branchId: initialBranchId,
        ),
      );
    }

    _checkStockAlerts(product, 0);
    notifyListeners();
  }

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

    if (name.trim().isEmpty) {
      throw Exception('Product name is required.');
    }

    final selectedCategory = findCategory(category);

    if (selectedCategory == null || !selectedCategory.active) {
      throw Exception('Please select a valid active category.');
    }

    if (costPrice < 0 || sellingPrice < 0 || minimumStock < 0) {
      throw Exception('Prices and minimum stock cannot be negative.');
    }

    final oldProduct = _products[index];

    _products[index] = _copyProduct(
      oldProduct,
      name: name.trim(),
      category: category,
      barcode: barcode.trim(),
      description: description.trim(),
      costPrice: costPrice,
      sellingPrice: sellingPrice,
      unit: unit,
      minimumStock: minimumStock,
      supplier: supplier.trim(),
    );

    _checkStockAlerts(
      _products[index],
      oldProduct.quantity,
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

    final productIndex = _products.indexWhere(
      (product) => product.id == productId,
    );

    if (productIndex == -1) {
      throw Exception('Product not found.');
    }

    final branchExists = _branches.any(
      (branch) => branch.id == branchId && branch.active,
    );

    if (!branchExists) {
      throw Exception('Branch not found or inactive.');
    }

    final product = _products[productIndex];

    final updatedBranchQuantities =
        Map<String, int>.from(product.branchQuantities);

    updatedBranchQuantities[branchId] =
        (updatedBranchQuantities[branchId] ?? 0) + quantity;

    _products[productIndex] = InventoryProduct(
      id: product.id,
      name: product.name,
      sku: product.sku,
      category: product.category,
      barcode: product.barcode,
      description: product.description,
      costPrice: product.costPrice,
      sellingPrice: product.sellingPrice,
      unit: product.unit,
      minimumStock: product.minimumStock,
      supplier: product.supplier,
      quantity: product.quantity + quantity,
      branchQuantities: updatedBranchQuantities,
    );

    _movements.insert(
      0,
      _createMovement(
        productId: product.id,
        productName: product.name,
        type: 'Stock In',
        quantity: quantity,
        branchId: branchId,
      ),
    );

    notificationCenter.add(
      title: 'Stock In',
      message: '$quantity ${product.unit} of ${product.name} allocated.',
      category: NotificationCategory.stock,
      action: 'stock',
      relatedId: product.id,
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
      throw Exception('Source and destination branches must be different.');
    }

    final productIndex = _products.indexWhere(
      (product) => product.id == productId,
    );

    if (productIndex == -1) {
      throw Exception('Product not found.');
    }

    final fromBranch = _branches.any(
      (branch) => branch.id == fromBranchId && branch.active,
    );

    final toBranch = _branches.any(
      (branch) => branch.id == toBranchId && branch.active,
    );

    if (!fromBranch || !toBranch) {
      throw Exception('Both branches must exist and be active.');
    }

    final product = _products[productIndex];

    final sourceQuantity =
        product.branchQuantities[fromBranchId] ?? 0;

    if (sourceQuantity < quantity) {
      throw Exception('Insufficient stock in the source branch.');
    }

    final updatedQuantities =
        Map<String, int>.from(product.branchQuantities);

    updatedQuantities[fromBranchId] = sourceQuantity - quantity;

    updatedQuantities[toBranchId] =
        (updatedQuantities[toBranchId] ?? 0) + quantity;

    _products[productIndex] = InventoryProduct(
      id: product.id,
      name: product.name,
      sku: product.sku,
      category: product.category,
      barcode: product.barcode,
      description: product.description,
      costPrice: product.costPrice,
      sellingPrice: product.sellingPrice,
      unit: product.unit,
      minimumStock: product.minimumStock,
      supplier: product.supplier,
      quantity: product.quantity,
      branchQuantities: updatedQuantities,
    );

    final transferCode = generateTransferCode();
    final transferDate = DateTime.now();

    _movements.insert(
      0,
      _createMovement(
        productId: product.id,
        productName: product.name,
        type: 'Transfer Out',
        quantity: quantity,
        branchId: fromBranchId,
        transferCode: transferCode,
        date: transferDate,
      ),
    );

    _movements.insert(
      0,
      _createMovement(
        productId: product.id,
        productName: product.name,
        type: 'Transfer In',
        quantity: quantity,
        branchId: toBranchId,
        transferCode: transferCode,
        date: transferDate,
      ),
    );

    notificationCenter.add(
      title: 'Stock Transfer',
      message: '$quantity ${product.unit} of ${product.name} transferred.',
      category: NotificationCategory.stock,
      action: 'stock',
      relatedId: product.id,
    );

    notifyListeners();
  }

  // ==========================================================
  // MANUAL STOCK IN / OUT
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
      throw Exception('Movement type must be Stock In or Stock Out.');
    }

    final productIndex = _products.indexWhere(
      (product) => product.id == productId,
    );

    if (productIndex == -1) {
      throw Exception('Product not found.');
    }

    final branchExists = _branches.any(
      (branch) => branch.id == branchId && branch.active,
    );

    if (!branchExists) {
      throw Exception('Branch not found or inactive.');
    }

    final product = _products[productIndex];

    final branchQuantity =
        product.branchQuantities[branchId] ?? 0;

    if (type == 'Stock Out' && branchQuantity < quantity) {
      throw Exception('Insufficient stock in this branch.');
    }

    final previousQuantity = product.quantity;

    final updatedQuantities =
        Map<String, int>.from(product.branchQuantities);

    if (type == 'Stock In') {
      updatedQuantities[branchId] = branchQuantity + quantity;
    } else {
      updatedQuantities[branchId] = branchQuantity - quantity;
    }

    final newTotalQuantity = type == 'Stock In'
        ? product.quantity + quantity
        : product.quantity - quantity;

    final updatedProduct = InventoryProduct(
      id: product.id,
      name: product.name,
      sku: product.sku,
      category: product.category,
      barcode: product.barcode,
      description: product.description,
      costPrice: product.costPrice,
      sellingPrice: product.sellingPrice,
      unit: product.unit,
      minimumStock: product.minimumStock,
      supplier: product.supplier,
      quantity: newTotalQuantity,
      branchQuantities: updatedQuantities,
    );

    _products[productIndex] = updatedProduct;

    _movements.insert(
      0,
      _createMovement(
        productId: product.id,
        productName: product.name,
        type: type,
        quantity: quantity,
        branchId: branchId,
      ),
    );

    notificationCenter.add(
      title: type,
      message: '$quantity ${product.unit} of ${product.name}.',
      category: NotificationCategory.stock,
      action: 'stock',
      relatedId: product.id,
    );

    _checkStockAlerts(updatedProduct, previousQuantity);

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
      throw Exception('Please select a valid active branch.');
    }

    if (items.isEmpty) {
      throw Exception('Please add at least one product.');
    }

    if (discount < 0 || tax < 0 || amountPaid < 0) {
      throw Exception('Discount, tax and payment cannot be negative.');
    }

    final requestedQuantities = <String, int>{};

    for (final item in items) {
      if (item.quantity <= 0) {
        throw Exception('Sale quantities must be greater than zero.');
      }

      requestedQuantities[item.productId] =
          (requestedQuantities[item.productId] ?? 0) + item.quantity;
    }

    for (final entry in requestedQuantities.entries) {
      final product = findProduct(entry.key);

      if (product == null) {
        throw Exception('A selected product no longer exists.');
      }

      final available = product.branchQuantities[branchId] ?? 0;

      if (available < entry.value) {
        throw Exception(
          'Insufficient stock for ${product.name}. Available: $available.',
        );
      }
    }

    final saleLines = <SaleLineItem>[];

    for (final item in items) {
      final product = findProduct(item.productId)!;

      saleLines.add(
        SaleLineItem(
          productId: product.id,
          productName: product.name,
          sku: product.sku,
          quantity: item.quantity,
          unitPrice: product.sellingPrice,
          costPrice: product.costPrice,
        ),
      );
    }

    final subtotal = saleLines.fold<double>(
      0,
      (sum, item) => sum + item.total,
    );

    if (discount > subtotal) {
      throw Exception('Discount cannot exceed the subtotal.');
    }

    final total = subtotal - discount + tax;

    if (amountPaid > total) {
      throw Exception('Amount paid cannot exceed the sale total.');
    }

    final saleDate = DateTime.now();

    final sale = SaleRecord(
      invoiceNumber: generateInvoiceCode(),
      branchId: branchId,
      customerName: customerName.trim(),
      customerPhone: customerPhone.trim(),
      paymentMethod: paymentMethod,
      items: saleLines,
      subtotal: subtotal,
      discount: discount,
      tax: tax,
      total: total,
      amountPaid: amountPaid,
      date: saleDate,
    );

    for (final entry in requestedQuantities.entries) {
      final productIndex = _products.indexWhere(
        (product) => product.id == entry.key,
      );

      final product = _products[productIndex];
      final previousQuantity = product.quantity;

      final updatedQuantities =
          Map<String, int>.from(product.branchQuantities);

      updatedQuantities[branchId] =
          (updatedQuantities[branchId] ?? 0) - entry.value;

      final updatedProduct = InventoryProduct(
        id: product.id,
        name: product.name,
        sku: product.sku,
        category: product.category,
        barcode: product.barcode,
        description: product.description,
        costPrice: product.costPrice,
        sellingPrice: product.sellingPrice,
        unit: product.unit,
        minimumStock: product.minimumStock,
        supplier: product.supplier,
        quantity: product.quantity - entry.value,
        branchQuantities: updatedQuantities,
      );

      _products[productIndex] = updatedProduct;

      _movements.insert(
        0,
        _createMovement(
          productId: product.id,
          productName: product.name,
          type: 'Stock Out',
          quantity: entry.value,
          branchId: branchId,
          date: saleDate,
        ),
      );

      _checkStockAlerts(updatedProduct, previousQuantity);
    }

    _sales.insert(0, sale);

    notificationCenter.add(
      title: 'New Sale',
      message: 'Invoice ${sale.invoiceNumber} created successfully.',
      category: NotificationCategory.sales,
      action: 'sale',
      relatedId: sale.invoiceNumber,
    );

    if (sale.balanceDue > 0) {
      notificationCenter.add(
        title: 'Payment Due',
        message:
            'An outstanding balance of ${sale.balanceDue.toStringAsFixed(2)} remains.',
        category: NotificationCategory.sales,
        action: 'sale',
        relatedId: sale.invoiceNumber,
      );
    }

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
    final index = _sales.indexWhere(
      (sale) => sale.invoiceNumber == invoiceNumber,
    );

    if (index == -1) {
      throw Exception('Sale invoice not found.');
    }

    final oldSale = _sales[index];

    if (amountPaid < 0 || amountPaid > oldSale.total) {
      throw Exception(
        'Payment must be between zero and the invoice total.',
      );
    }

    final cleanPaymentMethod = paymentMethod.trim();

    if (cleanPaymentMethod.isEmpty) {
      throw Exception('Please select a payment method.');
    }

    _sales[index] = SaleRecord(
      invoiceNumber: oldSale.invoiceNumber,
      branchId: oldSale.branchId,
      customerName: oldSale.customerName,
      customerPhone: oldSale.customerPhone,
      paymentMethod: cleanPaymentMethod,
      items: oldSale.items,
      subtotal: oldSale.subtotal,
      discount: oldSale.discount,
      tax: oldSale.tax,
      total: oldSale.total,
      amountPaid: amountPaid,
      date: oldSale.date,
    );

    notificationCenter.add(
      title: 'Sale Payment Updated',
      message: 'Payment updated for invoice $invoiceNumber.',
      category: NotificationCategory.sales,
      action: 'sale',
      relatedId: invoiceNumber,
    );

    notifyListeners();
  }

  // ==========================================================
  // SALES RETURN PROCESSING
  // ==========================================================

  SalesReturnRecord createSalesReturn({
    required String invoiceNumber,
    required Map<String, int> quantities,
    String reason = '',
  }) {
    // Find the original sale.
    final sale = findSale(invoiceNumber);

    if (sale == null) {
      throw Exception('Original sales invoice not found.');
    }

    if (quantities.isEmpty) {
      throw Exception('Select at least one product to return.');
    }

    // Returns must go back to the original sale branch.
    final branch = findBranch(sale.branchId);

    if (branch == null) {
      throw Exception('The original sale branch could not be found.');
    }

    // Combine quantities if the same product appears on
    // multiple lines of the original invoice.
    final soldQuantities = <String, int>{};
    final originalLines = <String, SaleLineItem>{};

    for (final item in sale.items) {
      soldQuantities[item.productId] =
          (soldQuantities[item.productId] ?? 0) + item.quantity;

      originalLines.putIfAbsent(
        item.productId,
        () => item,
      );
    }

    // Validate every requested return before changing stock.
    for (final entry in quantities.entries) {
      final productId = entry.key;
      final returnQuantity = entry.value;

      if (returnQuantity <= 0) {
        throw Exception(
          'Return quantities must be greater than zero.',
        );
      }

      final soldQuantity = soldQuantities[productId];

      if (soldQuantity == null) {
        throw Exception(
          'A selected product does not belong to this invoice.',
        );
      }

      final alreadyReturned =
          returnedQuantityFor(invoiceNumber, productId);

      final remainingReturnable =
          soldQuantity - alreadyReturned;

      if (returnQuantity > remainingReturnable) {
        final originalLine = originalLines[productId]!;

        throw Exception(
          'Only $remainingReturnable ${originalLine.productName} '
          'can still be returned.',
        );
      }

      if (findProduct(productId) == null) {
        throw Exception(
          'A returned product no longer exists in the product list.',
        );
      }
    }

    // Prepare the return details.
    final returnDate = DateTime.now();
    final returnLines = <SalesReturnLine>[];

    for (final entry in quantities.entries) {
      final originalLine = originalLines[entry.key]!;

      returnLines.add(
        SalesReturnLine(
          productId: originalLine.productId,
          productName: originalLine.productName,
          sku: originalLine.sku,
          quantity: entry.value,
          unitPrice: originalLine.unitPrice,
        ),
      );
    }

    final returnTotal = returnLines.fold<double>(
      0,
      (sum, item) => sum + item.total,
    );

    // IMPORTANT:
    // These field names match SalesReturnRecord in Part 1.
    final returnRecord = SalesReturnRecord(
      returnNumber: generateReturnCode(),
      originalInvoiceNumber: sale.invoiceNumber,
      branchId: sale.branchId,
      customerName: sale.customerName,
      items: returnLines,
      total: returnTotal,
      reason: reason.trim(),
      date: returnDate,
    );

    // Restore returned stock to the original sale branch.
    for (final entry in quantities.entries) {
      final productIndex = _products.indexWhere(
        (product) => product.id == entry.key,
      );

      final product = _products[productIndex];
      final returnQuantity = entry.value;
      final previousQuantity = product.quantity;

      final updatedBranchQuantities =
          Map<String, int>.from(product.branchQuantities);

      updatedBranchQuantities[sale.branchId] =
          (updatedBranchQuantities[sale.branchId] ?? 0) +
              returnQuantity;

      final updatedProduct = InventoryProduct(
        id: product.id,
        name: product.name,
        sku: product.sku,
        category: product.category,
        barcode: product.barcode,
        description: product.description,
        costPrice: product.costPrice,
        sellingPrice: product.sellingPrice,
        unit: product.unit,
        minimumStock: product.minimumStock,
        supplier: product.supplier,
        quantity: product.quantity + returnQuantity,
        branchQuantities: updatedBranchQuantities,
      );

      _products[productIndex] = updatedProduct;

      // Record the stock movement.
      _movements.insert(
        0,
        _createMovement(
          productId: product.id,
          productName: product.name,
          type: 'Sales Return',
          quantity: returnQuantity,
          branchId: sale.branchId,
          date: returnDate,
        ),
      );

      // Recheck stock alerts after the stock update.
      _checkStockAlerts(updatedProduct, previousQuantity);
    }

    // Save the return record.
    _salesReturns.insert(0, returnRecord);

    // Notify the user.
    notificationCenter.add(
      title: 'Sales Return Created',
      message:
          'Return ${returnRecord.returnNumber} recorded for '
          'invoice ${sale.invoiceNumber}.',
      category: NotificationCategory.sales,
      action: 'sale',
      relatedId: sale.invoiceNumber,
    );

    notifyListeners();

    return returnRecord;
  }

  // ==========================================================
  // BRANCH MANAGEMENT
  // ==========================================================

  void addBranch({
    required String name,
    String? code,
    required String city,
    required String address,
    required String phone,
    required String email,
    required String manager,
  }) {
    if (name.trim().isEmpty) {
      throw Exception('Branch name is required.');
    }

    final branchCode = code?.trim().isNotEmpty == true
        ? code!.trim()
        : generateBranchCode();

    if (_branches.any(
      (branch) =>
          branch.code.toLowerCase() == branchCode.toLowerCase(),
    )) {
      throw Exception('A branch with this code already exists.');
    }

    _branches.add(
      InventoryBranch(
        id: DateTime.now().microsecondsSinceEpoch.toString(),
        code: branchCode,
        name: name.trim(),
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
    final index = _branches.indexWhere(
      (branch) => branch.id == id,
    );

    if (index == -1) {
      throw Exception('Branch not found.');
    }

    if (name.trim().isEmpty || code.trim().isEmpty) {
      throw Exception('Branch name and code are required.');
    }

    if (_branches.any(
      (branch) =>
          branch.id != id &&
          branch.code.toLowerCase() == code.trim().toLowerCase(),
    )) {
      throw Exception('Another branch already uses this code.');
    }

    final oldBranch = _branches[index];

    _branches[index] = InventoryBranch(
      id: oldBranch.id,
      code: code.trim(),
      name: name.trim(),
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
    final index = _branches.indexWhere(
      (branch) => branch.id == id,
    );

    if (index == -1) {
      throw Exception('Branch not found.');
    }

    final branch = _branches[index];

    _branches[index] = InventoryBranch(
      id: branch.id,
      code: branch.code,
      name: branch.name,
      city: branch.city,
      address: branch.address,
      phone: branch.phone,
      email: branch.email,
      manager: branch.manager,
      active: !branch.active,
    );

    notifyListeners();
  }
}

// ============================================================
// INVENTORY PROVIDER
// ============================================================

final inventoryProvider =
    ChangeNotifierProvider<InventoryData>((ref) {
  return InventoryData();
});
