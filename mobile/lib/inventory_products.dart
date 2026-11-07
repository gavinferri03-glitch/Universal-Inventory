part of 'inventory_data.dart';

extension InventoryProducts on InventoryData {
  void addProduct({
    required String name,
    required String sku,
    required String category,
    String barcode = '',
    String description = '',
    double costPrice = 0,
    required double sellingPrice,
    String unit = 'Pieces',
    required int openingQuantity,
    int minimumStock = 5,
    String supplier = '',
    required String initialBranchId,
  }) {
    if (name.trim().isEmpty || sku.trim().isEmpty) {
      throw Exception('Product name and SKU are required.');
    }

    if (_products.any(
      (item) => item.sku.toLowerCase() == sku.trim().toLowerCase(),
    )) {
      throw Exception('This SKU already exists.');
    }

    if (barcode.trim().isNotEmpty &&
        _products.any((item) => item.barcode == barcode.trim())) {
      throw Exception('This barcode already exists.');
    }

    if (sellingPrice < 0 ||
        costPrice < 0 ||
        openingQuantity < 0 ||
        minimumStock < 0) {
      throw Exception('Prices and quantities cannot be negative.');
    }

    if (getBranchById(initialBranchId) == null) {
      throw Exception('Please select a valid branch.');
    }

    final product = InventoryProduct(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      name: name.trim(),
      sku: sku.trim(),
      category: category.trim(),
      barcode: barcode.trim(),
      description: description.trim(),
      costPrice: costPrice,
      sellingPrice: sellingPrice,
      unit: unit,
      minimumStock: minimumStock,
      supplier: supplier.trim(),
      quantity: openingQuantity,
      branchQuantities: {initialBranchId: openingQuantity},
    );

    _products.add(product);

    if (openingQuantity > 0) {
      _recordMovement(
        product: product,
        type: 'Stock In',
        quantity: openingQuantity,
        branchId: initialBranchId,
      );
    }

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
      (item) => item.id == productId,
    );

    if (index == -1) {
      throw Exception('Product not found.');
    }

    final oldProduct = _products[index];

    if (name.trim().isEmpty) {
      throw Exception('Product name is required.');
    }

    if (costPrice < 0 || sellingPrice < 0 || minimumStock < 0) {
      throw Exception('Prices and minimum stock cannot be negative.');
    }

    if (barcode.trim().isNotEmpty &&
        _products.any(
          (item) =>
              item.id != productId && item.barcode == barcode.trim(),
        )) {
      throw Exception('This barcode is already in use.');
    }

    _products[index] = InventoryProduct(
      id: oldProduct.id,
      name: name.trim(),
      sku: oldProduct.sku,
      category: category.trim(),
      barcode: barcode.trim(),
      description: description.trim(),
      costPrice: costPrice,
      sellingPrice: sellingPrice,
      unit: unit,
      minimumStock: minimumStock,
      supplier: supplier.trim(),
      quantity: oldProduct.quantity,
      branchQuantities: Map<String, int>.from(
        oldProduct.branchQuantities,
      ),
    );

    notifyListeners();
  }

  void deleteProduct(String productId) {
    if (getProductById(productId) == null) {
      throw Exception('Product not found.');
    }

    _products.removeWhere((item) => item.id == productId);
    notifyListeners();
  }
}