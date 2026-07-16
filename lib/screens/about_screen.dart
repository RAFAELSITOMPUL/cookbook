import 'package:flutter/material.dart';
import '../constants/app_constants.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Tentang Aplikasi')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.restaurant_menu, size: 100, color: Colors.deepOrange),
            const SizedBox(height: 20),
            Text(AppConstants.appName, style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold)),
            const Text('Versi 1.0.0'),
            const SizedBox(height: 20),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 40),
              child: Text(
                'CookBook+ adalah aplikasi manajemen resep masakan modern yang membantu Anda menyimpan dan mengelola resep favorit dengan mudah.',
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 40),
            const Text('Dibuat dengan ❤️ menggunakan Flutter'),
          ],
        ),
      ),
    );
  }
}
