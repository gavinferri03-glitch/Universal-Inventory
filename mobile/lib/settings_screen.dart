
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app_settings.dart';
import 'inventory_data.dart';
import 'l10n/app_localizations.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  static const Color blue = Color(0xFF5798FF);
  static const Color green = Color(0xFF45C99A);
  static const Color panel = Color(0xFF121D2D);
  static const Color muted = Color(0xFF91A4BE);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final appSettings = ref.watch(appSettingsProvider);
    final inventory = ref.watch(inventoryProvider);
    final notifications = inventory.notificationCenter;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          l10n.settings,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            onPressed: () => _showInfo(context, l10n),
            icon: const Icon(Icons.info_outline),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(18, 12, 18, 30),
        children: [
          Text(
            l10n.generalSettings,
            style: const TextStyle(color: muted, fontSize: 14),
          ),
          const SizedBox(height: 22),

          _profileCard(context, l10n),
          const SizedBox(height: 28),

          _sectionTitle(l10n.generalSettings),

          _tile(
            icon: Icons.business_outlined,
            title: l10n.businessProfile,
            subtitle: l10n.companyDetails,
            onTap: () => _message(
              context,
              'Open Business Profile from the main menu.',
            ),
          ),

          _tile(
            icon: Icons.language_outlined,
            title: l10n.language,
            subtitle: AppSettings.supportedLanguages[
                    appSettings.languageCode] ??
                'English',
            onTap: () => _selectLanguage(context, ref),
          ),

          _tile(
            icon: Icons.palette_outlined,
            title: l10n.appearance,
            subtitle: appSettings.themeMode == ThemeMode.dark
                ? l10n.darkMode
                : l10n.lightMode,
            onTap: () => _selectTheme(context, ref, l10n),
          ),

          const SizedBox(height: 25),

          _sectionTitle(l10n.notificationSettings),

          _notificationSwitch(
            title: l10n.enableAllNotifications,
            subtitle: l10n.notificationSettings,
            value: notifications.allNotifications,
            onChanged: (v) => notifications.updateSettings(all: v),
          ),

          _notificationSwitch(
            title: l10n.lowStockAlerts,
            subtitle: l10n.lowStock,
            value: notifications.lowStockAlerts,
            onChanged: (v) => notifications.updateSettings(lowStock: v),
          ),

          _notificationSwitch(
            title: l10n.outOfStockAlerts,
            subtitle: l10n.outOfStock,
            value: notifications.outOfStockAlerts,
            onChanged: (v) => notifications.updateSettings(outOfStock: v),
          ),

          _notificationSwitch(
            title: l10n.stockAdjustmentAlerts,
            subtitle: l10n.stockAdjustmentAlerts,
            value: notifications.stockAdjustmentAlerts,
            onChanged: (v) => notifications.updateSettings(stockAdjustment: v),
          ),

          _notificationSwitch(
            title: l10n.stockInAlerts,
            subtitle: l10n.stockIn,
            value: notifications.stockInAlerts,
            onChanged: (v) => notifications.updateSettings(stockIn: v),
          ),

          _notificationSwitch(
            title: l10n.stockOutAlerts,
            subtitle: l10n.stockOut,
            value: notifications.stockOutAlerts,
            onChanged: (v) => notifications.updateSettings(stockOut: v),
          ),

          _notificationSwitch(
            title: l10n.transferAlerts,
            subtitle: l10n.transferAlerts,
            value: notifications.transferAlerts,
            onChanged: (v) => notifications.updateSettings(transfer: v),
          ),

          _notificationSwitch(
            title: l10n.newSaleAlerts,
            subtitle: l10n.sales,
            value: notifications.newSaleAlerts,
            onChanged: (v) => notifications.updateSettings(newSale: v),
          ),

          _notificationSwitch(
            title: l10n.paymentDueAlerts,
            subtitle: l10n.payment,
            value: notifications.paymentDueAlerts,
            onChanged: (v) => notifications.updateSettings(paymentDue: v),
          ),

          _notificationSwitch(
            title: l10n.overduePaymentAlerts,
            subtitle: l10n.payment,
            value: notifications.overduePaymentAlerts,
            onChanged: (v) => notifications.updateSettings(overduePayment: v),
          ),

          _notificationSwitch(
            title: l10n.salesReturnAlerts,
            subtitle: l10n.salesReturnAlerts,
            value: notifications.salesReturnAlerts,
            onChanged: (v) => notifications.updateSettings(salesReturn: v),
          ),

          _notificationSwitch(
            title: l10n.supplierAlerts,
            subtitle: l10n.suppliers,
            value: notifications.supplierAlerts,
            onChanged: (v) => notifications.updateSettings(supplier: v),
          ),

          _notificationSwitch(
            title: l10n.userActivityAlerts,
            subtitle: l10n.users,
            value: notifications.userActivityAlerts,
            onChanged: (v) => notifications.updateSettings(userActivity: v),
          ),

          _notificationSwitch(
            title: l10n.backupAlerts,
            subtitle: l10n.dataAndBackup,
            value: notifications.backupAlerts,
            onChanged: (v) => notifications.updateSettings(backup: v),
          ),

          _notificationSwitch(
            title: l10n.syncAlerts,
            subtitle: l10n.syncAlerts,
            value: notifications.syncAlerts,
            onChanged: (v) => notifications.updateSettings(sync: v),
          ),

          const SizedBox(height: 25),

          _sectionTitle(l10n.security),

          _tile(
            icon: Icons.lock_outline,
            title: 'Change Password',
            subtitle: l10n.security,
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

          _sectionTitle(l10n.dataAndBackup),

          _tile(
            icon: Icons.backup_outlined,
            title: l10n.dataAndBackup,
            subtitle: l10n.backupAlerts,
            onTap: () => _message(
              context,
              'Backup and restore will be connected after persistent storage is implemented.',
            ),
          ),

          _tile(
            icon: Icons.storage_outlined,
            title: 'Storage & Data',
            subtitle: l10n.dataAndBackup,
            onTap: () => _showStorageInfo(context, l10n),
          ),

          _tile(
            icon: Icons.sync_outlined,
            title: l10n.syncAlerts,
            subtitle: l10n.dataAndBackup,
            onTap: () => _message(
              context,
              'Cloud synchronization requires a backend server.',
            ),
          ),

          const SizedBox(height: 25),

          _sectionTitle(l10n.about),

          _tile(
            icon: Icons.info_outline,
            title: l10n.about,
            subtitle: l10n.appTitle,
            onTap: () => _about(context, l10n),
          ),

          _tile(
            icon: Icons.description_outlined,
            title: l10n.termsAndConditions,
            subtitle: l10n.privacyPolicy,
            onTap: () => _message(
              context,
              'Terms and Privacy information will be added before release.',
            ),
          ),

          const SizedBox(height: 25),

          OutlinedButton.icon(
            onPressed: () => _confirmLogout(context, l10n),
            icon: const Icon(
              Icons.logout,
              color: Color(0xFFFF6B6B),
            ),
            label: Text(
              l10n.logout,
              style: const TextStyle(
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

          Center(
            child: Column(
              children: [
                Text(
                  l10n.appTitle.toUpperCase(),
                  style: const TextStyle(
                    color: muted,
                    fontSize: 11,
                    letterSpacing: 2,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
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

  Widget _profileCard(
    BuildContext context,
    AppLocalizations l10n,
  ) {
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
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.administrator,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 5),
                const Text(
                  'admin@example.com',
                  style: TextStyle(color: muted, fontSize: 12),
                ),
                const SizedBox(height: 7),
                Text(
                  l10n.administrator,
                  style: const TextStyle(
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
    final l10n = AppLocalizations.of(context)!;

    await showModalBottomSheet(
      context: context,
      backgroundColor: panel,
      builder: (sheetContext) {
        return SafeArea(
          child: ListView(
            shrinkWrap: true,
            children: [
              Padding(
                padding: const EdgeInsets.all(18),
                child: Text(
                  l10n.selectLanguage,
                  style: const TextStyle(
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
    AppLocalizations l10n,
  ) async {
    final settings = ref.read(appSettingsProvider);

    await showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(l10n.appearance),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              RadioListTile<ThemeMode>(
                title: Text(l10n.darkMode),
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
                title: Text(l10n.lightMode),
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

  void _showStorageInfo(
    BuildContext context,
    AppLocalizations l10n,
  ) {
    _dialog(
      context,
      l10n.dataAndBackup,
      'Your current inventory data is held in application memory. '
          'It may reset when the app is restarted. Persistent database '
          'storage will be added before backup and restore are enabled.',
    );
  }

  void _about(
    BuildContext context,
    AppLocalizations l10n,
  ) {
    _dialog(
      context,
      l10n.about,
      '${l10n.appTitle}\n\n'
          'Version 0.1.0\n\n'
          'A flexible inventory management platform designed to manage '
          'products, stock movements, suppliers, sales and multiple branches.',
    );
  }

  void _showInfo(
    BuildContext context,
    AppLocalizations l10n,
  ) {
    _dialog(
      context,
      l10n.settings,
      l10n.generalSettings,
    );
  }

  void _confirmLogout(
    BuildContext context,
    AppLocalizations l10n,
  ) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text('${l10n.logout}?'),
          content: Text(l10n.confirm),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: Text(l10n.cancel),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
                _message(
                  context,
                  'Logout requires account authentication.',
                );
              },
              child: Text(
                l10n.logout,
                style: const TextStyle(color: Color(0xFFFF6B6B)),
              ),
            ),
          ],
        );
      },
    );
  }

  void _dialog(
    BuildContext context,
    String title,
    String message,
  ) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(AppLocalizations.of(context)!.close),
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
