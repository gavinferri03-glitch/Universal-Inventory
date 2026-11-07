
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

// ============================================================
// NOTIFICATION CATEGORY
// ============================================================

enum NotificationCategory {
  inventory,
  stock,
  sales,
  suppliers,
  system,
}

// ============================================================
// NOTIFICATION MODEL
// ============================================================

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

// ============================================================
// NOTIFICATION CENTER
// ============================================================

class NotificationCenter extends ChangeNotifier {
  // Preference keys
  static const String _allKey = 'notifications_all';
  static const String _lowStockKey = 'notifications_low_stock';
  static const String _outOfStockKey = 'notifications_out_of_stock';
  static const String _adjustmentKey = 'notifications_adjustment';
  static const String _stockInKey = 'notifications_stock_in';
  static const String _stockOutKey = 'notifications_stock_out';
  static const String _transferKey = 'notifications_transfer';
  static const String _newSaleKey = 'notifications_new_sale';
  static const String _paymentDueKey = 'notifications_payment_due';
  static const String _overduePaymentKey = 'notifications_overdue_payment';
  static const String _salesReturnKey = 'notifications_sales_return';
  static const String _supplierKey = 'notifications_supplier';
  static const String _userActivityKey = 'notifications_user_activity';
  static const String _backupKey = 'notifications_backup';
  static const String _syncKey = 'notifications_sync';

  // Notification history
  final List<AppNotification> _notifications = [];

  // Loading status
  bool isLoaded = false;

  // Main notification switch
  bool allNotifications = true;

  // Inventory alerts
  bool lowStockAlerts = true;
  bool outOfStockAlerts = true;
  bool stockAdjustmentAlerts = true;

  // Stock alerts
  bool stockInAlerts = true;
  bool stockOutAlerts = true;
  bool transferAlerts = true;

  // Sales alerts
  bool newSaleAlerts = true;
  bool paymentDueAlerts = true;
  bool overduePaymentAlerts = true;
  bool salesReturnAlerts = true;

  // Other alerts
  bool supplierAlerts = true;
  bool userActivityAlerts = true;
  bool backupAlerts = true;
  bool syncAlerts = true;

  // ==========================================================
  // INITIALIZATION
  // ==========================================================

  NotificationCenter() {
    loadSettings();
  }

  Future<void> loadSettings() async {
    try {
      final preferences = await SharedPreferences.getInstance();

      allNotifications =
          preferences.getBool(_allKey) ?? true;

      lowStockAlerts =
          preferences.getBool(_lowStockKey) ?? true;

      outOfStockAlerts =
          preferences.getBool(_outOfStockKey) ?? true;

      stockAdjustmentAlerts =
          preferences.getBool(_adjustmentKey) ?? true;

      stockInAlerts =
          preferences.getBool(_stockInKey) ?? true;

      stockOutAlerts =
          preferences.getBool(_stockOutKey) ?? true;

      transferAlerts =
          preferences.getBool(_transferKey) ?? true;

      newSaleAlerts =
          preferences.getBool(_newSaleKey) ?? true;

      paymentDueAlerts =
          preferences.getBool(_paymentDueKey) ?? true;

      overduePaymentAlerts =
          preferences.getBool(_overduePaymentKey) ?? true;

      salesReturnAlerts =
          preferences.getBool(_salesReturnKey) ?? true;

      supplierAlerts =
          preferences.getBool(_supplierKey) ?? true;

      userActivityAlerts =
          preferences.getBool(_userActivityKey) ?? true;

      backupAlerts =
          preferences.getBool(_backupKey) ?? true;

      syncAlerts =
          preferences.getBool(_syncKey) ?? true;
    } catch (error) {
      debugPrint('Could not load notification settings: $error');
    }

    isLoaded = true;
    notifyListeners();
  }

  // ==========================================================
  // NOTIFICATION LIST
  // ==========================================================

  List<AppNotification> get notifications =>
      List.unmodifiable(_notifications);

  int get unreadCount =>
      _notifications.where((item) => !item.isRead).length;

  List<AppNotification> get unreadNotifications =>
      _notifications.where((item) => !item.isRead).toList();

  bool get hasNotifications => _notifications.isNotEmpty;

  // ==========================================================
  // ADD NOTIFICATION
  // ==========================================================

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

  // ==========================================================
  // CHECK NOTIFICATION SETTINGS
  // ==========================================================

  bool _isCategoryEnabled(
    String title,
    NotificationCategory category,
  ) {
    switch (category) {
      case NotificationCategory.inventory:
        if (title == 'Out of Stock') {
          return outOfStockAlerts;
        }

        if (title == 'Low Stock') {
          return lowStockAlerts;
        }

        if (title == 'Stock Adjustment') {
          return stockAdjustmentAlerts;
        }

        return true;

      case NotificationCategory.stock:
        if (title == 'Stock In') {
          return stockInAlerts;
        }

        if (title == 'Stock Out') {
          return stockOutAlerts;
        }

        if (title == 'Branch Transfer') {
          return transferAlerts;
        }

        return true;

      case NotificationCategory.sales:
        if (title == 'New Sale') {
          return newSaleAlerts;
        }

        if (title == 'Payment Due') {
          return paymentDueAlerts;
        }

        if (title == 'Overdue Payment') {
          return overduePaymentAlerts;
        }

        if (title == 'Sales Return') {
          return salesReturnAlerts;
        }

        return true;

      case NotificationCategory.suppliers:
        return supplierAlerts;

      case NotificationCategory.system:
        if (title == 'User Activity') {
          return userActivityAlerts;
        }

        if (title == 'Backup Reminder') {
          return backupAlerts;
        }

        if (title == 'Sync Update') {
          return syncAlerts;
        }

        return true;
    }
  }

  // ==========================================================
  // UPDATE SETTINGS
  // ==========================================================

  Future<void> updateSettings({
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
  }) async {
    if (all != null) {
      allNotifications = all;
    }

    if (lowStock != null) {
      lowStockAlerts = lowStock;
    }

    if (outOfStock != null) {
      outOfStockAlerts = outOfStock;
    }

    if (stockAdjustment != null) {
      stockAdjustmentAlerts = stockAdjustment;
    }

    if (stockIn != null) {
      stockInAlerts = stockIn;
    }

    if (stockOut != null) {
      stockOutAlerts = stockOut;
    }

    if (transfer != null) {
      transferAlerts = transfer;
    }

    if (newSale != null) {
      newSaleAlerts = newSale;
    }

    if (paymentDue != null) {
      paymentDueAlerts = paymentDue;
    }

    if (overduePayment != null) {
      overduePaymentAlerts = overduePayment;
    }

    if (salesReturn != null) {
      salesReturnAlerts = salesReturn;
    }

    if (supplier != null) {
      supplierAlerts = supplier;
    }

    if (userActivity != null) {
      userActivityAlerts = userActivity;
    }

    if (backup != null) {
      backupAlerts = backup;
    }

    if (sync != null) {
      syncAlerts = sync;
    }

    // Update the interface immediately.
    notifyListeners();

    // Save all settings.
    await _saveSettings();
  }

  // ==========================================================
  // SAVE SETTINGS
  // ==========================================================

  Future<void> _saveSettings() async {
    try {
      final preferences = await SharedPreferences.getInstance();

      await preferences.setBool(_allKey, allNotifications);
      await preferences.setBool(_lowStockKey, lowStockAlerts);
      await preferences.setBool(_outOfStockKey, outOfStockAlerts);
      await preferences.setBool(_adjustmentKey, stockAdjustmentAlerts);
      await preferences.setBool(_stockInKey, stockInAlerts);
      await preferences.setBool(_stockOutKey, stockOutAlerts);
      await preferences.setBool(_transferKey, transferAlerts);
      await preferences.setBool(_newSaleKey, newSaleAlerts);
      await preferences.setBool(_paymentDueKey, paymentDueAlerts);
      await preferences.setBool(
        _overduePaymentKey,
        overduePaymentAlerts,
      );
      await preferences.setBool(_salesReturnKey, salesReturnAlerts);
      await preferences.setBool(_supplierKey, supplierAlerts);
      await preferences.setBool(
        _userActivityKey,
        userActivityAlerts,
      );
      await preferences.setBool(_backupKey, backupAlerts);
      await preferences.setBool(_syncKey, syncAlerts);
    } catch (error) {
      debugPrint('Could not save notification settings: $error');
    }
  }

  // ==========================================================
  // MARK AS READ
  // ==========================================================

  void markAsRead(String id) {
    final index = _notifications.indexWhere(
      (item) => item.id == id,
    );

    if (index == -1) return;

    if (_notifications[index].isRead) return;

    _notifications[index].isRead = true;
    notifyListeners();
  }

  // ==========================================================
  // MARK ALL AS READ
  // ==========================================================

  void markAllAsRead() {
    for (final notification in _notifications) {
      notification.isRead = true;
    }

    notifyListeners();
  }

  // ==========================================================
  // REMOVE ONE NOTIFICATION
  // ==========================================================

  void remove(String id) {
    _notifications.removeWhere(
      (item) => item.id == id,
    );

    notifyListeners();
  }

  // ==========================================================
  // CLEAR ALL NOTIFICATIONS
  // ==========================================================

  void clearAll() {
    _notifications.clear();
    notifyListeners();
  }
}
