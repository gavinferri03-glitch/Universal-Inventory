part of 'inventory_data.dart';

extension InventoryHelpers on InventoryData {
  // ==========================================================
  // GENERAL LOOKUPS
  // ==========================================================

  InventoryBranch? findBranch(String branchId) {
    return getBranchById(branchId);
  }

  InventoryProduct? findProduct(String productId) {
    return getProductById(productId);
  }

  // ==========================================================
  // STOCK SUMMARY
  // ==========================================================

  int get totalUnitsInStock {
    return products.fold<int>(
      0,
      (total, product) => total + product.quantity,
    );
  }

  int get activeProductsCount {
    return products.length;
  }
}