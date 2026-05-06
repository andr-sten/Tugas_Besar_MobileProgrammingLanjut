// lib/widgets/floating_bottom_nav_bar.dart

import 'package:flutter/material.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import '../utils/constants.dart';

class FloatingBottomNavBar extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onTabChange;
  final List<GButton> tabs;

  const FloatingBottomNavBar({
    super.key,
    required this.selectedIndex,
    required this.onTabChange,
    required this.tabs,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(24, 0, 24, 24),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
        border: Border.all(color: const Color(0xFFE8EEE7).withOpacity(0.5)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8),
        child: GNav(
          rippleColor: AppConstants.primaryColor.withOpacity(0.1),
          hoverColor: AppConstants.primaryColor.withOpacity(0.05),
          gap: 8,
          activeColor: AppConstants.primaryColor,
          iconSize: 24,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          duration: const Duration(milliseconds: 400),
          tabBackgroundColor: AppConstants.primaryColor.withOpacity(0.1),
          color: Colors.grey[600],
          tabs: tabs,
          selectedIndex: selectedIndex,
          onTabChange: onTabChange,
        ),
      ),
    );
  }
}
