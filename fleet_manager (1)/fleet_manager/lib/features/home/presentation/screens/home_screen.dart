import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:fleet_manager/core/constants/app_colors.dart';
import 'package:fleet_manager/core/constants/app_strings.dart';
import 'package:fleet_manager/core/router/app_router.dart';

class HomeScreen extends StatelessWidget {
  final VoidCallback onAddTruckPressed;
  const HomeScreen({super.key, required this.onAddTruckPressed});

  // Mock data — no location/GPS fields, just plain route text.
  static final List<Map<String, dynamic>> _recentTrips = [
    {
      'id': 'TRP-1042',
      'truck': 'KDA 221B',
      'driver': 'James Otieno',
      'route': 'Mombasa → Nairobi',
      'cargo': 'Steel coils, 28T',
      'status': 'in_transit',
    },
    {
      'id': 'TRP-1041',
      'truck': 'KDB 447L',
      'driver': 'Peter Kamau',
      'route': 'Nairobi → Kisumu',
      'cargo': 'Cement, 30T',
      'status': 'delivered',
    },
    {
      'id': 'TRP-1040',
      'truck': 'KDC 903T',
      'driver': 'Ali Hassan',
      'route': 'Nakuru → Eldoret',
      'cargo': 'Timber, 22T',
      'status': 'delayed',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppStrings.homeGreeting),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {},
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
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
                value: '18',
                icon: Icons.local_shipping_outlined,
                color: AppColors.fleetBlue,
              ),
              _StatCard(
                label: AppStrings.inTransit,
                value: '7',
                icon: Icons.route_outlined,
                color: AppColors.highwayOrange,
              ),
              _StatCard(
                label: AppStrings.maintenance,
                value: '2',
                icon: Icons.build_outlined,
                color: AppColors.warningAmber,
              ),
              _StatCard(
                label: AppStrings.pendingTrips,
                value: '5',
                icon: Icons.pending_actions_outlined,
                color: AppColors.cargoGreen,
              ),
            ],
          ),
          const SizedBox(height: 24),

          // ── Quick action ─────────────────────────────────────────
          ElevatedButton.icon(
            onPressed: onAddTruckPressed,
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
              TextButton(onPressed: () {}, child: const Text('See all')),
            ],
          ),
          const SizedBox(height: 8),
          ..._recentTrips.map((trip) => _TripTile(
                trip: trip,
                onTap: () => context.push(AppRoutes.tripDetail, extra: trip),
              )),
        ],
      ),
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
