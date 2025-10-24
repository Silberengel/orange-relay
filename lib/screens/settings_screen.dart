import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:local_auth/local_auth.dart';
import '../providers/app_providers.dart';
import '../widgets/settings_section.dart';
import '../widgets/relay_settings.dart';
import '../widgets/security_settings.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  final LocalAuthentication _localAuth = LocalAuthentication();

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(settingsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        actions: [
          IconButton(
            icon: const Icon(Icons.info),
            onPressed: () {
              _showAboutDialog();
            },
          ),
        ],
      ),
      body: ListView(
        children: [
          // Profile Section
          SettingsSection(
            title: 'Profile',
            children: [
              ListTile(
                leading: const Icon(Icons.person),
                title: const Text('User Profile'),
                subtitle: const Text('Manage your Nostr profile'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  _showProfileDialog();
                },
              ),
              ListTile(
                leading: const Icon(Icons.key),
                title: const Text('Keys'),
                subtitle: const Text('Manage your Nostr keys'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  _showKeysDialog();
                },
              ),
            ],
          ),

          // Security Section
          SettingsSection(
            title: 'Security',
            children: [
              SwitchListTile(
                secondary: const Icon(Icons.fingerprint),
                title: const Text('Biometric Authentication'),
                subtitle: const Text('Use fingerprint or face unlock'),
                value: settings['biometric_auth'] ?? false,
                onChanged: (value) {
                  _toggleBiometricAuth(value);
                },
              ),
              ListTile(
                leading: const Icon(Icons.security),
                title: const Text('Security Settings'),
                subtitle: const Text('Advanced security options'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  _showSecuritySettings();
                },
              ),
            ],
          ),

          // Relay Settings
          SettingsSection(
            title: 'Relays',
            children: [
              ListTile(
                leading: const Icon(Icons.cloud),
                title: const Text('Relay Configuration'),
                subtitle: const Text('Manage your relay connections'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  _showRelaySettings();
                },
              ),
              SwitchListTile(
                secondary: const Icon(Icons.broadcast_on_personal),
                title: const Text('Auto Broadcast'),
                subtitle: const Text('Automatically broadcast events'),
                value: settings['auto_broadcast'] ?? false,
                onChanged: (value) {
                  ref.read(settingsProvider.notifier).updateSetting('auto_broadcast', value);
                },
              ),
            ],
          ),

          // Appearance Section
          SettingsSection(
            title: 'Appearance',
            children: [
              ListTile(
                leading: const Icon(Icons.palette),
                title: const Text('Theme'),
                subtitle: Text(settings['theme'] ?? 'System'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  _showThemeDialog();
                },
              ),
              SwitchListTile(
                secondary: const Icon(Icons.dark_mode),
                title: const Text('Dark Mode'),
                subtitle: const Text('Use dark theme'),
                value: settings['theme'] == 'dark',
                onChanged: (value) {
                  ref.read(settingsProvider.notifier).updateSetting(
                    'theme',
                    value ? 'dark' : 'light',
                  );
                },
              ),
            ],
          ),

          // Notifications Section
          SettingsSection(
            title: 'Notifications',
            children: [
              SwitchListTile(
                secondary: const Icon(Icons.notifications),
                title: const Text('Push Notifications'),
                subtitle: const Text('Receive notifications for new events'),
                value: settings['notifications'] ?? true,
                onChanged: (value) {
                  ref.read(settingsProvider.notifier).updateSetting('notifications', value);
                },
              ),
              ListTile(
                leading: const Icon(Icons.notification_important),
                title: const Text('Notification Settings'),
                subtitle: const Text('Customize notification preferences'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  _showNotificationSettings();
                },
              ),
            ],
          ),

          // Data Section
          SettingsSection(
            title: 'Data',
            children: [
              ListTile(
                leading: const Icon(Icons.storage),
                title: const Text('Storage'),
                subtitle: const Text('Manage app storage'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  _showStorageDialog();
                },
              ),
              ListTile(
                leading: const Icon(Icons.backup),
                title: const Text('Backup & Restore'),
                subtitle: const Text('Backup your data'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  _showBackupDialog();
                },
              ),
            ],
          ),

          // About Section
          SettingsSection(
            title: 'About',
            children: [
              ListTile(
                leading: const Icon(Icons.info),
                title: const Text('App Version'),
                subtitle: const Text('1.0.0'),
                onTap: () {
                  _showAboutDialog();
                },
              ),
              ListTile(
                leading: const Icon(Icons.help),
                title: const Text('Help & Support'),
                subtitle: const Text('Get help and support'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  _showHelpDialog();
                },
              ),
              ListTile(
                leading: const Icon(Icons.privacy_tip),
                title: const Text('Privacy Policy'),
                subtitle: const Text('Read our privacy policy'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  _showPrivacyDialog();
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _toggleBiometricAuth(bool value) async {
    if (value) {
      final isAvailable = await _localAuth.canCheckBiometrics;
      if (!isAvailable) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Biometric authentication not available'),
            backgroundColor: Colors.orange,
          ),
        );
        return;
      }

      final isAuthenticated = await _localAuth.authenticate(
        localizedReason: 'Enable biometric authentication for Alex Native',
      );

      if (isAuthenticated) {
        ref.read(settingsProvider.notifier).updateSetting('biometric_auth', true);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Biometric authentication enabled'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } else {
      ref.read(settingsProvider.notifier).updateSetting('biometric_auth', false);
    }
  }

  void _showProfileDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('User Profile'),
        content: const Text('Profile management coming soon...'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showKeysDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Key Management'),
        content: const Text('Key management coming soon...'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showSecuritySettings() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => const SecuritySettings(),
    );
  }

  void _showRelaySettings() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => const RelaySettings(),
    );
  }

  void _showThemeDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Theme'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RadioListTile<String>(
              title: const Text('System'),
              value: 'system',
              groupValue: ref.read(settingsProvider)['theme'] ?? 'system',
              onChanged: (value) {
                ref.read(settingsProvider.notifier).updateSetting('theme', value);
                Navigator.pop(context);
              },
            ),
            RadioListTile<String>(
              title: const Text('Light'),
              value: 'light',
              groupValue: ref.read(settingsProvider)['theme'] ?? 'system',
              onChanged: (value) {
                ref.read(settingsProvider.notifier).updateSetting('theme', value);
                Navigator.pop(context);
              },
            ),
            RadioListTile<String>(
              title: const Text('Dark'),
              value: 'dark',
              groupValue: ref.read(settingsProvider)['theme'] ?? 'system',
              onChanged: (value) {
                ref.read(settingsProvider.notifier).updateSetting('theme', value);
                Navigator.pop(context);
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  void _showNotificationSettings() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Notification Settings'),
        content: const Text('Notification settings coming soon...'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showStorageDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Storage'),
        content: const Text('Storage management coming soon...'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showBackupDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Backup & Restore'),
        content: const Text('Backup and restore coming soon...'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showAboutDialog() {
    showAboutDialog(
      context: context,
      applicationName: 'Alex Native',
      applicationVersion: '1.0.0',
      applicationIcon: const Icon(Icons.book, size: 48),
      children: [
        const Text('A high-performance Nostr relay with mobile interface.'),
        const SizedBox(height: 16),
        const Text('Built with Flutter and Rust for maximum performance.'),
      ],
    );
  }

  void _showHelpDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Help & Support'),
        content: const Text('Help and support coming soon...'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showPrivacyDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Privacy Policy'),
        content: const Text('Privacy policy coming soon...'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}
