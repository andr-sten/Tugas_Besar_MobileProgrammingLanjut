// lib/widgets/status_badge.dart

import 'package:flutter/material.dart';

class StatusBadge extends StatelessWidget {
  final String status;

  const StatusBadge({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    final isDipanggil = status == 'dipanggil';
    final bgColor =
        isDipanggil ? const Color(0xFFE8F5E9) : const Color(0xFFFFEBEE);
    final borderColor = isDipanggil
        ? Colors.green.withOpacity(0.3)
        : Colors.red.withOpacity(0.3);
    final textColor = isDipanggil ? Colors.green : Colors.red;
    final text = isDipanggil ? 'DIPANGGIL' : 'MENUNGGU';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(100),
        border: Border.all(color: borderColor),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: textColor,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            text,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: textColor,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }
}
