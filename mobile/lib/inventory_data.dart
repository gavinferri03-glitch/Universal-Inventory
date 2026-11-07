
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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

  double get balanceDue => (total - amountPaid).clamp(0, double.infinity);

  double get change => (amountPaid - total).clamp(0, double.infinity);
}

class InventoryData extends ChangeNotifier {
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

  final List<StockMovement> _movements = [];

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

  List<InventoryProduct> get products =>
      List.unmodifiable(_products);

  List<StockMovement> get movements =>
      List.unmodifiable(_movements);

  List<InventoryBranch> get branches =>
      List.unmodifiable(_branches);

  int get totalStock =>
      _products.fold(0, (total, product) => total + product.quantity);

  int get lowStockCount =>
      _products.where((product) =>
          product.quantity <= product.minimumStock).length;

  int get activeBranchCount =>
      _branches.where((branch) => branch.active).length;

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

  int getBranchQuantity(String productId, String branchId) {
    final product = findProduct(productId);
    if (product == null) return 0;
    return product.branchQuantities[branchId] ?? 0;
  }

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
      name: name,
      sku: sku,
      category: category,
      barcode: barcode,
      description: description,
      costPrice: costPrice,
      sellingPrice: sellingPrice,
      unit: unit,
      minimumStock: minimumStock,
      supplier: supplier,
      quantity: openingQuantity,
      branchQuantities: {
        initialBranchId: openingQuantity,
      },
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

  // Adds stock to a specific branch.
  void allocateStockToBranch({
    required String productId,
    required String branchId,
    required int quantity,
  }) {
    if (quantity <= 0) {
      throw Exception('Quantity must be greater than zero.');
    }

    final product = findProduct(productId);

    if (product == null) {
      throw Exception('Product not found.');
    }

    if (findBranch(branchId) == null) {
      throw Exception('Branch not found.');
    }

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

    notifyListeners();
  }

  // Transfers stock between two branches without changing total stock.
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

    if (product == null) {
      throw Exception('Product not found.');
    }

    if (findBranch(fromBranchId) == null ||
        findBranch(toBranchId) == null) {
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

    notifyListeners();
  }

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

    if (product == null) {
      throw Exception('Product not found.');
    }

    if (findBranch(branchId) == null) {
      throw Exception('Branch not found.');
    }

    if (type != 'Stock In' && type != 'Stock Out') {
      throw Exception('Invalid stock movement type.');
    }

    final branchStock =
        product.branchQuantities[branchId] ?? 0;

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

    notifyListeners();
  }

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

    if (index == -1) {
      throw Exception('Branch not found.');
    }

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

final inventoryProvider =
    ChangeNotifierProvider<InventoryData>((ref) {
  return InventoryData();
});
