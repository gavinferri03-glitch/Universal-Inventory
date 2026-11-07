part of 'inventory_data.dart';

extension InventoryStock on InventoryData {
  // ==========================================================
  // BRANCH STOCK LOOKUP
  // ==========================================================

  int getBranchQuantity(String productId, String branchId) {
    final product = getProductById(productId);

    if (product == null) return 0;

    return product.branchQuantities[branchId] ?? 0;
  }

  // ==========================================================
  // STOCK MOVEMENT RECORDING
  // ==========================================================

  void recordStockMovement({
    required String productId,
    required String type,
    required int quantity,
    required String branchId,
  }) {
    if (quantity <= 0) {
      throw Exception('Quantity must be greater than zero.');
    }

    if (type != 'Stock In' && type != 'Stock Out') {
      throw Exception('Invalid stock movement type.');
    }

    final product = getProductById(productId);

    if (product == null) {
      throw Exception('Product not found.');
    }

    if (getBranchById(branchId) == null) {
      throw Exception('Branch not found.');
    }

    final currentQuantity =
        product.branchQuantities[branchId] ?? 0;

    if (type == 'Stock Out' && currentQuantity < quantity) {
      throw Exception('Insufficient stock in this branch.');
    }

    final newQuantity = type == 'Stock In'
        ? currentQuantity + quantity
        : currentQuantity - quantity;

    product.branchQuantities[branchId] = newQuantity;

    product.quantity =
        product.branchQuantities.values.fold<int>(
      0,
      (total, value) => total + value,
    );

    _recordMovement(
      product: product,
      type: type,
      quantity: quantity,
      branchId: branchId,
    );

    notifyListeners();
  }
}