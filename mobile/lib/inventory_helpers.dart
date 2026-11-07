
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
  // DASHBOARD TOTALS
  // ==========================================================

  double get totalSalesToday => todaySales;

  int get salesCountToday => todaySalesCount;

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
