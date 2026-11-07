
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'inventory_purchase_data.dart';

final inventoryPurchaseProvider =
    ChangeNotifierProvider<InventoryPurchaseData>((ref) {
  return InventoryPurchaseData.instance;
});

final inventoryPurchaseInitializationProvider =
    FutureProvider<void>((ref) async {
  await ref.read(inventoryPurchaseProvider).initialize();
});
