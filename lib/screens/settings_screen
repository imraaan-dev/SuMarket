import 'package:flutter/material.dart';

import 'auth/login_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  static const routeName = '/settings';

  @override
  Widget build(BuildContext context) {
    final entries = [
      _SettingsItem(
        icon: Icons.person_outline,
        title: 'Edit Username',
        onTap: () {},
      ),
      _SettingsItem(
        icon: Icons.lock_outline,
        title: 'Change Password',
        onTap: () {},
      ),
      _SettingsItem(
        icon: Icons.image_outlined,
        title: 'Update Profile Picture',
        onTap: () {},
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          ...entries.map(
            (item) => Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: ListTile(
                leading: Icon(item.icon),
                title: Text(item.title),
                trailing: const Icon(Icons.chevron_right),
                onTap: item.onTap,
              ),
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () {
                Navigator.of(context).pushNamedAndRemoveUntil(
                  LoginScreen.routeName,
                  (route) => false,
                );
              },
              child: const Text('Logout'),
            ),
          ),
        ],
      ),
    );
  }
}

class _SettingsItem {
  const _SettingsItem({
    required this.icon,
    required this.title,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final VoidCallback onTap;
}
