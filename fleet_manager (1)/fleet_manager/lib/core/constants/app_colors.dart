import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // ── Backgrounds ───────────────────────────────────────────────────
  static const Color asphaltBlack = Color(0xFF0B0F14);
  static const Color surfaceDark   = Color(0xFF141A22);
  static const Color surfaceMedium = Color(0xFF1C2530);
  static const Color surfaceLight  = Color(0xFF26313F);

  // ── Primary action ────────────────────────────────────────────────
  static const Color highwayOrange     = Color(0xFFFF6A13);
  static const Color highwayOrangeDark = Color(0xFFCC5410);

  // ── Accents ──────────────────────────────────────────────────────
  static const Color fleetBlue    = Color(0xFF2F80ED);
  static const Color cargoGreen   = Color(0xFF1DB894);
  static const Color warningAmber = Color(0xFFFFB020);

  // ── Text ─────────────────────────────────────────────────────────
  static const Color textPrimary   = Color(0xFFEDEFF2);
  static const Color textSecondary = Color(0xFF8B96A3);
  static const Color textDisabled  = Color(0xFF4A5460);
  static const Color divider       = Color(0xFF26313F);

  // ── Status helpers ────────────────────────────────────────────────
  static Color statusColor(String status) {
    switch (status.toLowerCase()) {
      case 'active':
      case 'in_transit':  return fleetBlue;
      case 'delivered':
      case 'completed':   return cargoGreen;
      case 'maintenance': return warningAmber;
      case 'idle':        return textSecondary;
      case 'delayed':     return highwayOrange;
      case 'pending':     return textSecondary;
      default:            return textSecondary;
    }
  }

  static String statusLabel(String status) {
    switch (status.toLowerCase()) {
      case 'active':      return 'Active';
      case 'in_transit':  return 'In Transit';
      case 'delivered':   return 'Delivered';
      case 'completed':   return 'Completed';
      case 'maintenance': return 'Maintenance';
      case 'idle':        return 'Idle';
      case 'delayed':     return 'Delayed';
      case 'pending':     return 'Pending';
      default:            return status;
    }
  }
}
