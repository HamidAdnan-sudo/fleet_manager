import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:fleet_manager/core/constants/app_colors.dart';
import 'package:fleet_manager/core/constants/app_strings.dart';
import 'package:fleet_manager/core/router/app_router.dart';

class TripsScreen extends StatelessWidget {
  const TripsScreen({super.key});

  static final List<Map<String, dynamic>> _trips = [
    {
      'id': 'TRP-1042',
      'truck': 'KDA 221B',
      'driver': 'James Otieno',
      'route': 'Mombasa → Nairobi',
      'cargo': 'Steel coils, 28T',
      'status': 'in_transit',
      'date': '21 Jul 2026',
    },
    {
      'id': 'TRP-1041',
      'truck': 'KDB 447L',
      'driver': 'Peter Kamau',
      'route': 'Nairobi → Kisumu',
      'cargo': 'Cement, 30T',
      'status': 'delivered',
      'date': '20 Jul 2026',
    },
    {
      'id': 'TRP-1040',
      'truck': 'KDC 903T',
      'driver': 'Ali Hassan',
      'route': 'Nakuru → Eldoret',
      'cargo': 'Timber, 22T',
      'status': 'delayed',
      'date': '19 Jul 2026',
    },
    {
      'id': 'TRP-1039',
      'truck': 'KDA 221B',
      'driver': 'James Otieno',
      'route': 'Nairobi → Mombasa',
      'cargo': 'Empty return',
      'status': 'completed',
      'date': '18 Jul 2026',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text(AppStrings.tripsTitle)),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _trips.length,
        itemBuilder: (context, i) {
          final trip = _trips[i];
          final status = trip['status'] as String;
          return Card(
            margin: const EdgeInsets.only(bottom: 10),
            child: ListTile(
              onTap: () => context.push(AppRoutes.tripDetail, extra: trip),
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
    );
  }
}
