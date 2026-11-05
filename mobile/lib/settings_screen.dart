
import 'package:flutter/material.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  static const Color blue = Color(0xFF5798FF);
  static const Color green = Color(0xFF45C99A);

  bool notificationsEnabled = true;
  bool lowStockAlerts = true;
  bool movementAlerts = true;
  bool emailNotifications = false;
  bool biometricLogin = false;

  String selectedLanguage = 'English';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF080B12),
      appBar: AppBar(
        backgroundColor: const Color(0xFF080B12),
        title: const Text(
          'Settings',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            onPressed: _showInfo,
            icon: const Icon(Icons.info_outline),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 10, 20, 30),
          children: [
            const Text(
              'Manage your application preferences',
              style: TextStyle(
                color: Color(0xFF91A4BE),
                fontSize: 14,
              ),
            ),

            const SizedBox(height: 24),

            // PROFILE CARD

            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: const Color(0xFF121D2D),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: const Color(0xFF26364D),
                ),
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
                          style: TextStyle(
                            color: Color(0xFF91A4BE),
                            fontSize: 12,
                          ),
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
                    onPressed: _editProfile,
                    icon: const Icon(
                      Icons.edit_outlined,
                      color: blue,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 28),

            _sectionTitle('GENERAL'),

            _settingTile(
              icon: Icons.business_outlined,
              title: 'Business Information',
              subtitle: 'Manage your business details',
              onTap: _businessInformation,
            ),

            _settingTile(
              icon: Icons.language_outlined,
              title: 'Language',
              subtitle: selectedLanguage,
              onTap: _selectLanguage,
            ),

            _settingTile(
              icon: Icons.palette_outlined,
              title: 'Appearance',
              subtitle: 'Dark theme',
              onTap: _showAppearance,
            ),

            const SizedBox(height: 25),

            _sectionTitle('NOTIFICATIONS'),

            _switchTile(
              icon: Icons.notifications_active_outlined,
              title: 'All Notifications',
              subtitle: 'Enable or disable notifications',
              value: notificationsEnabled,
              onChanged: (value) {
                setState(() {
                  notificationsEnabled = value;
                  if (!value) {
                    lowStockAlerts = false;
                    movementAlerts = false;
                    emailNotifications = false;
                  }
                });
              },
            ),

            _switchTile(
              icon: Icons.warning_amber_outlined,
              title: 'Low Stock Alerts',
              subtitle: 'Get notified when stock is low',
              value: lowStockAlerts,
              onChanged: notificationsEnabled
                  ? (value) => setState(() => lowStockAlerts = value)
                  : null,
            ),

            _switchTile(
              icon: Icons.inventory_2_outlined,
              title: 'Stock Movement Alerts',
              subtitle: 'Receive stock in and out updates',
              value: movementAlerts,
              onChanged: notificationsEnabled
                  ? (value) => setState(() => movementAlerts = value)
                  : null,
            ),

            _switchTile(
              icon: Icons.email_outlined,
              title: 'Email Notifications',
              subtitle: 'Receive updates through email',
              value: emailNotifications,
              onChanged: notificationsEnabled
                  ? (value) => setState(() => emailNotifications = value)
                  : null,
            ),

            const SizedBox(height: 25),

            _sectionTitle('SECURITY'),

            _settingTile(
              icon: Icons.lock_outline,
              title: 'Change Password',
              subtitle: 'Update your account password',
              onTap: _changePassword,
            ),

            _switchTile(
              icon: Icons.fingerprint,
              title: 'Biometric Login',
              subtitle: 'Use fingerprint or device authentication',
              value: biometricLogin,
              onChanged: (value) {
                setState(() => biometricLogin = value);
                _message(
                  value
                      ? 'Biometric login preference enabled'
                      : 'Biometric login preference disabled',
                );
              },
            ),

            _settingTile(
              icon: Icons.devices_outlined,
              title: 'Active Sessions',
              subtitle: 'Manage connected devices',
              onTap: () => _message('Active Sessions'),
            ),

            const SizedBox(height: 25),

            _sectionTitle('DATA & SYSTEM'),

            _settingTile(
              icon: Icons.backup_outlined,
              title: 'Backup & Restore',
              subtitle: 'Manage your inventory backups',
              onTap: () => _message('Backup & Restore'),
            ),

            _settingTile(
              icon: Icons.storage_outlined,
              title: 'Storage & Data',
              subtitle: 'Manage application data',
              onTap: () => _message('Storage & Data'),
            ),

            _settingTile(
              icon: Icons.sync_outlined,
              title: 'Sync Settings',
              subtitle: 'Configure data synchronization',
              onTap: () => _message('Sync Settings'),
            ),

            const SizedBox(height: 25),

            _sectionTitle('ABOUT'),

            _settingTile(
              icon: Icons.info_outline,
              title: 'About Universal Inventory',
              subtitle: 'Application information',
              onTap: _aboutApp,
            ),

            _settingTile(
              icon: Icons.description_outlined,
              title: 'Terms & Privacy',
              subtitle: 'Read terms and privacy information',
              onTap: () => _message('Terms & Privacy'),
            ),

            const SizedBox(height: 28),

            // LOGOUT

            OutlinedButton.icon(
              onPressed: _confirmLogout,
              icon: const Icon(Icons.logout, color: Color(0xFFFF6B6B)),
              label: const Text(
                'Log Out',
                style: TextStyle(
                  color: Color(0xFFFF6B6B),
                  fontWeight: FontWeight.bold,
                ),
              ),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                side: const BorderSide(
                  color: Color(0xFF743B46),
                ),
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
                      color: Color(0xFF71849E),
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
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: const TextStyle(
          color: Color(0xFF71849E),
          fontSize: 11,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.5,
        ),
      ),
    );
  }

  Widget _settingTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 9),
      decoration: BoxDecoration(
        color: const Color(0xFF121D2D),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: const Color(0xFF26364D),
        ),
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
            style: const TextStyle(
              color: Color(0xFF91A4BE),
              fontSize: 11,
            ),
          ),
        ),
        trailing: const Icon(
          Icons.chevron_right,
          color: Color(0xFF71849E),
        ),
      ),
    );
  }

  Widget _switchTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool>? onChanged,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 9),
      decoration: BoxDecoration(
        color: const Color(0xFF121D2D),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: const Color(0xFF26364D),
        ),
      ),
      child: SwitchListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 15,
          vertical: 4,
        ),
        secondary: Icon(icon, color: blue, size: 23),
        title: Text(
          title,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: const TextStyle(
            color: Color(0xFF91A4BE),
            fontSize: 11,
          ),
        ),
        value: value,
        activeThumbColor: green,
        onChanged: onChanged,
      ),
    );
  }

  void _editProfile() {
    _message('Edit Profile');
  }

  void _businessInformation() {
    _message('Business Information');
  }

  void _selectLanguage() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF121D2D),
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
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
              ...['English', 'Nepali'].map((language) {
                return ListTile(
                  title: Text(language),
                  trailing: selectedLanguage == language
                      ? const Icon(Icons.check, color: blue)
                      : null,
                  onTap: () {
                    setState(() => selectedLanguage = language);
                    Navigator.pop(context);
                  },
                );
              }),
              const SizedBox(height: 12),
            ],
          ),
        );
      },
    );
  }

  void _showAppearance() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF121D2D),
        title: const Text('Appearance'),
        content: const Text(
          'The current application theme is Dark. '
          'Theme customization will be available in a future update.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _changePassword() {
    _message('Change Password');
  }

  void _aboutApp() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF121D2D),
        title: const Text('Universal Inventory'),
        content: const Text(
          'Version 0.1.0\n\n'
          'A flexible inventory management platform '
          'designed to manage products, stock movements '
          'and multiple warehouses.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _confirmLogout() {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: const Color(0xFF121D2D),
        title: const Text('Log Out?'),
        content: const Text(
          'Are you sure you want to log out of Universal Inventory?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFF6B6B),
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              Navigator.pop(dialogContext);
              _message('Logout');
            },
            child: const Text('Log Out'),
          ),
        ],
      ),
    );
  }

  void _showInfo() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF121D2D),
        title: const Text('Settings'),
        content: const Text(
          'Manage your account, business preferences, '
          'notifications, security and application settings here.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _message(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$message will be available soon.'),
      ),
    );
  }
}
