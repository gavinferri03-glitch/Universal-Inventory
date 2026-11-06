
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class InventoryProduct {
  final String id;
  final String name;
  final String sku;
  final String category;
  final double sellingPrice;
  int quantity;

  InventoryProduct({
    required this.id,
    required this.name,
    required this.sku,
    required this.category,
    required this.sellingPrice,
    required this.quantity,
  });
}

class StockMovement {
  final String productId;
  final String productName;
  final String type;
  final int quantity;
  final DateTime date;

  StockMovement({
    required this.productId,
    required this.productName,
    required this.type,
    required this.quantity,
    required this.date,
  });
}

class InventoryData extends ChangeNotifier {
  final List<InventoryProduct> _products = [
    InventoryProduct(
      id: '1',
      name: 'Wireless Mouse',
      sku: 'ELE-001',
      category: 'Electronics',
      sellingPrice: 850,
      quantity: 20,
    ),
    InventoryProduct(
      id: '2',
      name: 'USB Keyboard',
      sku: 'ACC-002',
      category: 'Accessories',
      sellingPrice: 1200,
      quantity: 8,
    ),
    InventoryProduct(
      id: '3',
      name: 'HDMI Cable',
      sku: 'ACC-003',
      category: 'Accessories',
      sellingPrice: 450,
      quantity: 5,
    ),
    InventoryProduct(
      id: '4',
      name: 'Bluetooth Speaker',
      sku: 'ELE-004',
      category: 'Electronics',
      sellingPrice: 2500,
      quantity: 35,
    ),
  ];

  final List<StockMovement> _movements = [];

  List<InventoryProduct> get products =>
      List.unmodifiable(_products);

  List<StockMovement> get movements =>
      List.unmodifiable(_movements);

  int get totalStock =>
      _products.fold(0, (total, product) => total + product.quantity);

  int get lowStockCount =>
      _products.where((product) => product.quantity <= 5).length;

  InventoryProduct? findProduct(String productId) {
    for (final product in _products) {
      if (product.id == productId) return product;
    }
    return null;
  }

  void addProduct({
    required String name,
    required String sku,
    required String category,
    required double sellingPrice,
    required int openingQuantity,
  }) {
    final duplicate = _products.any(
      (product) => product.sku.toLowerCase() == sku.toLowerCase(),
    );

    if (duplicate) {
      throw Exception('A product with this SKU already exists.');
    }

    final product = InventoryProduct(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      name: name,
      sku: sku,
      category: category,
      sellingPrice: sellingPrice,
      quantity: openingQuantity,
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
        ),
      );
    }

    notifyListeners();
  }

  void recordStockMovement({
    required String productId,
    required String type,
    required int quantity,
  }) {
    if (quantity <= 0) {
      throw Exception('Quantity must be greater than zero.');
    }

    final product = findProduct(productId);

    if (product == null) {
      throw Exception('Product not found.');
    }

    if (type == 'Stock Out' && product.quantity < quantity) {
      throw Exception('Not enough stock available.');
    }

    if (type != 'Stock In' && type != 'Stock Out') {
      throw Exception('Invalid stock movement type.');
    }

    if (type == 'Stock In') {
      product.quantity += quantity;
    } else {
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
      ),
    );

    notifyListeners();
  }
}

final inventoryProvider =
    ChangeNotifierProvider<InventoryData>((ref) {
  return InventoryData();
});
