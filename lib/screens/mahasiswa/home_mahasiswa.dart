// lib/screens/mahasiswa/home_mahasiswa.dart

import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:screenshot/screenshot.dart';
import 'package:gal/gal.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:q_campus_antrian_mahasiswa/models/antrian_model.dart';
import 'package:q_campus_antrian_mahasiswa/models/layanan_model.dart';
import 'package:q_campus_antrian_mahasiswa/services/api_service.dart';
import 'package:q_campus_antrian_mahasiswa/services/notification_service.dart';
import 'package:q_campus_antrian_mahasiswa/utils/auth_storage.dart';
import 'package:q_campus_antrian_mahasiswa/utils/constants.dart';
import 'package:q_campus_antrian_mahasiswa/utils/theme_notifier.dart';
import 'package:q_campus_antrian_mahasiswa/widgets/loading_indicator.dart';
import 'package:q_campus_antrian_mahasiswa/widgets/floating_bottom_nav_bar.dart';
import 'package:q_campus_antrian_mahasiswa/widgets/section_header.dart';
import 'package:q_campus_antrian_mahasiswa/widgets/profile_info_card.dart';
import 'package:q_campus_antrian_mahasiswa/widgets/status_badge.dart';
import 'booking_antrian.dart';
import 'scanner_screen.dart';

class HomeMahasiswa extends StatefulWidget {
  const HomeMahasiswa({super.key});

  @override
  State<HomeMahasiswa> createState() => _HomeMahasiswaState();
}

class _HomeMahasiswaState extends State<HomeMahasiswa> {
  int _selectedIndex = 0;
  int _activeTicketIndex = 0;
  int _layananSliderIndex = 0;
  List<AntrianModel> _antrianList = [];
  List<LayananModel> _layananList = [];
  bool _isLoading = true;
  String? _errorMessage;
  String _userName = '';
  String _userUsername = '';
  String _userProdi = '';
  Timer? _refreshTimer;
  final Map<int, String> _notifiedAntrianTimestamps = {};
  bool _isLiveBadgeVisible = true;
  bool _isLoggingOut = false;
  final ScreenshotController _screenshotController = ScreenshotController();

  @override
  void initState() {
    super.initState();
    _loadData();
    _startAutoRefresh();
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }

  void _startAutoRefresh() {
    _refreshTimer = Timer.periodic(const Duration(seconds: 2), (timer) {
      if (mounted) {
        _fetchInitialData(isAutoRefresh: true);
      }
    });
  }

  Future<void> _loadData() async {
    final user = await AuthStorage.getUser();
    if (mounted) {
      setState(() {
        _userName = user?['name'] as String? ?? 'Mahasiswa';
        _userUsername = user?['username'] as String? ?? '-';
        _userProdi = user?['prodi'] as String? ?? '-';
      });
    }
    await _fetchInitialData();
  }

  Future<void> _fetchInitialData({bool isAutoRefresh = false}) async {
    if (!isAutoRefresh) {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });
    }

    try {
      final results = await Future.wait([
        ApiService.getAntrian(),
        ApiService.getLayanan(),
      ]);
      if (mounted) {
        final newAntrianList = results[0] as List<AntrianModel>;

        for (var antrian in newAntrianList) {
          if (antrian.status == 'dipanggil') {
            String? lastTimestamp = _notifiedAntrianTimestamps[antrian.id];
            if (lastTimestamp == null || lastTimestamp != antrian.updatedAt) {
              _showCallDialogAndNotification(antrian);
              _notifiedAntrianTimestamps[antrian.id] = antrian.updatedAt ?? '';
            }
          }
        }

        setState(() {
          _antrianList = newAntrianList;
          _layananList = results[1] as List<LayananModel>;
          _isLoading = false;
        });
      }
    } on ApiException catch (e) {
      if (mounted && !isAutoRefresh) {
        setState(() {
          _errorMessage = e.message;
          _isLoading = false;
        });
      }
    }
  }

  void _showCallDialogAndNotification(AntrianModel antrian) {
    HapticFeedback.vibrate();
    NotificationService.showCallNotification(
      id: antrian.id,
      nomorAntrian: 'A-${antrian.nomor}',
      layanan: antrian.nomorMeja ?? antrian.layanan?.nama ?? '-',
    );

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.campaign_rounded,
                color: AppConstants.primaryColor, size: 30),
            SizedBox(width: 10),
            Text('Panggilan Antrian!'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Nomor antrian Anda sedang dipanggil:'),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppConstants.primaryColor,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                'A-${antrian.nomor}',
                style: const TextStyle(
                  fontSize: 40,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Silakan menuju Loket ${antrian.nomorMeja ?? antrian.layanan?.nama ?? "-"}',
              textAlign: TextAlign.center,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Saya Menuju Kesana'),
          ),
        ],
      ),
    );
  }

  Future<void> _batalkanAntrian(AntrianModel antrian) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Batalkan Antrian?'),
        content: Text(
            'Apakah Anda yakin ingin membatalkan antrian nomor ${antrian.nomor}?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Tidak')),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
                backgroundColor: AppConstants.errorColor),
            child: const Text('Ya, Batalkan',
                style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      await ApiService.batalkanAntrian(antrian.id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Antrian berhasil dibatalkan'),
            backgroundColor: AppConstants.primaryColor,
            behavior: SnackBarBehavior.floating,
          ),
        );
        _fetchInitialData();
      }
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
    }
  }

  Future<void> _deleteAntrian(int id) async {
    try {
      await ApiService.deleteAntrian(id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Riwayat antrian dihapus'),
            backgroundColor: AppConstants.primaryColor,
            behavior: SnackBarBehavior.floating,
          ),
        );
        _fetchInitialData();
      }
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
    }
  }

  Future<void> _logout() async {
    if (_isLoggingOut) return;
    _isLoggingOut = true;
    _refreshTimer?.cancel();
    await AuthStorage.clear();
    if (mounted) {
      Navigator.pushReplacementNamed(context, '/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: Stack(
        children: [
          IndexedStack(
            index: _selectedIndex,
            children: [
              _buildHomeTab(),
              const BookingAntrian(isEmbedded: true),
              _buildProfileTab(),
            ],
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: FloatingBottomNavBar(
              selectedIndex: _selectedIndex,
              onTabChange: (index) {
                setState(() => _selectedIndex = index);
                if (index == 0) _fetchInitialData();
              },
              tabs: const [
                GButton(icon: Icons.home_rounded, text: 'Beranda'),
                GButton(
                    icon: Icons.confirmation_number_rounded, text: 'Layanan'),
                GButton(icon: Icons.person_rounded, text: 'Akun'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHomeTab() {
    final activeQueues = _antrianList
        .where((a) => a.status == 'menunggu' || a.status == 'dipanggil')
        .toList();
    final historyQueues =
        _antrianList.where((a) => !activeQueues.contains(a)).toList();

    return SafeArea(
      child: RefreshIndicator(
        onRefresh: _fetchInitialData,
        color: AppConstants.primaryColor,
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
              sliver: SliverToBoxAdapter(
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          RichText(
                            text: TextSpan(
                              style: TextStyle(
                                  fontSize: 24,
                                  color:
                                      Theme.of(context).colorScheme.onSurface,
                                  fontFamily: 'Plus Jakarta Sans'),
                              children: [
                                const TextSpan(text: 'Selamat datang, '),
                                TextSpan(
                                  text: '$_userName.',
                                  style: TextStyle(
                                      fontWeight: FontWeight.w800,
                                      color: Theme.of(context)
                                          .colorScheme
                                          .primary),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Pantau antrianmu dan kelola keperluan kampus dengan lebih efisien hari ini.',
                            style: TextStyle(
                                fontSize: 14,
                                color: Theme.of(context)
                                    .colorScheme
                                    .onSurfaceVariant,
                                height: 1.5),
                          ),
                        ],
                      ),
                    ),
                    _buildScanButton(),
                  ],
                ),
              ),
            ),
            if (_isLoading)
              const SliverFillRemaining(child: LoadingIndicator())
            else if (_errorMessage != null)
              SliverFillRemaining(
                  child: ErrorView(
                      message: _errorMessage!, onRetry: _fetchInitialData))
            else
              SliverList(
                delegate: SliverChildListDelegate([
                  const SizedBox(height: 24),
                  if (activeQueues.isNotEmpty) ...[
                    _buildActiveTicketsSlider(activeQueues),
                    const SizedBox(height: 32),
                  ],
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: SectionHeader(
                      title: 'Jadwal Layanan Tersedia',
                      actionLabel: 'Lihat Semua',
                      onActionPressed: () {
                        setState(() => _selectedIndex = 1);
                      },
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildLayananSlider(),
                  const SizedBox(height: 32),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: const SectionHeader(title: 'Riwayat Antrian'),
                  ),
                  const SizedBox(height: 16),
                  if (historyQueues.isEmpty)
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 24),
                      child: EmptyView(
                          message: 'Belum ada riwayat antrian.',
                          icon: Icons.history_rounded),
                    )
                  else
                    ...historyQueues
                        .map((a) => Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 24, vertical: 6),
                              child: Dismissible(
                                key: Key('history_${a.id}'),
                                direction: DismissDirection.endToStart,
                                onDismissed: (direction) {
                                  _deleteAntrian(a.id);
                                  setState(() {
                                    _antrianList
                                        .removeWhere((item) => item.id == a.id);
                                  });
                                },
                                background: Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 20),
                                  decoration: BoxDecoration(
                                    color: AppConstants.errorColor,
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: const Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      Icon(Icons.delete_outline_rounded,
                                          color: Colors.white),
                                      SizedBox(width: 8),
                                      Text('Hapus',
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold)),
                                    ],
                                  ),
                                ),
                                child: _buildHistoryItem(a),
                              ),
                            ))
                        .toList(),
                  const SizedBox(height: 120),
                ]),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildScanButton() {
    return InkWell(
      onTap: () async {
        var status = await Permission.camera.status;
        if (!status.isGranted) {
          status = await Permission.camera.request();
        }
        if (status.isGranted) {
          if (!mounted) return;
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const ScannerScreen()),
          );
          if (result != null && result is Map<String, dynamic>) {
            if (result['type'] == 'jadwal') {
              _handleScannedJadwal(result['id']);
            }
          }
        } else {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                  content: Text('Akses kamera diperlukan untuk scan QR')),
            );
          }
        }
      },
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppConstants.primaryColor,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: AppConstants.primaryColor.withOpacity(0.3),
              blurRadius: 10,
              offset: const Offset(0, 4),
            )
          ],
        ),
        child: const Icon(Icons.qr_code_scanner_rounded,
            size: 24, color: Colors.white),
      ),
    );
  }

  void _handleScannedJadwal(int jadwalId) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );
    try {
      final jadwals = await ApiService.getJadwal();
      if (!mounted) return;
      Navigator.pop(context);
      final target = jadwals.firstWhere((j) => j.id == jadwalId,
          orElse: () => throw Exception('Jadwal tidak ditemukan'));
      _showBookingConfirmation(target);
    } catch (e) {
      if (!mounted) return;
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    }
  }

  void _showBookingConfirmation(dynamic jadwal) {
    final messenger = ScaffoldMessenger.of(context);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Theme.of(context).colorScheme.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Text('Konfirmasi Antrian',
            style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onSurface)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Apakah Anda ingin mengambil antrian untuk:',
                style:
                    TextStyle(color: Theme.of(context).colorScheme.onSurface)),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(jadwal.layanan?.nama ?? 'Layanan',
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Theme.of(context).colorScheme.onSurface)),
                  const SizedBox(height: 4),
                  Text('Ruangan: ${jadwal.layanan?.ruangan ?? "-"}',
                      style: TextStyle(
                          fontSize: 14,
                          color:
                              Theme.of(context).colorScheme.onSurfaceVariant)),
                  Text(
                      'Waktu: ${jadwal.tanggalFormatted} (${jadwal.jamMulaiShort})',
                      style: TextStyle(
                          fontSize: 14,
                          color:
                              Theme.of(context).colorScheme.onSurfaceVariant)),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Batal',
                style: TextStyle(color: Theme.of(context).colorScheme.primary)),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              try {
                await ApiService.ambilAntrian(
                  jadwalId: jadwal.id,
                  layananId: jadwal.layananId,
                );
                if (mounted) {
                  messenger.showSnackBar(
                    SnackBar(
                      content: const Text('Antrian berhasil diambil!'),
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                  _fetchInitialData();
                }
              } on ApiException catch (e) {
                if (mounted) {
                  messenger.showSnackBar(
                    SnackBar(
                        content: Text(e.message),
                        backgroundColor: Theme.of(context).colorScheme.error),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.primary,
              foregroundColor: Theme.of(context).colorScheme.onPrimary,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('Ambil Antrian'),
          ),
        ],
      ),
    );
  }

  void _showTicketQrDialog(AntrianModel antrian) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Text('Detail Antrian Saya',
            style: TextStyle(fontWeight: FontWeight.bold)),
        content: SizedBox(
          width: 300, // Fixed width for dialog content
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Screenshot(
                  controller: _screenshotController,
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    width: 300, // Matching width
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surface,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(
                          color: Theme.of(context).colorScheme.outlineVariant),
                    ),
                    child: Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: Colors.grey.shade200),
                          ),
                          child: QrImageView(
                            data:
                                '{"type":"antrian","id":${antrian.id},"nomor":${antrian.nomor}}',
                            version: QrVersions.auto,
                            size: 180.0,
                            eyeStyle: QrEyeStyle(
                                eyeShape: QrEyeShape.square,
                                color: Theme.of(context).colorScheme.primary),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'A-${antrian.nomor}',
                          style: TextStyle(
                              fontWeight: FontWeight.w900,
                              fontSize: 32,
                              color: Theme.of(context).colorScheme.primary,
                              height: 1.0),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          antrian.layanan?.nama ?? 'Layanan',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: Theme.of(context).colorScheme.onSurface),
                        ),
                        Divider(
                            height: 24,
                            color:
                                Theme.of(context).colorScheme.outlineVariant),
                        _buildPopupDetailRow(
                            context,
                            'Ruangan',
                            antrian.nomorMeja ??
                                antrian.layanan?.ruangan ??
                                '-'),
                        _buildPopupDetailRow(
                            context, 'Status', antrian.statusLabel),
                        _buildPopupDetailRow(context, 'Estimasi',
                            '~${antrian.estimasiWaktu ?? 0} Menit'),
                        _buildPopupDetailRow(context, 'Di Depan',
                            '${antrian.antrianDiDepan ?? 0} Orang'),
                        if (antrian.createdAt != null)
                          _buildPopupDetailRow(
                              context, 'Waktu Ambil', antrian.createdAt!),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        actions: [
          ElevatedButton.icon(
            onPressed: () async {
              final status = await Permission.storage.request();
              if (status.isGranted || status.isLimited || Platform.isIOS) {
                try {
                  final image = await _screenshotController.captureFromWidget(
                    Container(
                      padding: const EdgeInsets.all(24),
                      width: 320,
                      color: Colors.white,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text(
                            'SISTEM ANTRIAN KAMPUS',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: Colors.black54,
                              letterSpacing: 1.2,
                            ),
                          ),
                          const SizedBox(height: 16),
                          QrImageView(
                            data:
                                '{"type":"antrian","id":${antrian.id},"nomor":${antrian.nomor}}',
                            version: QrVersions.auto,
                            size: 200.0,
                            eyeStyle: const QrEyeStyle(
                              eyeShape: QrEyeShape.square,
                              color: AppConstants.primaryColor,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'A-${antrian.nomor}',
                            style: const TextStyle(
                              fontWeight: FontWeight.w900,
                              fontSize: 36,
                              color: AppConstants.primaryColor,
                              height: 1.0,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            antrian.layanan?.nama ?? 'Layanan',
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                              color: Colors.black87,
                            ),
                          ),
                          const Divider(height: 24, color: Colors.black12),
                          _buildStaticDetailRow(
                              'Ruangan',
                              antrian.nomorMeja ??
                                  antrian.layanan?.ruangan ??
                                  '-'),
                          _buildStaticDetailRow('Status', antrian.statusLabel),
                          _buildStaticDetailRow('Estimasi',
                              '~${antrian.estimasiWaktu ?? 0} Menit'),
                          _buildStaticDetailRow('Di Depan',
                              '${antrian.antrianDiDepan ?? 0} Orang'),
                          if (antrian.createdAt != null)
                            _buildStaticDetailRow(
                                'Waktu Ambil', antrian.createdAt!),
                        ],
                      ),
                    ),
                  );

                  await Gal.putImageBytes(image, album: 'QCampus');
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('QR disimpan ke Galeri (Album: QCampus)'),
                        backgroundColor: Colors.green,
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  }
                } catch (e) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Gagal menyimpan QR'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                }
              }
            },
            icon: const Icon(Icons.download_rounded, size: 18),
            label: const Text('Unduh QR'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.primary,
              foregroundColor: Theme.of(context).colorScheme.onPrimary,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPopupDetailRow(
      BuildContext context, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                  fontSize: 12)),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 12,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStaticDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: const TextStyle(color: Colors.black54, fontSize: 12)),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                  color: Colors.black87),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActiveTicketsSlider(List<AntrianModel> activeQueues) {
    return Column(
      children: [
        CarouselSlider(
          options: CarouselOptions(
            height: 400,
            viewportFraction: 0.85,
            enlargeCenterPage: true,
            enableInfiniteScroll: activeQueues.length > 1,
            autoPlay: activeQueues.length > 1,
            autoPlayInterval: const Duration(seconds: 4),
            onPageChanged: (index, reason) {
              setState(() => _activeTicketIndex = index);
            },
          ),
          items: activeQueues.map((antrian) {
            return _buildActiveTicketCard(antrian);
          }).toList(),
        ),
        if (activeQueues.length > 1) ...[
          const SizedBox(height: 16),
          AnimatedSmoothIndicator(
            activeIndex: _activeTicketIndex,
            count: activeQueues.length,
            effect: const ExpandingDotsEffect(
              dotHeight: 8,
              dotWidth: 8,
              activeDotColor: AppConstants.primaryColor,
              dotColor: Color(0xFFE8EEE7),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildActiveTicketCard(AntrianModel antrian) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).colorScheme.primary.withOpacity(0.05),
            blurRadius: 30,
            offset: const Offset(0, 10),
          )
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.secondaryContainer,
                  borderRadius: BorderRadius.circular(100),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.confirmation_number_rounded,
                        size: 12,
                        color:
                            Theme.of(context).colorScheme.onSecondaryContainer),
                    const SizedBox(width: 4),
                    Text(
                      'Tiket Aktif',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color:
                            Theme.of(context).colorScheme.onSecondaryContainer,
                      ),
                    ),
                  ],
                ),
              ),
              if ((antrian.status == 'dipanggil' ||
                      antrian.status == 'menunggu') &&
                  _isLiveBadgeVisible) ...[
                const SizedBox(width: 8),
                StatusBadge(status: antrian.status),
              ],
              const Spacer(),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'ESTIMASI',
                    style: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                  Text(
                    '~${antrian.estimasiWaktu ?? 0} Menit',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 140,
                height: 150,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Theme.of(context)
                          .colorScheme
                          .primary
                          .withOpacity(0.15),
                      blurRadius: 15,
                      offset: const Offset(0, 8),
                    )
                  ],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.confirmation_number_rounded,
                      color: Theme.of(context).colorScheme.onPrimaryContainer,
                      size: 28,
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'No. Antrian',
                          style: TextStyle(
                            fontSize: 11,
                            color: Theme.of(context)
                                .colorScheme
                                .onPrimaryContainer
                                .withOpacity(0.7),
                          ),
                        ),
                        FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            'A-${antrian.nomor}',
                            style: TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.w900,
                              color: Theme.of(context)
                                  .colorScheme
                                  .onPrimaryContainer,
                              height: 1.1,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                            child: _buildInfoItem(
                                'Layanan', antrian.layanan?.nama ?? '-')),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                            child: _buildInfoItem(
                                'Ruangan',
                                antrian.nomorMeja ??
                                    antrian.layanan?.ruangan ??
                                    '-')),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                            child: _buildInfoItem('Di Depan',
                                '${antrian.antrianDiDepan ?? 0} Orang')),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _showTicketQrDialog(antrian),
                  icon: const Icon(Icons.qr_code_2_rounded, size: 16),
                  label: const Text(
                    'Tampilkan QR',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    side: BorderSide(
                        color: Theme.of(context)
                            .colorScheme
                            .primary
                            .withOpacity(0.5)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                onPressed: () => _batalkanAntrian(antrian),
                icon: const Icon(Icons.close_rounded, size: 18),
                padding: const EdgeInsets.all(12),
                style: IconButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.errorContainer,
                  foregroundColor: Theme.of(context).colorScheme.error,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoItem(String label, String value) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
            color:
                Theme.of(context).colorScheme.outlineVariant.withOpacity(0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: TextStyle(
                  fontSize: 10,
                  color: Theme.of(context).colorScheme.onSurfaceVariant),
              maxLines: 1,
              overflow: TextOverflow.ellipsis),
          const SizedBox(height: 2),
          Text(
            value,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildLayananSlider() {
    if (_layananList.isEmpty) {
      return const SizedBox.shrink();
    }
    return Column(
      children: [
        SizedBox(
          height: 120,
          child: CarouselSlider(
            options: CarouselOptions(
              height: 120,
              viewportFraction: 0.85,
              enlargeCenterPage: true,
              enableInfiniteScroll: _layananList.length > 1,
              autoPlay: _layananList.length > 1,
              autoPlayInterval: const Duration(seconds: 3),
              onPageChanged: (index, reason) {
                setState(() => _layananSliderIndex = index);
              },
            ),
            items: _layananList.map((layanan) {
              return GestureDetector(
                onTap: () => setState(() => _selectedIndex = 1),
                child: Container(
                  margin:
                      const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: Theme.of(context)
                            .colorScheme
                            .primary
                            .withOpacity(0.08),
                        blurRadius: 15,
                        offset: const Offset(0, 5),
                      )
                    ],
                    border: Border.all(
                      color: Theme.of(context).colorScheme.outlineVariant,
                      width: 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        flex: 5,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 16),
                          decoration: BoxDecoration(
                            color: Theme.of(context)
                                .colorScheme
                                .secondaryContainer,
                            borderRadius: BorderRadius.circular(22),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'LAYANAN',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onSecondaryContainer
                                      .withOpacity(0.7),
                                  letterSpacing: 1,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                layanan.nama,
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w800,
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onSecondaryContainer,
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
                                width: 80,
                                height: 80,
                                decoration: BoxDecoration(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .secondaryContainer
                                      .withOpacity(0.15),
                                  shape: BoxShape.circle,
                                ),
                              ),
                            ),
                            Icon(
                              Icons.confirmation_number_rounded,
                              size: 56,
                              color: Theme.of(context).colorScheme.secondary,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ),
        if (_layananList.length > 1) ...[
          const SizedBox(height: 12),
          AnimatedSmoothIndicator(
            activeIndex: _layananSliderIndex,
            count: _layananList.length,
            effect: const ExpandingDotsEffect(
              dotHeight: 6,
              dotWidth: 6,
              activeDotColor: AppConstants.primaryColor,
              dotColor: Color(0xFFE8EEE7),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildHistoryItem(AntrianModel antrian) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(Icons.history_rounded,
                color: Theme.of(context).colorScheme.onPrimaryContainer),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(antrian.layanan?.nama ?? '-',
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.onSurface)),
                Text(antrian.statusLabel,
                    style: TextStyle(
                        fontSize: 12,
                        color: Theme.of(context).colorScheme.onSurfaceVariant)),
              ],
            ),
          ),
          Icon(Icons.chevron_right_rounded,
              color: Theme.of(context).colorScheme.onSurfaceVariant),
        ],
      ),
    );
  }

  Widget _buildProfileTab() {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            CircleAvatar(
              radius: 50,
              backgroundColor: Theme.of(context).colorScheme.primary,
              child: Icon(Icons.person_rounded,
                  size: 50, color: Theme.of(context).colorScheme.onPrimary),
            ),
            const SizedBox(height: 16),
            Text(_userName,
                style:
                    const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const Text('Mahasiswa Aktif', style: TextStyle(color: Colors.grey)),
            const SizedBox(height: 40),
            ProfileInfoCard(
                icon: Icons.badge_outlined, label: 'NIM', value: _userUsername),
            ProfileInfoCard(
                icon: Icons.school_outlined,
                label: 'Program Studi',
                value: _userProdi),
            const SizedBox(height: 40),
            Container(
              margin: const EdgeInsets.only(bottom: 24),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                    color: Theme.of(context).colorScheme.outlineVariant),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Pengaturan Tema',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildThemeTile(
                    context,
                    mode: ThemeMode.light,
                    label: 'Mode Terang',
                    icon: Icons.light_mode_rounded,
                    isSelected:
                        ThemeNotifier.instance.themeMode == ThemeMode.light,
                  ),
                  const SizedBox(height: 8),
                  _buildThemeTile(
                    context,
                    mode: ThemeMode.dark,
                    label: 'Mode Gelap',
                    icon: Icons.dark_mode_rounded,
                    isSelected:
                        ThemeNotifier.instance.themeMode == ThemeMode.dark,
                  ),
                  const SizedBox(height: 8),
                  _buildThemeTile(
                    context,
                    mode: ThemeMode.system,
                    label: 'Default Sistem',
                    icon: Icons.settings_brightness_rounded,
                    isSelected:
                        ThemeNotifier.instance.themeMode == ThemeMode.system,
                  ),
                ],
              ),
            ),
            ElevatedButton.icon(
              onPressed: _logout,
              icon: const Icon(Icons.logout_rounded),
              label: const Text('Keluar Aplikasi'),
              style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.error,
                  foregroundColor: Theme.of(context).colorScheme.onError),
            ),
            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }

  Widget _buildThemeTile(
    BuildContext context, {
    required ThemeMode mode,
    required String label,
    required IconData icon,
    required bool isSelected,
  }) {
    final colorScheme = Theme.of(context).colorScheme;

    return InkWell(
      onTap: () {
        ThemeNotifier.instance.updateThemeMode(mode);
        (context as Element).markNeedsBuild();
      },
      borderRadius: BorderRadius.circular(16),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected
              ? colorScheme.primaryContainer
              : colorScheme.surfaceContainerHighest.withOpacity(0.3),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color:
                isSelected ? colorScheme.primary : colorScheme.outlineVariant,
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: isSelected
                  ? colorScheme.onPrimaryContainer
                  : colorScheme.onSurfaceVariant,
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  color: isSelected
                      ? colorScheme.onPrimaryContainer
                      : colorScheme.onSurface,
                ),
              ),
            ),
            if (isSelected)
              Icon(
                Icons.check_circle_rounded,
                color: colorScheme.onPrimaryContainer,
                size: 18,
              ),
          ],
        ),
      ),
    );
  }
}
