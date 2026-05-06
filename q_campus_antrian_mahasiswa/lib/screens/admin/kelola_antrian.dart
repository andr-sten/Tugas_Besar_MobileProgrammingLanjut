// lib/screens/admin/kelola_antrian.dart

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:q_campus_antrian_mahasiswa/models/antrian_model.dart';
import 'package:q_campus_antrian_mahasiswa/services/api_service.dart';
import 'package:q_campus_antrian_mahasiswa/utils/auth_storage.dart';
import 'package:q_campus_antrian_mahasiswa/utils/constants.dart';
import 'package:q_campus_antrian_mahasiswa/widgets/loading_indicator.dart';

class KelolaAntrian extends StatefulWidget {
  final int? antrianId;
  final bool isEmbedded;

  const KelolaAntrian({super.key, this.antrianId, this.isEmbedded = false});

  @override
  State<KelolaAntrian> createState() => _KelolaAntrianState();
}

class _KelolaAntrianState extends State<KelolaAntrian> {
  List<AntrianModel> _antrianList = [];
  bool _isLoading = true;
  String? _errorMessage;
  Timer? _refreshTimer;
  String? _nomorMejaAdmin;

  @override
  void initState() {
    super.initState();
    _loadAdminData();
    _fetchAntrian();
    _startAutoRefresh();
  }

  Future<void> _loadAdminData() async {
    final user = await AuthStorage.getUser();
    if (mounted) {
      setState(() {
        _nomorMejaAdmin = user?['nomor_meja'] as String?;
      });
    }
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }

  void _startAutoRefresh() {
    _refreshTimer = Timer.periodic(const Duration(seconds: 2), (timer) {
      if (mounted) {
        _fetchAntrian(isAutoRefresh: true);
      }
    });
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
          _antrianList = list
              .where((a) => a.status == 'menunggu' || a.status == 'dipanggil')
              .toList();
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

  Future<void> _updateStatus(AntrianModel antrian, String newStatus) async {
    try {
      await ApiService.updateAntrian(id: antrian.id, status: newStatus);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                'Status Antrian #${antrian.nomor} diperbarui menjadi $newStatus'),
            backgroundColor: AppConstants.primaryColor,
            behavior: SnackBarBehavior.floating,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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

  Future<void> _handleReset() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Reset Seluruh Antrian?'),
        content: const Text(
            'Tindakan ini akan menghapus seluruh data antrian hari ini. Data yang sudah dihapus tidak dapat dikembalikan.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Batal')),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
                backgroundColor: AppConstants.errorColor),
            child: const Text('Ya, Reset Semua',
                style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      await ApiService.resetAntrian();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Antrian berhasil diberihkan'),
              backgroundColor: AppConstants.primaryColor),
        );
        _fetchAntrian();
      }
    } on ApiException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(e.message),
              backgroundColor: AppConstants.errorColor),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final content = _isLoading
        ? const LoadingIndicator(message: 'Sinkronisasi data live...')
        : _errorMessage != null
            ? ErrorView(message: _errorMessage!, onRetry: _fetchAntrian)
            : _antrianList.isEmpty
                ? const EmptyView(
                    message: 'Semua mahasiswa telah terlayani.\nKerja bagus!',
                    icon: Icons.done_all_rounded)
                : RefreshIndicator(
                    onRefresh: _fetchAntrian,
                    color: AppConstants.primaryColor,
                    child: ListView.builder(
                      padding: const EdgeInsets.all(20),
                      itemCount: _antrianList.length,
                      itemBuilder: (context, index) {
                        final antrian = _antrianList[index];
                        return _buildAdminActionCard(antrian);
                      },
                    ),
                  );

    if (widget.isEmbedded) {
      return Scaffold(
        backgroundColor: AppConstants.backgroundColor,
        appBar: AppBar(
          title: const Text('Antrian Live',
              style: TextStyle(fontWeight: FontWeight.w800)),
          backgroundColor: Colors.white,
          elevation: 0,
          actions: [
            IconButton(
                icon: const Icon(Icons.refresh_rounded),
                onPressed: _fetchAntrian),
            IconButton(
                icon: const Icon(Icons.delete_sweep_rounded,
                    color: AppConstants.errorColor),
                onPressed: _handleReset),
            const SizedBox(width: 8),
          ],
        ),
        body: content,
      );
    }

    return Scaffold(
      backgroundColor: AppConstants.backgroundColor,
      appBar: AppBar(
        title: const Text('Antrian Live',
            style: TextStyle(fontWeight: FontWeight.w800)),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded,
                color: AppConstants.primaryColor),
            onPressed: _fetchAntrian,
          ),
          IconButton(
            icon: const Icon(Icons.delete_sweep_rounded,
                color: AppConstants.errorColor),
            onPressed: _handleReset,
            tooltip: 'Reset Antrian',
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: content,
    );
  }

  Widget _buildAdminActionCard(AntrianModel antrian) {
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: const Color(0xFFE8EEE7)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                Row(
                  children: [
                    Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        color: AppConstants.primaryColor,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: AppConstants.primaryColor.withOpacity(0.3),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Center(
                        child: Text(
                          '${antrian.nomor}',
                          style: const TextStyle(
                            fontWeight: FontWeight.w900,
                            fontSize: 24,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            antrian.user?.name ?? 'Mahasiswa',
                            style: const TextStyle(
                                fontWeight: FontWeight.w800,
                                fontSize: 18,
                                color: AppConstants.onSurfaceColor),
                          ),
                          Text(
                            'NIM: ${antrian.user?.username ?? "-"}',
                            style: TextStyle(
                                color: Colors.grey[500],
                                fontSize: 13,
                                fontWeight: FontWeight.w500),
                          ),
                        ],
                      ),
                    ),
                    _buildStatusBadge(antrian.status),
                  ],
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 20),
                  child: Divider(color: Color(0xFFE8EEE7)),
                ),
                Row(
                  children: [
                    _buildInfoTile(Icons.room_service_rounded,
                        antrian.layanan?.nama ?? 'Layanan'),
                    const SizedBox(width: 12),
                    _buildInfoTile(Icons.access_time_rounded,
                        antrian.jadwal?.jamMulaiShort ?? '-'),
                  ],
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: const BoxDecoration(
              color: Color(0xFFF7FAF2),
              borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(32),
                  bottomRight: Radius.circular(32)),
            ),
            child: Row(
              children: [
                if (antrian.isMenunggu)
                  Expanded(
                    child: _buildButton(
                      label: 'PANGGIL',
                      icon: Icons.volume_up_rounded,
                      color: AppConstants.primaryColor,
                      onPressed: () => _updateStatus(antrian, 'dipanggil'),
                    ),
                  ),
                if (antrian.isDipanggil) ...[
                  _buildButton(
                    label: 'ULANG',
                    icon: Icons.volume_up_rounded,
                    color: AppConstants.primaryColor,
                    isOutlined: true,
                    onPressed: () => _updateStatus(antrian, 'dipanggil'),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildButton(
                      label: 'SELESAI',
                      icon: Icons.check_circle_rounded,
                      color: Colors.green,
                      onPressed: () => _updateStatus(antrian, 'selesai'),
                    ),
                  ),
                ],
                const SizedBox(width: 12),
                _buildButton(
                  label: 'BATAL',
                  icon: Icons.close_rounded,
                  color: AppConstants.errorColor,
                  isOutlined: true,
                  onPressed: () => _updateStatus(antrian, 'batal'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    Color color =
        status == 'menunggu' ? Colors.orange : AppConstants.primaryColor;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(100),
      ),
      child: Text(
        status.toUpperCase(),
        style: TextStyle(
            color: color,
            fontWeight: FontWeight.w900,
            fontSize: 10,
            letterSpacing: 0.5),
      ),
    );
  }

  Widget _buildInfoTile(IconData icon, String text) {
    return Expanded(
      child: Row(
        children: [
          Icon(icon, size: 16, color: Colors.grey[400]),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[700]),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildButton({
    required String label,
    required IconData icon,
    required Color color,
    required VoidCallback onPressed,
    bool isOutlined = false,
  }) {
    if (isOutlined) {
      return OutlinedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, size: 18),
        label: Text(label),
        style: OutlinedButton.styleFrom(
          foregroundColor: color,
          side: BorderSide(color: color, width: 2),
          minimumSize: const Size(0, 52),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          textStyle: const TextStyle(
              fontWeight: FontWeight.w900, fontSize: 12, letterSpacing: 1),
        ),
      );
    }
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 18),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        minimumSize: const Size(0, 52),
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        textStyle: const TextStyle(
            fontWeight: FontWeight.w900, fontSize: 12, letterSpacing: 1),
      ),
    );
  }
}
