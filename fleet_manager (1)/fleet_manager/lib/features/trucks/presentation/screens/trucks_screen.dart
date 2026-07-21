import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:fleet_manager/core/constants/app_colors.dart';
import 'package:fleet_manager/core/constants/app_strings.dart';
import 'package:fleet_manager/core/router/app_router.dart';

class TrucksScreen extends StatelessWidget {
  const TrucksScreen({super.key});

  static final List<Map<String, dynamic>> _trucks = [
    {
      'plate': 'KDA 221B',
      'model': 'Isuzu FVZ 34T',
      'driver': 'James Otieno',
      'status': 'active',
    },
    {
      'plate': 'KDB 447L',
      'model': 'Mitsubishi Fuso 30T',
      'driver': 'Peter Kamau',
      'status': 'idle',
    },
    {
      'plate': 'KDC 903T',
      'model': 'Scania R450 32T',
      'driver': 'Ali Hassan',
      'status': 'active',
    },
    {
      'plate': 'KDD 118M',
      'model': 'MAN TGS 28T',
      'driver': 'Unassigned',
      'status': 'maintenance',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.trucksTitle),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_rounded),
            onPressed: () => context.push(AppRoutes.truckDetail),
          ),
        ],
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _trucks.length,
        itemBuilder: (context, i) {
          final truck = _trucks[i];
          final status = truck['status'] as String;
          return Card(
            margin: const EdgeInsets.only(bottom: 10),
            child: ListTile(
              onTap: () => context.push(AppRoutes.truckDetail, extra: truck),
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
    );
  }
}
