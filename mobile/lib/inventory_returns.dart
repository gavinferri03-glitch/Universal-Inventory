
part of 'inventory_data.dart';

mixin InventoryReturns on InventoryData {
  // ==========================================================
  // SALES RETURN LOOKUP
  // ==========================================================

  SalesReturnRecord? findSalesReturn(String returnNumber) {
    try {
      return salesReturns.firstWhere(
        (e) => e.returnNumber == returnNumber,
      );
    } catch (_) {
      return null;
    }
  }

  // ==========================================================
  // RETURN SUMMARY
  // ==========================================================

  int get totalSalesReturns => salesReturns.length;

  double get totalReturnedAmount {
    return salesReturns.fold<double>(
      0,
      (total, item) => total + item.total,
    );
  }
}
