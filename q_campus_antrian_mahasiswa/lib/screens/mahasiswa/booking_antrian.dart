// lib/screens/mahasiswa/booking_antrian.dart

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:q_campus_antrian_mahasiswa/models/layanan_model.dart';
import 'package:q_campus_antrian_mahasiswa/models/jadwal_model.dart';
import 'package:q_campus_antrian_mahasiswa/services/api_service.dart';
import 'package:q_campus_antrian_mahasiswa/utils/constants.dart';
import 'package:q_campus_antrian_mahasiswa/widgets/custom_button.dart';
import 'package:q_campus_antrian_mahasiswa/widgets/loading_indicator.dart';

class BookingAntrian extends StatefulWidget {
  final bool isEmbedded;
  const BookingAntrian({super.key, this.isEmbedded = false});

  @override
  State<BookingAntrian> createState() => _BookingAntrianState();
}

class _BookingAntrianState extends State<BookingAntrian> {
  // ── Data dari server ───────────────────────────────────────────
  List<LayananModel> _layananList = [];
  List<JadwalModel> _jadwalList = [];
  Timer? _refreshTimer;

  // ── State selection ────────────────────────────────────────────
  LayananModel? _selectedLayanan;
  JadwalModel? _selectedJadwal;

  bool _isLoadingLayanan = true;
  bool _isLoadingJadwal = false;
  bool _isBooking = false;
  String? _errorLayanan;

  @override
  void initState() {
    super.initState();
    _fetchLayanan();
    _startAutoRefresh();
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }

  void _startAutoRefresh() {
    _refreshTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
      if (mounted) {
        if (_selectedLayanan != null) {
          _fetchJadwal(_selectedLayanan!.id, isAutoRefresh: true);
        } else {
          _fetchLayanan(isAutoRefresh: true);
        }
      }
    });
  }

  /// GET /layanan — Ambil daftar layanan dari server dan parsing JSON
  Future<void> _fetchLayanan({bool isAutoRefresh = false}) async {
    if (!isAutoRefresh) {
      setState(() {
        _isLoadingLayanan = true;
        _errorLayanan = null;
      });
    }
    try {
      final list = await ApiService.getLayanan();
      if (mounted) {
        setState(() {
          _layananList = list;
          _isLoadingLayanan = false;
        });
      }
    } on ApiException catch (e) {
      if (mounted) {
        setState(() {
          _errorLayanan = e.message;
          _isLoadingLayanan = false;
        });
      }
    }
  }

  /// GET /jadwal?layanan_id=X — Ambil jadwal berdasarkan layanan terpilih
  Future<void> _fetchJadwal(int layananId, {bool isAutoRefresh = false}) async {
    if (!isAutoRefresh) {
      setState(() {
        _isLoadingJadwal = true;
        _jadwalList = [];
        _selectedJadwal = null;
      });
    }
    try {
      final list = await ApiService.getJadwal(layananId: layananId);
      if (mounted) {
        setState(() {
          _jadwalList = list;
          _isLoadingJadwal = false;
        });
      }
    } on ApiException catch (e) {
      if (mounted && !isAutoRefresh) {
        setState(() => _isLoadingJadwal = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.message),
            backgroundColor: AppConstants.errorColor,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  /// POST /antrian — Konfirmasi dan ambil nomor antrian
  Future<void> _konfirmasiBooking() async {
    if (_selectedLayanan == null || _selectedJadwal == null) return;

    setState(() => _isBooking = true);
    try {
      final antrian = await ApiService.ambilAntrian(
        jadwalId: _selectedJadwal!.id,
        layananId: _selectedLayanan!.id,
      );

      if (!mounted) return;

      // Tampilkan dialog sukses dengan nomor antrian
      await showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppConstants.borderRadiusLarge)),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Antrian Berhasil! 🎉',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 24),
                const Text('Nomor Antrian Anda', style: TextStyle(fontSize: 14, color: Colors.grey)),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
                  decoration: BoxDecoration(
                    color: AppConstants.primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${antrian.nomor}',
                    style: const TextStyle(
                      fontSize: 64,
                      fontWeight: FontWeight.w900,
                      color: AppConstants.primaryColor,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  _selectedLayanan!.nama,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                Text(
                  '${_selectedJadwal!.tanggalFormatted}  •  ${_selectedJadwal!.jamMulaiShort}',
                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                ),
                const SizedBox(height: 32),
                CustomButton(
                  label: 'Selesai',
                  onPressed: () {
                    Navigator.pop(context);
                    if (!widget.isEmbedded) Navigator.pop(context);
                  },
                ),
              ],
            ),
          ),
        ),
      );
    } on ApiException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.message),
            backgroundColor: AppConstants.errorColor,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isBooking = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final content = _isLoadingLayanan
        ? const LoadingIndicator(message: 'Memuat daftar layanan...')
        : _errorLayanan != null
            ? ErrorView(message: _errorLayanan!, onRetry: _fetchLayanan)
            : SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Pilih Layanan',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),

                    // ── Grid card layanan ─────────────────────────
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        childAspectRatio: 1.1,
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                      ),
                      itemCount: _layananList.length,
                      itemBuilder: (_, i) {
                        final layanan = _layananList[i];
                        final isSelected = _selectedLayanan?.id == layanan.id;
                        return GestureDetector(
                          onTap: () {
                            setState(() => _selectedLayanan = layanan);
                            _fetchJadwal(layanan.id);
                          },
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            decoration: BoxDecoration(
                              color: isSelected ? AppConstants.primaryColor : Colors.white,
                              borderRadius: BorderRadius.circular(AppConstants.borderRadiusLarge),
                              boxShadow: [
                                if (!isSelected)
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.03),
                                    blurRadius: 10,
                                    offset: const Offset(0, 4),
                                  ),
                              ],
                              border: Border.all(
                                color: isSelected ? AppConstants.primaryColor : const Color(0xFFE8EEE7),
                                width: 2,
                              ),
                            ),
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: isSelected ? Colors.white.withOpacity(0.2) : AppConstants.primaryColor.withOpacity(0.1),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    Icons.room_service_rounded,
                                    size: 20,
                                    color: isSelected ? Colors.white : AppConstants.primaryColor,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  layanan.nama,
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                    color: isSelected ? Colors.white : AppConstants.onSurfaceColor,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  layanan.durasiFormatted,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: isSelected ? Colors.white70 : Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),

                    // ── Daftar Jadwal ─────────────────────────────
                    if (_selectedLayanan != null) ...[
                      const SizedBox(height: 40),
                      Row(
                        children: [
                          const Text(
                            'Pilih Jadwal',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          const Spacer(),
                          Text(
                            _selectedLayanan!.nama,
                            style: const TextStyle(fontSize: 14, color: AppConstants.primaryColor, fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      if (_isLoadingJadwal)
                        const Center(child: Padding(padding: EdgeInsets.all(20), child: CircularProgressIndicator()))
                      else if (_jadwalList.isEmpty)
                        const EmptyView(message: 'Tidak ada jadwal tersedia', icon: Icons.event_busy_rounded)
                      else
                        ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: _jadwalList.length,
                          itemBuilder: (_, i) {
                            final jadwal = _jadwalList[i];
                            final isSelected = _selectedJadwal?.id == jadwal.id;
                            return Container(
                              margin: const EdgeInsets.only(bottom: 12),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(AppConstants.borderRadiusDefault),
                                border: Border.all(
                                  color: isSelected ? AppConstants.primaryColor : const Color(0xFFE8EEE7),
                                  width: isSelected ? 2 : 1,
                                ),
                              ),
                              child: ListTile(
                                onTap: () => setState(() => _selectedJadwal = jadwal),
                                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                leading: Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: AppConstants.primaryColor.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: const Icon(Icons.calendar_today_rounded, size: 20, color: AppConstants.primaryColor),
                                ),
                                title: Text(jadwal.tanggalFormatted, style: const TextStyle(fontWeight: FontWeight.bold)),
                                subtitle: Text('${jadwal.jamMulaiShort} - ${jadwal.jamSelesaiShort}  •  Kuota: ${jadwal.kuota}'),
                                trailing: isSelected
                                    ? const Icon(Icons.check_circle_rounded, color: AppConstants.primaryColor)
                                    : const Icon(Icons.chevron_right_rounded, color: Colors.grey),
                              ),
                            );
                          },
                        ),
                    ],

                    // ── Tombol Konfirmasi ─────────────────────────
                    if (_selectedLayanan != null && _selectedJadwal != null) ...[
                      const SizedBox(height: 40),
                      CustomButton(
                        label: 'Konfirmasi Ambil Antrian',
                        onPressed: _konfirmasiBooking,
                        isLoading: _isBooking,
                      ),
                    ],
                    const SizedBox(height: 120), // Bottom nav space
                  ],
                ),
              );

    if (widget.isEmbedded) {
      return Scaffold(backgroundColor: AppConstants.backgroundColor, body: SafeArea(child: content));
    }

    return Scaffold(
      backgroundColor: AppConstants.backgroundColor,
      appBar: AppBar(
        title: const Text('Ambil Antrian', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: content,
    );
  }
}
