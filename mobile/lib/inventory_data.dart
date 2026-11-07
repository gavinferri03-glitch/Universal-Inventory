
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'inventory_models.dart';

export 'inventory_models.dart';

import 'inventory_storage.dart';
import 'notifications_data.dart';
import 'code_generator.dart';

part 'inventory_products.dart';
part 'inventory_categories.dart';
part 'inventory_branches.dart';
part 'inventory_customers.dart';
part 'inventory_stock.dart';
part 'inventory_sales.dart';
part 'inventory_returns.dart';
part 'inventory_helpers.dart';

// ============================================================
// INVENTORY DATA
// ============================================================

class InventoryData extends ChangeNotifier {
  final NotificationCenter notificationCenter = NotificationCenter();

  InventoryData() {
    notificationCenter.addListener(notifyListeners);
  }

  // Storage state is added here.
  bool _storageInitialized = false;
  bool _restoringStorage = false;
  Future<void> _saveQueue = Future<void>.value();

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
  // PUBLIC LIST GETTERS
  // ==========================================================

  List<InventoryProduct> get products =>
      List.unmodifiable(_products);

  List<InventoryCategory> get categories =>
      List.unmodifiable(_categories);

  List<StockMovement> get movements =>
      List.unmodifiable(_movements);

  List<InventoryBranch> get branches =>
      List.unmodifiable(_branches);

  List<InventoryCustomer> get customers =>
      List.unmodifiable(_customers);

  List<SaleRecord> get sales =>
      List.unmodifiable(_sales);

  List<SalesReturnRecord> get salesReturns =>
      List.unmodifiable(_salesReturns);

  // ==========================================================
  // INVENTORY SUMMARY
  // ==========================================================

  int get totalProducts => _products.length;

  int get totalCategories => _categories.length;

  int get totalBranches =>
      _branches.where((branch) => branch.active).length;

  int get totalCustomers =>
      _customers.where((customer) => customer.active).length;

  int get totalStock =>
      _products.fold(0, (sum, product) => sum + product.quantity);

  double get totalStockValue => _products.fold(
        0.0,
        (sum, product) =>
            sum + (product.quantity * product.costPrice),
      );

  double get totalSellingValue => _products.fold(
        0.0,
        (sum, product) =>
            sum + (product.quantity * product.sellingPrice),
      );

  int get lowStockCount => _products
      .where((product) => product.quantity <= product.minimumStock)
      .length;

  int get outOfStockCount =>
      _products.where((product) => product.quantity <= 0).length;

  double get totalSales =>
      _sales.fold(0.0, (sum, sale) => sum + sale.total);

  double get totalProfit =>
      _sales.fold(0.0, (sum, sale) => sum + sale.profit);

  double get totalOutstanding =>
      _sales.fold(0.0, (sum, sale) => sum + sale.balanceDue);

  int get todaySalesCount {
    final now = DateTime.now();

    return _sales.where((sale) =>
        sale.date.year == now.year &&
        sale.date.month == now.month &&
        sale.date.day == now.day).length;
  }

  double get todaySales {
    final now = DateTime.now();

    return _sales
        .where((sale) =>
            sale.date.year == now.year &&
            sale.date.month == now.month &&
            sale.date.day == now.day)
        .fold(0.0, (sum, sale) => sum + sale.total);
  }

  // ==========================================================
  // SEARCH HELPERS
  // ==========================================================

  InventoryProduct? getProductById(String id) {
    try {
      return _products.firstWhere((product) => product.id == id);
    } catch (_) {
      return null;
    }
  }

  InventoryProduct? getProductBySku(String sku) {
    try {
      return _products.firstWhere(
        (product) => product.sku.toLowerCase() == sku.toLowerCase(),
      );
    } catch (_) {
      return null;
    }
  }

  InventoryProduct? getProductByBarcode(String barcode) {
    try {
      return _products.firstWhere(
        (product) =>
            product.barcode.isNotEmpty &&
            product.barcode == barcode,
      );
    } catch (_) {
      return null;
    }
  }

  InventoryCategory? getCategoryById(String id) {
    try {
      return _categories.firstWhere((category) => category.id == id);
    } catch (_) {
      return null;
    }
  }

  InventoryBranch? getBranchById(String id) {
    try {
      return _branches.firstWhere((branch) => branch.id == id);
    } catch (_) {
      return null;
    }
  }

  InventoryCustomer? getCustomerById(String id) {
    try {
      return _customers.firstWhere((customer) => customer.id == id);
    } catch (_) {
      return null;
    }
  }

  SaleRecord? getSaleByInvoice(String invoiceNumber) {
    try {
      return _sales.firstWhere(
        (sale) => sale.invoiceNumber == invoiceNumber,
      );
    } catch (_) {
      return null;
    }
  }

  // ==========================================================
  // PRODUCT FILTERING
  // ==========================================================

  List<InventoryProduct> searchProducts(String query) {
    final search = query.trim().toLowerCase();

    if (search.isEmpty) return List.unmodifiable(_products);

    return _products.where((product) {
      return product.name.toLowerCase().contains(search) ||
          product.sku.toLowerCase().contains(search) ||
          product.barcode.toLowerCase().contains(search) ||
          product.category.toLowerCase().contains(search) ||
          product.supplier.toLowerCase().contains(search);
    }).toList();
  }

  List<InventoryProduct> getProductsByCategory(String category) {
    return _products
        .where((product) =>
            product.category.toLowerCase() == category.toLowerCase())
        .toList();
  }

  List<InventoryProduct> getLowStockProducts() {
    return _products
        .where((product) => product.quantity <= product.minimumStock)
        .toList();
  }

  List<InventoryProduct> getOutOfStockProducts() {
    return _products
        .where((product) => product.quantity <= 0)
        .toList();
  }

  // ==========================================================
  // PRODUCT SORTING
  // ==========================================================

  List<InventoryProduct> sortProducts(String sortBy) {
    final result = List<InventoryProduct>.from(_products);

    switch (sortBy) {
      case 'a-z':
        result.sort((a, b) =>
            a.name.toLowerCase().compareTo(b.name.toLowerCase()));
        break;

      case 'z-a':
        result.sort((a, b) =>
            b.name.toLowerCase().compareTo(a.name.toLowerCase()));
        break;

      case 'high-stock':
        result.sort((a, b) => b.quantity.compareTo(a.quantity));
        break;

      case 'low-stock':
        result.sort((a, b) => a.quantity.compareTo(b.quantity));
        break;

      case 'high-value':
        result.sort((a, b) =>
            (b.quantity * b.costPrice)
                .compareTo(a.quantity * a.costPrice));
        break;

      case 'low-value':
        result.sort((a, b) =>
            (a.quantity * a.costPrice)
                .compareTo(b.quantity * b.costPrice));
        break;

      case 'high-price':
        result.sort(
            (a, b) => b.sellingPrice.compareTo(a.sellingPrice));
        break;

      case 'low-price':
        result.sort(
            (a, b) => a.sellingPrice.compareTo(b.sellingPrice));
        break;

      case 'newest':
        result.sort((a, b) => b.id.compareTo(a.id));
        break;

      case 'oldest':
        result.sort((a, b) => a.id.compareTo(b.id));
        break;

      default:
        break;
    }

    return result;
  }

  // ==========================================================
  // CATEGORY FILTERING AND SORTING
  // ==========================================================

  List<InventoryCategory> searchCategories(String query) {
    final search = query.trim().toLowerCase();

    if (search.isEmpty) return List.unmodifiable(_categories);

    return _categories.where((category) {
      return category.name.toLowerCase().contains(search) ||
          category.code.toLowerCase().contains(search) ||
          category.description.toLowerCase().contains(search);
    }).toList();
  }

  List<InventoryCategory> sortCategories(String sortBy) {
    final result = List<InventoryCategory>.from(_categories);

    switch (sortBy) {
      case 'a-z':
        result.sort((a, b) => a.name.compareTo(b.name));
        break;
      case 'z-a':
        result.sort((a, b) => b.name.compareTo(a.name));
        break;
      case 'active':
        result.sort((a, b) =>
            (b.active ? 1 : 0).compareTo(a.active ? 1 : 0));
        break;
      case 'inactive':
        result.sort((a, b) =>
            (a.active ? 1 : 0).compareTo(b.active ? 1 : 0));
        break;
    }

    return result;
  }

  // ==========================================================
  // BRANCH FILTERING AND SORTING
  // ==========================================================

  List<InventoryBranch> searchBranches(String query) {
    final search = query.trim().toLowerCase();

    if (search.isEmpty) return List.unmodifiable(_branches);

    return _branches.where((branch) {
      return branch.name.toLowerCase().contains(search) ||
          branch.code.toLowerCase().contains(search) ||
          branch.city.toLowerCase().contains(search) ||
          branch.manager.toLowerCase().contains(search);
    }).toList();
  }

  List<InventoryBranch> sortBranches(String sortBy) {
    final result = List<InventoryBranch>.from(_branches);

    switch (sortBy) {
      case 'a-z':
        result.sort((a, b) => a.name.compareTo(b.name));
        break;
      case 'z-a':
        result.sort((a, b) => b.name.compareTo(a.name));
        break;
      case 'active':
        result.sort((a, b) =>
            (b.active ? 1 : 0).compareTo(a.active ? 1 : 0));
        break;
      case 'inactive':
        result.sort((a, b) =>
            (a.active ? 1 : 0).compareTo(b.active ? 1 : 0));
        break;
    }

    return result;
  }

  // ==========================================================
  // CUSTOMER FILTERING AND SORTING
  // ==========================================================

  List<InventoryCustomer> searchCustomers(String query) {
    final search = query.trim().toLowerCase();

    if (search.isEmpty) return List.unmodifiable(_customers);

    return _customers.where((customer) {
      return customer.name.toLowerCase().contains(search) ||
          customer.code.toLowerCase().contains(search) ||
          customer.phone.toLowerCase().contains(search) ||
          customer.email.toLowerCase().contains(search);
    }).toList();
  }

  List<InventoryCustomer> sortCustomers(String sortBy) {
    final result = List<InventoryCustomer>.from(_customers);

    switch (sortBy) {
      case 'a-z':
        result.sort((a, b) => a.name.compareTo(b.name));
        break;
      case 'z-a':
        result.sort((a, b) => b.name.compareTo(a.name));
        break;
      case 'newest':
        result.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        break;
      case 'oldest':
        result.sort((a, b) => a.createdAt.compareTo(b.createdAt));
        break;
      case 'active':
        result.sort((a, b) =>
            (b.active ? 1 : 0).compareTo(a.active ? 1 : 0));
        break;
      case 'inactive':
        result.sort((a, b) =>
            (a.active ? 1 : 0).compareTo(b.active ? 1 : 0));
        break;
    }

    return result;
  }

  // ==========================================================
  // PRODUCT MANAGEMENT
  // ==========================================================

  void addProduct(InventoryProduct product) {
    if (_products.any((e) => e.id == product.id)) {
      throw Exception('A product with this ID already exists.');
    }

    if (_products.any(
        (e) => e.sku.toLowerCase() == product.sku.toLowerCase())) {
      throw Exception('A product with this SKU already exists.');
    }

    _products.add(product);
    notifyListeners();
  }

  void updateProduct(InventoryProduct updatedProduct) {
    final index =
        _products.indexWhere((e) => e.id == updatedProduct.id);

    if (index == -1) {
      throw Exception('Product not found.');
    }

    final duplicateSku = _products.any((e) =>
        e.id != updatedProduct.id &&
        e.sku.toLowerCase() == updatedProduct.sku.toLowerCase());

    if (duplicateSku) {
      throw Exception('Another product already uses this SKU.');
    }

    _products[index] = updatedProduct;
    notifyListeners();
  }

  void deleteProduct(String productId) {
    final exists = _products.any((e) => e.id == productId);

    if (!exists) {
      throw Exception('Product not found.');
    }

    _products.removeWhere((e) => e.id == productId);
    notifyListeners();
  }

  // ==========================================================
  // CATEGORY MANAGEMENT
  // ==========================================================

  void addCategory(InventoryCategory category) {
    if (_categories.any((e) => e.id == category.id)) {
      throw Exception('Category ID already exists.');
    }

    if (_categories.any(
        (e) => e.name.toLowerCase() == category.name.toLowerCase())) {
      throw Exception('Category name already exists.');
    }

    if (_categories.any(
        (e) => e.code.toLowerCase() == category.code.toLowerCase())) {
      throw Exception('Category code already exists.');
    }

    _categories.add(category);
    notifyListeners();
  }

  void updateCategory(InventoryCategory updatedCategory) {
    final index =
        _categories.indexWhere((e) => e.id == updatedCategory.id);

    if (index == -1) {
      throw Exception('Category not found.');
    }

    final duplicateName = _categories.any((e) =>
        e.id != updatedCategory.id &&
        e.name.toLowerCase() == updatedCategory.name.toLowerCase());

    final duplicateCode = _categories.any((e) =>
        e.id != updatedCategory.id &&
        e.code.toLowerCase() == updatedCategory.code.toLowerCase());

    if (duplicateName || duplicateCode) {
      throw Exception('Category name or code already exists.');
    }

    _categories[index] = updatedCategory;
    notifyListeners();
  }

  void deleteCategory(String categoryId) {
    final category = getCategoryById(categoryId);

    if (category == null) {
      throw Exception('Category not found.');
    }

    final hasProducts = _products.any(
      (product) =>
          product.category.toLowerCase() ==
          category.name.toLowerCase(),
    );

    if (hasProducts) {
      throw Exception(
        'Cannot delete a category that contains products.',
      );
    }

    _categories.removeWhere((e) => e.id == categoryId);
    notifyListeners();
  }

  void toggleCategoryStatus(String categoryId) {
    final category = getCategoryById(categoryId);

    if (category == null) {
      throw Exception('Category not found.');
    }

    category.active = !category.active;
    notifyListeners();
  }

  // ==========================================================
  // BRANCH MANAGEMENT
  // ==========================================================

  void addBranch(InventoryBranch branch) {
    if (_branches.any((e) => e.id == branch.id)) {
      throw Exception('Branch ID already exists.');
    }

    if (_branches.any(
        (e) => e.code.toLowerCase() == branch.code.toLowerCase())) {
      throw Exception('Branch code already exists.');
    }

    _branches.add(branch);
    notifyListeners();
  }

  void updateBranch(InventoryBranch updatedBranch) {
    final index =
        _branches.indexWhere((e) => e.id == updatedBranch.id);

    if (index == -1) {
      throw Exception('Branch not found.');
    }

    final duplicateCode = _branches.any((e) =>
        e.id != updatedBranch.id &&
        e.code.toLowerCase() == updatedBranch.code.toLowerCase());

    if (duplicateCode) {
      throw Exception('Another branch already uses this code.');
    }

    _branches[index] = updatedBranch;
    notifyListeners();
  }

  void deleteBranch(String branchId) {
    final branch = getBranchById(branchId);

    if (branch == null) {
      throw Exception('Branch not found.');
    }

    if (_products.any(
        (product) => (product.branchQuantities[branchId] ?? 0) > 0)) {
      throw Exception(
        'Cannot delete a branch containing stock.',
      );
    }

    _branches.removeWhere((e) => e.id == branchId);
    notifyListeners();
  }

  void toggleBranchStatus(String branchId) {
    final branch = getBranchById(branchId);

    if (branch == null) {
      throw Exception('Branch not found.');
    }

    branch.active = !branch.active;
    notifyListeners();
  }

  // ==========================================================
  // CUSTOMER MANAGEMENT
  // ==========================================================

  void addCustomer(InventoryCustomer customer) {
    if (_customers.any((e) => e.id == customer.id)) {
      throw Exception('Customer ID already exists.');
    }

    if (_customers.any(
        (e) => e.code.toLowerCase() == customer.code.toLowerCase())) {
      throw Exception('Customer code already exists.');
    }

    _customers.add(customer);
    notifyListeners();
  }

  void updateCustomer(InventoryCustomer updatedCustomer) {
    final index =
        _customers.indexWhere((e) => e.id == updatedCustomer.id);

    if (index == -1) {
      throw Exception('Customer not found.');
    }

    final duplicateCode = _customers.any((e) =>
        e.id != updatedCustomer.id &&
        e.code.toLowerCase() == updatedCustomer.code.toLowerCase());

    if (duplicateCode) {
      throw Exception('Another customer already uses this code.');
    }

    _customers[index] = updatedCustomer;
    notifyListeners();
  }

  void deleteCustomer(String customerId) {
    final exists = _customers.any((e) => e.id == customerId);

    if (!exists) {
      throw Exception('Customer not found.');
    }

    _customers.removeWhere((e) => e.id == customerId);
    notifyListeners();
  }

  void toggleCustomerStatus(String customerId) {
    final customer = getCustomerById(customerId);

    if (customer == null) {
      throw Exception('Customer not found.');
    }

    customer.active = !customer.active;
    notifyListeners();
  }

  // ==========================================================
  // STOCK HELPERS
  // ==========================================================

  int getBranchStock(String productId, String branchId) {
    final product = getProductById(productId);

    if (product == null) return 0;

    return product.branchQuantities[branchId] ?? 0;
  }

  void _recordMovement({
    required InventoryProduct product,
    required String type,
    required int quantity,
    required String branchId,
    String? transferCode,
  }) {
    _movements.add(
      StockMovement(
        referenceCode: generateStockMovementCode(),
        productId: product.id,
        productName: product.name,
        type: type,
        quantity: quantity,
        date: DateTime.now(),
        branchId: branchId,
        transferCode: transferCode,
      ),
    );
  }

  // ==========================================================
  // STOCK ADJUSTMENT
  // ==========================================================

  void adjustStock({
    required String productId,
    required int quantity,
    required String branchId,
    required String reason,
  }) {
    if (quantity == 0) {
      throw Exception('Adjustment quantity cannot be zero.');
    }

    final product = getProductById(productId);

    if (product == null) {
      throw Exception('Product not found.');
    }

    if (getBranchById(branchId) == null) {
      throw Exception('Branch not found.');
    }

    final current = product.branchQuantities[branchId] ?? 0;
    final updated = current + quantity;

    if (updated < 0) {
      throw Exception('Insufficient stock for this adjustment.');
    }

    product.branchQuantities[branchId] = updated;

    product.quantity =
        product.branchQuantities.values.fold(0, (a, b) => a + b);

    _recordMovement(
      product: product,
      type: quantity > 0 ? 'Stock Added' : 'Stock Removed',
      quantity: quantity.abs(),
      branchId: branchId,
    );

    notifyListeners();
  }

  // ==========================================================
  // BRANCH TRANSFER
  // ==========================================================

  void transferStock({
    required String productId,
    required String fromBranchId,
    required String toBranchId,
    required int quantity,
  }) {
    if (quantity <= 0) {
      throw Exception('Transfer quantity must be greater than zero.');
    }

    if (fromBranchId == toBranchId) {
      throw Exception('Select two different branches.');
    }

    final product = getProductById(productId);

    if (product == null) {
      throw Exception('Product not found.');
    }

    if (getBranchById(fromBranchId) == null ||
        getBranchById(toBranchId) == null) {
      throw Exception('One or both branches were not found.');
    }

    final available = product.branchQuantities[fromBranchId] ?? 0;

    if (available < quantity) {
      throw Exception('Not enough stock in the source branch.');
    }

    final transferCode = generateTransferCode();

    product.branchQuantities[fromBranchId] = available - quantity;

    product.branchQuantities[toBranchId] =
        (product.branchQuantities[toBranchId] ?? 0) + quantity;

    product.quantity =
        product.branchQuantities.values.fold(0, (a, b) => a + b);

    _recordMovement(
      product: product,
      type: 'Transfer Out',
      quantity: quantity,
      branchId: fromBranchId,
      transferCode: transferCode,
    );

    _recordMovement(
      product: product,
      type: 'Transfer In',
      quantity: quantity,
      branchId: toBranchId,
      transferCode: transferCode,
    );

    notifyListeners();
  }

  // ==========================================================
  // STOCK MOVEMENT SEARCH AND SORTING
  // ==========================================================

  List<StockMovement> searchMovements(String query) {
    final search = query.trim().toLowerCase();

    if (search.isEmpty) return List.unmodifiable(_movements);

    return _movements.where((movement) {
      return movement.referenceCode.toLowerCase().contains(search) ||
          movement.productName.toLowerCase().contains(search) ||
          movement.productId.toLowerCase().contains(search) ||
          movement.type.toLowerCase().contains(search) ||
          (movement.transferCode ?? '').toLowerCase().contains(search);
    }).toList();
  }

  List<StockMovement> sortMovements(String sortBy) {
    final result = List<StockMovement>.from(_movements);

    switch (sortBy) {
      case 'newest':
        result.sort((a, b) => b.date.compareTo(a.date));
        break;
      case 'oldest':
        result.sort((a, b) => a.date.compareTo(b.date));
        break;
      case 'high-quantity':
        result.sort((a, b) => b.quantity.compareTo(a.quantity));
        break;
      case 'low-quantity':
        result.sort((a, b) => a.quantity.compareTo(b.quantity));
        break;
      case 'a-z':
        result.sort((a, b) => a.productName.compareTo(b.productName));
        break;
      case 'z-a':
        result.sort((a, b) => b.productName.compareTo(a.productName));
        break;
    }

    return result;
  }

  // ==========================================================
  // SALES MANAGEMENT
  // ==========================================================

  void createSale({
    required String branchId,
    required String customerName,
    required String customerPhone,
    required String paymentMethod,
    required List<SalesCartItem> cartItems,
    required double discount,
    required double tax,
    required double amountPaid,
  }) {
    if (cartItems.isEmpty) {
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

    // Validate every item before changing stock.
    for (final cartItem in cartItems) {
      if (cartItem.quantity <= 0) {
        throw Exception('Product quantity must be greater than zero.');
      }

      if (cartItem.unitPrice < 0) {
        throw Exception('Product price cannot be negative.');
      }

      final product = getProductById(cartItem.productId);

      if (product == null) {
        throw Exception('A product in the cart no longer exists.');
      }

      final available = product.branchQuantities[branchId] ?? 0;

      if (available < cartItem.quantity) {
        throw Exception(
          'Insufficient stock for ${product.name}.',
        );
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

    // Update stock after all validation succeeds.
    for (final item in saleItems) {
      final product = getProductById(item.productId)!;

      product.branchQuantities[branchId] =
          (product.branchQuantities[branchId] ?? 0) - item.quantity;

      product.quantity =
          product.branchQuantities.values.fold(0, (a, b) => a + b);

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
  }

  // ==========================================================
  // PAYMENT MANAGEMENT
  // Only payment amount can be changed.
  // ==========================================================

  void updateSalePayment({
    required String invoiceNumber,
    required double amountPaid,
  }) {
    if (amountPaid < 0) {
      throw Exception('Payment amount cannot be negative.');
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
      paymentMethod: oldSale.paymentMethod,
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

  // ==========================================================
  // SALES SEARCH AND SORTING
  // ==========================================================

  List<SaleRecord> searchSales(String query) {
    final search = query.trim().toLowerCase();

    if (search.isEmpty) return List.unmodifiable(_sales);

    return _sales.where((sale) {
      return sale.invoiceNumber.toLowerCase().contains(search) ||
          sale.customerName.toLowerCase().contains(search) ||
          sale.customerPhone.toLowerCase().contains(search) ||
          sale.paymentMethod.toLowerCase().contains(search);
    }).toList();
  }

  List<SaleRecord> sortSales(String sortBy) {
    final result = List<SaleRecord>.from(_sales);

    switch (sortBy) {
      case 'newest':
        result.sort((a, b) => b.date.compareTo(a.date));
        break;
      case 'oldest':
        result.sort((a, b) => a.date.compareTo(b.date));
        break;
      case 'high-value':
        result.sort((a, b) => b.total.compareTo(a.total));
        break;
      case 'low-value':
        result.sort((a, b) => a.total.compareTo(b.total));
        break;
      case 'paid':
        result.sort((a, b) =>
            (b.paymentStatus == 'Paid' ? 1 : 0)
                .compareTo(a.paymentStatus == 'Paid' ? 1 : 0));
        break;
      case 'unpaid':
        result.sort((a, b) =>
            (a.paymentStatus == 'Paid' ? 1 : 0)
                .compareTo(b.paymentStatus == 'Paid' ? 1 : 0));
        break;
    }

    return result;
  }

  // ==========================================================
  // SALES RETURNS
  // ==========================================================

  void createSalesReturn({
    required String originalInvoiceNumber,
    required List<SalesReturnLine> items,
    required String reason,
  }) {
    if (items.isEmpty) {
      throw Exception('Select at least one product to return.');
    }

    final saleIndex = _sales.indexWhere(
      (sale) => sale.invoiceNumber == originalInvoiceNumber,
    );

    if (saleIndex == -1) {
      throw Exception('Original sale was not found.');
    }

    final originalSale = _sales[saleIndex];

    // Track quantities already returned from this invoice.
    final alreadyReturned = <String, int>{};

    for (final previousReturn in _salesReturns.where(
      (record) => record.originalInvoiceNumber == originalInvoiceNumber,
    )) {
      for (final item in previousReturn.items) {
        alreadyReturned[item.productId] =
            (alreadyReturned[item.productId] ?? 0) + item.quantity;
      }
    }

    // Validate the requested return before modifying stock.
    for (final returnItem in items) {
      if (returnItem.quantity <= 0) {
        throw Exception('Return quantity must be greater than zero.');
      }

      final soldQuantity = originalSale.items
          .where((item) => item.productId == returnItem.productId)
          .fold(0, (sum, item) => sum + item.quantity);

      final returnedQuantity =
          alreadyReturned[returnItem.productId] ?? 0;

      if (returnedQuantity + returnItem.quantity > soldQuantity) {
        throw Exception(
          'Return quantity exceeds the original sold quantity.',
        );
      }

      if (!originalSale.items.any(
          (item) => item.productId == returnItem.productId)) {
        throw Exception('A returned product was not in this sale.');
      }

      if (returnItem.unitPrice < 0) {
        throw Exception('Return price cannot be negative.');
      }
    }

    final branchId = originalSale.branchId;

    final returnTotal = items.fold<double>(
      0,
      (sum, item) => sum + item.total,
    );

    // Restore returned quantities to the original sale branch.
    for (final item in items) {
      final product = getProductById(item.productId);

      if (product == null) {
        throw Exception(
          'Product ${item.productName} no longer exists.',
        );
      }
    }

    for (final item in items) {
      final product = getProductById(item.productId)!;

      product.branchQuantities[branchId] =
          (product.branchQuantities[branchId] ?? 0) + item.quantity;

      product.quantity =
          product.branchQuantities.values.fold(0, (a, b) => a + b);

      _recordMovement(
        product: product,
        type: 'Sales Return',
        quantity: item.quantity,
        branchId: branchId,
      );
    }

    _salesReturns.add(
      SalesReturnRecord(
        returnNumber: generateReturnCode(),
        originalInvoiceNumber: originalInvoiceNumber,
        branchId: branchId,
        customerName: originalSale.customerName,
        items: List<SalesReturnLine>.from(items),
        total: returnTotal,
        reason: reason,
        date: DateTime.now(),
      ),
    );

    notifyListeners();
  }

  List<SalesReturnRecord> searchSalesReturns(String query) {
    final search = query.trim().toLowerCase();

    if (search.isEmpty) {
      return List.unmodifiable(_salesReturns);
    }

    return _salesReturns.where((record) {
      return record.returnNumber.toLowerCase().contains(search) ||
          record.originalInvoiceNumber.toLowerCase().contains(search) ||
          record.customerName.toLowerCase().contains(search) ||
          record.reason.toLowerCase().contains(search);
    }).toList();
  }

  List<SalesReturnRecord> sortSalesReturns(String sortBy) {
    final result = List<SalesReturnRecord>.from(_salesReturns);

    switch (sortBy) {
      case 'newest':
        result.sort((a, b) => b.date.compareTo(a.date));
        break;
      case 'oldest':
        result.sort((a, b) => a.date.compareTo(b.date));
        break;
      case 'high-value':
        result.sort((a, b) => b.total.compareTo(a.total));
        break;
      case 'low-value':
        result.sort((a, b) => a.total.compareTo(b.total));
        break;
    }

    return result;
  }

  // ==========================================================
  // PERMANENT LOCAL STORAGE
  // ==========================================================

  /// Loads saved inventory from the phone.
  ///
  /// Must complete before showing the dashboard.
  Future<void> initialize() async {
    if (_storageInitialized) return;

    _restoringStorage = true;

    try {
      final savedData =
          await InventoryStorage.instance.loadSnapshot();

      if (savedData != null) {
        _restoreSnapshot(savedData);
      }

      _storageInitialized = true;
    } catch (error, stackTrace) {
      debugPrint('Inventory loading failed: $error');
      debugPrintStack(stackTrace: stackTrace);
      rethrow;
    } finally {
      _restoringStorage = false;
    }

    // First launch: save the initial sample data.
    if (await InventoryStorage.instance.loadSnapshot() == null) {
      _queueSave();
    }
  }

  /// Automatically saves whenever inventory changes.
  @override
  void notifyListeners() {
    super.notifyListeners();

    if (_storageInitialized && !_restoringStorage) {
      _queueSave();
    }
  }

  /// Adds a save operation to the queue.
  void _queueSave() {
    if (!_storageInitialized || _restoringStorage) return;

    final snapshot = _createSnapshot();

    _saveQueue = _saveQueue
        .then((_) => InventoryStorage.instance.saveSnapshot(snapshot))
        .catchError((Object error, StackTrace stackTrace) {
      debugPrint('Inventory saving failed: $error');
      debugPrintStack(stackTrace: stackTrace);
    });
  }

  /// Waits for pending database operations.
  Future<void> waitForPendingSaves() async {
    await _saveQueue;
  }

  // ==========================================================
  // EXPORT INVENTORY TO JSON
  // ==========================================================

  Map<String, dynamic> _createSnapshot() {
    return {
      'categories': _categories.map((e) => {
        'id': e.id,
        'name': e.name,
        'code': e.code,
        'description': e.description,
        'active': e.active,
      }).toList(),

      'products': _products.map((e) => {
        'id': e.id,
        'name': e.name,
        'sku': e.sku,
        'category': e.category,
        'barcode': e.barcode,
        'description': e.description,
        'costPrice': e.costPrice,
        'sellingPrice': e.sellingPrice,
        'unit': e.unit,
        'minimumStock': e.minimumStock,
        'supplier': e.supplier,
        'quantity': e.quantity,
        'branchQuantities': e.branchQuantities,
      }).toList(),

      'movements': _movements.map((e) => {
        'referenceCode': e.referenceCode,
        'productId': e.productId,
        'productName': e.productName,
        'type': e.type,
        'quantity': e.quantity,
        'date': e.date.toIso8601String(),
        'branchId': e.branchId,
        'transferCode': e.transferCode,
      }).toList(),

      'branches': _branches.map((e) => {
        'id': e.id,
        'name': e.name,
        'code': e.code,
        'city': e.city,
        'address': e.address,
        'phone': e.phone,
        'email': e.email,
        'manager': e.manager,
        'active': e.active,
      }).toList(),

      'customers': _customers.map((e) => {
        'id': e.id,
        'code': e.code,
        'name': e.name,
        'phone': e.phone,
        'email': e.email,
        'address': e.address,
        'city': e.city,
        'country': e.country,
        'notes': e.notes,
        'createdAt': e.createdAt.toIso8601String(),
        'active': e.active,
      }).toList(),

      'sales': _sales.map((e) => {
        'invoiceNumber': e.invoiceNumber,
        'branchId': e.branchId,
        'customerName': e.customerName,
        'customerPhone': e.customerPhone,
        'paymentMethod': e.paymentMethod,
        'items': e.items.map((item) => {
          'productId': item.productId,
          'productName': item.productName,
          'sku': item.sku,
          'quantity': item.quantity,
          'unitPrice': item.unitPrice,
          'costPrice': item.costPrice,
        }).toList(),
        'subtotal': e.subtotal,
        'discount': e.discount,
        'tax': e.tax,
        'total': e.total,
        'amountPaid': e.amountPaid,
        'date': e.date.toIso8601String(),
      }).toList(),

      'salesReturns': _salesReturns.map((e) => {
        'returnNumber': e.returnNumber,
        'originalInvoiceNumber': e.originalInvoiceNumber,
        'branchId': e.branchId,
        'customerName': e.customerName,
        'items': e.items.map((item) => {
          'productId': item.productId,
          'productName': item.productName,
          'sku': item.sku,
          'quantity': item.quantity,
          'unitPrice': item.unitPrice,
        }).toList(),
        'total': e.total,
        'reason': e.reason,
        'date': e.date.toIso8601String(),
      }).toList(),
    };
  }

  // ==========================================================
  // RESTORE INVENTORY FROM JSON
  // ==========================================================

  void _restoreSnapshot(Map<String, dynamic> data) {
    String stringValue(dynamic value, [String fallback = '']) {
      return value == null ? fallback : value.toString();
    }

    int intValue(dynamic value, [int fallback = 0]) {
      if (value is num) return value.toInt();
      return int.tryParse(value?.toString() ?? '') ?? fallback;
    }

    double doubleValue(dynamic value, [double fallback = 0]) {
      if (value is num) return value.toDouble();
      return double.tryParse(value?.toString() ?? '') ?? fallback;
    }

    bool boolValue(dynamic value, [bool fallback = true]) {
      return value is bool ? value : fallback;
    }

    DateTime dateValue(dynamic value) {
      return DateTime.tryParse(value?.toString() ?? '') ??
          DateTime.now();
    }

    Map<String, dynamic> mapValue(dynamic value) {
      if (value is Map) {
        return Map<String, dynamic>.from(value);
      }
      return {};
    }

    List<dynamic> listValue(dynamic value) {
      return value is List ? value : [];
    }

    // Restore categories.
    _categories
      ..clear()
      ..addAll(listValue(data['categories']).map((value) {
        final e = mapValue(value);

        return InventoryCategory(
          id: stringValue(e['id']),
          name: stringValue(e['name']),
          code: stringValue(e['code']),
          description: stringValue(e['description']),
          active: boolValue(e['active']),
        );
      }));

    // Restore products.
    _products
      ..clear()
      ..addAll(listValue(data['products']).map((value) {
        final e = mapValue(value);
        final branchData = mapValue(e['branchQuantities']);

        return InventoryProduct(
          id: stringValue(e['id']),
          name: stringValue(e['name']),
          sku: stringValue(e['sku']),
          category: stringValue(e['category']),
          barcode: stringValue(e['barcode']),
          description: stringValue(e['description']),
          costPrice: doubleValue(e['costPrice']),
          sellingPrice: doubleValue(e['sellingPrice']),
          unit: stringValue(e['unit'], 'Pieces'),
          minimumStock: intValue(e['minimumStock'], 5),
          supplier: stringValue(e['supplier']),
          quantity: intValue(e['quantity']),
          branchQuantities: branchData.map(
            (key, value) => MapEntry(key, intValue(value)),
          ),
        );
      }));

    // Restore stock movements.
    _movements
      ..clear()
      ..addAll(listValue(data['movements']).map((value) {
        final e = mapValue(value);

        return StockMovement(
          referenceCode: stringValue(e['referenceCode']),
          productId: stringValue(e['productId']),
          productName: stringValue(e['productName']),
          type: stringValue(e['type']),
          quantity: intValue(e['quantity']),
          date: dateValue(e['date']),
          branchId: stringValue(e['branchId'], '1'),
          transferCode: e['transferCode']?.toString(),
        );
      }));

    // Restore branches.
    _branches
      ..clear()
      ..addAll(listValue(data['branches']).map((value) {
        final e = mapValue(value);

        return InventoryBranch(
          id: stringValue(e['id']),
          name: stringValue(e['name']),
          code: stringValue(e['code']),
          city: stringValue(e['city']),
          address: stringValue(e['address']),
          phone: stringValue(e['phone']),
          email: stringValue(e['email']),
          manager: stringValue(e['manager']),
          active: boolValue(e['active']),
        );
      }));

    // Restore customers.
    _customers
      ..clear()
      ..addAll(listValue(data['customers']).map((value) {
        final e = mapValue(value);

        return InventoryCustomer(
          id: stringValue(e['id']),
          code: stringValue(e['code']),
          name: stringValue(e['name']),
          phone: stringValue(e['phone']),
          email: stringValue(e['email']),
          address: stringValue(e['address']),
          city: stringValue(e['city']),
          country: stringValue(e['country'], 'Nepal'),
          notes: stringValue(e['notes']),
          createdAt: dateValue(e['createdAt']),
          active: boolValue(e['active']),
        );
      }));

    // Restore sales.
    _sales
      ..clear()
      ..addAll(listValue(data['sales']).map((value) {
        final e = mapValue(value);

        final items = listValue(e['items']).map((itemValue) {
          final item = mapValue(itemValue);

          return SaleLineItem(
            productId: stringValue(item['productId']),
            productName: stringValue(item['productName']),
            sku: stringValue(item['sku']),
            quantity: intValue(item['quantity']),
            unitPrice: doubleValue(item['unitPrice']),
            costPrice: doubleValue(item['costPrice']),
          );
        }).toList();

        return SaleRecord(
          invoiceNumber: stringValue(e['invoiceNumber']),
          branchId: stringValue(e['branchId']),
          customerName: stringValue(e['customerName']),
          customerPhone: stringValue(e['customerPhone']),
          paymentMethod: stringValue(e['paymentMethod']),
          items: items,
          subtotal: doubleValue(e['subtotal']),
          discount: doubleValue(e['discount']),
          tax: doubleValue(e['tax']),
          total: doubleValue(e['total']),
          amountPaid: doubleValue(e['amountPaid']),
          date: dateValue(e['date']),
        );
      }));

    // Restore sales returns.
    _salesReturns
      ..clear()
      ..addAll(listValue(data['salesReturns']).map((value) {
        final e = mapValue(value);

        final items = listValue(e['items']).map((itemValue) {
          final item = mapValue(itemValue);

          return SalesReturnLine(
            productId: stringValue(item['productId']),
            productName: stringValue(item['productName']),
            sku: stringValue(item['sku']),
            quantity: intValue(item['quantity']),
            unitPrice: doubleValue(item['unitPrice']),
          );
        }).toList();

        return SalesReturnRecord(
          returnNumber: stringValue(e['returnNumber']),
          originalInvoiceNumber:
              stringValue(e['originalInvoiceNumber']),
          branchId: stringValue(e['branchId']),
          customerName: stringValue(e['customerName']),
          items: items,
          total: doubleValue(e['total']),
          reason: stringValue(e['reason']),
          date: dateValue(e['date']),
        );
      }));
  }
}

// ============================================================
// INVENTORY PROVIDER
// ============================================================

final inventoryProvider =
    ChangeNotifierProvider<InventoryData>((ref) {
  return InventoryData();
});

final inventoryInitializationProvider = FutureProvider<void>((ref) async {
  await ref.read(inventoryProvider).initialize();
});
