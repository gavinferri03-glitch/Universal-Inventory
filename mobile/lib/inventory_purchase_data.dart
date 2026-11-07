
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'inventory_data.dart';
import 'inventory_models.dart';

class InventoryPurchaseData extends ChangeNotifier {
  InventoryPurchaseData._();

  static final InventoryPurchaseData instance =
      InventoryPurchaseData._();

  static const String _storageKey = 'inventory_purchase_transactions_v1';

  final List<PurchaseOrderRecord> _purchaseOrders = [];
  final List<SupplierReturnRecord> _supplierReturns = [];

  bool _initialized = false;

  List<PurchaseOrderRecord> get purchaseOrders =>
      List.unmodifiable(_purchaseOrders);

  List<SupplierReturnRecord> get supplierReturns =>
      List.unmodifiable(_supplierReturns);

  Future<void> initialize() async {
    if (_initialized) return;

    final preferences = await SharedPreferences.getInstance();
    final saved = preferences.getString(_storageKey);

    if (saved != null && saved.isNotEmpty) {
      final decoded = jsonDecode(saved);

      if (decoded is Map) {
        final data = Map<String, dynamic>.from(decoded);

        _purchaseOrders
          ..clear()
          ..addAll(_list(data['purchaseOrders']).map(
            (value) => _purchaseFromMap(_map(value)),
          ));

        _supplierReturns
          ..clear()
          ..addAll(_list(data['supplierReturns']).map(
            (value) => _returnFromMap(_map(value)),
          ));
      }
    }

    _initialized = true;
    notifyListeners();
  }

  Future<void> _save() async {
    final preferences = await SharedPreferences.getInstance();

    await preferences.setString(
      _storageKey,
      jsonEncode({
        'purchaseOrders':
            _purchaseOrders.map(_purchaseToMap).toList(),
        'supplierReturns':
            _supplierReturns.map(_returnToMap).toList(),
      }),
    );
  }

  String _nextPurchaseNumber() {
    var number = _purchaseOrders.length + 1;
    var code = 'PO-${number.toString().padLeft(4, '0')}';

    while (_purchaseOrders.any((e) => e.purchaseOrderNumber == code)) {
      number++;
      code = 'PO-${number.toString().padLeft(4, '0')}';
    }

    return code;
  }

  String _nextSupplierReturnNumber() {
    var number = _supplierReturns.length + 1;
    var code = 'SR-${number.toString().padLeft(4, '0')}';

    while (_supplierReturns.any((e) => e.returnNumber == code)) {
      number++;
      code = 'SR-${number.toString().padLeft(4, '0')}';
    }

    return code;
  }

  Future<PurchaseOrderRecord> createPurchaseOrder({
    required InventoryData inventory,
    required String supplierName,
    String supplierPhone = '',
    String supplierAddress = '',
    String supplierInvoiceNumber = '',
    required String branchId,
    required List<PurchaseOrderLine> items,
    double discount = 0,
    double tax = 0,
    double amountPaid = 0,
    String paymentMethod = 'Cash',
    String notes = '',
  }) async {
    if (supplierName.trim().isEmpty) {
      throw Exception('Enter the supplier name.');
    }

    if (items.isEmpty) {
      throw Exception('Add at least one product.');
    }

    if (inventory.getBranchById(branchId) == null) {
      throw Exception('Select a valid branch.');
    }

    for (final item in items) {
      if (item.quantity <= 0 || item.unitCost < 0) {
        throw Exception('Check the product quantities and costs.');
      }

      if (inventory.getProductById(item.productId) == null) {
        throw Exception('A selected product could not be found.');
      }
    }

    final subtotal =
        items.fold<double>(0, (sum, item) => sum + item.total);

    if (discount < 0 || tax < 0 || discount > subtotal) {
      throw Exception('Check the discount and tax amounts.');
    }

    final total = subtotal - discount + tax;

    if (amountPaid < 0) {
      throw Exception('Amount paid cannot be negative.');
    }

    final record = PurchaseOrderRecord(
      purchaseOrderNumber: _nextPurchaseNumber(),
      supplierInvoiceNumber: supplierInvoiceNumber.trim(),
      supplierName: supplierName.trim(),
      supplierPhone: supplierPhone.trim(),
      supplierAddress: supplierAddress.trim(),
      branchId: branchId,
      items: List<PurchaseOrderLine>.from(items),
      subtotal: subtotal,
      discount: discount,
      tax: tax,
      total: total,
      amountPaid: amountPaid,
      paymentMethod: paymentMethod,
      status: 'Received',
      notes: notes.trim(),
      date: DateTime.now(),
    );

    for (final item in items) {
      inventory.recordStockMovement(
        productId: item.productId,
        type: 'Stock In',
        quantity: item.quantity,
        branchId: branchId,
      );

      final product = inventory.getProductById(item.productId)!;
      product.branchQuantities[branchId] =
          product.branchQuantities[branchId] ?? 0;
    }

    _purchaseOrders.insert(0, record);

    await _save();
    notifyListeners();

    return record;
  }

  Future<SupplierReturnRecord> createSupplierReturn({
    required InventoryData inventory,
    required String originalPurchaseOrderNumber,
    required List<SupplierReturnLine> items,
    required String reason,
    String settlementType = 'Supplier Credit',
    String notes = '',
  }) async {
    if (items.isEmpty) {
      throw Exception('Add at least one product to return.');
    }

    final purchase = _purchaseOrders.cast<PurchaseOrderRecord?>().firstWhere(
          (e) => e?.purchaseOrderNumber == originalPurchaseOrderNumber,
          orElse: () => null,
        );

    if (purchase == null) {
      throw Exception('Original purchase order was not found.');
    }

    if (reason.trim().isEmpty) {
      throw Exception('Enter the reason for the return.');
    }

    final alreadyReturned = <String, int>{};

    for (final previous in _supplierReturns.where(
      (e) => e.originalPurchaseOrderNumber == originalPurchaseOrderNumber,
    )) {
      for (final item in previous.items) {
        alreadyReturned[item.productId] =
            (alreadyReturned[item.productId] ?? 0) + item.quantity;
      }
    }

    for (final item in items) {
      if (item.quantity <= 0 || item.unitCost < 0) {
        throw Exception('Check the return quantities and costs.');
      }

      final purchasedQuantity = purchase.items
          .where((e) => e.productId == item.productId)
          .fold<int>(0, (sum, e) => sum + e.quantity);

      final returnedQuantity = alreadyReturned[item.productId] ?? 0;

      if (purchasedQuantity == 0) {
        throw Exception('${item.productName} was not in this purchase.');
      }

      if (returnedQuantity + item.quantity > purchasedQuantity) {
        throw Exception(
          'Return quantity exceeds the purchased quantity for ${item.productName}.',
        );
      }

      final product = inventory.getProductById(item.productId);

      if (product == null) {
        throw Exception('${item.productName} could not be found.');
      }

      final available = inventory.getBranchQuantity(
        item.productId,
        purchase.branchId,
      );

      if (available < item.quantity) {
        throw Exception(
          'Not enough ${item.productName} stock at the original branch.',
        );
      }

      alreadyReturned[item.productId] =
          returnedQuantity + item.quantity;
    }

    final total =
        items.fold<double>(0, (sum, item) => sum + item.total);

    final record = SupplierReturnRecord(
      returnNumber: _nextSupplierReturnNumber(),
      originalPurchaseOrderNumber: originalPurchaseOrderNumber,
      supplierName: purchase.supplierName,
      supplierPhone: purchase.supplierPhone,
      branchId: purchase.branchId,
      items: List<SupplierReturnLine>.from(items),
      total: total,
      reason: reason.trim(),
      settlementType: settlementType,
      notes: notes.trim(),
      date: DateTime.now(),
    );

    for (final item in items) {
      inventory.recordStockMovement(
        productId: item.productId,
        type: 'Stock Out',
        quantity: item.quantity,
        branchId: purchase.branchId,
      );
    }

    _supplierReturns.insert(0, record);

    await _save();
    notifyListeners();

    return record;
  }

  List<PurchaseOrderRecord> searchPurchaseOrders(String query) {
    final q = query.trim().toLowerCase();

    if (q.isEmpty) return purchaseOrders;

    return _purchaseOrders.where((e) =>
        e.purchaseOrderNumber.toLowerCase().contains(q) ||
        e.supplierName.toLowerCase().contains(q) ||
        e.supplierInvoiceNumber.toLowerCase().contains(q)).toList();
  }

  List<SupplierReturnRecord> searchSupplierReturns(String query) {
    final q = query.trim().toLowerCase();

    if (q.isEmpty) return supplierReturns;

    return _supplierReturns.where((e) =>
        e.returnNumber.toLowerCase().contains(q) ||
        e.originalPurchaseOrderNumber.toLowerCase().contains(q) ||
        e.supplierName.toLowerCase().contains(q)).toList();
  }

  Map<String, dynamic> _purchaseToMap(PurchaseOrderRecord e) => {
        'purchaseOrderNumber': e.purchaseOrderNumber,
        'supplierInvoiceNumber': e.supplierInvoiceNumber,
        'supplierName': e.supplierName,
        'supplierPhone': e.supplierPhone,
        'supplierAddress': e.supplierAddress,
        'branchId': e.branchId,
        'items': e.items.map((item) => {
              'productId': item.productId,
              'productName': item.productName,
              'sku': item.sku,
              'unit': item.unit,
              'quantity': item.quantity,
              'unitCost': item.unitCost,
            }).toList(),
        'subtotal': e.subtotal,
        'discount': e.discount,
        'tax': e.tax,
        'total': e.total,
        'amountPaid': e.amountPaid,
        'paymentMethod': e.paymentMethod,
        'status': e.status,
        'notes': e.notes,
        'date': e.date.toIso8601String(),
      };

  Map<String, dynamic> _returnToMap(SupplierReturnRecord e) => {
        'returnNumber': e.returnNumber,
        'originalPurchaseOrderNumber': e.originalPurchaseOrderNumber,
        'supplierName': e.supplierName,
        'supplierPhone': e.supplierPhone,
        'branchId': e.branchId,
        'items': e.items.map((item) => {
              'productId': item.productId,
              'productName': item.productName,
              'sku': item.sku,
              'unit': item.unit,
              'quantity': item.quantity,
              'unitCost': item.unitCost,
            }).toList(),
        'total': e.total,
        'reason': e.reason,
        'settlementType': e.settlementType,
        'notes': e.notes,
        'date': e.date.toIso8601String(),
      };

  PurchaseOrderRecord _purchaseFromMap(Map<String, dynamic> e) {
    return PurchaseOrderRecord(
      purchaseOrderNumber: _string(e['purchaseOrderNumber']),
      supplierInvoiceNumber: _string(e['supplierInvoiceNumber']),
      supplierName: _string(e['supplierName']),
      supplierPhone: _string(e['supplierPhone']),
      supplierAddress: _string(e['supplierAddress']),
      branchId: _string(e['branchId'], '1'),
      items: _list(e['items'])
          .map((value) {
            final item = _map(value);
            return PurchaseOrderLine(
              productId: _string(item['productId']),
              productName: _string(item['productName']),
              sku: _string(item['sku']),
              unit: _string(item['unit'], 'Pieces'),
              quantity: _integer(item['quantity']),
              unitCost: _decimal(item['unitCost']),
            );
          })
          .toList(),
      subtotal: _decimal(e['subtotal']),
      discount: _decimal(e['discount']),
      tax: _decimal(e['tax']),
      total: _decimal(e['total']),
      amountPaid: _decimal(e['amountPaid']),
      paymentMethod: _string(e['paymentMethod'], 'Cash'),
      status: _string(e['status'], 'Received'),
      notes: _string(e['notes']),
      date: DateTime.tryParse(_string(e['date'])) ?? DateTime.now(),
    );
  }

  SupplierReturnRecord _returnFromMap(Map<String, dynamic> e) {
    return SupplierReturnRecord(
      returnNumber: _string(e['returnNumber']),
      originalPurchaseOrderNumber:
          _string(e['originalPurchaseOrderNumber']),
      supplierName: _string(e['supplierName']),
      supplierPhone: _string(e['supplierPhone']),
      branchId: _string(e['branchId'], '1'),
      items: _list(e['items'])
          .map((value) {
            final item = _map(value);
            return SupplierReturnLine(
              productId: _string(item['productId']),
              productName: _string(item['productName']),
              sku: _string(item['sku']),
              unit: _string(item['unit'], 'Pieces'),
              quantity: _integer(item['quantity']),
              unitCost: _decimal(item['unitCost']),
            );
          })
          .toList(),
      total: _decimal(e['total']),
      reason: _string(e['reason']),
      settlementType: _string(e['settlementType'], 'Supplier Credit'),
      notes: _string(e['notes']),
      date: DateTime.tryParse(_string(e['date'])) ?? DateTime.now(),
    );
  }

  Map<String, dynamic> _map(dynamic value) =>
      value is Map ? Map<String, dynamic>.from(value) : {};

  List<dynamic> _list(dynamic value) =>
      value is List ? value : <dynamic>[];

  String _string(dynamic value, [String fallback = '']) =>
      value == null ? fallback : value.toString();

  int _integer(dynamic value) {
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }

  double _decimal(dynamic value) {
    if (value is num) return value.toDouble();
    return double.tryParse(value?.toString() ?? '') ?? 0;
  }
}
