import 'package:flutter/material.dart';

class PrivacySecurityScreen extends StatefulWidget {
  const PrivacySecurityScreen({Key? key}) : super(key: key);

  @override
  State<PrivacySecurityScreen> createState() => _PrivacySecurityScreenState();
}

class _PrivacySecurityScreenState extends State<PrivacySecurityScreen> {
  bool biometricAuth = false;
  bool twoFactorAuth = false;
  bool privateProfile = false;
  bool showReadingActivity = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Privacy & Security')),
      body: ListView(
        children: [
          const Padding(
            padding: EdgeInsets.all(16),
            child: Text(
              'Manage your privacy and security settings',
              style: TextStyle(color: Colors.grey),
            ),
          ),

          SwitchListTile(
            secondary: const Icon(Icons.fingerprint),
            title: const Text('Biometric Authentication'),
            subtitle: const Text('Use fingerprint or face ID to unlock app'),
            value: biometricAuth,
            onChanged: (value) {
              setState(() => biometricAuth = value);
            },
          ),

          SwitchListTile(
            secondary: const Icon(Icons.security),
            title: const Text('Two-Factor Authentication'),
            subtitle: const Text('Add an extra layer of security'),
            value: twoFactorAuth,
            onChanged: (value) {
              setState(() => twoFactorAuth = value);
            },
          ),

          const Divider(),

          SwitchListTile(
            secondary: const Icon(Icons.visibility_off),
            title: const Text('Private Profile'),
            subtitle: const Text('Hide your profile from searches'),
            value: privateProfile,
            onChanged: (value) {
              setState(() => privateProfile = value);
            },
          ),

          SwitchListTile(
            secondary: const Icon(Icons.history),
            title: const Text('Show Reading Activity'),
            subtitle: const Text('Display your reading activity to others'),
            value: showReadingActivity,
            onChanged: (value) {
              setState(() => showReadingActivity = value);
            },
          ),

          const Divider(),

          ListTile(
            leading: const Icon(Icons.block),
            title: const Text('Blocked Users'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {},
          ),

          ListTile(
            leading: const Icon(Icons.download),
            title: const Text('Download My Data'),
            subtitle: const Text('Request a copy of your data'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {},
          ),
        ],
      ),
    );
  }
}
