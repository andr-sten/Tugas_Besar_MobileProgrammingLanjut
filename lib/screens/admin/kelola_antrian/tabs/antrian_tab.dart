// lib/screens/admin/kelola_antrian/tabs/antrian_tab.dart

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:q_campus_antrian_mahasiswa/models/antrian_model.dart';
import 'package:q_campus_antrian_mahasiswa/services/api_service.dart';
import 'package:q_campus_antrian_mahasiswa/utils/constants.dart';
import 'package:q_campus_antrian_mahasiswa/widgets/loading_indicator.dart';

class AntrianTab extends StatefulWidget {
  const AntrianTab({super.key});

  @override
  State<AntrianTab> createState() => _AntrianTabState();
}

class _AntrianTabState extends State<AntrianTab> {
  List<AntrianModel> _antrianList = [];
  bool _isLoading = true;
  String? _errorMessage;
  Timer? _refreshTimer;

  @override
  void initState() {
    super.initState();
    _fetchAntrian();
    _startAutoRefresh();
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }

  void _startAutoRefresh() {
    _refreshTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
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
                'Status Antrian A-${antrian.nomor} diperbarui menjadi $newStatus'),
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
            'Tindakan ini akan menghapus seluruh data antrian hari ini.'),
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
    if (_isLoading) return const LoadingIndicator();
    if (_errorMessage != null) {
      return ErrorView(message: _errorMessage!, onRetry: _fetchAntrian);
    }
    if (_antrianList.isEmpty) {
      return const EmptyView(
          message: 'Semua mahasiswa telah terlayani.',
          icon: Icons.done_all_rounded);
    }

    return RefreshIndicator(
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
  }

  Widget _buildAdminActionCard(AntrianModel antrian) {
    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: Theme.of(context).colorScheme.outlineVariant),
      ),
      color: Theme.of(context).colorScheme.surface,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Center(
                    child: Text(
                      'A-${antrian.nomor}',
                      style: TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 18,
                        color: Theme.of(context).colorScheme.onPrimaryContainer,
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
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${antrian.layanan?.nama ?? "-"} • ${antrian.jadwal?.jamMulaiShort ?? "-"}',
                        style: TextStyle(
                          fontSize: 13,
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                _buildStatusBadge(antrian.status),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (antrian.isMenunggu)
                  _buildIconButton(
                    icon: Icons.volume_up_rounded,
                    color: Theme.of(context).colorScheme.primary,
                    tooltip: 'Panggil',
                    onPressed: () => _updateStatus(antrian, 'dipanggil'),
                  ),
                if (antrian.isDipanggil) ...[
                  _buildIconButton(
                    icon: Icons.volume_up_rounded,
                    color: Theme.of(context).colorScheme.primary,
                    tooltip: 'Panggil Ulang',
                    isOutlined: true,
                    onPressed: () => _updateStatus(antrian, 'dipanggil'),
                  ),
                  const SizedBox(width: 8),
                  _buildIconButton(
                    icon: Icons.check_circle_rounded,
                    color: Colors.green,
                    tooltip: 'Selesai',
                    onPressed: () => _updateStatus(antrian, 'selesai'),
                  ),
                ],
                const SizedBox(width: 8),
                _buildIconButton(
                  icon: Icons.close_rounded,
                  color: Theme.of(context).colorScheme.error,
                  tooltip: 'Batal',
                  isOutlined: true,
                  onPressed: () => _updateStatus(antrian, 'batal'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    Color color =
        status == 'menunggu' ? Colors.orange : Theme.of(context).colorScheme.primary;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(100),
      ),
      child: Text(
        status.toUpperCase(),
        style: TextStyle(
            color: color, fontWeight: FontWeight.bold, fontSize: 10),
      ),
    );
  }

  Widget _buildIconButton({
    required IconData icon,
    required Color color,
    required VoidCallback onPressed,
    required String tooltip,
    bool isOutlined = false,
  }) {
    if (isOutlined) {
      return Tooltip(
        message: tooltip,
        child: OutlinedButton(
          onPressed: onPressed,
          style: OutlinedButton.styleFrom(
            foregroundColor: color,
            side: BorderSide(color: color, width: 2),
            shape: const CircleBorder(),
            padding: const EdgeInsets.all(12),
            minimumSize: Size.zero,
          ),
          child: Icon(icon, size: 20),
        ),
      );
    }
    return Tooltip(
      message: tooltip,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          shape: const CircleBorder(),
          padding: const EdgeInsets.all(12),
          elevation: 0,
          minimumSize: Size.zero,
        ),
        child: Icon(icon, size: 20),
      ),
    );
  }
}
