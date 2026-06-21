// lib/screens/onboarding_screen.dart

import 'package:flutter/material.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:q_campus_antrian_mahasiswa/utils/theme_notifier.dart';
import 'package:q_campus_antrian_mahasiswa/utils/constants.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageCtrl = PageController();
  int _currentPage = 0;
  final int _numPages = 3;

  @override
  void dispose() {
    _pageCtrl.dispose();
    super.dispose();
  }

  Future<void> _completeOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('has_seen_onboarding', true);
    if (mounted) {
      Navigator.pushReplacementNamed(context, '/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          if (_currentPage < _numPages - 1)
            TextButton(
              onPressed: _completeOnboarding,
              child: Text(
                'Lewati',
                style: TextStyle(
                  color: colorScheme.primary,
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),
            ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView(
                controller: _pageCtrl,
                onPageChanged: (index) {
                  setState(() => _currentPage = index);
                },
                children: [
                  _buildPage(
                    title: 'Selamat Datang di Q-Campus',
                    description:
                        'Solusi cerdas antrian kampus digital. Pantau, ambil, dan kelola antrian layanan akademik Anda secara real-time langsung dari smartphone.',
                    visual: _buildWelcomeVector(),
                  ),
                  _buildPage(
                    title: 'Pilih Mode Tampilan Anda',
                    description:
                        'Q-Campus mendukung penuh Mode Terang dan Mode Gelap. Sesuaikan tampilan yang paling nyaman untuk mata Anda saat ini.',
                    visual: _buildThemeSelectorVector(),
                  ),
                  _buildPage(
                    title: 'Scan QR & Mulai Antri',
                    description:
                        'Cukup pindai kode QR jadwal layanan pada loket petugas untuk masuk ke barisan antrian secara instan. Praktis dan efisien!',
                    visual: _buildScannerVector(),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Indicators
                  SmoothPageIndicator(
                    controller: _pageCtrl,
                    count: _numPages,
                    effect: ExpandingDotsEffect(
                      activeDotColor: colorScheme.primary,
                      dotColor: colorScheme.outlineVariant,
                      dotHeight: 8,
                      dotWidth: 8,
                      expansionFactor: 3,
                    ),
                  ),
                  // Next / Done Button
                  ElevatedButton(
                    onPressed: () {
                      if (_currentPage < _numPages - 1) {
                        _pageCtrl.nextPage(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                        );
                      } else {
                        _completeOnboarding();
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(140, 56),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: Text(
                        _currentPage == _numPages - 1 ? 'Mulai' : 'Lanjut'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPage({
    required String title,
    required String description,
    required Widget visual,
  }) {
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
            flex: 5,
            child: Center(child: visual),
          ),
          const SizedBox(height: 16),
          Expanded(
            flex: 4,
            child: Column(
              children: [
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                    color: colorScheme.onSurface,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  description,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: colorScheme.onSurfaceVariant,
                    height: 1.6,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // --- Slide 1 Vector (Queueing / Ticket Stack) ---
  Widget _buildWelcomeVector() {
    final colorScheme = Theme.of(context).colorScheme;

    return SizedBox(
      height: 240,
      width: 280,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Background Glow
          Container(
            width: 180,
            height: 180,
            decoration: BoxDecoration(
              gradient: RadialGradient(
                colors: [
                  colorScheme.primary.withOpacity(0.15),
                  colorScheme.primary.withOpacity(0.0),
                ],
              ),
              shape: BoxShape.circle,
            ),
          ),
          // Back ticket decorative
          Positioned(
            left: 30,
            top: 40,
            child: Transform.rotate(
              angle: -0.15,
              child: _buildMiniTicket(
                icon: Icons.confirmation_number_outlined,
                number: 'A-24',
                color: colorScheme.secondaryContainer,
                textColor: colorScheme.onSecondaryContainer,
                opacity: 0.6,
              ),
            ),
          ),
          // Front Main Ticket
          Positioned(
            right: 40,
            bottom: 30,
            child: Transform.rotate(
              angle: 0.08,
              child: _buildMiniTicket(
                icon: Icons.confirmation_number_rounded,
                number: 'A-25',
                color: colorScheme.primaryContainer,
                textColor: colorScheme.onPrimaryContainer,
                opacity: 1.0,
                elevation: 8,
              ),
            ),
          ),
          // Floating Badge 1
          Positioned(
            right: 20,
            top: 30,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.amber.shade100,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.amber.shade300),
              ),
              child: Row(
                children: const [
                  Icon(Icons.access_time_filled_rounded,
                      size: 12, color: Colors.amber),
                  SizedBox(width: 4),
                  Text(
                    'Est. 5m',
                    style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: amberScale),
                  ),
                ],
              ),
            ),
          ),
          // Floating Badge 2
          Positioned(
            left: 20,
            bottom: 40,
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: colorScheme.surface,
                shape: BoxShape.circle,
                border: Border.all(color: colorScheme.outlineVariant),
              ),
              child: Icon(Icons.check_circle_rounded,
                  color: colorScheme.primary, size: 16),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMiniTicket({
    required IconData icon,
    required String number,
    required Color color,
    required Color textColor,
    required double opacity,
    double elevation = 0,
  }) {
    return Opacity(
      opacity: opacity,
      child: Container(
        width: 140,
        height: 150,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(24),
          boxShadow: elevation > 0
              ? [
                  BoxShadow(
                    color:
                        Theme.of(context).colorScheme.primary.withOpacity(0.15),
                    blurRadius: elevation,
                    offset: const Offset(0, 8),
                  )
                ]
              : null,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: textColor, size: 28),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'No. Antrian',
                  style: TextStyle(
                      fontSize: 10, color: textColor.withOpacity(0.7)),
                ),
                Text(
                  number,
                  style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w900,
                      color: textColor,
                      height: 1.1),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // --- Slide 2 Vector (Dynamic Theme Selector) ---
  Widget _buildThemeSelectorVector() {
    final themeNotifier = ThemeNotifier.instance;
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      width: 280,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: colorScheme.outlineVariant),
        boxShadow: [
          BoxShadow(
            color: colorScheme.primary.withOpacity(0.04),
            blurRadius: 20,
            offset: const Offset(0, 8),
          )
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Theme.of(context).brightness == Brightness.dark
                    ? Icons.dark_mode_rounded
                    : Icons.light_mode_rounded,
                color: colorScheme.primary,
                size: 28,
              ),
              const SizedBox(width: 8),
              Text(
                'Ubah Tampilan',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onSurface,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _buildThemeTile(
            mode: ThemeMode.light,
            label: 'Mode Terang',
            icon: Icons.light_mode_rounded,
            isSelected: themeNotifier.themeMode == ThemeMode.light,
          ),
          const SizedBox(height: 8),
          _buildThemeTile(
            mode: ThemeMode.dark,
            label: 'Mode Gelap',
            icon: Icons.dark_mode_rounded,
            isSelected: themeNotifier.themeMode == ThemeMode.dark,
          ),
          const SizedBox(height: 8),
          _buildThemeTile(
            mode: ThemeMode.system,
            label: 'Default Sistem',
            icon: Icons.settings_brightness_rounded,
            isSelected: themeNotifier.themeMode == ThemeMode.system,
          ),
        ],
      ),
    );
  }

  Widget _buildThemeTile({
    required ThemeMode mode,
    required String label,
    required IconData icon,
    required bool isSelected,
  }) {
    final colorScheme = Theme.of(context).colorScheme;

    return InkWell(
      onTap: () {
        ThemeNotifier.instance.updateThemeMode(mode);
        setState(() {}); // Refresh local selection icon
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

  // --- Slide 3 Vector (Scanning illustration) ---
  Widget _buildScannerVector() {
    final colorScheme = Theme.of(context).colorScheme;

    return SizedBox(
      height: 240,
      width: 240,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Scanner outer frame
          Container(
            width: 180,
            height: 180,
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerHighest.withOpacity(0.3),
              borderRadius: BorderRadius.circular(32),
              border: Border.all(color: colorScheme.outlineVariant, width: 2),
            ),
          ),
          // QR Box code
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: colorScheme.primary.withOpacity(0.08),
                  blurRadius: 15,
                  offset: const Offset(0, 5),
                )
              ],
            ),
            child: QrImageView(
              data: '{"type":"demo"}',
              size: 100,
              version: QrVersions.auto,
              eyeStyle: QrEyeStyle(
                eyeShape: QrEyeShape.square,
                color: colorScheme.primary,
              ),
            ),
          ),
          // Scanning lasers
          Positioned(
            top: 50,
            child: Container(
              width: 140,
              height: 4,
              decoration: BoxDecoration(
                color: colorScheme.primary,
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: colorScheme.primary.withOpacity(0.8),
                    blurRadius: 10,
                    spreadRadius: 2,
                  )
                ],
              ),
            ),
          ),
          // Scan brackets corners
          Positioned(
            left: 24,
            top: 24,
            child: _buildCorner(top: true, left: true),
          ),
          Positioned(
            right: 24,
            top: 24,
            child: _buildCorner(top: true, left: false),
          ),
          Positioned(
            left: 24,
            bottom: 24,
            child: _buildCorner(top: false, left: true),
          ),
          Positioned(
            right: 24,
            bottom: 24,
            child: _buildCorner(top: false, left: false),
          ),
        ],
      ),
    );
  }

  Widget _buildCorner({required bool top, required bool left}) {
    final color = Theme.of(context).colorScheme.primary;
    return Container(
      width: 24,
      height: 24,
      decoration: BoxDecoration(
        border: Border(
          top: top ? BorderSide(color: color, width: 4) : BorderSide.none,
          bottom: !top ? BorderSide(color: color, width: 4) : BorderSide.none,
          left: left ? BorderSide(color: color, width: 4) : BorderSide.none,
          right: !left ? BorderSide(color: color, width: 4) : BorderSide.none,
        ),
      ),
    );
  }
}

// Dummy color scale extension for inline code safety
const Color amberScale = Color(0xFFC78E00);
