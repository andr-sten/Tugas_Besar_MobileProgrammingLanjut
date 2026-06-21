// lib/utils/constants.dart
import 'package:flutter/material.dart';

class AppConstants {
  // Ganti dengan IP server kamu (gunakan IP LAN jika emulator fisik)
  // Contoh: 'http://192.168.1.100:8000/api'
  // Jika pakai emulator Android bawaan: 'http://10.0.2.2:8000/api'
  static const String baseUrl = 'https://tugas-besar-backend.vercel.app/api';

  // Endpoint Auth
  static const String registerEndpoint = '/register';
  static const String loginEndpoint = '/login';
  static const String usersEndpoint = '/users';

  // Endpoint Layanan
  static const String layananEndpoint = '/layanan';

  // Endpoint Jadwal
  static const String jadwalEndpoint = '/jadwal';

  // Endpoint Antrian
  static const String antrianEndpoint = '/antrian';

  // Storage Keys
  static const String tokenKey = 'auth_token';
  static const String userKey = 'auth_user';

  static final ColorScheme lightColorScheme = ColorScheme.fromSeed(
    seedColor: const Color(0xFF006E25),
    brightness: Brightness.light,
    primary: const Color(0xFF006E25),
    secondary: const Color(0xFF064E3B),
    surface: const Color(0xFFF7FAF2),
    onSurface: const Color(0xFF191D18),
    onSurfaceVariant: const Color(0xFF4F6A49),
    error: const Color(0xFFBA1A1A),
    outline: const Color(0xFF6E7B6B),
    outlineVariant: const Color(0xFFE8EEE7),
    surfaceContainerHighest: const Color(0xFFF2F5EC),
  );

  static final ColorScheme darkColorScheme = ColorScheme.fromSeed(
    seedColor: const Color(0xFF006E25),
    brightness: Brightness.dark,
    primary: const Color(0xFF00E653),
    secondary: const Color(0xFF52B788),
    surface: const Color(0xFF11140E),
    onSurface: const Color(0xFFE2E3DD),
    onSurfaceVariant: const Color(0xFFA1AAB0),
    error: const Color(0xFFFFB4AB),
    outline: const Color(0xFF8D9286),
    outlineVariant: const Color(0xFF43493E),
    surfaceContainerHighest: const Color(0xFF1D221A),
  );

  // Legacy fallback color constants for compilation compatibility
  static const Color primaryColor = Color(0xFF006E25);
  static const Color secondaryColor = Color(0xFF064E3B);
  static const Color backgroundColor = Color(0xFFF7FAF2);
  static const Color surfaceColor = Color(0xFFF7FAF2);
  static const Color onSurfaceColor = Color(0xFF191D18);
  static const Color errorColor = Color(0xFFBA1A1A);
  static const Color outlineColor = Color(0xFF6E7B6B);

  static const double borderRadiusSmall = 8.0;
  static const double borderRadiusDefault = 16.0;
  static const double borderRadiusLarge = 24.0;

  static Color? get onSurfaceVariant => null;
}
