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
  // INITIAL DATA
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

  final List<StockMovement> _movements = [];

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

  final List<InventoryCustomer> _customers = [];
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

  List<InventoryProduct> get products => List.unmodifiable(_products);
  List<InventoryCategory> get categories => List.unmodifiable(_categories);
  List<StockMovement> get movements => List.unmodifiable(_movements);
  List<InventoryBranch> get branches => List.unmodifiable(_branches);
  List<InventoryCustomer> get customers => List.unmodifiable(_customers);
  List<SaleRecord> get sales => List.unmodifiable(_sales);
  List<SalesReturnRecord> get salesReturns =>
      List.unmodifiable(_salesReturns);

  // ==========================================================
  // INVENTORY SUMMARY
  // ==========================================================

  int get totalProducts => _products.length;
  int get totalCategories => _categories.length;
  int get totalBranches => _branches.where((e) => e.active).length;
  int get totalCustomers => _customers.where((e) => e.active).length;
  int get totalStock =>
      _products.fold(0, (sum, product) => sum + product.quantity);

  double get totalStockValue => _products.fold(
        0.0,
        (sum, product) => sum + product.quantity * product.costPrice,
      );

  double get totalSellingValue => _products.fold(
        0.0,
        (sum, product) => sum + product.quantity * product.sellingPrice,
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
  // RECORD LOOKUPS
  // ==========================================================

  InventoryProduct? getProductById(String id) {
    for (final item in _products) {
      if (item.id == id) return item;
    }
    return null;
  }

  InventoryProduct? getProductBySku(String sku) {
    for (final item in _products) {
      if (item.sku.toLowerCase() == sku.toLowerCase()) return item;
    }
    return null;
  }

  InventoryProduct? getProductByBarcode(String barcode) {
    for (final item in _products) {
      if (item.barcode.isNotEmpty && item.barcode == barcode) return item;
    }
    return null;
  }

  InventoryCategory? getCategoryById(String id) {
    for (final item in _categories) {
      if (item.id == id) return item;
    }
    return null;
  }

  InventoryBranch? getBranchById(String id) {
    for (final item in _branches) {
      if (item.id == id) return item;
    }
    return null;
  }

  InventoryCustomer? getCustomerById(String id) {
    for (final item in _customers) {
      if (item.id == id) return item;
    }
    return null;
  }

  SaleRecord? getSaleByInvoice(String invoiceNumber) {
    for (final item in _sales) {
      if (item.invoiceNumber == invoiceNumber) return item;
    }
    return null;
  }

  // ==========================================================
  // PRODUCT SEARCH, FILTER AND SORT
  // ==========================================================

  List<InventoryProduct> searchProducts(String query) {
    final q = query.trim().toLowerCase();
    if (q.isEmpty) return List.unmodifiable(_products);
    return _products.where((p) =>
        p.name.toLowerCase().contains(q) ||
        p.sku.toLowerCase().contains(q) ||
        p.barcode.toLowerCase().contains(q) ||
        p.category.toLowerCase().contains(q) ||
        p.supplier.toLowerCase().contains(q)).toList();
  }

  List<InventoryProduct> getProductsByCategory(String category) =>
      _products.where((p) =>
          p.category.toLowerCase() == category.toLowerCase()).toList();

  List<InventoryProduct> getLowStockProducts() => _products
      .where((p) => p.quantity <= p.minimumStock).toList();

  List<InventoryProduct> getOutOfStockProducts() =>
      _products.where((p) => p.quantity <= 0).toList();

  List<InventoryProduct> sortProducts(String sortBy) {
    final result = List<InventoryProduct>.from(_products);
    switch (sortBy) {
      case 'a-z':
        result.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
        break;
      case 'z-a':
        result.sort((a, b) => b.name.toLowerCase().compareTo(a.name.toLowerCase()));
        break;
      case 'high-stock':
        result.sort((a, b) => b.quantity.compareTo(a.quantity));
        break;
      case 'low-stock':
        result.sort((a, b) => a.quantity.compareTo(b.quantity));
        break;
      case 'high-value':
        result.sort((a, b) =>
            (b.quantity * b.costPrice).compareTo(a.quantity * a.costPrice));
        break;
      case 'low-value':
        result.sort((a, b) =>
            (a.quantity * a.costPrice).compareTo(b.quantity * b.costPrice));
        break;
      case 'high-price':
        result.sort((a, b) => b.sellingPrice.compareTo(a.sellingPrice));
        break;
      case 'low-price':
        result.sort((a, b) => a.sellingPrice.compareTo(b.sellingPrice));
        break;
      case 'newest':
        result.sort((a, b) => b.id.compareTo(a.id));
        break;
      case 'oldest':
        result.sort((a, b) => a.id.compareTo(b.id));
        break;
    }
    return result;
  }

  // ==========================================================
  // CATEGORY SEARCH AND SORT
  // ==========================================================

  List<InventoryCategory> searchCategories(String query) {
    final q = query.trim().toLowerCase();
    if (q.isEmpty) return List.unmodifiable(_categories);
    return _categories.where((c) =>
        c.name.toLowerCase().contains(q) ||
        c.code.toLowerCase().contains(q) ||
        c.description.toLowerCase().contains(q)).toList();
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
        result.sort((a, b) => (b.active ? 1 : 0).compareTo(a.active ? 1 : 0));
        break;
      case 'inactive':
        result.sort((a, b) => (a.active ? 1 : 0).compareTo(b.active ? 1 : 0));
        break;
    }
    return result;
  }

  // ==========================================================
  // BRANCH SEARCH AND SORT
  // ==========================================================

  List<InventoryBranch> searchBranches(String query) {
    final q = query.trim().toLowerCase();
    if (q.isEmpty) return List.unmodifiable(_branches);
    return _branches.where((b) =>
        b.name.toLowerCase().contains(q) ||
        b.code.toLowerCase().contains(q) ||
        b.city.toLowerCase().contains(q) ||
        b.manager.toLowerCase().contains(q)).toList();
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
        result.sort((a, b) => (b.active ? 1 : 0).compareTo(a.active ? 1 : 0));
        break;
      case 'inactive':
        result.sort((a, b) => (a.active ? 1 : 0).compareTo(b.active ? 1 : 0));
        break;
    }
    return result;
  }

  // ==========================================================
  // CUSTOMER SEARCH AND SORT
  // ==========================================================

  List<InventoryCustomer> searchCustomers(String query) {
    final q = query.trim().toLowerCase();
    if (q.isEmpty) return List.unmodifiable(_customers);
    return _customers.where((c) =>
        c.name.toLowerCase().contains(q) ||
        c.code.toLowerCase().contains(q) ||
        c.phone.toLowerCase().contains(q) ||
        c.email.toLowerCase().contains(q)).toList();
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
        result.sort((a, b) => (b.active ? 1 : 0).compareTo(a.active ? 1 : 0));
        break;
      case 'inactive':
        result.sort((a, b) => (a.active ? 1 : 0).compareTo(b.active ? 1 : 0));
        break;
    }
    return result;
  }

  // ==========================================================
  // STOCK OPERATIONS
  // ==========================================================

  int getBranchStock(String productId, String branchId) {
    final product = getProductById(productId);
    return product?.branchQuantities[branchId] ?? 0;
  }

  void _recordMovement({
    required InventoryProduct product,
    required String type,
    required int quantity,
    required String branchId,
    String? transferCode,
  }) {
    _movements.add(StockMovement(
      referenceCode: generateStockMovementCode(),
      productId: product.id,
      productName: product.name,
      type: type,
      quantity: quantity,
      date: DateTime.now(),
      branchId: branchId,
      transferCode: transferCode,
    ));
  }

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
    if (product == null) throw Exception('Product not found.');
    if (getBranchById(branchId) == null) throw Exception('Branch not found.');

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
    if (product == null) throw Exception('Product not found.');
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

  List<StockMovement> searchMovements(String query) {
    final q = query.trim().toLowerCase();
    if (q.isEmpty) return List.unmodifiable(_movements);
    return _movements.where((m) =>
        m.referenceCode.toLowerCase().contains(q) ||
        m.productName.toLowerCase().contains(q) ||
        m.productId.toLowerCase().contains(q) ||
        m.type.toLowerCase().contains(q) ||
        (m.transferCode ?? '').toLowerCase().contains(q)).toList();
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
  // SALES SEARCH AND SORT
  // ==========================================================

  List<SaleRecord> searchSales(String query) {
    final q = query.trim().toLowerCase();
    if (q.isEmpty) return List.unmodifiable(_sales);
    return _sales.where((s) =>
        s.invoiceNumber.toLowerCase().contains(q) ||
        s.customerName.toLowerCase().contains(q) ||
        s.customerPhone.toLowerCase().contains(q) ||
        s.paymentMethod.toLowerCase().contains(q)).toList();
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
    if (saleIndex == -1) throw Exception('Original sale was not found.');

    final originalSale = _sales[saleIndex];
    final alreadyReturned = <String, int>{};

    for (final previousReturn in _salesReturns.where(
      (record) => record.originalInvoiceNumber == originalInvoiceNumber,
    )) {
      for (final item in previousReturn.items) {
        alreadyReturned[item.productId] =
            (alreadyReturned[item.productId] ?? 0) + item.quantity;
      }
    }

    for (final item in items) {
      if (item.quantity <= 0) {
        throw Exception('Return quantity must be greater than zero.');
      }
      final soldQuantity = originalSale.items
          .where((sold) => sold.productId == item.productId)
          .fold(0, (sum, sold) => sum + sold.quantity);
      final returnedQuantity = alreadyReturned[item.productId] ?? 0;

      if (returnedQuantity + item.quantity > soldQuantity) {
        throw Exception('Return quantity exceeds the original sold quantity.');
      }
      if (soldQuantity == 0) {
        throw Exception('A returned product was not in this sale.');
      }
      if (item.unitPrice < 0) {
        throw Exception('Return price cannot be negative.');
      }
      if (getProductById(item.productId) == null) {
        throw Exception('Product ${item.productName} no longer exists.');
      }
      alreadyReturned[item.productId] =
          returnedQuantity + item.quantity;
    }

    final branchId = originalSale.branchId;
    final returnTotal =
        items.fold<double>(0, (sum, item) => sum + item.total);

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

    _salesReturns.add(SalesReturnRecord(
      returnNumber: generateReturnCode(),
      originalInvoiceNumber: originalInvoiceNumber,
      branchId: branchId,
      customerName: originalSale.customerName,
      items: List<SalesReturnLine>.from(items),
      total: returnTotal,
      reason: reason,
      date: DateTime.now(),
    ));
    notifyListeners();
  }

  List<SalesReturnRecord> searchSalesReturns(String query) {
    final q = query.trim().toLowerCase();
    if (q.isEmpty) return List.unmodifiable(_salesReturns);
    return _salesReturns.where((r) =>
        r.returnNumber.toLowerCase().contains(q) ||
        r.originalInvoiceNumber.toLowerCase().contains(q) ||
        r.customerName.toLowerCase().contains(q) ||
        r.reason.toLowerCase().contains(q)).toList();
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

  Future<void> initialize() async {
    if (_storageInitialized) return;
    _restoringStorage = true;

    try {
      final savedData = await InventoryStorage.instance.loadSnapshot();
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

    if (await InventoryStorage.instance.loadSnapshot() == null) {
      _queueSave();
    }
  }

  @override
  void notifyListeners() {
    super.notifyListeners();
    if (_storageInitialized && !_restoringStorage) {
      _queueSave();
    }
  }

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

  Future<void> waitForPendingSaves() async {
    await _saveQueue;
  }

  // ==========================================================
  // SAVE INVENTORY SNAPSHOT
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
  // RESTORE INVENTORY SNAPSHOT
  // ==========================================================

  void _restoreSnapshot(Map<String, dynamic> data) {
    String stringValue(dynamic value, [String fallback = '']) =>
        value == null ? fallback : value.toString();

    int intValue(dynamic value, [int fallback = 0]) {
      if (value is num) return value.toInt();
      return int.tryParse(value?.toString() ?? '') ?? fallback;
    }

    double doubleValue(dynamic value, [double fallback = 0]) {
      if (value is num) return value.toDouble();
      return double.tryParse(value?.toString() ?? '') ?? fallback;
    }

    bool boolValue(dynamic value, [bool fallback = true]) =>
        value is bool ? value : fallback;

    DateTime dateValue(dynamic value) =>
        DateTime.tryParse(value?.toString() ?? '') ?? DateTime.now();

    Map<String, dynamic> mapValue(dynamic value) =>
        value is Map ? Map<String, dynamic>.from(value) : <String, dynamic>{};

    List<dynamic> listValue(dynamic value) =>
        value is List ? value : <dynamic>[];

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
            (key, value) => MapEntry(key.toString(), intValue(value)),
          ),
        );
      }));

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
          originalInvoiceNumber: stringValue(e['originalInvoiceNumber']),
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