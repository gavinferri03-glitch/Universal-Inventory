
part of 'inventory_data.dart';

extension InventorySales on InventoryData {
  // ==========================================================
  // SALES SUMMARY
  // ==========================================================

  double get totalSalesToday => todaySales;

  int get salesCountToday => todaySalesCount;

  // ==========================================================
  // FIND SALE
  // ==========================================================

  SaleRecord? findSale(String invoiceNumber) {
    return getSaleByInvoice(invoiceNumber);
  }
}
