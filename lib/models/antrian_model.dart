// lib/models/antrian_model.dart

import 'user_model.dart';
import 'layanan_model.dart';
import 'jadwal_model.dart';

class AntrianModel {
  final int id;
  final int userId;
  final int layananId;
  final int jadwalId;
  final int nomor;
  final String status; // 'menunggu' | 'dipanggil' | 'selesai' | 'batal'
  final String? nomorMeja;
  final String? createdAt;
  final String? updatedAt;
  final int? estimasiWaktu;
  final int? antrianDiDepan;

  // Relasi eager-loaded (opsional, tersedia jika backend menyertakannya)
  final UserModel? user;
  final LayananModel? layanan;
  final JadwalModel? jadwal;

  AntrianModel({
    required this.id,
    required this.userId,
    required this.layananId,
    required this.jadwalId,
    required this.nomor,
    required this.status,
    this.nomorMeja,
    this.createdAt,
    this.updatedAt,
    this.estimasiWaktu,
    this.antrianDiDepan,
    this.user,
    this.layanan,
    this.jadwal,
  });

  // ─── Parsing JSON → AntrianModel ─────────────────────────────────
  factory AntrianModel.fromJson(Map<String, dynamic> json) {
    return AntrianModel(
      id: json['id'] as int,
      userId: json['user_id'] as int,
      layananId: json['layanan_id'] as int,
      jadwalId: json['jadwal_id'] as int,
      nomor: json['nomor'] is int
          ? json['nomor'] as int
          : int.parse(json['nomor'].toString()),
      status: json['status'] as String,
      nomorMeja: json['nomor_meja'] as String?,
      createdAt: json['created_at'] as String?,
      updatedAt: json['updated_at'] as String?,
      estimasiWaktu: json['estimasi_waktu'] as int?,
      antrianDiDepan: json['antrian_di_depan'] as int?,
      // Parse relasi jika tersedia
      user: json['user'] != null
          ? UserModel.fromJson(json['user'] as Map<String, dynamic>)
          : null,
      layanan: json['layanan'] != null
          ? LayananModel.fromJson(json['layanan'] as Map<String, dynamic>)
          : null,
      jadwal: json['jadwal'] != null
          ? JadwalModel.fromJson(json['jadwal'] as Map<String, dynamic>)
          : null,
    );
  }

  // ─── AntrianModel → JSON ─────────────────────────────────────────
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'layanan_id': layananId,
      'jadwal_id': jadwalId,
      'nomor': nomor,
      'status': status,
      'nomor_meja': nomorMeja,
    };
  }

  // ─── Helper Status ───────────────────────────────────────────────
  bool get isMenunggu => status == 'menunggu';
  bool get isDipanggil => status == 'dipanggil';
  bool get isSelesai => status == 'selesai';
  bool get isBatal => status == 'batal';
  bool get isAktif => isMenunggu || isDipanggil;

  /// Label status yang lebih ramah untuk ditampilkan di UI
  String get statusLabel {
    switch (status) {
      case 'menunggu':
        return 'Menunggu';
      case 'dipanggil':
        return 'Dipanggil';
      case 'selesai':
        return 'Selesai';
      case 'batal':
        return 'Dibatalkan';
      default:
        return status;
    }
  }

  @override
  String toString() => 'AntrianModel(id: $id, nomor: $nomor, status: $status)';
}
