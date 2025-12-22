import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';
import '../providers/theme_provider.dart';
import 'auth/login_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  static const routeName = '/settings';

  @override
  Widget build(BuildContext context) {
    // We watch ThemeProvider for the UI switch state
    final themeProvider = context.watch<ThemeProvider>();
    
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
          // Theme Toggle
          Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: SwitchListTile(
              secondary: Icon(
                  themeProvider.isDarkMode ? Icons.dark_mode : Icons.light_mode),
              title: const Text('Dark Mode'),
              value: themeProvider.isDarkMode,
              onChanged: (value) {
                themeProvider.toggleTheme();
              },
            ),
          ),
          const SizedBox(height: 12),
        
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
              onPressed: () async {
                 // Use AuthProvider for logout
                 await context.read<AuthProvider>().logout();
                 
                 // AuthGate in main.dart will handle navigation automatically
                 // But strictly, we might want to pop just in case.
                 // Actually, AuthGate is the parent of MainNavigation.
                 // If we logout, AuthGate rebuilds and shows LoginScreen.
                 // So we don't necessarily need to nav manually, 
                 // but popping SettingsScreen is good practice if we were pushed.
                 // However, AuthGate will switch the whole tree.
                 // Let's just pop settings to be clean.
                 if (context.mounted) {
                   Navigator.of(context).popUntil((route) => route.isFirst);
                 }
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
