// lib/screens/admin/kelola_antrian.dart

import 'package:flutter/material.dart';
import 'package:q_campus_antrian_mahasiswa/utils/constants.dart';
import 'kelola_antrian/tabs/antrian_tab.dart';
import 'kelola_antrian/tabs/layanan_tab.dart';
import 'kelola_antrian/tabs/jadwal_tab.dart';

class KelolaAntrian extends StatefulWidget {
  final bool isEmbedded;

  const KelolaAntrian({super.key, this.isEmbedded = false});

  @override
  State<KelolaAntrian> createState() => _KelolaAntrianState();
}

class _KelolaAntrianState extends State<KelolaAntrian> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tabBar = TabBar(
      controller: _tabController,
      labelColor: Theme.of(context).colorScheme.primary,
      unselectedLabelColor: Theme.of(context).colorScheme.onSurfaceVariant,
      indicatorColor: Theme.of(context).colorScheme.primary,
      indicatorWeight: 3,
      tabs: const [
        Tab(text: 'Antrian', icon: Icon(Icons.confirmation_number_rounded)),
        Tab(text: 'Layanan', icon: Icon(Icons.room_service_rounded)),
        Tab(text: 'Jadwal', icon: Icon(Icons.event_note_rounded)),
      ],
    );

    final tabView = TabBarView(
      controller: _tabController,
      children: const [
        AntrianTab(),
        LayananTab(),
        JadwalTab(),
      ],
    );

    if (widget.isEmbedded) {
      return Column(
        children: [
          Container(
            color: Theme.of(context).colorScheme.surface,
            child: tabBar,
          ),
          Expanded(child: tabView),
        ],
      );
    }

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: const Text('Manajemen Sistem', style: TextStyle(fontWeight: FontWeight.w800)),
        backgroundColor: Theme.of(context).colorScheme.surface,
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(70),
          child: tabBar,
        ),
      ),
      body: tabView,
    );
  }
}
