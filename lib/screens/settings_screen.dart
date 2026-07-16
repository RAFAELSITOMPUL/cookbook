import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:sqflite/sqflite.dart';
import 'dart:io';
import '../providers/theme_provider.dart';
import '../providers/recipe_provider.dart';
import '../constants/app_constants.dart';
import 'privacy_policy_screen.dart';
import 'terms_of_service_screen.dart';
import 'about_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text('Tampilan', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.deepOrange)),
        ListTile(
          title: const Text('Mode Tema'),
          trailing: DropdownButton<ThemeMode>(
            value: themeProvider.themeMode,
            items: const [
              DropdownMenuItem(value: ThemeMode.system, child: Text('Sistem')),
              DropdownMenuItem(value: ThemeMode.light, child: Text('Terang')),
              DropdownMenuItem(value: ThemeMode.dark, child: Text('Gelap')),
            ],
            onChanged: (mode) {
              if (mode != null) themeProvider.setThemeMode(mode);
            },
          ),
        ),
        ListTile(
          title: const Text('Ukuran Font'),
          subtitle: Slider(
            value: themeProvider.fontSizeFactor,
            min: 0.8,
            max: 1.5,
            onChanged: (val) => themeProvider.setFontSizeFactor(val),
          ),
        ),
        const Divider(),
        const Text('Database', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.deepOrange)),
        ListTile(
          leading: const Icon(Icons.backup),
          title: const Text('Backup Database'),
          onTap: () => _confirmBackup(context),
        ),
        ListTile(
          leading: const Icon(Icons.restore),
          title: const Text('Restore Database'),
          onTap: () => _confirmRestore(context),
        ),
        ListTile(
          leading: const Icon(Icons.share),
          title: const Text('Export Database (Share)'),
          onTap: () async {
            final dbPath = await getDatabasesPath();
            final path = '$dbPath/${AppConstants.dbName}';
            if (await File(path).exists()) {
              await Share.shareXFiles([XFile(path)], text: 'CookBook+ Database Backup');
            }
          },
        ),
        ListTile(
          leading: const Icon(Icons.auto_awesome, color: Colors.amber),
          title: const Text('Generate 300 Resep'),
          subtitle: const Text('Isi aplikasi dengan data otomatis'),
          onTap: () async {
            _showLoadingDialog(context, 'Sedang memasukkan 300 data ke SQLite...');
            try {
              await Provider.of<RecipeProvider>(context, listen: false).generateDummyData();
              if (context.mounted) {
                Navigator.pop(context); // Tutup loading
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Berhasil menambahkan 300 resep!')));
              }
            } catch (e) {
              if (context.mounted) {
                Navigator.pop(context); // Pastikan loading tertutup jika error
                _showErrorDialog(context, e.toString());
              }
            }
          },
        ),
        ListTile(
          leading: const Icon(Icons.shopping_basket, color: Colors.blue),
          title: const Text('Generate 400 Item Belanja'),
          subtitle: const Text('Isi daftar belanja otomatis'),
          onTap: () async {
            _showLoadingDialog(context, 'Sedang memasukkan 400 item belanja...');
            try {
              await Provider.of<RecipeProvider>(context, listen: false).generateShoppingListData();
              if (context.mounted) {
                Navigator.pop(context); // Tutup loading
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Berhasil menambahkan 400 item belanja!')));
              }
            } catch (e) {
              if (context.mounted) {
                Navigator.pop(context); // Pastikan loading tertutup jika error
                _showErrorDialog(context, e.toString());
              }
            }
          },
        ),
        ListTile(
          leading: const Icon(Icons.delete_forever, color: Colors.red),
          title: const Text('Reset Database'),
          onTap: () => _confirmReset(context),
        ),
        const Divider(),
        const Text('Tentang', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.deepOrange)),
        ListTile(
          leading: const Icon(Icons.info),
          title: const Text('Tentang Aplikasi'),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const AboutScreen()),
            );
          },
        ),
        ListTile(
          leading: const Icon(Icons.info_outline),
          title: const Text('Privacy Policy'),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const PrivacyPolicyScreen()),
            );
          },
        ),
        ListTile(
          leading: const Icon(Icons.description_outlined),
          title: const Text('Terms of Service'),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const TermsOfServiceScreen()),
            );
          },
        ),
        const ListTile(
          title: Text('Versi Aplikasi'),
          trailing: Text('1.3.0'),
        ),
      ],
    );
  }

  void _showErrorDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Gagal Memasukkan Data'),
        content: Text(message),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Tutup')),
        ],
      ),
    );
  }

  void _showLoadingDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 16),
            Text(message),
          ],
        ),
      ),
    );
  }

  void _confirmBackup(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Backup Database'),
        content: const Text('Buat cadangan data resep saat ini secara permanen?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Batal')),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              try {
                await Provider.of<RecipeProvider>(context, listen: false).backupDatabase();
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Database berhasil di-backup secara lokal')),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Gagal backup: $e'), backgroundColor: Colors.red),
                  );
                }
              }
            },
            child: const Text('Backup'),
          ),
        ],
      ),
    );
  }

  void _confirmRestore(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Restore Database'),
        content: const Text('Data saat ini akan digantikan dengan data cadangan. Lanjutkan?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Batal')),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              try {
                await Provider.of<RecipeProvider>(context, listen: false).restoreDatabase();
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Data berhasil dikembalikan (Restored)')),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Gagal restore: $e'), backgroundColor: Colors.red),
                  );
                }
              }
            },
            child: const Text('Restore'),
          ),
        ],
      ),
    );
  }

  void _confirmReset(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reset Database'),
        content: const Text('Semua data resep akan dihapus permanen. Lanjutkan?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Batal')),
          TextButton(
            onPressed: () async {
              await Provider.of<RecipeProvider>(context, listen: false).resetDatabase();
              if (context.mounted) Navigator.pop(context);
              if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Database telah direset')));
            },
            child: const Text('Reset', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
