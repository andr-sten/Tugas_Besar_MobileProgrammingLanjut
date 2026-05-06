// lib/screens/mahasiswa/home_mahasiswa.dart

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:q_campus_antrian_mahasiswa/models/antrian_model.dart';
import 'package:q_campus_antrian_mahasiswa/models/layanan_model.dart';
import 'package:q_campus_antrian_mahasiswa/services/api_service.dart';
import 'package:q_campus_antrian_mahasiswa/services/notification_service.dart';
import 'package:q_campus_antrian_mahasiswa/utils/auth_storage.dart';
import 'package:q_campus_antrian_mahasiswa/utils/constants.dart';
import 'package:q_campus_antrian_mahasiswa/widgets/loading_indicator.dart';
import 'package:q_campus_antrian_mahasiswa/widgets/floating_bottom_nav_bar.dart';
import 'booking_antrian.dart';

class HomeMahasiswa extends StatefulWidget {
  const HomeMahasiswa({super.key});

  @override
  State<HomeMahasiswa> createState() => _HomeMahasiswaState();
}

class _HomeMahasiswaState extends State<HomeMahasiswa> {
  int _selectedIndex = 0;
  int _activeTicketIndex = 0;
  List<AntrianModel> _antrianList = [];
  List<LayananModel> _layananList = [];
  bool _isLoading = true;
  String? _errorMessage;
  String _userName = '';
  Timer? _refreshTimer;
  final Map<int, String> _notifiedAntrianTimestamps = {};
  bool _isLiveBadgeVisible = true;

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
      setState(() => _userName = user?['name'] as String? ?? 'Mahasiswa');
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

        // Cek apakah ada antrian yang baru dipanggil atau dipanggil ulang
        for (var antrian in newAntrianList) {
          if (antrian.status == 'dipanggil') {
            String? lastTimestamp = _notifiedAntrianTimestamps[antrian.id];

            // Panggil jika belum pernah dinotifikasi ATAU timestamp update berubah (dipanggil ulang)
            if (lastTimestamp == null || lastTimestamp != antrian.updatedAt) {
              _showCallDialogAndNotification(antrian);
              _notifiedAntrianTimestamps[antrian.id] =
                  (antrian.updatedAt as String?) ?? '';
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
    // Vibrate to grab attention
    HapticFeedback.vibrate();

    // Show Local Notification
    NotificationService.showCallNotification(
      id: antrian.id,
      nomorAntrian: 'A-${antrian.nomor}',
      layanan: antrian.nomorMeja ?? antrian.layanan?.nama ?? '-',
    );

    // Show In-App Pop-up
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

  Future<void> _logout() async {
    await AuthStorage.clear();
    if (mounted) {
      Navigator.pushReplacementNamed(context, '/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppConstants.backgroundColor,
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
                              style: const TextStyle(
                                  fontSize: 24,
                                  color: AppConstants.onSurfaceColor,
                                  fontFamily: 'Plus Jakarta Sans'),
                              children: [
                                const TextSpan(text: 'Selamat datang, '),
                                TextSpan(
                                  text: '$_userName.',
                                  style: const TextStyle(
                                      fontWeight: FontWeight.w800,
                                      color: AppConstants.primaryColor),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Pantau antrianmu dan kelola keperluan kampus dengan lebih efisien hari ini.',
                            style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[600],
                                height: 1.5),
                          ),
                        ],
                      ),
                    ),
                    _buildNotificationIcon(),
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
              SliverPadding(
                padding: const EdgeInsets.all(24),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    if (activeQueues.isNotEmpty) ...[
                      _buildActiveTicketsSlider(activeQueues),
                      const SizedBox(height: 32),
                    ],
                    _buildSectionHeader('Jadwal Layanan Tersedia'),
                    const SizedBox(height: 16),
                    _buildLayananGrid(),
                    const SizedBox(height: 32),
                    _buildSectionHeader('Riwayat Antrian'),
                    const SizedBox(height: 16),
                    if (historyQueues.isEmpty)
                      const EmptyView(
                          message: 'Belum ada riwayat antrian.',
                          icon: Icons.history_rounded)
                    else
                      ...historyQueues
                          .map((a) => _buildHistoryItem(a))
                          .toList(),
                    const SizedBox(height: 120), // Bottom nav space
                  ]),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildLiveBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFFE8F5E9),
        borderRadius: BorderRadius.circular(100),
        border: Border.all(color: Colors.green.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: const BoxDecoration(
              color: Colors.green,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 6),
          const Text(
            'LIVE',
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: Colors.green,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationIcon() {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE8EEE7)),
      ),
      child: Stack(
        children: [
          const Icon(Icons.notifications_none_rounded,
              size: 24, color: AppConstants.onSurfaceColor),
          Positioned(
            right: 0,
            top: 0,
            child: Container(
              width: 8,
              height: 8,
              decoration: const BoxDecoration(
                  color: AppConstants.primaryColor, shape: BoxShape.circle),
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
            height: 320, // Diperbesar dari 280 untuk menghindari overflow
            viewportFraction: 1.0,
            enlargeCenterPage: false,
            enableInfiniteScroll: false,
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
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: const Color(0xFFE8EEE7)),
        boxShadow: [
          BoxShadow(
            color: AppConstants.primaryColor.withOpacity(0.05),
            blurRadius: 30,
            offset: const Offset(0, 10),
          )
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFC9E8BF),
                  borderRadius: BorderRadius.circular(100),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.confirmation_number_rounded,
                        size: 12, color: Color(0xFF4F6A49)),
                    SizedBox(width: 4),
                    Text(
                      'Tiket Aktif',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF4F6A49),
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const Text(
                    'ESTIMASI',
                    style: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                      color: Colors.grey,
                    ),
                  ),
                  Text(
                    '~${antrian.estimasiWaktu ?? 0} Menit',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: AppConstants.primaryColor,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Container(
                width: 90,
                height: 90,
                decoration: BoxDecoration(
                  color: AppConstants.primaryColor,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: AppConstants.primaryColor.withOpacity(0.3),
                      blurRadius: 15,
                      offset: const Offset(0, 8),
                    )
                  ],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'NOMOR',
                      style: TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                        color: Colors.white70,
                        letterSpacing: 1,
                      ),
                    ),
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: Text(
                          'A-${antrian.nomor}',
                          style: const TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                            height: 1.1,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                            child: _buildInfoItem(
                                'Layanan', antrian.layanan?.nama ?? '-')),
                        const SizedBox(width: 6),
                        Expanded(
                            child: _buildInfoItem(
                                'Ruangan',
                                antrian.nomorMeja ??
                                    antrian.layanan?.ruangan ??
                                    '-')),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Expanded(
                            child: _buildStatusItem(
                                'Status', antrian.statusLabel)),
                        const SizedBox(width: 6),
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
                child: ElevatedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.qr_code_2_rounded, size: 20),
                  label: const Text(
                    'Tampilkan QR',
                    style: TextStyle(fontSize: 13),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16)),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                onPressed: () => _batalkanAntrian(antrian),
                icon: const Icon(Icons.close_rounded, size: 20),
                padding: const EdgeInsets.all(12),
                style: IconButton.styleFrom(
                  backgroundColor: const Color(0xFFFFDAD6),
                  foregroundColor: const Color(0xFFBA1A1A),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
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
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: const Color(0xFFF2F5EC),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE8EEE7).withOpacity(0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontSize: 10, color: Colors.grey)),
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

  Widget _buildStatusItem(String label, String value) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: const Color(0xFFF2F5EC),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE8EEE7).withOpacity(0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontSize: 10, color: Colors.grey)),
          const SizedBox(height: 4),
          Row(
            children: [
              Container(
                width: 6,
                height: 6,
                decoration: const BoxDecoration(
                    color: AppConstants.primaryColor, shape: BoxShape.circle),
              ),
              const SizedBox(width: 6),
              Text(
                value,
                style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: AppConstants.primaryColor),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
        TextButton(
          onPressed: () {},
          child: const Row(
            children: [
              Text('Lihat Semua',
                  style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: AppConstants.primaryColor)),
              Icon(Icons.arrow_forward_rounded,
                  size: 14, color: AppConstants.primaryColor),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildLayananGrid() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        childAspectRatio: 0.8,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: _layananList.take(3).length,
      itemBuilder: (context, index) {
        final layanan = _layananList[index];
        return GestureDetector(
          onTap: () => setState(() => _selectedIndex = 1),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: const Color(0xFFE8EEE7)),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: const Color(0xFFC9E8BF),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(Icons.room_service_rounded,
                      color: AppConstants.primaryColor, size: 24),
                ),
                const SizedBox(height: 12),
                Text(
                  layanan.nama,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: AppConstants.onSurfaceColor),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildHistoryItem(AntrianModel antrian) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE8EEE7)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFFF2F5EC),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(Icons.history_rounded, color: Colors.grey[400]),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(antrian.layanan?.nama ?? '-',
                    style: const TextStyle(fontWeight: FontWeight.bold)),
                Text(antrian.statusLabel,
                    style: TextStyle(fontSize: 12, color: Colors.grey[600])),
              ],
            ),
          ),
          const Icon(Icons.chevron_right_rounded, color: Colors.grey),
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
            const CircleAvatar(
              radius: 50,
              backgroundColor: AppConstants.primaryColor,
              child: Icon(Icons.person_rounded, size: 50, color: Colors.white),
            ),
            const SizedBox(height: 16),
            Text(_userName,
                style:
                    const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const Text('Mahasiswa Aktif', style: TextStyle(color: Colors.grey)),
            const SizedBox(height: 40),
            _buildProfileItem(Icons.badge_outlined, 'NIM', '20210042'),
            _buildProfileItem(
                Icons.school_outlined, 'Fakultas', 'Teknologi Informasi'),
            const SizedBox(height: 40),
            ElevatedButton.icon(
              onPressed: _logout,
              icon: const Icon(Icons.logout_rounded),
              label: const Text('Keluar Aplikasi'),
              style: ElevatedButton.styleFrom(
                  backgroundColor: AppConstants.errorColor),
            ),
            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileItem(IconData icon, String label, String value) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE8EEE7)),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppConstants.primaryColor),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: TextStyle(
                        fontSize: 10,
                        color: Colors.grey[500],
                        fontWeight: FontWeight.bold)),
                Text(value,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                    overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
