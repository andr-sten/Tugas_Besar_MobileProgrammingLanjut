// lib/screens/admin/kelola_antrian/tabs/jadwal_tab.dart

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:screenshot/screenshot.dart';
import 'package:path_provider/path_provider.dart';
import 'package:gal/gal.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:q_campus_antrian_mahasiswa/models/jadwal_model.dart';
import 'package:q_campus_antrian_mahasiswa/models/layanan_model.dart';
import 'package:q_campus_antrian_mahasiswa/services/api_service.dart';
import 'package:q_campus_antrian_mahasiswa/utils/constants.dart';
import 'package:q_campus_antrian_mahasiswa/widgets/loading_indicator.dart';

class JadwalTab extends StatefulWidget {
  const JadwalTab({super.key});

  @override
  State<JadwalTab> createState() => _JadwalTabState();
}

class _JadwalTabState extends State<JadwalTab> {
  List<JadwalModel> _jadwalList = [];
  List<LayananModel> _layananList = [];
  bool _isLoading = true;
  String? _errorMessage;
  final ScreenshotController _screenshotController = ScreenshotController();

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      final results = await Future.wait([
        ApiService.getJadwal(),
        ApiService.getLayanan(),
      ]);
      if (mounted) {
        setState(() {
          _jadwalList = results[0] as List<JadwalModel>;
          _layananList = results[1] as List<LayananModel>;
          _isLoading = false;
        });
      }
    } on ApiException catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.message;
          _isLoading = false;
        });
      }
    }
  }

  void _showQrDialog(JadwalModel jadwal) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Text('QR Antrian: ${jadwal.layanan?.nama ?? "Layanan"}'),
        content: SizedBox(
          width: 320,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
                  ),
                  child: Column(
                    children: [
                      Text(
                        'SISTEM ANTRIAN KAMPUS',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                          letterSpacing: 1.2,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.grey.shade200),
                        ),
                        child: QrImageView(
                          data: '{"type":"jadwal","id":${jadwal.id}}',
                          version: QrVersions.auto,
                          size: 200.0,
                          eyeStyle: QrEyeStyle(
                            eyeShape: QrEyeShape.square,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        jadwal.layanan?.nama ?? 'Layanan',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontWeight: FontWeight.w900,
                          fontSize: 18,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.surfaceContainerHighest,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: Theme.of(context).colorScheme.outlineVariant.withOpacity(0.5)),
                        ),
                        child: Column(
                          children: [
                            Text(
                              jadwal.tanggalFormatted,
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Theme.of(context).colorScheme.onSurface),
                            ),
                            Text(
                              'Waktu: ${jadwal.jamMulaiShort} - ${jadwal.jamSelesaiShort}',
                              style: TextStyle(fontSize: 11, color: Theme.of(context).colorScheme.onSurfaceVariant),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'SCAN UNTUK AMBIL ANTRIAN',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        actions: [
          ElevatedButton(
            onPressed: () async {
              final status = await Permission.storage.request(); 
              if (status.isGranted || status.isLimited || Platform.isIOS) {
                 try {
                   final image = await _screenshotController.captureFromWidget(
                     Container(
                       width: 320,
                       padding: const EdgeInsets.all(24),
                       decoration: BoxDecoration(
                         color: Colors.white,
                         borderRadius: BorderRadius.circular(16),
                       ),
                       child: Column(
                         mainAxisSize: MainAxisSize.min,
                         children: [
                           const Text(
                             'SISTEM ANTRIAN KAMPUS',
                             style: TextStyle(
                               fontSize: 10,
                               fontWeight: FontWeight.bold,
                               color: Colors.black54, // Force dark color
                               letterSpacing: 1.2,
                             ),
                           ),
                           const SizedBox(height: 16),
                           QrImageView(
                              data: '{"type":"jadwal","id":${jadwal.id}}',
                              version: QrVersions.auto,
                              size: 220.0,
                              eyeStyle: const QrEyeStyle(
                                eyeShape: QrEyeShape.square,
                                color: AppConstants.primaryColor,
                              ),
                            ),
                            const SizedBox(height: 20),
                            Text(
                              jadwal.layanan?.nama ?? 'Layanan',
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontWeight: FontWeight.w900,
                                fontSize: 20,
                                color: AppConstants.secondaryColor, // Secondary is already dark
                              ),
                            ),
                            const SizedBox(height: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF2F5EC),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Column(
                                children: [
                                  Text(
                                    jadwal.tanggalFormatted,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold, 
                                      fontSize: 13,
                                      color: Colors.black87, // Force dark color
                                    ),
                                  ),
                                  Text(
                                    'Waktu: ${jadwal.jamMulaiShort} - ${jadwal.jamSelesaiShort}',
                                    style: const TextStyle(
                                      fontSize: 12, 
                                      color: Colors.black54, // Force dark color
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 24),
                            const Text(
                              'SCAN UNTUK AMBIL ANTRIAN',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w800,
                                color: AppConstants.primaryColor,
                              ),
                            ),
                         ],
                       ),
                     )
                   );
                   
                   await Gal.putImageBytes(image, album: 'QCampus_Jadwal');
                   
                   if (mounted) {
                     ScaffoldMessenger.of(context).showSnackBar(
                       const SnackBar(
                         content: Text('QR berhasil diunduh ke Galeri'),
                         backgroundColor: Colors.green,
                         behavior: SnackBarBehavior.floating,
                       ),
                     );
                   }
                 } catch (e) {
                   if (mounted) {
                     ScaffoldMessenger.of(context).showSnackBar(
                       const SnackBar(content: Text('Gagal mengunduh QR')),
                     );
                   }
                 }
              }
            },
            child: const Text('Unduh QR'),
          ),
        ],
      ),
    );
  }

  void _showForm({JadwalModel? jadwal}) {
    int? selectedLayananId = jadwal?.layananId ?? (_layananList.isNotEmpty ? _layananList.first.id : null);
    final dateController = TextEditingController(text: jadwal?.tanggal ?? DateTime.now().toString().split(' ').first);
    final startController = TextEditingController(text: jadwal?.jamMulaiShort ?? '08:00');
    final endController = TextEditingController(text: jadwal?.jamSelesaiShort ?? '12:00');
    final quotaController = TextEditingController(text: jadwal?.kuota.toString() ?? '20');

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: 24,
            right: 24,
            top: 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                jadwal == null ? 'Tambah Jadwal' : 'Edit Jadwal',
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 24),
              DropdownButtonFormField<int>(
                value: selectedLayananId,
                decoration: const InputDecoration(
                  labelText: 'Layanan',
                  border: OutlineInputBorder(),
                ),
                items: _layananList.map((l) => DropdownMenuItem(
                  value: l.id,
                  child: Text(l.nama),
                )).toList(),
                onChanged: (val) => setModalState(() => selectedLayananId = val),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: dateController,
                decoration: const InputDecoration(
                  labelText: 'Tanggal (YYYY-MM-DD)',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.calendar_today_rounded),
                ),
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime.now(),
                    lastDate: DateTime.now().add(const Duration(days: 30)),
                  );
                  if (picked != null) {
                    dateController.text = picked.toString().split(' ').first;
                  }
                },
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: startController,
                      decoration: const InputDecoration(
                        labelText: 'Jam Mulai',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextField(
                      controller: endController,
                      decoration: const InputDecoration(
                        labelText: 'Jam Selesai',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              TextField(
                controller: quotaController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Kuota Antrian',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  onPressed: () async {
                    if (selectedLayananId == null) return;
                    
                    Navigator.pop(context);
                    try {
                      if (jadwal == null) {
                        await ApiService.createJadwal(
                          layananId: selectedLayananId!,
                          tanggal: dateController.text,
                          jamMulai: startController.text,
                          jamSelesai: endController.text,
                          kuota: int.parse(quotaController.text),
                        );
                      } else {
                        await ApiService.updateJadwal(
                          id: jadwal.id,
                          layananId: selectedLayananId!,
                          tanggal: dateController.text,
                          jamMulai: startController.text,
                          jamSelesai: endController.text,
                          kuota: int.parse(quotaController.text),
                        );
                      }
                      _fetchData();
                    } on ApiException catch (e) {
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(e.message), backgroundColor: AppConstants.errorColor),
                        );
                      }
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppConstants.primaryColor,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  child: const Text('Simpan Jadwal'),
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _deleteJadwal(int id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Jadwal?'),
        content: const Text('Tindakan ini tidak dapat dibatalkan.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Batal')),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: AppConstants.errorColor),
            child: const Text('Ya, Hapus', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      await ApiService.deleteJadwal(id);
      _fetchData();
    } on ApiException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.message), backgroundColor: AppConstants.errorColor),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) return const LoadingIndicator();
    if (_errorMessage != null) {
      return ErrorView(message: _errorMessage!, onRetry: _fetchData);
    }

    return Scaffold(
      backgroundColor: Colors.transparent,
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 100),
        child: FloatingActionButton(
          onPressed: () => _showForm(),
          backgroundColor: Theme.of(context).colorScheme.primaryContainer,
          child: Icon(Icons.add_rounded, color: Theme.of(context).colorScheme.onPrimaryContainer, size: 28),
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 40, 24, 16),
            child: Text(
              'Kelola Jadwal',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w900,
                color: Theme.of(context).colorScheme.onSurface,
                letterSpacing: -0.5,
              ),
            ),
          ),
          Expanded(
            child: RefreshIndicator(
              onRefresh: _fetchData,
              color: Theme.of(context).colorScheme.primary,
              child: ListView.builder(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 150),
                itemCount: _jadwalList.length,
                itemBuilder: (context, index) {
                  final item = _jadwalList[index];
                  return Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surface,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.02),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: Colors.orange.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(Icons.event_note_rounded,
                                  color: Colors.orange, size: 20),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item.layanan?.nama ?? 'Layanan',
                                    softWrap: true,
                                    maxLines: 2,
                                    overflow: TextOverflow.visible,
                                    style: TextStyle(
                                      fontWeight: FontWeight.w800,
                                      fontSize: 14,
                                      color: Theme.of(context).colorScheme.onSurface,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    '${item.tanggalFormatted} • ${item.jamMulaiShort}-${item.jamSelesaiShort}',
                                    style: TextStyle(fontSize: 11, color: Theme.of(context).colorScheme.onSurfaceVariant),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const Divider(height: 24, thickness: 0.5),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Kuota: ${item.kuota}',
                              style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: Theme.of(context).colorScheme.primary),
                            ),
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                _buildActionIcon(Icons.qr_code_rounded, AppConstants.primaryColor, () => _showQrDialog(item)),
                                const SizedBox(width: 4), 
                                _buildActionIcon(Icons.edit_rounded, Colors.blue, () => _showForm(jadwal: item)),
                                const SizedBox(width: 4), 
                                _buildActionIcon(Icons.delete_outline_rounded, Colors.red, () => _deleteJadwal(item.id)),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionIcon(IconData icon, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, size: 18, color: color),
      ),
    );
  }
}
