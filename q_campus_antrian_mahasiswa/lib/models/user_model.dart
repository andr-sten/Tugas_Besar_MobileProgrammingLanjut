// lib/models/user_model.dart

class UserModel {
  final int id;
  final String name;
  final String username;
  final String role;
  final String? prodi;
  final int? layananId;
  final String? nomorMeja;

  UserModel({
    required this.id,
    required this.name,
    required this.username,
    required this.role,
    this.prodi,
    this.layananId,
    this.nomorMeja,
  });

  // ─── Parsing JSON → UserModel ────────────────────────────────────
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as int,
      name: json['name'] as String,
      username: json['username'] as String,
      role: json['role'] as String,
      prodi: json['prodi'] as String?,
      layananId: json['layanan_id'] as int?,
      nomorMeja: json['nomor_meja'] as String?,
    );
  }

  // ─── UserModel → JSON (untuk keperluan penyimpanan lokal) ────────
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'username': username,
      'role': role,
      'prodi': prodi,
      'layanan_id': layananId,
      'nomor_meja': nomorMeja,
    };
  }

  bool get isAdmin => role == 'admin';
  bool get isMahasiswa => role == 'mahasiswa';

  @override
  String toString() => 'UserModel(id: $id, name: $name, role: $role)';
}
