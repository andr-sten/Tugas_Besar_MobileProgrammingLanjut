// lib/models/layanan_model.dart

class LayananModel {
  final int id;
  final String nama;
  final int durasi; // dalam menit
  final String ruangan;

  LayananModel({
    required this.id,
    required this.nama,
    required this.durasi,
    required this.ruangan,
  });

  // ─── Parsing JSON → LayananModel ─────────────────────────────────
  factory LayananModel.fromJson(Map<String, dynamic> json) {
    return LayananModel(
      id: json['id'] as int,
      nama: json['nama'] as String,
      // durasi bisa datang sebagai int atau string, handle keduanya
      durasi: json['durasi'] is int
          ? json['durasi'] as int
          : int.parse(json['durasi'].toString()),
      ruangan: json['ruangan'] as String,
    );
  }

  // ─── LayananModel → JSON ─────────────────────────────────────────
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nama': nama,
      'durasi': durasi,
      'ruangan': ruangan,
    };
  }

  /// Tampilan durasi yang lebih ramah: "30 menit" atau "1 jam 30 menit"
  String get durasiFormatted {
    if (durasi < 60) return '$durasi menit';
    final jam = durasi ~/ 60;
    final sisa = durasi % 60;
    return sisa == 0 ? '$jam jam' : '$jam jam $sisa menit';
  }

  @override
  String toString() => 'LayananModel(id: $id, nama: $nama)';
}
