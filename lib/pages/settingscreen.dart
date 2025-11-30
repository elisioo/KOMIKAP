import 'package:flutter/material.dart';
import 'package:komikap/pages/auth/introscreen.dart';
import 'package:komikap/pages/privacysecurityscreen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  // TODO: Get from SettingsProvider
  String selectedTheme = 'Light';
  String selectedFont = 'Roboto';
  double fontSize = 16.0;
  String readingMode = 'Vertical';
  bool bookmarkSync = true;
  bool progressSync = true;
  bool autoRotate = false;
  bool notifications = true;
  double brightness = 0.8;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        children: [
          // Appearance Section
          _buildSectionHeader('Appearance'),

          ListTile(
            leading: const Icon(Icons.palette),
            title: const Text('Theme'),
            subtitle: Text(selectedTheme),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _showThemeDialog(),
          ),

          ListTile(
            leading: const Icon(Icons.brightness_6),
            title: const Text('Brightness'),
            subtitle: Slider(
              value: brightness,
              min: 0.2,
              max: 1.0,
              divisions: 8,
              label: '${(brightness * 100).round()}%',
              onChanged: (value) {
                setState(() => brightness = value);
                // TODO: Save to SettingsProvider
              },
            ),
          ),

          const Divider(),

          // Reading Settings
          _buildSectionHeader('Reading'),

          ListTile(
            leading: const Icon(Icons.font_download),
            title: const Text('Font Family'),
            subtitle: Text(selectedFont),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _showFontDialog(),
          ),

          ListTile(
            leading: const Icon(Icons.format_size),
            title: const Text('Font Size'),
            subtitle: Slider(
              value: fontSize,
              min: 12.0,
              max: 24.0,
              divisions: 12,
              label: fontSize.toStringAsFixed(0),
              onChanged: (value) {
                setState(() => fontSize = value);
                // TODO: Save to SettingsProvider
              },
            ),
          ),

          ListTile(
            leading: const Icon(Icons.view_agenda),
            title: const Text('Reading Mode'),
            subtitle: Text(readingMode),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _showReadingModeDialog(),
          ),

          SwitchListTile(
            secondary: const Icon(Icons.screen_rotation),
            title: const Text('Auto Rotate'),
            subtitle: const Text('Automatically rotate screen while reading'),
            value: autoRotate,
            onChanged: (value) {
              setState(() => autoRotate = value);
              // TODO: Save to SettingsProvider
            },
          ),

          const Divider(),

          // Sync & Backup
          _buildSectionHeader('Sync & Backup'),

          SwitchListTile(
            secondary: const Icon(Icons.bookmark),
            title: const Text('Sync Bookmarks'),
            subtitle: const Text('Sync bookmarks across devices'),
            value: bookmarkSync,
            onChanged: (value) {
              setState(() => bookmarkSync = value);
              // TODO: Save to SettingsProvider
            },
          ),

          SwitchListTile(
            secondary: const Icon(Icons.sync),
            title: const Text('Sync Reading Progress'),
            subtitle: const Text('Sync your reading progress'),
            value: progressSync,
            onChanged: (value) {
              setState(() => progressSync = value);
              // TODO: Save to SettingsProvider
            },
          ),

          ListTile(
            leading: const Icon(Icons.backup),
            title: const Text('Backup & Restore'),
            subtitle: const Text('Backup your data to cloud'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              // Navigate to backup screen
            },
          ),

          const Divider(),

          // Notifications
          _buildSectionHeader('Notifications'),

          SwitchListTile(
            secondary: const Icon(Icons.notifications),
            title: const Text('Push Notifications'),
            subtitle: const Text('Receive updates about new chapters'),
            value: notifications,
            onChanged: (value) {
              setState(() => notifications = value);
            },
          ),

          const Divider(),

          // Account Section
          _buildSectionHeader('Account'),

          ListTile(
            leading: const Icon(Icons.security),
            title: const Text('Privacy & Security'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const PrivacySecurityScreen(),
                ),
              );
            },
          ),

          ListTile(
            leading: const Icon(Icons.lock),
            title: const Text('Change Password'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              // Navigate to change password screen
            },
          ),

          ListTile(
            leading: Icon(Icons.cancel, color: Colors.orange[700]),
            title: Text(
              'Deactivate Account',
              style: TextStyle(color: Colors.orange[700]),
            ),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _showDeactivateDialog(),
          ),

          ListTile(
            leading: const Icon(Icons.delete_forever, color: Colors.red),
            title: const Text(
              'Delete Account',
              style: TextStyle(color: Colors.red),
            ),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _showDeleteDialog(),
          ),

          const Divider(),

          // About Section
          _buildSectionHeader('About'),

          ListTile(
            leading: const Icon(Icons.help),
            title: const Text('Help & Support'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {},
          ),

          ListTile(
            leading: const Icon(Icons.info),
            title: const Text('About'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {},
          ),

          ListTile(
            leading: const Icon(Icons.description),
            title: const Text('Terms of Service'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {},
          ),

          ListTile(
            leading: const Icon(Icons.privacy_tip),
            title: const Text('Privacy Policy'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {},
          ),

          const SizedBox(height: 16),

          // Version info
          Center(
            child: Text(
              'Version 1.0.0',
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
          ),

          const SizedBox(height: 32),

          // Logout button
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: OutlinedButton.icon(
              onPressed: () => _showLogoutDialog(),
              icon: const Icon(Icons.logout),
              label: const Text('Log Out'),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
          ),

          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: Theme.of(context).primaryColor,
        ),
      ),
    );
  }

  void _showThemeDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Choose Theme'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: ['Light', 'Dark', 'System'].map((theme) {
            return RadioListTile<String>(
              title: Text(theme),
              value: theme,
              groupValue: selectedTheme,
              onChanged: (value) {
                setState(() => selectedTheme = value!);
                Navigator.pop(context);
                // TODO: Update theme via ThemeFactory and SettingsProvider
              },
            );
          }).toList(),
        ),
      ),
    );
  }

  void _showFontDialog() {
    final fonts = ['Roboto', 'Open Sans', 'Lato', 'Montserrat', 'Poppins'];
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Choose Font'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: fonts.map((font) {
            return RadioListTile<String>(
              title: Text(font, style: TextStyle(fontFamily: font)),
              value: font,
              groupValue: selectedFont,
              onChanged: (value) {
                setState(() => selectedFont = value!);
                Navigator.pop(context);
                // TODO: Save to SettingsProvider
              },
            );
          }).toList(),
        ),
      ),
    );
  }

  void _showReadingModeDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reading Mode'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: ['Vertical', 'Horizontal'].map((mode) {
            return RadioListTile<String>(
              title: Text(mode),
              subtitle: Text(
                mode == 'Vertical'
                    ? 'Scroll down to read'
                    : 'Swipe left/right to read',
              ),
              value: mode,
              groupValue: readingMode,
              onChanged: (value) {
                setState(() => readingMode = value!);
                Navigator.pop(context);
                // TODO: Save to SettingsProvider
              },
            );
          }).toList(),
        ),
      ),
    );
  }

  void _showDeactivateDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Deactivate Account'),
        content: const Text(
          'Deactivating your account will:\n\n'
          '• Hide your profile from other users\n'
          '• Disable sync features\n'
          '• Keep your data for 30 days\n\n'
          'You can reactivate anytime within 30 days.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _confirmDeactivation();
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
            child: const Text('Deactivate'),
          ),
        ],
      ),
    );
  }

  void _confirmDeactivation() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Final Confirmation'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Are you absolutely sure?'),
            const SizedBox(height: 16),
            TextField(
              decoration: const InputDecoration(
                labelText: 'Type "DEACTIVATE" to confirm',
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                // Validate input
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              // TODO: Call AccountManager.deactivateAccount()
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Account deactivated successfully'),
                  duration: Duration(seconds: 3),
                ),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
            child: const Text('Confirm'),
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Account'),
        content: const Text(
          'This action is PERMANENT and IRREVERSIBLE.\n\n'
          'Deleting your account will:\n\n'
          '• Permanently delete all your data\n'
          '• Remove all bookmarks and progress\n'
          '• Cannot be undone\n\n'
          'Consider deactivating instead if you might return.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // Show final confirmation
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete Forever'),
          ),
        ],
      ),
    );
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Log Out'),
        content: const Text('Are you sure you want to log out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              // TODO: Clear auth tokens and navigate to login
              Navigator.pushReplacement(
                // ignore: use_build_context_synchronously
                context,
                MaterialPageRoute(builder: (context) => const SplashScreen()),
              );
            },
            child: const Text('Log Out'),
          ),
        ],
      ),
    );
  }
}
