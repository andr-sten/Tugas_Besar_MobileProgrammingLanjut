// lib/utils/constants.dart
import 'package:flutter/material.dart';

class AppConstants {
  // Ganti dengan IP server kamu (gunakan IP LAN jika emulator fisik)
  // Contoh: 'http://192.168.1.100:8000/api'
  // Jika pakai emulator Android bawaan: 'http://10.0.2.2:8000/api'
  static const String baseUrl = 'http://192.168.1.3:8000/api';

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

  // Design Tokens (based on DESIGN.md)
  static const Color primaryColor = Color(0xFF006E25);
  static const Color secondaryColor = Color(0xFF4A6545);
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
