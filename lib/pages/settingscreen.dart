import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:komikap/pages/auth/introscreen.dart';
import 'package:komikap/pages/privacysecurityscreen.dart';
import 'package:komikap/state/firebase_providers.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  String selectedTheme = 'System';
  String readingMode = 'Vertical';
  String selectedFont = 'Roboto';

  @override
  Widget build(BuildContext context) {
    final themeMode = ref.watch(themeModeProvider);
    selectedTheme = _themeLabelFromMode(themeMode);
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

          const Divider(),

          // Reading Section
          _buildSectionHeader('Reading'),

          ListTile(
            leading: const Icon(Icons.view_agenda),
            title: const Text('Reading Mode'),
            subtitle: Text(readingMode),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _showReadingModeDialog(),
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

          const Divider(),

          // About Section
          _buildSectionHeader('About'),

          ListTile(
            leading: const Icon(Icons.info_outline),
            title: const Text('About Komikap'),
            subtitle: const Text('Manga reader built with Flutter'),
          ),

          ListTile(
            leading: const Icon(Icons.description_outlined),
            title: const Text('Terms & Privacy'),
          ),

          const SizedBox(height: 16),

          Center(
            child: Text(
              'Version 1.0.0',
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
          ),

          const SizedBox(height: 24),

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

  String _themeLabelFromMode(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.light:
        return 'Light';
      case ThemeMode.dark:
        return 'Dark';
      case ThemeMode.system:
      default:
        return 'System';
    }
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
                ref.read(themeModeProvider.notifier).setThemeFromString(value!);
                Navigator.pop(context);
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
