// lib/screens/mahasiswa/scanner_screen.dart

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class ScannerScreen extends StatefulWidget {
  const ScannerScreen({super.key});

  @override
  State<ScannerScreen> createState() => _ScannerScreenState();
}

class _ScannerScreenState extends State<ScannerScreen> {
  final MobileScannerController _scannerController = MobileScannerController();
  DateTime? _lastErrorTime;

  @override
  void dispose() {
    _scannerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scan QR Antrian', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Theme.of(context).colorScheme.surface,
        foregroundColor: Theme.of(context).colorScheme.onSurface,
        elevation: 0,
      ),
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          MobileScanner(
            controller: _scannerController,
            onDetect: (capture) {
              final List<Barcode> barcodes = capture.barcodes;
              for (final barcode in barcodes) {
                final String? code = barcode.rawValue;
                if (code != null) {
                  try {
                    final data = jsonDecode(code);
                    if (data['type'] == 'jadwal' && data['id'] != null) {
                        _scannerController.stop(); // Hentikan kamera segera setelah berhasil
                        Navigator.pop(context, data);
                        return; // Keluar dari fungsi agar tidak memproses frame lebih lanjut
                    }
                  } catch (e) {
                    // Abaikan error parse JSON di sini, tangani di bawah
                  }
                }
              }

              // Jika kode mencapai titik ini dan ada barcode yang terdeteksi, berarti barcode tidak valid
              if (barcodes.isNotEmpty) {
                 final now = DateTime.now();
                 // Batasi pesan error agar tidak spam (tunggu 2 detik)
                 if (_lastErrorTime == null || now.difference(_lastErrorTime!).inSeconds > 2) {
                    _lastErrorTime = now;
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Format QR tidak sesuai. Gunakan QR Jadwal.'),
                        backgroundColor: Colors.red,
                        behavior: SnackBarBehavior.floating,
                        duration: Duration(seconds: 2),
                      ),
                    );
                 }
              }
            },
          ),
          // Scanner Overlay
          Center(
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                border: Border.all(color: Theme.of(context).colorScheme.primary, width: 4),
                borderRadius: BorderRadius.circular(24),
              ),
            ),
          ),
          Positioned(
            bottom: 50,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.black54,
                  borderRadius: BorderRadius.circular(100),
                ),
                child: const Text(
                  'Arahkan kamera ke kode QR Jadwal',
                  style: TextStyle(color: Colors.white, fontSize: 14),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
