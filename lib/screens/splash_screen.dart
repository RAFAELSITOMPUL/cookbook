import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import '../providers/recipe_provider.dart';
import 'main_navigation_screen.dart';
import '../constants/app_constants.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigateToHome();
  }

  _navigateToHome() async {
    try {
      // Tambahkan timeout 10 detik agar tidak stuck selamanya jika ada error database
      await Future.wait([
        Provider.of<RecipeProvider>(context, listen: false).fetchRecipes(),
        Future.delayed(const Duration(seconds: 3)),
      ]).timeout(const Duration(seconds: 10));
    } catch (e) {
      debugPrint("Gagal memuat data: $e");
    }

    if (!mounted) return;
    
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => const MainNavigationScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
        transitionDuration: const Duration(milliseconds: 1000),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SvgPicture.asset(
              'assets/images/logo.svg',
              width: 120,
              height: 120,
              colorFilter: const ColorFilter.mode(Colors.deepOrange, BlendMode.srcIn),
            )
                .animate(onPlay: (controller) => controller.repeat(reverse: true))
                .fade(duration: 800.ms)
                .scale(delay: 400.ms)
                .moveY(begin: 0, end: -15, duration: 1500.ms, curve: Curves.easeInOut),
            const SizedBox(height: 20),
            Text(
              AppConstants.appName,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.deepOrange,
                  ),
            ).animate().fade(delay: 800.ms),
            Text(
              AppConstants.appSubtitle,
              style: Theme.of(context).textTheme.bodyMedium,
            ).animate().fade(delay: 1000.ms),
            const SizedBox(height: 50),
            const SizedBox(
              width: 40,
              height: 40,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.deepOrange),
              ),
            )
                .animate() // Jangan pakai .repeat() di sini agar tidak loop dari awal delay
                .fade(delay: 1200.ms, duration: 800.ms)
                .then() // Setelah muncul, baru jalankan animasi berulang
                .shimmer(duration: 1500.ms, color: Colors.orangeAccent),
          ],
        ),
      ),
    );
  }
}
