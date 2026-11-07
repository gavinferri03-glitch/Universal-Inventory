
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app_settings.dart';
import 'inventory_data.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  static const Color blue = Color(0xFF5798FF);
  static const Color green = Color(0xFF45C99A);
  static const Color panel = Color(0xFF121D2D);
  static const Color muted = Color(0xFF91A4BE);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appSettings = ref.watch(appSettingsProvider);
    final inventory = ref.watch(inventoryProvider);
    final notifications = inventory.notificationCenter;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Settings',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            onPressed: () => _showInfo(context),
            icon: const Icon(Icons.info_outline),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(18, 12, 18, 30),
        children: [
          const Text(
            'Manage your application preferences',
            style: TextStyle(color: muted, fontSize: 14),
          ),
          const SizedBox(height: 22),

          // ACCOUNT

          _profileCard(context),
          const SizedBox(height: 28),

          _sectionTitle('GENERAL'),

          _tile(
            icon: Icons.business_outlined,
            title: 'Business Information',
            subtitle: 'Manage your business details',
            onTap: () => _message(
              context,
              'Open Business Profile from the main menu.',
            ),
          ),

          _tile(
            icon: Icons.language_outlined,
            title: 'Language',
            subtitle: AppSettings.supportedLanguages[
                    appSettings.languageCode] ??
                'English',
            onTap: () => _selectLanguage(context, ref),
          ),

          _tile(
            icon: Icons.palette_outlined,
            title: 'Appearance',
            subtitle: appSettings.themeMode == ThemeMode.dark
                ? 'Dark theme'
                : 'Light theme',
            onTap: () => _selectTheme(context, ref),
          ),

          const SizedBox(height: 25),

          // NOTIFICATIONS

          _sectionTitle('NOTIFICATIONS'),

          _notificationSwitch(
            title: 'All Notifications',
            subtitle: 'Enable or disable all notifications',
            value: notifications.allNotifications,
            onChanged: (v) =>
                notifications.updateSettings(all: v),
          ),

          _notificationSwitch(
            title: 'Low Stock Alerts',
            subtitle: 'When product stock reaches its minimum level',
            value: notifications.lowStockAlerts,
            onChanged: (v) =>
                notifications.updateSettings(lowStock: v),
          ),

          _notificationSwitch(
            title: 'Out of Stock Alerts',
            subtitle: 'When a product runs out of stock',
            value: notifications.outOfStockAlerts,
            onChanged: (v) =>
                notifications.updateSettings(outOfStock: v),
          ),

          _notificationSwitch(
            title: 'Stock Adjustment Alerts',
            subtitle: 'When inventory quantities are adjusted',
            value: notifications.stockAdjustmentAlerts,
            onChanged: (v) =>
                notifications.updateSettings(stockAdjustment: v),
          ),

          _notificationSwitch(
            title: 'Stock In Alerts',
            subtitle: 'When stock is added',
            value: notifications.stockInAlerts,
            onChanged: (v) =>
                notifications.updateSettings(stockIn: v),
          ),

          _notificationSwitch(
            title: 'Stock Out Alerts',
            subtitle: 'When stock is removed',
            value: notifications.stockOutAlerts,
            onChanged: (v) =>
                notifications.updateSettings(stockOut: v),
          ),

          _notificationSwitch(
            title: 'Branch Transfer Alerts',
            subtitle: 'When stock is transferred between branches',
            value: notifications.transferAlerts,
            onChanged: (v) =>
                notifications.updateSettings(transfer: v),
          ),

          _notificationSwitch(
            title: 'New Sale Alerts',
            subtitle: 'When a new sale is recorded',
            value: notifications.newSaleAlerts,
            onChanged: (v) =>
                notifications.updateSettings(newSale: v),
          ),

          _notificationSwitch(
            title: 'Payment Due Alerts',
            subtitle: 'When a customer payment is due',
            value: notifications.paymentDueAlerts,
            onChanged: (v) =>
                notifications.updateSettings(paymentDue: v),
          ),

          _notificationSwitch(
            title: 'Overdue Payment Alerts',
            subtitle: 'When a payment becomes overdue',
            value: notifications.overduePaymentAlerts,
            onChanged: (v) =>
                notifications.updateSettings(overduePayment: v),
          ),

          _notificationSwitch(
            title: 'Sales Return Alerts',
            subtitle: 'When a sale is returned',
            value: notifications.salesReturnAlerts,
            onChanged: (v) =>
                notifications.updateSettings(salesReturn: v),
          ),

          _notificationSwitch(
            title: 'Supplier Alerts',
            subtitle: 'Updates related to suppliers',
            value: notifications.supplierAlerts,
            onChanged: (v) =>
                notifications.updateSettings(supplier: v),
          ),

          _notificationSwitch(
            title: 'User Activity Alerts',
            subtitle: 'Updates about user activity',
            value: notifications.userActivityAlerts,
            onChanged: (v) =>
                notifications.updateSettings(userActivity: v),
          ),

          _notificationSwitch(
            title: 'Backup Alerts',
            subtitle: 'Backup reminders and updates',
            value: notifications.backupAlerts,
            onChanged: (v) =>
                notifications.updateSettings(backup: v),
          ),

          _notificationSwitch(
            title: 'Sync Alerts',
            subtitle: 'Data synchronization updates',
            value: notifications.syncAlerts,
            onChanged: (v) =>
                notifications.updateSettings(sync: v),
          ),

          const SizedBox(height: 25),

          // SECURITY

          _sectionTitle('SECURITY'),

          _tile(
            icon: Icons.lock_outline,
            title: 'Change Password',
            subtitle: 'Update your account password',
            onTap: () => _message(
              context,
              'Password changes require account authentication.',
            ),
          ),

          _tile(
            icon: Icons.fingerprint,
            title: 'Biometric Login',
            subtitle: 'Fingerprint or device authentication',
            onTap: () => _message(
              context,
              'Biometric login requires authentication integration.',
            ),
          ),

          _tile(
            icon: Icons.devices_outlined,
            title: 'Active Sessions',
            subtitle: 'Manage connected devices',
            onTap: () => _message(
              context,
              'Active sessions require account authentication.',
            ),
          ),

          const SizedBox(height: 25),

          // DATA AND SYSTEM

          _sectionTitle('DATA & SYSTEM'),

          _tile(
            icon: Icons.backup_outlined,
            title: 'Backup & Restore',
            subtitle: 'Manage inventory backups',
            onTap: () => _message(
              context,
              'Backup and restore will be connected after persistent storage is implemented.',
            ),
          ),

          _tile(
            icon: Icons.storage_outlined,
            title: 'Storage & Data',
            subtitle: 'Manage application data',
            onTap: () => _showStorageInfo(context),
          ),

          _tile(
            icon: Icons.sync_outlined,
            title: 'Sync Settings',
            subtitle: 'Configure data synchronization',
            onTap: () => _message(
              context,
              'Cloud synchronization requires a backend server.',
            ),
          ),

          const SizedBox(height: 25),

          // ABOUT

          _sectionTitle('ABOUT'),

          _tile(
            icon: Icons.info_outline,
            title: 'About Universal Inventory',
            subtitle: 'Application information',
            onTap: () => _about(context),
          ),

          _tile(
            icon: Icons.description_outlined,
            title: 'Terms & Privacy',
            subtitle: 'Terms and privacy information',
            onTap: () => _message(
              context,
              'Terms and Privacy information will be added before release.',
            ),
          ),

          const SizedBox(height: 25),

          OutlinedButton.icon(
            onPressed: () => _confirmLogout(context),
            icon: const Icon(
              Icons.logout,
              color: Color(0xFFFF6B6B),
            ),
            label: const Text(
              'Log Out',
              style: TextStyle(
                color: Color(0xFFFF6B6B),
                fontWeight: FontWeight.bold,
              ),
            ),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              side: const BorderSide(color: Color(0xFF743B46)),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
          ),

          const SizedBox(height: 25),

          const Center(
            child: Column(
              children: [
                Text(
                  'UNIVERSAL INVENTORY',
                  style: TextStyle(
                    color: muted,
                    fontSize: 11,
                    letterSpacing: 2,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 6),
                Text(
                  'Version 0.1.0',
                  style: TextStyle(
                    color: Color(0xFF52647D),
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _profileCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: panel,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFF26364D)),
      ),
      child: Row(
        children: [
          Container(
            width: 58,
            height: 58,
            decoration: BoxDecoration(
              color: blue.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(18),
            ),
            child: const Icon(
              Icons.person_outline,
              color: blue,
              size: 32,
            ),
          ),
          const SizedBox(width: 15),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Administrator',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 5),
                Text(
                  'admin@example.com',
                  style: TextStyle(color: muted, fontSize: 12),
                ),
                SizedBox(height: 7),
                Text(
                  'Administrator Account',
                  style: TextStyle(
                    color: green,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () => _message(
              context,
              'Profile editing requires account integration.',
            ),
            icon: const Icon(Icons.edit_outlined, color: blue),
          ),
        ],
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: const TextStyle(
          color: muted,
          fontSize: 11,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.5,
        ),
      ),
    );
  }

  Widget _tile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 9),
      decoration: BoxDecoration(
        color: panel,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFF26364D)),
      ),
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 15,
          vertical: 5,
        ),
        leading: Icon(icon, color: blue, size: 23),
        title: Text(
          title,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Text(
            subtitle,
            style: const TextStyle(color: muted, fontSize: 11),
          ),
        ),
        trailing: const Icon(
          Icons.chevron_right,
          color: Color(0xFF71849E),
        ),
      ),
    );
  }

  Widget _notificationSwitch({
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 9),
      decoration: BoxDecoration(
        color: panel,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFF26364D)),
      ),
      child: SwitchListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 15,
          vertical: 4,
        ),
        secondary: const Icon(
          Icons.notifications_outlined,
          color: blue,
          size: 23,
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: const TextStyle(color: muted, fontSize: 11),
        ),
        value: value,
        activeThumbColor: green,
        onChanged: onChanged,
      ),
    );
  }

  Future<void> _selectLanguage(
    BuildContext context,
    WidgetRef ref,
  ) async {
    final settings = ref.read(appSettingsProvider);

    await showModalBottomSheet(
      context: context,
      backgroundColor: panel,
      builder: (sheetContext) {
        return SafeArea(
          child: ListView(
            shrinkWrap: true,
            children: [
              const Padding(
                padding: EdgeInsets.all(18),
                child: Text(
                  'Select Language',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              ...AppSettings.supportedLanguages.entries.map((entry) {
                return ListTile(
                  title: Text(entry.value),
                  trailing: settings.languageCode == entry.key
                      ? const Icon(Icons.check, color: blue)
                      : null,
                  onTap: () {
                    settings.setLanguage(entry.key);
                    Navigator.pop(sheetContext);
                  },
                );
              }),
            ],
          ),
        );
      },
    );
  }

  Future<void> _selectTheme(
    BuildContext context,
    WidgetRef ref,
  ) async {
    final settings = ref.read(appSettingsProvider);

    await showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Choose Appearance'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              RadioListTile<ThemeMode>(
                title: const Text('Dark'),
                value: ThemeMode.dark,
                groupValue: settings.themeMode,
                onChanged: (value) {
                  if (value != null) {
                    settings.setTheme(value);
                    Navigator.pop(dialogContext);
                  }
                },
              ),
              RadioListTile<ThemeMode>(
                title: const Text('Light'),
                value: ThemeMode.light,
                groupValue: settings.themeMode,
                onChanged: (value) {
                  if (value != null) {
                    settings.setTheme(value);
                    Navigator.pop(dialogContext);
                  }
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _showStorageInfo(BuildContext context) {
    _dialog(
      context,
      'Storage & Data',
      'Your current inventory data is held in application memory. '
          'It may reset when the app is restarted. Persistent database '
          'storage will be added before backup and restore are enabled.',
    );
  }

  void _about(BuildContext context) {
    _dialog(
      context,
      'Universal Inventory',
      'Version 0.1.0\n\n'
          'A flexible inventory management platform designed to manage '
          'products, stock movements, suppliers, sales and multiple branches.',
    );
  }

  void _showInfo(BuildContext context) {
    _dialog(
      context,
      'Settings',
      'Manage your account, business preferences, notifications, '
          'security and application settings here.',
    );
  }

  void _confirmLogout(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Log Out?'),
          content: const Text(
            'Are you sure you want to log out of Universal Inventory?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
                _message(
                  context,
                  'Logout requires account authentication.',
                );
              },
              child: const Text(
                'Log Out',
                style: TextStyle(color: Color(0xFFFF6B6B)),
              ),
            ),
          ],
        );
      },
    );
  }

  void _dialog(BuildContext context, String title, String message) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _message(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }
}
