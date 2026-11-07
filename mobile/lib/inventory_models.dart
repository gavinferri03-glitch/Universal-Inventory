
// ============================================================
// UNIVERSAL INVENTORY - DATA MODELS
// ============================================================

// PRODUCT MODEL

class InventoryProduct {
  final String id;
  final String name;
  final String sku;
  final String category;
  final String barcode;
  final String description;
  final double costPrice;
  final double sellingPrice;
  final String unit;
  final int minimumStock;
  final String supplier;

  int quantity;
  final Map<String, int> branchQuantities;

  InventoryProduct({
    required this.id,
    required this.name,
    required this.sku,
    required this.category,
    this.barcode = '',
    this.description = '',
    this.costPrice = 0,
    required this.sellingPrice,
    this.unit = 'Pieces',
    this.minimumStock = 5,
    this.supplier = '',
    required this.quantity,
    Map<String, int>? branchQuantities,
  }) : branchQuantities = branchQuantities ?? {};

  double get profitPerUnit => sellingPrice - costPrice;

  double get profitMargin {
    if (sellingPrice <= 0) return 0;
    return (profitPerUnit / sellingPrice) * 100;
  }
}

// CATEGORY MODEL

class InventoryCategory {
  final String id;
  final String name;
  final String code;
  final String description;
  bool active;

  InventoryCategory({
    required this.id,
    required this.name,
    required this.code,
    required this.description,
    required this.active,
  });
}

// STOCK MOVEMENT MODEL

class StockMovement {
  final String referenceCode;
  final String productId;
  final String productName;
  final String type;
  final int quantity;
  final DateTime date;
  final String branchId;
  final String? transferCode;

  StockMovement({
    required this.referenceCode,
    required this.productId,
    required this.productName,
    required this.type,
    required this.quantity,
    required this.date,
    this.branchId = '1',
    this.transferCode,
  });
}

// BRANCH MODEL

class InventoryBranch {
  final String id;
  final String name;
  final String code;
  final String city;
  final String address;
  final String phone;
  final String email;
  final String manager;
  bool active;

  InventoryBranch({
    required this.id,
    required this.name,
    required this.code,
    required this.city,
    required this.address,
    required this.phone,
    required this.email,
    required this.manager,
    required this.active,
  });
}

// CUSTOMER MODEL

class InventoryCustomer {
  final String id;
  final String code;
  final String name;
  final String phone;
  final String email;
  final String address;
  final String city;
  final String country;
  final String notes;
  final DateTime createdAt;

  bool active;

  InventoryCustomer({
    required this.id,
    required this.code,
    required this.name,
    this.phone = '',
    this.email = '',
    this.address = '',
    this.city = '',
    this.country = 'Nepal',
    this.notes = '',
    required this.createdAt,
    this.active = true,
  });
}

// SALES CART MODEL

class SalesCartItem {
  final String productId;
  final int quantity;
  final double unitPrice;

  SalesCartItem({
    required this.productId,
    required this.quantity,
    required this.unitPrice,
  });
}

// SALE LINE MODEL

class SaleLineItem {
  final String productId;
  final String productName;
  final String sku;
  final int quantity;
  final double unitPrice;
  final double costPrice;

  SaleLineItem({
    required this.productId,
    required this.productName,
    required this.sku,
    required this.quantity,
    required this.unitPrice,
    required this.costPrice,
  });

  double get total => quantity * unitPrice;

  double get profit => (unitPrice - costPrice) * quantity;
}

// SALE RECORD MODEL

class SaleRecord {
  final String invoiceNumber;
  final String branchId;
  final String customerName;
  final String customerPhone;
  final String paymentMethod;
  final List<SaleLineItem> items;
  final double subtotal;
  final double discount;
  final double tax;
  final double total;
  final double amountPaid;
  final DateTime date;

  SaleRecord({
    required this.invoiceNumber,
    required this.branchId,
    required this.customerName,
    required this.customerPhone,
    required this.paymentMethod,
    required this.items,
    required this.subtotal,
    required this.discount,
    required this.tax,
    required this.total,
    required this.amountPaid,
    required this.date,
  });

  double get balanceDue =>
      (total - amountPaid).clamp(0, double.infinity).toDouble();

  double get change =>
      (amountPaid - total).clamp(0, double.infinity).toDouble();

  double get profit =>
      items.fold(0.0, (sum, item) => sum + item.profit);

  String get paymentStatus {
    if (amountPaid <= 0) return 'Unpaid';
    if (amountPaid >= total) return 'Paid';
    return 'Partially Paid';
  }
}

// SALES RETURN LINE MODEL

class SalesReturnLine {
  final String productId;
  final String productName;
  final String sku;
  final int quantity;
  final double unitPrice;

  SalesReturnLine({
    required this.productId,
    required this.productName,
    required this.sku,
    required this.quantity,
    required this.unitPrice,
  });

  double get total => quantity * unitPrice;
}

// SALES RETURN RECORD MODEL

class SalesReturnRecord {
  final String returnNumber;
  final String originalInvoiceNumber;
  final String branchId;
  final String customerName;
  final List<SalesReturnLine> items;
  final double total;
  final String reason;
  final DateTime date;

  SalesReturnRecord({
    required this.returnNumber,
    required this.originalInvoiceNumber,
    required this.branchId,
    required this.customerName,
    required this.items,
    required this.total,
    required this.reason,
    required this.date,
  });
}
