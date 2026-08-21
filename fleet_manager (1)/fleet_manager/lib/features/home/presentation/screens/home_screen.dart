import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:fleet_manager/core/constants/app_colors.dart';
import 'package:fleet_manager/core/constants/app_strings.dart';
import 'package:fleet_manager/core/models/profile.dart';
import 'package:fleet_manager/core/router/app_router.dart';
import 'package:fleet_manager/core/services/fleet_service.dart';
import 'package:fleet_manager/core/services/profile_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> {
  bool _loading = true;
  String? _error;
  List<Map<String, dynamic>> _trucks = [];
  List<Map<String, dynamic>> _trips = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  /// Public so MainScreen can force a refresh when this tab becomes visible.
  Future<void> reload() => _load();

  Future<void> _addTruck() async {
    final added = await context.push<bool>(AppRoutes.truckDetail);
    if (added == true) _load();
  }

  Future<void> _openTrip(Map<String, dynamic> trip) async {
    final changed = await context.push<bool>(AppRoutes.tripDetail, extra: trip);
    if (changed == true) _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      ProfileService.current ??= await ProfileService.fetchCurrent();
      final results = await Future.wait([
        FleetService.fetchTrucks(),
        FleetService.fetchTrips(limit: 5),
      ]);
      if (!mounted) return;
      setState(() {
        _trucks = results[0];
        _trips = results[1];
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = 'Could not load fleet data: $e';
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final profile = ProfileService.current;
    return Scaffold(
      appBar: AppBar(
        title: Text(profile != null
            ? 'Welcome, ${profile.firstName}'
            : AppStrings.homeGreeting),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('No new notifications')),
            ),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _load,
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : _error != null
                ? _ErrorState(message: _error!, onRetry: _load)
                : _buildContent(profile),
      ),
    );
  }

  Widget _buildContent(Profile? profile) {
    final activeTrucks = _trucks.where((t) => t['status'] == 'active').length;
    final maintenanceTrucks = _trucks.where((t) => t['status'] == 'maintenance').length;
    final inTransitTrips = _trips.where((t) => t['status'] == 'in_transit').length;
    final pendingTrips = _trips.where((t) => t['status'] == 'pending').length;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        if (profile != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Text(
              '${profile.roleLabel}${profile.company != null && profile.company!.isNotEmpty ? ' · ${profile.company}' : ''}',
              style: GoogleFonts.inter(fontSize: 13, color: AppColors.textSecondary),
            ),
          ),

        // ── Stat cards grid ─────────────────────────────────────
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 1.5,
          children: [
            _StatCard(
              label: AppStrings.activeTrucks,
              value: '$activeTrucks',
              icon: Icons.local_shipping_outlined,
              color: AppColors.fleetBlue,
            ),
            _StatCard(
              label: AppStrings.inTransit,
              value: '$inTransitTrips',
              icon: Icons.route_outlined,
              color: AppColors.highwayOrange,
            ),
            _StatCard(
              label: AppStrings.maintenance,
              value: '$maintenanceTrucks',
              icon: Icons.build_outlined,
              color: AppColors.warningAmber,
            ),
            _StatCard(
              label: AppStrings.pendingTrips,
              value: '$pendingTrips',
              icon: Icons.pending_actions_outlined,
              color: AppColors.cargoGreen,
            ),
          ],
        ),
        const SizedBox(height: 24),

        // ── Quick action ─────────────────────────────────────────
        ElevatedButton.icon(
          onPressed: _addTruck,
          icon: const Icon(Icons.add_rounded),
          label: const Text('Add a Truck'),
        ),
        const SizedBox(height: 24),

        // ── Recent trips ──────────────────────────────────────────
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Recent Trips',
              style: GoogleFonts.spaceGrotesk(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        if (_trips.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 24),
            child: Center(
              child: Text('No trips yet',
                  style: GoogleFonts.inter(color: AppColors.textSecondary)),
            ),
          )
        else
          ..._trips.map((row) {
            final trip = FleetService.tripDisplayMap(row);
            return _TripTile(
              trip: trip,
              onTap: () => _openTrip(trip),
            );
          }),
      ],
    );
  }
}

class _ErrorState extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  const _ErrorState({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        const SizedBox(height: 80),
        Icon(Icons.cloud_off_rounded, size: 48, color: AppColors.textSecondary),
        const SizedBox(height: 16),
        Text(message, textAlign: TextAlign.center,
            style: GoogleFonts.inter(color: AppColors.textSecondary)),
        const SizedBox(height: 16),
        Center(
          child: OutlinedButton(onPressed: onRetry, child: const Text('Retry')),
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Icon(icon, color: color, size: 22),
            Text(
              value,
              style: GoogleFonts.spaceGrotesk(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
              ),
            ),
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 12,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TripTile extends StatelessWidget {
  final Map<String, dynamic> trip;
  final VoidCallback onTap;
  const _TripTile({required this.trip, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final status = trip['status'] as String;
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        onTap: onTap,
        leading: CircleAvatar(
          backgroundColor: AppColors.surfaceLight,
          child: Icon(Icons.local_shipping_outlined,
              color: AppColors.textSecondary, size: 20),
        ),
        title: Text(
          trip['route'] as String,
          style: GoogleFonts.inter(
              fontWeight: FontWeight.w600, color: AppColors.textPrimary),
        ),
        subtitle: Text(
          '${trip['truck']} • ${trip['driver']}',
          style: GoogleFonts.inter(
              fontSize: 12, color: AppColors.textSecondary),
        ),
        trailing: Chip(
          label: Text(AppColors.statusLabel(status)),
          backgroundColor: AppColors.statusColor(status).withValues(alpha: 0.15),
          labelStyle: TextStyle(color: AppColors.statusColor(status)),
          side: BorderSide.none,
        ),
      ),
    );
  }
}
