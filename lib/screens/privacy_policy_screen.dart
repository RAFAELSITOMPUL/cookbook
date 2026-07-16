import 'package:flutter/material.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Privacy Policy'),
      ),
      body: const SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Kebijakan Privasi CookBook+',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            Text(
              'Privasi Anda sangat penting bagi kami. Kebijakan Privasi ini menjelaskan bagaimana CookBook+ mengumpulkan, menggunakan, dan melindungi informasi Anda saat menggunakan aplikasi kami.',
            ),
            SizedBox(height: 12),
            Text(
              '1. Informasi yang Kami Kumpulkan',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Text(
              'Aplikasi ini menyimpan semua data resep secara lokal di perangkat Anda menggunakan database SQLite. Kami tidak mengirimkan data resep Anda ke server eksternal kami.',
            ),
            SizedBox(height: 12),
            Text(
              '2. Penggunaan Izin Perangkat',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Text(
              'Kami meminta izin akses ke kamera dan galeri hanya untuk memungkinkan Anda mengunggah foto resep masakan Anda sendiri. Data ini tetap berada di perangkat Anda.',
            ),
            SizedBox(height: 12),
            Text(
              '3. Keamanan Data',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Text(
              'Kami berkomitmen untuk melindungi data lokal Anda. Kami menyarankan Anda untuk menggunakan fitur Backup secara berkala agar data Anda tetap aman jika terjadi masalah pada perangkat.',
            ),
            SizedBox(height: 12),
            Text(
              '4. Perubahan Kebijakan',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Text(
              'Kami dapat memperbarui Kebijakan Privasi ini dari waktu ke waktu. Penggunaan berkelanjutan Anda atas aplikasi ini setelah perubahan tersebut merupakan penerimaan Anda terhadap kebijakan yang baru.',
            ),
            SizedBox(height: 24),
            Text(
              'Terakhir diperbarui: Januari 2026',
              style: TextStyle(fontStyle: FontStyle.italic, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}
