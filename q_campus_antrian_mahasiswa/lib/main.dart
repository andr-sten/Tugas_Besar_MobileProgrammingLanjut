//baru
// lib/main.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:q_campus_antrian_mahasiswa/services/notification_service.dart';
import 'package:q_campus_antrian_mahasiswa/utils/auth_storage.dart';
import 'package:q_campus_antrian_mahasiswa/utils/constants.dart';
import 'package:q_campus_antrian_mahasiswa/screens/auth/login_screen.dart';
import 'package:q_campus_antrian_mahasiswa/screens/auth/register_screen.dart';
import 'package:q_campus_antrian_mahasiswa/screens/mahasiswa/home_mahasiswa.dart';
import 'package:q_campus_antrian_mahasiswa/screens/mahasiswa/booking_antrian.dart';
import 'package:q_campus_antrian_mahasiswa/screens/admin/home_admin.dart';
import 'package:q_campus_antrian_mahasiswa/screens/admin/kelola_antrian.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await NotificationService.init();
  runApp(const QCampusApp());
}

class QCampusApp extends StatelessWidget {
  const QCampusApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Q-Campus',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppConstants.primaryColor,
          primary: AppConstants.primaryColor,
          secondary: AppConstants.secondaryColor,
          surface: AppConstants.surfaceColor,
          onSurface: AppConstants.onSurfaceColor,
          error: AppConstants.errorColor,
        ),
        textTheme: GoogleFonts.plusJakartaSansTextTheme(),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: const Color(0xFFF0F4EF),
          border: OutlineInputBorder(
            borderRadius:
                BorderRadius.circular(AppConstants.borderRadiusDefault),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius:
                BorderRadius.circular(AppConstants.borderRadiusDefault),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius:
                BorderRadius.circular(AppConstants.borderRadiusDefault),
            borderSide:
                const BorderSide(color: AppConstants.primaryColor, width: 2),
          ),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        ),
        cardTheme: CardThemeData(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppConstants.borderRadiusLarge),
            side: const BorderSide(color: Color(0xFFE8EEE7), width: 1),
          ),
          color: Colors.white,
          surfaceTintColor: Colors.transparent,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppConstants.primaryColor,
            foregroundColor: Colors.white,
            minimumSize: const Size(double.infinity, 56),
            shape: RoundedRectangleBorder(
              borderRadius:
                  BorderRadius.circular(AppConstants.borderRadiusDefault),
            ),
            elevation: 0,
            textStyle: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
      // ── SplashScreen: cek apakah sudah login ─────────────────────
      home: const SplashScreen(),
      routes: {
        '/login': (_) => const LoginScreen(),
        '/register': (_) => const RegisterScreen(),
        '/mahasiswa/home': (_) => const HomeMahasiswa(),
        '/mahasiswa/booking': (_) => const BookingAntrian(),
        '/admin/home': (_) => const HomeAdmin(),
        '/admin/kelola': (_) => const KelolaAntrian(),
      },
    );
  }
}

/// Layar splash yang memeriksa status login dan mengarahkan ke halaman yang tepat
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkAuth();
  }

  Future<void> _checkAuth() async {
    // Sedikit delay untuk splash screen
    await Future.delayed(const Duration(milliseconds: 800));
    if (!mounted) return;

    final isLoggedIn = await AuthStorage.isLoggedIn();
    if (!mounted) return;

    if (isLoggedIn) {
      // Cek role untuk routing yang benar
      final user = await AuthStorage.getUser();
      if (!mounted) return;
      final role = user?['role'] as String? ?? 'mahasiswa';
      Navigator.pushReplacementNamed(
        context,
        role == 'admin' ? '/admin/home' : '/mahasiswa/home',
      );
    } else {
      Navigator.pushReplacementNamed(context, '/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.queue_outlined,
              size: 80,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 16),
            Text(
              'Q-Campus',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Sistem Antrian Kampus',
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 40),
            const CircularProgressIndicator(),
          ],
        ),
      ),
    );
  }
}
