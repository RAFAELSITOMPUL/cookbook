import 'package:flutter/material.dart';

class TermsOfServiceScreen extends StatelessWidget {
  const TermsOfServiceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Terms of Service'),
      ),
      body: const SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Syarat dan Ketentuan Penggunaan CookBook+',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            Text(
              'Selamat datang di CookBook+. Dengan mengunduh atau menggunakan aplikasi ini, Anda secara otomatis menyetujui syarat dan ketentuan berikut. Harap baca dengan saksama sebelum menggunakan aplikasi.',
            ),
            SizedBox(height: 12),
            Text(
              '1. Lisensi Penggunaan',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Text(
              'CookBook+ memberikan Anda lisensi pribadi, non-eksklusif, dan tidak dapat dipindahtangankan untuk menggunakan aplikasi ini semata-mata untuk tujuan pengelolaan resep pribadi Anda.',
            ),
            SizedBox(height: 12),
            Text(
              '2. Konten Pengguna',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Text(
              'Anda bertanggung jawab penuh atas data resep, gambar, dan teks yang Anda masukkan ke dalam aplikasi. CookBook+ tidak bertanggung jawab atas hilangnya data karena kegagalan perangkat atau penghapusan aplikasi tanpa backup.',
            ),
            SizedBox(height: 12),
            Text(
              '3. Batasan Tanggung Jawab',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Text(
              'Aplikasi ini disediakan "apa adanya" tanpa jaminan dalam bentuk apa pun. Kami tidak bertanggung jawab atas kerugian tidak langsung yang timbul dari penggunaan atau ketidakmampuan menggunakan aplikasi ini.',
            ),
            SizedBox(height: 12),
            Text(
              '4. Penggunaan Database Lokal',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Text(
              'Seluruh data Anda disimpan secara lokal. Fitur Backup dan Restore disediakan untuk memudahkan Anda mengelola data tersebut, namun keamanan penyimpanan backup tetap menjadi tanggung jawab pengguna.',
            ),
            SizedBox(height: 12),
            Text(
              '5. Perubahan Ketentuan',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Text(
              'Kami berhak mengubah syarat dan ketentuan ini kapan saja. Perubahan akan berlaku segera setelah dipublikasikan di dalam aplikasi.',
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
