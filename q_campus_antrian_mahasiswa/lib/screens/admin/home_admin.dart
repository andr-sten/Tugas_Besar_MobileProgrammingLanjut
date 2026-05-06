// lib/screens/admin/home_admin.dart

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:q_campus_antrian_mahasiswa/models/antrian_model.dart';
import 'package:q_campus_antrian_mahasiswa/services/api_service.dart';
import 'package:q_campus_antrian_mahasiswa/utils/auth_storage.dart';
import 'package:q_campus_antrian_mahasiswa/utils/constants.dart';
import 'package:q_campus_antrian_mahasiswa/widgets/loading_indicator.dart';
import 'package:q_campus_antrian_mahasiswa/widgets/floating_bottom_nav_bar.dart';
import 'kelola_antrian.dart';

class HomeAdmin extends StatefulWidget {
  const HomeAdmin({super.key});

  @override
  State<HomeAdmin> createState() => _HomeAdminState();
}

class _HomeAdminState extends State<HomeAdmin> {
  int _selectedIndex = 0;
  List<AntrianModel> _antrianList = [];
  bool _isLoading = true;
  String? _errorMessage;
  String _adminName = '';
  String _adminLayanan = '';
  String _nomorMejaAdmin = '1';
  Timer? _refreshTimer;

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
      if (mounted && _selectedIndex == 0) {
        _fetchAntrian(isAutoRefresh: true);
      }
    });
  }

  Future<void> _loadData() async {
    final user = await AuthStorage.getUser();
    if (mounted) {
      setState(() {
        _adminName = user?['name'] as String? ?? 'Admin';
        _adminLayanan = 'Pusat Administrasi';
      });
    }
    await _fetchAntrian();
  }

  Future<void> _fetchAntrian({bool isAutoRefresh = false}) async {
    if (!isAutoRefresh) {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });
    }
    try {
      final list = await ApiService.getAntrian();
      if (mounted) {
        setState(() {
          _antrianList = list;
          _isLoading = false;
        });
      }
    } on ApiException catch (e) {
      if (e.statusCode == 401) {
        _logout();
        return;
      }
      if (mounted && !isAutoRefresh) {
        setState(() {
          _errorMessage = e.message;
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _logout() async {
    await AuthStorage.clear();
    if (mounted) Navigator.pushReplacementNamed(context, '/login');
  }

  Future<void> _panggilAntrian() async {
    final target = _antrianList.firstWhere(
      (a) => a.status == 'dipanggil',
      orElse: () => _antrianList.firstWhere(
        (a) => a.status == 'menunggu',
        orElse: () => AntrianModel(
          id: -1,
          userId: 0,
          layananId: 0,
          jadwalId: 0,
          nomor: 0,
          status: 'none',
        ),
      ),
    );

    if (target.id == -1) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Tidak ada antrian untuk dipanggil')),
      );
      return;
    }

    try {
      await ApiService.updateAntrian(
        id: target.id,
        status: 'dipanggil',
        nomorMeja: _nomorMejaAdmin,
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Memanggil Nomor A-${target.nomor}'),
            backgroundColor: AppConstants.primaryColor,
            behavior: SnackBarBehavior.floating,
          ),
        );
        _fetchAntrian();
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppConstants.backgroundColor,
      body: Stack(
        children: [
          IndexedStack(
            index: _selectedIndex,
            children: [
              _buildDashboardTab(),
              const KelolaAntrian(isEmbedded: true),
              _buildAccountTab(),
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
                if (index == 0) _fetchAntrian();
              },
              tabs: const [
                GButton(icon: Icons.dashboard_rounded, text: 'Dashboard'),
                GButton(
                    icon: Icons.confirmation_number_rounded, text: 'Antrian'),
                GButton(icon: Icons.manage_accounts_rounded, text: 'Akun'),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: _selectedIndex == 0
          ? Padding(
              padding: const EdgeInsets.only(bottom: 100),
              child: FloatingActionButton.extended(
                onPressed: () {},
                backgroundColor: AppConstants.primaryColor,
                icon: const Icon(Icons.volume_up_rounded, color: Colors.white),
                label: const Text('PANGGIL',
                    style: TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            )
          : null,
    );
  }

  Widget _buildDashboardTab() {
    final activeCount = _antrianList
        .where((a) => a.status == 'menunggu' || a.status == 'dipanggil')
        .length;
    final finishedCount =
        _antrianList.where((a) => a.status == 'selesai').length;

    return SafeArea(
      child: RefreshIndicator(
        onRefresh: _fetchAntrian,
        color: AppConstants.primaryColor,
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.all(24),
              sliver: SliverToBoxAdapter(
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
                          const TextSpan(text: 'Halo, '),
                          TextSpan(
                            text: '$_adminName.',
                            style: const TextStyle(
                                fontWeight: FontWeight.w800,
                                color: AppConstants.primaryColor),
                          ),
                        ],
                      ),
                    ),
                    Text('Unit Kerja: $_adminLayanan',
                        style:
                            TextStyle(color: Colors.grey[600], fontSize: 14)),
                    const SizedBox(height: 32),
                    GridView.count(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisCount: 2,
                      mainAxisSpacing: 16,
                      crossAxisSpacing: 16,
                      childAspectRatio: 1.3,
                      children: [
                        _buildStatCard('Aktif', '$activeCount',
                            Icons.groups_rounded, Colors.amber),
                        _buildStatCard(
                            'Selesai',
                            '$finishedCount',
                            Icons.check_circle_rounded,
                            AppConstants.primaryColor),
                        _buildStatCard('Rata Tunggu', '12m',
                            Icons.timer_rounded, Colors.blue),
                        _buildStatCard(
                            'Kepuasan',
                            '98%',
                            Icons.sentiment_very_satisfied_rounded,
                            Colors.purple),
                      ],
                    ),
                    const SizedBox(height: 32),
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.analytics_rounded,
                                color: AppConstants.primaryColor, size: 20),
                            SizedBox(width: 8),
                            Text('Aktivitas Terkini',
                                style: TextStyle(
                                    fontSize: 18, fontWeight: FontWeight.bold)),
                          ],
                        ),
                        Text('Lihat Semua',
                            style: TextStyle(
                                fontSize: 12,
                                color: AppConstants.primaryColor,
                                fontWeight: FontWeight.bold)),
                      ],
                    ),
                    const SizedBox(height: 16),
                    if (_isLoading)
                      const LoadingIndicator()
                    else if (_antrianList.isEmpty)
                      const EmptyView(
                          message: 'Belum ada aktivitas hari ini',
                          icon: Icons.history_rounded)
                    else
                      ..._antrianList
                          .take(5)
                          .map((a) => _buildRecentActivityItem(a))
                          .toList(),
                    const SizedBox(height: 120),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAccountTab() {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            const CircleAvatar(
              radius: 50,
              backgroundColor: AppConstants.primaryColor,
              child: Icon(Icons.admin_panel_settings_rounded,
                  size: 50, color: Colors.white),
            ),
            const SizedBox(height: 16),
            Text(_adminName,
                style:
                    const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const Text('Administrator Sistem',
                style: TextStyle(color: Colors.grey)),
            const SizedBox(height: 40),
            _buildInfoCard(
                Icons.alternate_email_rounded, 'Username', 'admin_utama'),
            _buildInfoCard(
                Icons.account_balance_rounded, 'Unit Kerja', 'Gedung Rektorat'),
            const SizedBox(height: 40),
            ElevatedButton.icon(
              onPressed: _logout,
              icon: const Icon(Icons.logout_rounded),
              label: const Text('Keluar Panel Admin'),
              style: ElevatedButton.styleFrom(
                  backgroundColor: AppConstants.errorColor),
            ),
            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(
      String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFE8EEE7)),
        boxShadow: [
          BoxShadow(
              color: color.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12)),
              child: Icon(icon, color: color, size: 20)),
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(title.toUpperCase(),
                style: TextStyle(
                    fontSize: 10,
                    color: Colors.grey[500],
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5)),
            Text(value,
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.w900)),
          ]),
        ],
      ),
    );
  }

  Widget _buildRecentActivityItem(AntrianModel antrian) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFFE8EEE7))),
      child: Row(
        children: [
          Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                  color: const Color(0xFFF2F5EC),
                  borderRadius: BorderRadius.circular(12)),
              child: Center(
                  child: Text('${antrian.nomor}',
                      style: const TextStyle(
                          fontWeight: FontWeight.w900,
                          color: AppConstants.primaryColor)))),
          const SizedBox(width: 16),
          Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                Text(antrian.user?.name ?? 'Mahasiswa',
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 14)),
                Text(antrian.statusLabel,
                    style: TextStyle(fontSize: 12, color: Colors.grey[600])),
              ])),
          const Icon(Icons.chevron_right_rounded, color: Colors.grey),
        ],
      ),
    );
  }

  Widget _buildInfoCard(IconData icon, String label, String value) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFFE8EEE7))),
      child: Row(children: [
        Icon(icon, color: AppConstants.primaryColor),
        const SizedBox(width: 16),
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(label,
              style: TextStyle(
                  fontSize: 10,
                  color: Colors.grey[500],
                  fontWeight: FontWeight.bold)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        ]),
      ]),
    );
  }
}
