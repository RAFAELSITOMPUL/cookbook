import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_animate/flutter_animate.dart';

class ExitScreen extends StatelessWidget {
  const ExitScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.deepOrange, Colors.orange.shade800],
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.restaurant_menu, size: 100, color: Colors.white)
                .animate()
                .scale(duration: 600.ms, curve: Curves.easeOutCubic)
                .rotate(delay: 300.ms),
            const SizedBox(height: 30),
            const Text(
              'Terima Kasih!',
              style: TextStyle(
                color: Colors.white,
                fontSize: 32,
                fontWeight: FontWeight.bold,
              ),
            ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.2, end: 0),
            const SizedBox(height: 10),
            const Text(
              'Sampai jumpa kembali di CookBook+',
              style: TextStyle(color: Colors.white70, fontSize: 16),
            ).animate().fadeIn(delay: 600.ms),
            const SizedBox(height: 50),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.deepOrange,
                    padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                  ),
                  child: const Text('Batal', style: TextStyle(fontWeight: FontWeight.bold)),
                ).animate().fadeIn(delay: 800.ms).slideX(begin: -0.2, end: 0),
                const SizedBox(width: 20),
                ElevatedButton(
                  onPressed: () {
                    if (kIsWeb) {
                      // Web cannot close the window easily
                      Navigator.pop(context);
                    } else if (Platform.isAndroid || Platform.isIOS) {
                      SystemNavigator.pop();
                    } else {
                      exit(0);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red.shade900,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                  ),
                  child: const Text('Keluar Sekarang', style: TextStyle(fontWeight: FontWeight.bold)),
                ).animate().fadeIn(delay: 800.ms).slideX(begin: 0.2, end: 0),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
