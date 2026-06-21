// lib/screens/admin/home_admin.dart

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:q_campus_antrian_mahasiswa/models/antrian_model.dart';
import 'package:q_campus_antrian_mahasiswa/models/layanan_model.dart';
import 'package:q_campus_antrian_mahasiswa/services/api_service.dart';
import 'package:q_campus_antrian_mahasiswa/utils/auth_storage.dart';
import 'package:q_campus_antrian_mahasiswa/utils/constants.dart';
import 'package:q_campus_antrian_mahasiswa/utils/theme_notifier.dart';
import 'package:q_campus_antrian_mahasiswa/widgets/loading_indicator.dart';
import 'package:q_campus_antrian_mahasiswa/widgets/floating_bottom_nav_bar.dart';
import 'package:q_campus_antrian_mahasiswa/widgets/stat_card.dart';
import 'package:q_campus_antrian_mahasiswa/widgets/section_header.dart';
import 'package:q_campus_antrian_mahasiswa/widgets/profile_info_card.dart';
import 'kelola_antrian/tabs/antrian_tab.dart';
import 'kelola_antrian/tabs/layanan_tab.dart';
import 'kelola_antrian/tabs/jadwal_tab.dart';

class HomeAdmin extends StatefulWidget {
  const HomeAdmin({super.key});

  @override
  State<HomeAdmin> createState() => _HomeAdminState();
}

class _HomeAdminState extends State<HomeAdmin> {
  int _selectedIndex = 0;
  int _statIndex = 0;
  List<AntrianModel> _antrianList = [];
  bool _isLoading = true;
  String? _errorMessage;
  String _adminName = '';
  String _adminUsername = '';
  String _adminLayanan = '';
  String _nomorMejaAdmin = '1';
  Timer? _refreshTimer;
  bool _isLoggingOut = false;
  final FlutterTts _flutterTts = FlutterTts();

  @override
  void initState() {
    super.initState();
    _initTts();
    _loadData();
    _startAutoRefresh();
  }

  void _initTts() async {
    await _flutterTts.setLanguage("id-ID");
    await _flutterTts.setSpeechRate(0.5); // Kecepatan bicara (0.0 - 1.0)
    await _flutterTts.setPitch(1.0); // Nada bicara (0.5 - 2.0)
  }

  Future<void> _speak(int nomor, String loket) async {
    String text = "Nomor antrian A $nomor, silakan menuju ke Loket $loket";
    await _flutterTts.speak(text);
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    _flutterTts.stop();
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
        _adminUsername = user?['username'] as String? ?? '-';
        // Ambil nama layanan dari data user jika ada
        if (user?['layanan'] != null) {
          _adminLayanan = (user?['layanan'] as Map<String, dynamic>)['nama'] ??
              'Pusat Administrasi';
        } else {
          _adminLayanan = 'Pusat Administrasi';
        }
        _nomorMejaAdmin = user?['nomor_meja'] as String? ?? '1';
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
          // Urutkan berdasarkan ID terbaru agar Aktivitas Terkini menampilkan data terbaru
          _antrianList = list..sort((a, b) => b.id.compareTo(a.id));
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
    if (_isLoggingOut) return;
    _isLoggingOut = true;
    _refreshTimer?.cancel();

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
        _speak(target.nomor, _nomorMejaAdmin);
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
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: Stack(
        children: [
          IndexedStack(
            index: _selectedIndex,
            children: [
              _buildDashboardTab(),
              const LayananTab(),
              const JadwalTab(),
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
                GButton(icon: Icons.room_service_rounded, text: 'Layanan'),
                GButton(icon: Icons.event_note_rounded, text: 'Jadwal'),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: _selectedIndex == 0
          ? Padding(
              padding: const EdgeInsets.only(bottom: 100),
              child: FloatingActionButton(
                onPressed: _panggilAntrian,
                backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                child: Icon(Icons.volume_up_rounded,
                    color: Theme.of(context).colorScheme.onPrimaryContainer, size: 28),
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
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              RichText(
                                text: TextSpan(
                                  style: TextStyle(
                                      fontSize: 24,
                                      color: Theme.of(context).colorScheme.onSurface,
                                      fontFamily: 'Plus Jakarta Sans'),
                                  children: [
                                    const TextSpan(text: 'Halo, '),
                                    TextSpan(
                                      text: '$_adminName.',
                                      style: TextStyle(
                                          fontWeight: FontWeight.w800,
                                          color: Theme.of(context).colorScheme.primary),
                                    ),
                                  ],
                                ),
                              ),
                              Text('Unit Kerja: $_adminLayanan',
                                  style: TextStyle(
                                      color: Theme.of(context).colorScheme.onSurfaceVariant, fontSize: 14)),
                            ],
                          ),
                        ),
                        IconButton(
                          onPressed: () {
                            showModalBottomSheet(
                              context: context,
                              isScrollControlled: true,
                              shape: const RoundedRectangleBorder(
                                borderRadius: BorderRadius.vertical(
                                    top: Radius.circular(32)),
                              ),
                              builder: (context) => _buildAccountTab(),
                            );
                          },
                          icon: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(Icons.account_circle_sharp,
                                color: Theme.of(context).colorScheme.primary),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),
                    CarouselSlider(
                      options: CarouselOptions(
                        height: 160,
                        viewportFraction: 0.9,
                        enlargeCenterPage: true,
                        autoPlay: true,
                        autoPlayCurve: Curves.fastOutSlowIn,
                        autoPlayInterval: const Duration(seconds: 5),
                        onPageChanged: (index, reason) {
                          setState(() => _statIndex = index);
                        },
                      ),
                      items: [
                        StatCard(
                            title: 'Antrian Aktif',
                            value: '$activeCount',
                            icon: Icons.groups_rounded,
                            color: Colors.amber),
                        StatCard(
                            title: 'Selesai Dilayani',
                            value: '$finishedCount',
                            icon: Icons.check_circle_rounded,
                            color: Theme.of(context).colorScheme.primary),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Center(
                      child: AnimatedSmoothIndicator(
                        activeIndex: _statIndex,
                        count: 4,
                        effect: ExpandingDotsEffect(
                          dotHeight: 6,
                          dotWidth: 6,
                          activeDotColor: Theme.of(context).colorScheme.primary,
                          dotColor: const Color(0xFFE8EEE7),
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),
                    SectionHeader(
                      title: 'Aktivitas Terkini',
                      icon: Icons.analytics_rounded,
                      actionLabel: 'Lihat Semua',
                      onActionPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => Scaffold(
                              backgroundColor: Theme.of(context).colorScheme.surface,
                              appBar: AppBar(
                                title: const Text('Semua Antrian',
                                    style:
                                        TextStyle(fontWeight: FontWeight.w800)),
                                backgroundColor: Theme.of(context).colorScheme.surface,
                                foregroundColor: Theme.of(context).colorScheme.onSurface,
                                elevation: 0,
                              ),
                              body: const AntrianTab(),
                            ),
                          ),
                        );
                      },
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
                          .where((a) =>
                              a.status == 'menunggu' || a.status == 'dipanggil')
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
            CircleAvatar(
              radius: 50,
              backgroundColor: Theme.of(context).colorScheme.primary,
              child: Icon(Icons.admin_panel_settings_rounded,
                  size: 50, color: Theme.of(context).colorScheme.onPrimary),
            ),
            const SizedBox(height: 16),
            Text(_adminName,
                style:
                    const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const Text('Administrator Sistem',
                style: TextStyle(color: Colors.grey)),
            const SizedBox(height: 40),
            ProfileInfoCard(
                icon: Icons.alternate_email_rounded,
                label: 'Username',
                value: _adminUsername),
            ProfileInfoCard(
                icon: Icons.account_balance_rounded,
                label: 'Unit Kerja',
                value: _adminLayanan),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.pop(context);
                _showAddAdminDialog();
              },
              icon: const Icon(Icons.person_add_alt_1_rounded),
              label: const Text('Register Admin Baru'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.secondary,
                foregroundColor: Theme.of(context).colorScheme.onSecondary,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              margin: const EdgeInsets.only(bottom: 24),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
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
                    isSelected: ThemeNotifier.instance.themeMode == ThemeMode.light,
                  ),
                  const SizedBox(height: 8),
                  _buildThemeTile(
                    context,
                    mode: ThemeMode.dark,
                    label: 'Mode Gelap',
                    icon: Icons.dark_mode_rounded,
                    isSelected: ThemeNotifier.instance.themeMode == ThemeMode.dark,
                  ),
                  const SizedBox(height: 8),
                  _buildThemeTile(
                    context,
                    mode: ThemeMode.system,
                    label: 'Default Sistem',
                    icon: Icons.settings_brightness_rounded,
                    isSelected: ThemeNotifier.instance.themeMode == ThemeMode.system,
                  ),
                ],
              ),
            ),
            ElevatedButton.icon(
              onPressed: _logout,
              icon: const Icon(Icons.logout_rounded),
              label: const Text('Keluar Panel Admin'),
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

  void _showAddAdminDialog() async {
    final nameController = TextEditingController();
    final usernameController = TextEditingController();
    final passwordController = TextEditingController();
    final passwordConfirmController = TextEditingController();
    final nomorMejaController = TextEditingController(text: '1');

    List<LayananModel> layanans = [];
    int? selectedLayananId;
    bool isLoadingLayanan = true;

    // Fetch layanans first
    try {
      layanans = await ApiService.getLayanan();
      if (layanans.isNotEmpty) {
        selectedLayananId = layanans.first.id;
      }
      isLoadingLayanan = false;
    } catch (e) {
      isLoadingLayanan = false;
    }

    if (!mounted) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Register Admin Baru',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: nameController,
                      decoration: const InputDecoration(
                        labelText: 'Nama Lengkap',
                        prefixIcon: Icon(Icons.person_outline),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: usernameController,
                      decoration: const InputDecoration(
                        labelText: 'Username',
                        prefixIcon: Icon(Icons.alternate_email),
                      ),
                    ),
                    const SizedBox(height: 16),
                    if (isLoadingLayanan)
                      const CircularProgressIndicator()
                    else if (layanans.isEmpty)
                      const Text('Data layanan tidak tersedia',
                          style: TextStyle(color: Colors.red))
                    else
                      DropdownButtonFormField<int>(
                        value: selectedLayananId,
                        decoration: const InputDecoration(
                          labelText: 'Unit Kerja / Layanan',
                          prefixIcon: Icon(Icons.account_balance_rounded),
                        ),
                        items: layanans.map((l) {
                          return DropdownMenuItem(
                            value: l.id,
                            child: Text(l.nama,
                                style: const TextStyle(fontSize: 13)),
                          );
                        }).toList(),
                        onChanged: (val) {
                          setDialogState(() => selectedLayananId = val);
                        },
                      ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: nomorMejaController,
                      decoration: const InputDecoration(
                        labelText: 'Nomor Meja / Loket',
                        prefixIcon: Icon(Icons.table_restaurant_outlined),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: passwordController,
                      obscureText: true,
                      decoration: const InputDecoration(
                        labelText: 'Password',
                        prefixIcon: Icon(Icons.lock_outline),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: passwordConfirmController,
                      obscureText: true,
                      decoration: const InputDecoration(
                        labelText: 'Konfirmasi Password',
                        prefixIcon: Icon(Icons.lock_reset_outlined),
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Batal'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    if (nameController.text.isEmpty ||
                        usernameController.text.isEmpty ||
                        passwordController.text.isEmpty ||
                        selectedLayananId == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Harap isi semua data')),
                      );
                      return;
                    }

                    if (passwordController.text !=
                        passwordConfirmController.text) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Password tidak cocok')),
                      );
                      return;
                    }

                    final navigator = Navigator.of(context);
                    final messenger = ScaffoldMessenger.of(context);

                    try {
                      navigator.pop(); // Close reg dialog

                      showDialog(
                        context: context,
                        barrierDismissible: false,
                        builder: (_) =>
                            const Center(child: CircularProgressIndicator()),
                      );

                      await ApiService.createAdminAccount(
                        name: nameController.text,
                        username: usernameController.text,
                        password: passwordController.text,
                        passwordConfirmation: passwordConfirmController.text,
                        layananId: selectedLayananId!,
                        nomorMeja: nomorMejaController.text,
                      );

                      if (!mounted) return;
                      navigator.pop(); // Close loading

                      messenger.showSnackBar(
                        const SnackBar(
                          content: Text('Akun Admin berhasil didaftarkan'),
                          backgroundColor: Colors.green,
                        ),
                      );
                    } on ApiException catch (e) {
                      if (!mounted) return;
                      navigator.pop(); // Close loading
                      messenger.showSnackBar(
                        SnackBar(
                          content: Text(e.message),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    minimumSize: const Size(120, 45),
                  ),
                  child: const Text('Daftarkan'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _updateStatus(AntrianModel antrian, String newStatus) async {
    try {
      await ApiService.updateAntrian(
        id: antrian.id,
        status: newStatus,
        nomorMeja: _nomorMejaAdmin,
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Nomor A-${antrian.nomor} diperbarui ke $newStatus'),
            backgroundColor: Theme.of(context).colorScheme.primary,
            behavior: SnackBarBehavior.floating,
          ),
        );
        if (newStatus == 'dipanggil') {
          _speak(antrian.nomor, _nomorMejaAdmin);
        }
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

  void _showActionMenu(AntrianModel antrian) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Aksi Antrian A-${antrian.nomor}',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(antrian.user?.name ?? 'Mahasiswa',
                style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant)),
            const SizedBox(height: 24),
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(Icons.volume_up_rounded,
                    color: Theme.of(context).colorScheme.primary),
              ),
              title: const Text('Panggil Antrian',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              subtitle: const Text('Ubah status ke "Dipanggil"'),
              onTap: () {
                Navigator.pop(context);
                _updateStatus(antrian, 'dipanggil');
              },
            ),
            const SizedBox(height: 8),
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child:
                    const Icon(Icons.check_circle_rounded, color: Colors.green),
              ),
              title: const Text('Selesaikan Antrian',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              subtitle: const Text('Ubah status ke "Selesai"'),
              onTap: () {
                Navigator.pop(context);
                _updateStatus(antrian, 'selesai');
              },
            ),
            const SizedBox(height: 8),
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppConstants.errorColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.close_rounded,
                    color: AppConstants.errorColor),
              ),
              title: const Text('Batalkan Antrian',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              subtitle: const Text('Mahasiswa tidak hadir'),
              onTap: () {
                Navigator.pop(context);
                _updateStatus(antrian, 'batal');
              },
            ),
            const SizedBox(height: 24),
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
            color: isSelected ? colorScheme.primary : colorScheme.outlineVariant,
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: isSelected ? colorScheme.onPrimaryContainer : colorScheme.onSurfaceVariant,
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  color: isSelected ? colorScheme.onPrimaryContainer : colorScheme.onSurface,
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

  Widget _buildRecentActivityItem(AntrianModel antrian) {
    return Dismissible(
      key: Key('antrian_${antrian.id}'),
      direction: DismissDirection.endToStart,
      background: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 24),
        decoration: BoxDecoration(
          color: AppConstants.errorColor,
          borderRadius: BorderRadius.circular(20),
        ),
        alignment: Alignment.centerRight,
        child: const Icon(Icons.delete_outline_rounded, color: Colors.white),
      ),
      onDismissed: (direction) {
        setState(() {
          _antrianList.removeWhere((a) => a.id == antrian.id);
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Aktivitas A-${antrian.nomor} dihapus dari daftar'),
            action: SnackBarAction(
              label: 'UNDO',
              onPressed: () {
                setState(() {
                  _antrianList.add(antrian);
                  _antrianList.sort((a, b) => b.id.compareTo(a.id));
                });
              },
            ),
          ),
        );
      },
      child: InkWell(
        onTap: () => _showActionMenu(antrian),
        borderRadius: BorderRadius.circular(20),
        child: Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Theme.of(context).colorScheme.outlineVariant)),
          child: Row(
            children: [
              Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(12)),
                  child: Center(
                      child: FittedBox(
                    child: Padding(
                      padding: const EdgeInsets.all(4.0),
                      child: Text('A-${antrian.nomor}',
                          style: TextStyle(
                              fontWeight: FontWeight.w900,
                              color: Theme.of(context).colorScheme.primary)),
                    ),
                  ))),
              const SizedBox(width: 16),
              Expanded(
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                    Text(antrian.user?.name ?? 'Mahasiswa',
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 14)),
                    Text(antrian.statusLabel,
                        style:
                            TextStyle(fontSize: 12, color: Theme.of(context).colorScheme.onSurfaceVariant)),
                  ])),
              const Icon(Icons.more_vert_rounded, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }
}
