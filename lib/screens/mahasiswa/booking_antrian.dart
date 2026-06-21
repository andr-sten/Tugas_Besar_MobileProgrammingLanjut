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
  List<LayananModel> _filteredLayananList = [];
  List<JadwalModel> _jadwalList = [];
  Timer? _refreshTimer;
  final TextEditingController _searchController = TextEditingController();

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
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    setState(() {
      _filteredLayananList = _layananList
          .where((layanan) => layanan.nama
              .toLowerCase()
              .contains(_searchController.text.toLowerCase()))
          .toList();
    });
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
          _filteredLayananList = list
              .where((layanan) => layanan.nama
                  .toLowerCase()
                  .contains(_searchController.text.toLowerCase()))
              .toList();
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
  Future<void> _fetchJadwal(int layananId, {bool isAutoRefresh = false, VoidCallback? onUpdate}) async {
    if (!isAutoRefresh) {
      setState(() {
        _isLoadingJadwal = true;
        _jadwalList = [];
        _selectedJadwal = null;
      });
      onUpdate?.call();
    }
    try {
      final list = await ApiService.getJadwal(layananId: layananId);
      if (mounted) {
        setState(() {
          _jadwalList = list;
          _isLoadingJadwal = false;
        });
        onUpdate?.call();
      }
    } on ApiException catch (e) {
      if (mounted && !isAutoRefresh) {
        setState(() => _isLoadingJadwal = false);
        onUpdate?.call();
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

  void _showJadwalBottomSheet(LayananModel layanan) {
    setState(() {
      _selectedJadwal = null;
      _jadwalList = [];
    });

    StateSetter? sheetSetter;

    // Trigger fetch and pass a callback to update the sheet when data arrives
    _fetchJadwal(layanan.id, onUpdate: () {
      if (sheetSetter != null) {
        sheetSetter!(() {});
      }
    });

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setSheetState) {
          sheetSetter = setSheetState;

          return Container(
            height: MediaQuery.of(context).size.height * 0.75,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
            ),
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  'Pilih Jadwal',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                Text(
                  layanan.nama,
                  style: TextStyle(fontSize: 14, color: Theme.of(context).colorScheme.onSurfaceVariant),
                ),
                const SizedBox(height: 24),
                Expanded(
                  child: _isLoadingJadwal
                      ? const Center(child: CircularProgressIndicator())
                      : _jadwalList.isEmpty
                          ? const Center(
                              child: Text('Tidak ada jadwal tersedia'),
                            )
                          : ListView.builder(
                              itemCount: _jadwalList.length,
                              itemBuilder: (context, i) {
                                final jadwal = _jadwalList[i];
                                final isSelected = _selectedJadwal?.id == jadwal.id;
                                return Container(
                                  margin: const EdgeInsets.only(bottom: 12),
                                  decoration: BoxDecoration(
                                    color: Theme.of(context).colorScheme.surfaceContainerHighest,
                                    borderRadius: BorderRadius.circular(AppConstants.borderRadiusDefault),
                                    border: Border.all(
                                      color: isSelected ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.outlineVariant,
                                      width: isSelected ? 2 : 1,
                                    ),
                                  ),
                                  child: ListTile(
                                    onTap: () {
                                      setSheetState(() => _selectedJadwal = jadwal);
                                      setState(() => _selectedJadwal = jadwal);
                                    },
                                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                    leading: Container(
                                      padding: const EdgeInsets.all(10),
                                      decoration: BoxDecoration(
                                        color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Icon(Icons.calendar_today_rounded, size: 20, color: Theme.of(context).colorScheme.primary),
                                    ),
                                    title: Text(jadwal.tanggalFormatted, style: const TextStyle(fontWeight: FontWeight.bold)),
                                    subtitle: Text('${jadwal.jamMulaiShort} - ${jadwal.jamSelesaiShort}  •  Kuota: ${jadwal.kuota}'),
                                    trailing: isSelected
                                        ? Icon(Icons.check_circle_rounded, color: Theme.of(context).colorScheme.primary)
                                        : const Icon(Icons.chevron_right_rounded, color: Colors.grey),
                                  ),
                                );
                              },
                            ),
                ),
                if (_selectedJadwal != null) ...[
                  const SizedBox(height: 16),
                  CustomButton(
                    label: 'Konfirmasi Ambil Antrian',
                    onPressed: () {
                      Navigator.pop(context);
                      _konfirmasiBooking();
                    },
                    isLoading: _isBooking,
                  ),
                ],
              ],
            ),
          );
        },
      ),
    ).then((_) {
      // Clear setter when sheet is dismissed
      sheetSetter = null;
    });
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
                  'Antrian Berhasil!',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 24),
                Text('Nomor Antrian Anda', style: TextStyle(fontSize: 14, color: Theme.of(context).colorScheme.onSurfaceVariant)),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${antrian.nomor}',
                    style: TextStyle(
                      fontSize: 64,
                      fontWeight: FontWeight.w900,
                      color: Theme.of(context).colorScheme.primary,
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
                      'Cari Layanan',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surface,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          )
                        ],
                      ),
                      child: TextField(
                        controller: _searchController,
                        decoration: InputDecoration(
                          hintText: 'Masukkan nama layanan...',
                          prefixIcon: Icon(Icons.search_rounded, color: Theme.of(context).colorScheme.primary),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide.none,
                          ),
                          filled: true,
                          fillColor: Theme.of(context).colorScheme.surfaceContainerHighest,
                          contentPadding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),
                    const Text(
                      'Pilih Layanan',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),

                    // ── List card layanan ─────────────────────────
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _filteredLayananList.length,
                      itemBuilder: (_, i) {
                        final layanan = _filteredLayananList[i];
                        final isSelected = _selectedLayanan?.id == layanan.id;
                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              _selectedLayanan = layanan;
                              _selectedJadwal = null;
                            });
                            _showJadwalBottomSheet(layanan);
                          },
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            margin: const EdgeInsets.only(bottom: 20),
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.surface,
                              borderRadius: BorderRadius.circular(24),
                              boxShadow: [
                                BoxShadow(
                                  color: isSelected 
                                      ? Theme.of(context).colorScheme.primary.withOpacity(0.2) 
                                      : Theme.of(context).colorScheme.primary.withOpacity(0.08),
                                  blurRadius: 15,
                                  offset: const Offset(0, 5),
                                )
                              ],
                              border: Border.all(
                                color: isSelected ? Theme.of(context).colorScheme.primary : Colors.transparent,
                                width: 2,
                              ),
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  flex: 5,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
                                    decoration: BoxDecoration(
                                      color: Theme.of(context).colorScheme.secondaryContainer,
                                      borderRadius: BorderRadius.circular(22),
                                    ),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          'LAYANAN',
                                          style: TextStyle(
                                            fontSize: 11,
                                            fontWeight: FontWeight.bold,
                                            color: Theme.of(context).colorScheme.onSecondaryContainer.withOpacity(0.7),
                                            letterSpacing: 1.2,
                                          ),
                                        ),
                                        const SizedBox(height: 6),
                                        Text(
                                          layanan.nama,
                                          style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.w800,
                                            color: Theme.of(context).colorScheme.onSecondaryContainer,
                                          ),
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                Expanded(
                                  flex: 3,
                                  child: Stack(
                                    alignment: Alignment.center,
                                    children: [
                                      Positioned(
                                        right: -10,
                                        child: Container(
                                          width: 100,
                                          height: 100,
                                          decoration: BoxDecoration(
                                            color: Theme.of(context).colorScheme.secondaryContainer.withOpacity(0.15),
                                            shape: BoxShape.circle,
                                          ),
                                        ),
                                      ),
                                      Icon(
                                        Icons.confirmation_number_rounded,
                                        size: 64,
                                        color: Theme.of(context).colorScheme.secondary,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 120), // Bottom nav space
                  ],
                ),
              );

    if (widget.isEmbedded) {
      return Scaffold(backgroundColor: Theme.of(context).colorScheme.surface, body: SafeArea(child: content));
    }

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: const Text('Ambil Antrian', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Theme.of(context).colorScheme.surface,
        foregroundColor: Theme.of(context).colorScheme.onSurface,
        elevation: 0,
      ),
      body: content,
    );
  }
}
