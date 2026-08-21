import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:fleet_manager/core/constants/app_colors.dart';
import 'package:fleet_manager/core/constants/app_strings.dart';
import 'package:fleet_manager/core/router/app_router.dart';
import 'package:fleet_manager/core/services/fleet_service.dart';

class TrucksScreen extends StatefulWidget {
  const TrucksScreen({super.key});

  @override
  State<TrucksScreen> createState() => TrucksScreenState();
}

class TrucksScreenState extends State<TrucksScreen> {
  bool _loading = true;
  String? _error;
  List<Map<String, dynamic>> _trucks = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  /// Public so MainScreen can force a refresh when this tab becomes visible.
  Future<void> reload() => _load();

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final rows = await FleetService.fetchTrucks();
      if (!mounted) return;
      setState(() {
        _trucks = rows;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = 'Could not load trucks: $e';
        _loading = false;
      });
    }
  }

  Future<void> _openDetail([Map<String, dynamic>? truck]) async {
    final changed = await context.push<bool>(AppRoutes.truckDetail, extra: truck);
    if (changed == true) _load();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.trucksTitle),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_rounded),
            onPressed: () => _openDetail(),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _load,
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : _error != null
                ? ListView(children: [
                    const SizedBox(height: 80),
                    Center(
                      child: Text(_error!,
                          style: GoogleFonts.inter(color: AppColors.textSecondary)),
                    ),
                  ])
                : _trucks.isEmpty
                    ? ListView(children: [
                        const SizedBox(height: 80),
                        Center(
                          child: Text('No trucks yet — tap + to add one.',
                              style: GoogleFonts.inter(color: AppColors.textSecondary)),
                        ),
                      ])
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: _trucks.length,
                        itemBuilder: (context, i) {
                          final truck = FleetService.truckDisplayMap(_trucks[i]);
                          final status = truck['status'] as String;
                          return Card(
                            margin: const EdgeInsets.only(bottom: 10),
                            child: ListTile(
                              onTap: () => _openDetail(truck),
                              leading: CircleAvatar(
                                backgroundColor: AppColors.surfaceLight,
                                child: const Icon(Icons.local_shipping_outlined,
                                    color: AppColors.textSecondary),
                              ),
                              title: Text(
                                truck['plate'] as String,
                                style: GoogleFonts.spaceGrotesk(
                                    fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                              ),
                              subtitle: Text(
                                '${truck['model']} • ${truck['driver']}',
                                style: GoogleFonts.inter(
                                    fontSize: 12, color: AppColors.textSecondary),
                              ),
                              trailing: Chip(
                                label: Text(AppColors.statusLabel(status)),
                                backgroundColor:
                                    AppColors.statusColor(status).withValues(alpha: 0.15),
                                labelStyle: TextStyle(color: AppColors.statusColor(status)),
                                side: BorderSide.none,
                              ),
                            ),
                          );
                        },
                      ),
      ),
    );
  }
}
