//baru
// lib/main.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:q_campus_antrian_mahasiswa/services/notification_service.dart';
import 'package:q_campus_antrian_mahasiswa/utils/auth_storage.dart';
import 'package:q_campus_antrian_mahasiswa/utils/constants.dart';
import 'package:q_campus_antrian_mahasiswa/utils/theme_notifier.dart';
import 'package:q_campus_antrian_mahasiswa/screens/auth/login_screen.dart';
import 'package:q_campus_antrian_mahasiswa/screens/auth/register_screen.dart';
import 'package:q_campus_antrian_mahasiswa/screens/splash_screen.dart';
import 'package:q_campus_antrian_mahasiswa/screens/mahasiswa/home_mahasiswa.dart';
import 'package:q_campus_antrian_mahasiswa/screens/mahasiswa/booking_antrian.dart';
import 'package:q_campus_antrian_mahasiswa/screens/admin/home_admin.dart';
import 'package:q_campus_antrian_mahasiswa/screens/admin/kelola_antrian.dart';
import 'package:q_campus_antrian_mahasiswa/screens/onboarding_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await NotificationService.init();
  await initializeDateFormatting('id_ID', null);
  final themeNotifier = ThemeNotifier();
  runApp(QCampusApp(themeNotifier: themeNotifier));
}

class QCampusApp extends StatelessWidget {
  final ThemeNotifier themeNotifier;
  const QCampusApp({super.key, required this.themeNotifier});

  ThemeData _buildThemeData(ColorScheme colorScheme) {
    final isDark = colorScheme.brightness == Brightness.dark;
    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      textTheme: GoogleFonts.plusJakartaSansTextTheme(
        isDark ? ThemeData.dark().textTheme : ThemeData.light().textTheme,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: isDark ? colorScheme.surfaceContainerHighest : const Color(0xFFF0F4EF),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.borderRadiusDefault),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.borderRadiusDefault),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.borderRadiusDefault),
          borderSide: BorderSide(color: colorScheme.primary, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.borderRadiusLarge),
          side: BorderSide(color: colorScheme.outlineVariant, width: 1),
        ),
        color: colorScheme.surface,
        surfaceTintColor: Colors.transparent,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: colorScheme.primary,
          foregroundColor: colorScheme.onPrimary,
          minimumSize: const Size(double.infinity, 56),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppConstants.borderRadiusDefault),
          ),
          elevation: 0,
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: themeNotifier,
      builder: (context, _) {
        return MaterialApp(
          title: 'Q-Campus',
          debugShowCheckedModeBanner: false,
          themeMode: themeNotifier.themeMode,
          theme: _buildThemeData(AppConstants.lightColorScheme),
          darkTheme: _buildThemeData(AppConstants.darkColorScheme),
          home: const SplashScreen(),
          routes: {
            '/onboarding': (_) => const OnboardingScreen(),
            '/login': (_) => const LoginScreen(),
            '/register': (_) => const RegisterScreen(),
            '/mahasiswa/home': (_) => const HomeMahasiswa(),
            '/mahasiswa/booking': (_) => const BookingAntrian(),
            '/admin/home': (_) => const HomeAdmin(),
            '/admin/kelola': (_) => const KelolaAntrian(),
          },
        );
      },
    );
  }
}

