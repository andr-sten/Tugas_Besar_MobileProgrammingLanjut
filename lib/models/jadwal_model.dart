// lib/models/jadwal_model.dart

import 'package:intl/intl.dart';
import 'layanan_model.dart';

class JadwalModel {
  final int id;
  final int layananId;
  final String tanggal;   // format: "YYYY-MM-DD"
  final String jamMulai;  // format: "HH:MM:SS" atau "HH:MM"
  final String jamSelesai;
  final int kuota;
  final LayananModel? layanan; // relasi eager-loaded (opsional)

  JadwalModel({
    required this.id,
    required this.layananId,
    required this.tanggal,
    required this.jamMulai,
    required this.jamSelesai,
    required this.kuota,
    this.layanan,
  });

  // ─── Parsing JSON → JadwalModel ──────────────────────────────────
  factory JadwalModel.fromJson(Map<String, dynamic> json) {
    return JadwalModel(
      id: json['id'] as int,
      layananId: json['layanan_id'] as int,
      tanggal: json['tanggal'] as String,
      jamMulai: json['jam_mulai'] as String,
      jamSelesai: json['jam_selesai'] as String,
      kuota: json['kuota'] is int
          ? json['kuota'] as int
          : int.parse(json['kuota'].toString()),
      // Jika response menyertakan relasi 'layanan', parse juga
      layanan: json['layanan'] != null
          ? LayananModel.fromJson(json['layanan'] as Map<String, dynamic>)
          : null,
    );
  }

  // ─── JadwalModel → JSON ──────────────────────────────────────────
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'layanan_id': layananId,
      'tanggal': tanggal,
      'jam_mulai': jamMulai,
      'jam_selesai': jamSelesai,
      'kuota': kuota,
    };
  }

  /// Memotong detik dari format jam HH:MM:SS → HH:MM
  String get jamMulaiShort => jamMulai.length >= 5 ? jamMulai.substring(0, 5) : jamMulai;
  String get jamSelesaiShort => jamSelesai.length >= 5 ? jamSelesai.substring(0, 5) : jamSelesai;

  /// Menampilkan tanggal dalam format bahasa Indonesia (Contoh: Senin, 06 Mei 2026)
  String get tanggalFormatted {
    try {
      final date = DateTime.parse(tanggal);
      return DateFormat('EEEE, dd MMMM yyyy', 'id_ID').format(date);
    } catch (_) {
      return tanggal;
    }
  }

  @override
  String toString() => 'JadwalModel(id: $id, tanggal: $tanggal)';
}
