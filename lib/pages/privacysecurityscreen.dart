import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:komikap/services/firebase_service.dart';

class PrivacySecurityScreen extends StatefulWidget {
  const PrivacySecurityScreen({Key? key}) : super(key: key);

  @override
  State<PrivacySecurityScreen> createState() => _PrivacySecurityScreenState();
}

class _PrivacySecurityScreenState extends State<PrivacySecurityScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseService _firebaseService = FirebaseService();

  bool _privateProfile = false;
  bool _showReadingActivity = true;
  bool _loading = true;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final user = _auth.currentUser;
    if (user == null) {
      setState(() => _loading = false);
      return;
    }

    try {
      final profile = await _firebaseService.getUserProfile(user.uid);
      setState(() {
        _privateProfile = profile?.privateProfile ?? false;
        _showReadingActivity = profile?.showReadingActivity ?? true;
        _loading = false;
      });
    } catch (_) {
      setState(() => _loading = false);
    }
  }

  Future<void> _updateSettings({bool? privateProfile, bool? showReadingActivity}) async {
    final user = _auth.currentUser;
    if (user == null) return;

    setState(() {
      _saving = true;
      if (privateProfile != null) _privateProfile = privateProfile;
      if (showReadingActivity != null) {
        _showReadingActivity = showReadingActivity;
      }
    });

    try {
      await _firebaseService.updateUserProfile(user.uid, {
        'privateProfile': _privateProfile,
        'showReadingActivity': _showReadingActivity,
      });
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to save privacy settings')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _saving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Privacy & Security')),
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    final user = _auth.currentUser;
    if (user == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Privacy & Security')),
        body: const Center(
          child: Text('Please log in to manage privacy settings'),
        ),
      );
    }

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
            secondary: const Icon(Icons.visibility_off),
            title: const Text('Private Profile'),
            subtitle: const Text('Hide your profile from searches'),
            value: _privateProfile,
            onChanged: _saving
                ? null
                : (value) => _updateSettings(privateProfile: value),
          ),

          SwitchListTile(
            secondary: const Icon(Icons.history),
            title: const Text('Show Reading Activity'),
            subtitle: const Text('Display your reading activity to others'),
            value: _showReadingActivity,
            onChanged: _saving
                ? null
                : (value) => _updateSettings(showReadingActivity: value),
          ),

          if (_saving)
            const Padding(
              padding: EdgeInsets.all(16),
              child: LinearProgressIndicator(),
            ),
        ],
      ),
    );
  }
}
