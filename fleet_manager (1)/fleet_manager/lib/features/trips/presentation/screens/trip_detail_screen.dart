import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fleet_manager/core/constants/app_colors.dart';

class TripDetailScreen extends StatelessWidget {
  final Map<String, dynamic>? trip;
  const TripDetailScreen({super.key, this.trip});

  @override
  Widget build(BuildContext context) {
    final t = trip ?? {};
    final status = (t['status'] as String?) ?? 'pending';

    return Scaffold(
      appBar: AppBar(title: Text(t['id'] as String? ?? 'Trip')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  t['route'] as String? ?? '—',
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                  ),
                ),
                Chip(
                  label: Text(AppColors.statusLabel(status)),
                  backgroundColor:
                      AppColors.statusColor(status).withValues(alpha: 0.15),
                  labelStyle: TextStyle(color: AppColors.statusColor(status)),
                  side: BorderSide.none,
                ),
              ],
            ),
            const SizedBox(height: 20),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    _DetailRow(
                        icon: Icons.local_shipping_outlined,
                        label: 'Truck',
                        value: t['truck'] as String? ?? '—'),
                    const Divider(height: 24),
                    _DetailRow(
                        icon: Icons.person_outline_rounded,
                        label: 'Driver',
                        value: t['driver'] as String? ?? '—'),
                    const Divider(height: 24),
                    _DetailRow(
                        icon: Icons.inventory_2_outlined,
                        label: 'Cargo',
                        value: t['cargo'] as String? ?? '—'),
                    const Divider(height: 24),
                    _DetailRow(
                        icon: Icons.calendar_today_outlined,
                        label: 'Date',
                        value: t['date'] as String? ?? '—'),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  const _DetailRow(
      {required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: AppColors.textSecondary, size: 20),
        const SizedBox(width: 12),
        Text(label,
            style: GoogleFonts.inter(
                fontSize: 13, color: AppColors.textSecondary)),
        const Spacer(),
        Text(value,
            style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary)),
      ],
    );
  }
}
