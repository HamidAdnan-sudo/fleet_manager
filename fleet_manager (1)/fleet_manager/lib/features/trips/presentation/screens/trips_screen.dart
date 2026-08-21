import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:fleet_manager/core/constants/app_colors.dart';
import 'package:fleet_manager/core/constants/app_strings.dart';
import 'package:fleet_manager/core/router/app_router.dart';
import 'package:fleet_manager/core/services/fleet_service.dart';

class TripsScreen extends StatefulWidget {
  const TripsScreen({super.key});

  @override
  State<TripsScreen> createState() => TripsScreenState();
}

class TripsScreenState extends State<TripsScreen> {
  bool _loading = true;
  String? _error;
  List<Map<String, dynamic>> _trips = [];

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
      final rows = await FleetService.fetchTrips();
      if (!mounted) return;
      setState(() {
        _trips = rows;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = 'Could not load trips: $e';
        _loading = false;
      });
    }
  }

  Future<void> _openDetail([Map<String, dynamic>? trip]) async {
    final changed = await context.push<bool>(AppRoutes.tripDetail, extra: trip);
    if (changed == true) _load();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.tripsTitle),
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
                : _trips.isEmpty
                    ? ListView(children: [
                        const SizedBox(height: 80),
                        Center(
                          child: Text('No trips logged yet.',
                              style: GoogleFonts.inter(color: AppColors.textSecondary)),
                        ),
                      ])
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: _trips.length,
                        itemBuilder: (context, i) {
                          final trip = FleetService.tripDisplayMap(_trips[i]);
                          final status = trip['status'] as String;
                          return Card(
                            margin: const EdgeInsets.only(bottom: 10),
                            child: ListTile(
                              onTap: () => _openDetail(trip),
                              leading: CircleAvatar(
                                backgroundColor: AppColors.surfaceLight,
                                child: const Icon(Icons.route_outlined,
                                    color: AppColors.textSecondary),
                              ),
                              title: Text(
                                trip['route'] as String,
                                style: GoogleFonts.inter(
                                    fontWeight: FontWeight.w600, color: AppColors.textPrimary),
                              ),
                              subtitle: Text(
                                '${trip['truck']} • ${trip['date']}',
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
