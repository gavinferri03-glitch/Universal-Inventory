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
