// lib/screens/settings/settings_screen.dart

import 'package:flutter/material.dart';
import 'package:inventory_tracker/providers/auth_provider.dart';
import 'package:provider/provider.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Kita gunakan Consumer agar UI rebuild saat user berubah (setelah logout)
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        return Scaffold(
          appBar: AppBar(title: const Text('Settings')),
          body: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                if (authProvider.isAuthenticated) ...[
                  ListTile(
                    leading: const Icon(Icons.person),

                    // Di dalam ListTile
                    title: Text(
                      authProvider.user?.displayName ?? 'No Name Set',
                    ),
                    subtitle: Text(authProvider.user?.email ?? 'No Email'),
                  ),
                  const Divider(),
                ],
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.logout),
                    label: const Text('Logout'),
                    onPressed: () {
                      _showLogoutConfirmationDialog(context);
                      context.read<AuthProvider>().logout();
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.red,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

// Method helper untuk menampilkan dialog
void _showLogoutConfirmationDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (BuildContext ctx) {
      return AlertDialog(
        title: const Text('Konfirmasi'),
        content: const Text('Apakah Anda yakin ingin logout?'),
        actions: [
          TextButton(
            child: const Text('Batal'),
            onPressed: () {
              Navigator.of(ctx).pop(); // Tutup dialog
            },
          ),
          FilledButton(
            child: const Text('Logout'),
            onPressed: () {
              // Panggil fungsi logout
              context.read<AuthProvider>().logout();
              // Tutup dialog
              Navigator.of(ctx).pop();
              // (Opsional) Jika SettingsScreen dibuka dari halaman lain,
              // tutup juga halaman SettingsScreen setelah logout.
              Navigator.of(context).pop();
            },
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
          ),
        ],
      );
    },
  );
}
