// lib/services/api_service.dart

import 'dart:convert';
import 'package:http/http.dart' as http;
import '../utils/constants.dart';
import '../utils/auth_storage.dart';
import '../models/user_model.dart';
import '../models/layanan_model.dart';
import '../models/jadwal_model.dart';
import '../models/antrian_model.dart';

// ─── Generic Response Wrapper ────────────────────────────────────────────────
class ApiResponse<T> {
  final bool status;
  final String message;
  final T? data;

  ApiResponse({
    required this.status,
    required this.message,
    this.data,
  });
}

// ─── Custom Exception ────────────────────────────────────────────────────────
class ApiException implements Exception {
  final String message;
  final int? statusCode;

  ApiException(this.message, {this.statusCode});

  @override
  String toString() => message;
}

// ─── API Service ─────────────────────────────────────────────────────────────
class ApiService {
  // ── Header Helper ──────────────────────────────────────────────────────────

  /// Header untuk request publik (tanpa token)
  static Map<String, String> get _publicHeaders => {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      };

  /// Header untuk request terproteksi (dengan Bearer Token)
  static Future<Map<String, String>> get _authHeaders async {
    final token = await AuthStorage.getToken();
    if (token == null)
      throw ApiException('Token tidak ditemukan. Silakan login ulang.',
          statusCode: 401);
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  // ── Response Parser ────────────────────────────────────────────────────────

  /// Decode response dan lempar exception jika status code tidak OK
  static Map<String, dynamic> _parseResponse(http.Response response) {
    final Map<String, dynamic> body =
        jsonDecode(response.body) as Map<String, dynamic>;

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return body;
    }

    // Ambil pesan error dari body jika ada
    final errorMessage =
        body['message'] as String? ?? 'Terjadi kesalahan pada server';
    throw ApiException(errorMessage, statusCode: response.statusCode);
  }

  // ══════════════════════════════════════════════════════════════════
  // AUTH ENDPOINTS
  // ══════════════════════════════════════════════════════════════════

  /// POST /register
  static Future<ApiResponse<Map<String, dynamic>>> register({
    required String name,
    required String username,
    required String password,
    required String passwordConfirmation,
    required String role,
    String? prodi,
    int? layananId,
    String? nomorMeja,
  }) async {
    try {
      final response = await http
          .post(
            Uri.parse(
                '${AppConstants.baseUrl}${AppConstants.registerEndpoint}'),
            headers: _publicHeaders,
            body: jsonEncode({
              'name': name,
              'username': username,
              'password': password,
              'password_confirmation': passwordConfirmation,
              'role': role,
              if (prodi != null) 'prodi': prodi,
              if (layananId != null) 'layanan_id': layananId,
              if (nomorMeja != null) 'nomor_meja': nomorMeja,
            }),
          )
          .timeout(const Duration(seconds: 15));

      final body = _parseResponse(response);

      // Simpan token dan data user ke storage lokal jika berhasil
      if (body['status'] == true && body['data'] != null) {
        final data = body['data'] as Map<String, dynamic>;
        await AuthStorage.saveToken(data['token'] as String);
        await AuthStorage.saveUser(data['user'] as Map<String, dynamic>);
      }

      return ApiResponse(
        status: body['status'] as bool,
        message: body['message'] as String,
        data: body['data'] as Map<String, dynamic>?,
      );
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException(
          'Gagal terhubung ke server. Periksa koneksi internet Anda.');
    }
  }

  /// POST /login
  static Future<ApiResponse<Map<String, dynamic>>> login({
    required String username,
    required String password,
  }) async {
    try {
      final response = await http
          .post(
            Uri.parse('${AppConstants.baseUrl}${AppConstants.loginEndpoint}'),
            headers: _publicHeaders,
            body: jsonEncode({'username': username, 'password': password}),
          )
          .timeout(const Duration(seconds: 15));

      final body = _parseResponse(response);

      // Simpan token dan data user ke storage lokal
      if (body['status'] == true && body['data'] != null) {
        final data = body['data'] as Map<String, dynamic>;
        await AuthStorage.saveToken(data['token'] as String);
        await AuthStorage.saveUser(data['user'] as Map<String, dynamic>);
      }

      return ApiResponse(
        status: body['status'] as bool,
        message: body['message'] as String,
        data: body['data'] as Map<String, dynamic>?,
      );
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException(
          'Gagal terhubung ke server. Periksa koneksi internet Anda.');
    }
  }

  // ══════════════════════════════════════════════════════════════════
  // LAYANAN ENDPOINTS
  // ══════════════════════════════════════════════════════════════════

  /// GET /layanan  →  List<LayananModel>
  static Future<List<LayananModel>> getLayanan() async {
    try {
      final headers = await _authHeaders;
      final response = await http
          .get(
            Uri.parse('${AppConstants.baseUrl}${AppConstants.layananEndpoint}'),
            headers: headers,
          )
          .timeout(const Duration(seconds: 15));

      final body = _parseResponse(response);

      // body['data'] adalah array JSON → parsing ke List<LayananModel>
      final List<dynamic> rawList = body['data'] as List<dynamic>;
      return rawList
          .map((item) => LayananModel.fromJson(item as Map<String, dynamic>))
          .toList();
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException('Gagal mengambil data layanan.');
    }
  }

  /// POST /layanan  (Admin only)
  static Future<LayananModel> createLayanan({
    required String nama,
    required int durasi,
    required String ruangan,
  }) async {
    try {
      final headers = await _authHeaders;
      final response = await http
          .post(
            Uri.parse('${AppConstants.baseUrl}${AppConstants.layananEndpoint}'),
            headers: headers,
            body: jsonEncode(
                {'nama': nama, 'durasi': durasi, 'ruangan': ruangan}),
          )
          .timeout(const Duration(seconds: 15));

      final body = _parseResponse(response);
      return LayananModel.fromJson(body['data'] as Map<String, dynamic>);
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException('Gagal membuat layanan baru.');
    }
  }

  // ══════════════════════════════════════════════════════════════════
  // JADWAL ENDPOINTS
  // ══════════════════════════════════════════════════════════════════

  /// GET /jadwal?layanan_id={id}  →  List<JadwalModel>
  static Future<List<JadwalModel>> getJadwal({int? layananId}) async {
    try {
      final headers = await _authHeaders;

      // Bangun URL dengan query parameter opsional
      final uri = Uri.parse(
        '${AppConstants.baseUrl}${AppConstants.jadwalEndpoint}',
      ).replace(
        queryParameters:
            layananId != null ? {'layanan_id': layananId.toString()} : null,
      );

      final response = await http
          .get(uri, headers: headers)
          .timeout(const Duration(seconds: 15));

      final body = _parseResponse(response);

      final List<dynamic> rawList = body['data'] as List<dynamic>;
      return rawList
          .map((item) => JadwalModel.fromJson(item as Map<String, dynamic>))
          .toList();
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException('Gagal mengambil data jadwal.');
    }
  }

  // ══════════════════════════════════════════════════════════════════
  // ANTRIAN ENDPOINTS
  // ══════════════════════════════════════════════════════════════════

  /// GET /antrian/status  →  Status antrian aktif (Mahasiswa)
  static Future<ApiResponse<Map<String, dynamic>>> checkStatus() async {
    try {
      final headers = await _authHeaders;
      final response = await http
          .get(
            Uri.parse('${AppConstants.baseUrl}${AppConstants.antrianEndpoint}/status'),
            headers: headers,
          )
          .timeout(const Duration(seconds: 15));

      final body = _parseResponse(response);

      return ApiResponse(
        status: body['status'] as bool,
        message: body['message'] as String,
        data: body['data'] as Map<String, dynamic>?,
      );
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException('Gagal mengecek status antrian.');
    }
  }

  /// POST /antrian/reset  →  Admin Only
  static Future<ApiResponse<void>> resetAntrian() async {
    try {
      final headers = await _authHeaders;
      final response = await http
          .post(
            Uri.parse('${AppConstants.baseUrl}${AppConstants.antrianEndpoint}/reset'),
            headers: headers,
          )
          .timeout(const Duration(seconds: 15));

      final body = _parseResponse(response);

      return ApiResponse(
        status: body['status'] as bool,
        message: body['message'] as String,
        data: null,
      );
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException('Gagal meriset antrian.');
    }
  }

  /// GET /antrian  →  List<AntrianModel>
  static Future<List<AntrianModel>> getAntrian() async {
    try {
      final headers = await _authHeaders;
      final response = await http
          .get(
            Uri.parse('${AppConstants.baseUrl}${AppConstants.antrianEndpoint}'),
            headers: headers,
          )
          .timeout(const Duration(seconds: 15));

      final body = _parseResponse(response);

      final List<dynamic> rawList = body['data'] as List<dynamic>;
      return rawList
          .map((item) => AntrianModel.fromJson(item as Map<String, dynamic>))
          .toList();
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException('Gagal mengambil data antrian.');
    }
  }

  /// POST /antrian  →  AntrianModel (Ambil nomor antrian)
  static Future<AntrianModel> ambilAntrian({
    required int jadwalId,
    required int layananId,
  }) async {
    try {
      final headers = await _authHeaders;
      final response = await http
          .post(
            Uri.parse('${AppConstants.baseUrl}${AppConstants.antrianEndpoint}'),
            headers: headers,
            body: jsonEncode({'jadwal_id': jadwalId, 'layanan_id': layananId}),
          )
          .timeout(const Duration(seconds: 15));

      final body = _parseResponse(response);
      return AntrianModel.fromJson(body['data'] as Map<String, dynamic>);
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException('Gagal mengambil antrian.');
    }
  }

  /// PUT /antrian/{id}  →  AntrianModel (Update status)
  static Future<AntrianModel> updateAntrian({
    required int id,
    required String status,
    String? nomorMeja,
  }) async {
    try {
      final headers = await _authHeaders;
      final response = await http
          .put(
            Uri.parse(
                '${AppConstants.baseUrl}${AppConstants.antrianEndpoint}/$id'),
            headers: headers,
            body: jsonEncode({
              'status': status,
              if (nomorMeja != null) 'nomor_meja': nomorMeja,
            }),
          )
          .timeout(const Duration(seconds: 15));

      final body = _parseResponse(response);
      return AntrianModel.fromJson(body['data'] as Map<String, dynamic>);
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException('Gagal memperbarui status antrian.');
    }
  }

  /// Batalkan antrian (alias untuk update status ke 'batal')
  static Future<AntrianModel> batalkanAntrian(int id) =>
      updateAntrian(id: id, status: 'batal');
}
