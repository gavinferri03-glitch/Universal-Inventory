
import 'package:flutter/foundation.dart';

enum NotificationCategory {
  inventory,
  stock,
  sales,
  suppliers,
  system,
}

class AppNotification {
  final String id;
  final String title;
  final String message;
  final NotificationCategory category;
  final DateTime date;
  final String? relatedId;
  final String? action;
  bool isRead;

  AppNotification({
    required this.id,
    required this.title,
    required this.message,
    required this.category,
    required this.date,
    this.relatedId,
    this.action,
    this.isRead = false,
  });
}

class NotificationCenter extends ChangeNotifier {
  final List<AppNotification> _notifications = [];

  bool allNotifications = true;

  bool lowStockAlerts = true;
  bool outOfStockAlerts = true;
  bool stockAdjustmentAlerts = true;

  bool stockInAlerts = true;
  bool stockOutAlerts = true;
  bool transferAlerts = true;

  bool newSaleAlerts = true;
  bool paymentDueAlerts = true;
  bool overduePaymentAlerts = true;
  bool salesReturnAlerts = true;

  bool supplierAlerts = true;

  bool userActivityAlerts = true;
  bool backupAlerts = true;
  bool syncAlerts = true;

  List<AppNotification> get notifications =>
      List.unmodifiable(_notifications);

  int get unreadCount =>
      _notifications.where((item) => !item.isRead).length;

  List<AppNotification> get unreadNotifications =>
      _notifications.where((item) => !item.isRead).toList();

  bool get hasNotifications => _notifications.isNotEmpty;

  void add({
    required String title,
    required String message,
    required NotificationCategory category,
    String? relatedId,
    String? action,
  }) {
    if (!allNotifications) return;
    if (!_isCategoryEnabled(title, category)) return;

    _notifications.insert(
      0,
      AppNotification(
        id: DateTime.now().microsecondsSinceEpoch.toString(),
        title: title,
        message: message,
        category: category,
        date: DateTime.now(),
        relatedId: relatedId,
        action: action,
      ),
    );

    notifyListeners();
  }

  bool _isCategoryEnabled(
    String title,
    NotificationCategory category,
  ) {
    switch (category) {
      case NotificationCategory.inventory:
        if (title == 'Out of Stock') return outOfStockAlerts;
        if (title == 'Low Stock') return lowStockAlerts;
        if (title == 'Stock Adjustment') {
          return stockAdjustmentAlerts;
        }
        return true;

      case NotificationCategory.stock:
        if (title == 'Stock In') return stockInAlerts;
        if (title == 'Stock Out') return stockOutAlerts;
        if (title == 'Branch Transfer') return transferAlerts;
        return true;

      case NotificationCategory.sales:
        if (title == 'New Sale') return newSaleAlerts;
        if (title == 'Payment Due') return paymentDueAlerts;
        if (title == 'Overdue Payment') {
          return overduePaymentAlerts;
        }
        if (title == 'Sales Return') return salesReturnAlerts;
        return true;

      case NotificationCategory.suppliers:
        return supplierAlerts;

      case NotificationCategory.system:
        if (title == 'User Activity') return userActivityAlerts;
        if (title == 'Backup Reminder') return backupAlerts;
        if (title == 'Sync Update') return syncAlerts;
        return true;
    }
  }

  void updateSettings({
    bool? all,
    bool? lowStock,
    bool? outOfStock,
    bool? stockAdjustment,
    bool? stockIn,
    bool? stockOut,
    bool? transfer,
    bool? newSale,
    bool? paymentDue,
    bool? overduePayment,
    bool? salesReturn,
    bool? supplier,
    bool? userActivity,
    bool? backup,
    bool? sync,
  }) {
    if (all != null) allNotifications = all;
    if (lowStock != null) lowStockAlerts = lowStock;
    if (outOfStock != null) outOfStockAlerts = outOfStock;
    if (stockAdjustment != null) {
      stockAdjustmentAlerts = stockAdjustment;
    }
    if (stockIn != null) stockInAlerts = stockIn;
    if (stockOut != null) stockOutAlerts = stockOut;
    if (transfer != null) transferAlerts = transfer;
    if (newSale != null) newSaleAlerts = newSale;
    if (paymentDue != null) paymentDueAlerts = paymentDue;
    if (overduePayment != null) {
      overduePaymentAlerts = overduePayment;
    }
    if (salesReturn != null) salesReturnAlerts = salesReturn;
    if (supplier != null) supplierAlerts = supplier;
    if (userActivity != null) userActivityAlerts = userActivity;
    if (backup != null) backupAlerts = backup;
    if (sync != null) syncAlerts = sync;

    notifyListeners();
  }

  void markAsRead(String id) {
    final notification = _notifications
        .where((item) => item.id == id)
        .firstOrNull;

    if (notification == null || notification.isRead) return;

    notification.isRead = true;
    notifyListeners();
  }

  void markAllAsRead() {
    for (final notification in _notifications) {
      notification.isRead = true;
    }

    notifyListeners();
  }

  void remove(String id) {
    _notifications.removeWhere((item) => item.id == id);
    notifyListeners();
  }

  void clearAll() {
    _notifications.clear();
    notifyListeners();
  }
}
