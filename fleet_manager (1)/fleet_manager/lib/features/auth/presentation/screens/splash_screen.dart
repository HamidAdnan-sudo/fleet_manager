import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:fleet_manager/core/constants/app_colors.dart';
import 'package:fleet_manager/core/constants/app_strings.dart';
import 'package:fleet_manager/core/router/app_router.dart';
import 'package:fleet_manager/core/services/profile_service.dart';
import 'package:fleet_manager/core/supabase_service.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _resolveInitialRoute();
  }

  Future<void> _resolveInitialRoute() async {
    // Keep the brand animation visible for a moment, then route based on
    // whether there's already a signed-in session.
    await Future.delayed(const Duration(seconds: 2));
    if (!mounted) return;

    final session = SupabaseService.client.auth.currentSession;
    if (session == null) {
      context.go(AppRoutes.login);
      return;
    }

    try {
      await ProfileService.fetchCurrent();
      if (!mounted) return;
      context.go(AppRoutes.main);
    } catch (_) {
      // Session exists but couldn't be validated against the backend —
      // send back to login rather than showing a broken main screen.
      if (mounted) context.go(AppRoutes.login);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.asphaltBlack,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 96,
              height: 96,
              decoration: BoxDecoration(
                color: AppColors.highwayOrange,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.highwayOrange.withValues(alpha: 0.35),
                    blurRadius: 24,
                    spreadRadius: 4,
                  ),
                ],
              ),
              child: const Icon(Icons.local_shipping_rounded,
                  color: Colors.white, size: 48),
            ).animate().scale(duration: 500.ms, curve: Curves.easeOutBack),
            const SizedBox(height: 24),
            Text(
              AppStrings.appName,
              style: GoogleFonts.spaceGrotesk(
                fontSize: 28,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
              ),
            ).animate().fadeIn(delay: 200.ms, duration: 500.ms),
            const SizedBox(height: 8),
            Text(
              AppStrings.tagline,
              style: GoogleFonts.inter(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
            ).animate().fadeIn(delay: 400.ms, duration: 500.ms),
          ],
        ),
      ),
    );
  }
}
