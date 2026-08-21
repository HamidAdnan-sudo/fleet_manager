import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fleet_manager/core/constants/app_colors.dart';
import 'home_screen.dart';
import 'package:fleet_manager/features/trips/presentation/screens/trips_screen.dart';
import 'package:fleet_manager/features/trucks/presentation/screens/trucks_screen.dart';
import 'package:fleet_manager/features/profile/presentation/screens/profile_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;
  late final List<Widget> _tabs;

  final _homeKey = GlobalKey<HomeScreenState>();
  final _tripsKey = GlobalKey<TripsScreenState>();
  final _trucksKey = GlobalKey<TrucksScreenState>();

  @override
  void initState() {
    super.initState();
    // Tabs stay alive in an IndexedStack (so scroll position/state is kept),
    // which means they don't naturally know when data changed on another
    // tab — each screen exposes reload() via these keys so switching to a
    // tab always shows fresh data instead of a stale cached list.
    _tabs = [
      HomeScreen(key: _homeKey),
      TripsScreen(key: _tripsKey),
      TrucksScreen(key: _trucksKey),
      const ProfileScreen(),
    ];
  }

  void _switchTab(int index) {
    setState(() => _currentIndex = index);
    switch (index) {
      case 0:
        _homeKey.currentState?.reload();
        break;
      case 1:
        _tripsKey.currentState?.reload();
        break;
      case 2:
        _trucksKey.currentState?.reload();
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _tabs,
      ),
      bottomNavigationBar: _BottomNav(
        currentIndex: _currentIndex,
        onTap: _switchTab,
      ),
    );
  }
}

// ── Custom bottom nav bar ─────────────────────────────────────────────────────
class _BottomNav extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;
  const _BottomNav({required this.currentIndex, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surfaceMedium,
        border: Border(top: BorderSide(color: AppColors.divider, width: 1)),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _NavItem(
                icon: Icons.dashboard_outlined,
                activeIcon: Icons.dashboard_rounded,
                label: 'Home',
                index: 0,
                currentIndex: currentIndex,
                onTap: onTap,
              ),
              _NavItem(
                icon: Icons.route_outlined,
                activeIcon: Icons.route_rounded,
                label: 'Trips',
                index: 1,
                currentIndex: currentIndex,
                onTap: onTap,
              ),

              // ── Trucks centre circle button ──────────────────────────
              GestureDetector(
                onTap: () => onTap(2),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        color: currentIndex == 2
                            ? AppColors.highwayOrangeDark
                            : AppColors.highwayOrange,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color:
                                AppColors.highwayOrange.withValues(alpha: 0.4),
                            blurRadius: 12,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: const Icon(Icons.local_shipping_rounded,
                          color: Colors.white, size: 24),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Trucks',
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: AppColors.highwayOrange,
                        letterSpacing: 1,
                      ),
                    ),
                  ],
                ),
              ),

              _NavItem(
                icon: Icons.person_outlined,
                activeIcon: Icons.person_rounded,
                label: 'Profile',
                index: 3,
                currentIndex: currentIndex,
                onTap: onTap,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final int index;
  final int currentIndex;
  final ValueChanged<int> onTap;

  const _NavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.index,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final bool selected = currentIndex == index;
    return GestureDetector(
      onTap: () => onTap(index),
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              selected ? activeIcon : icon,
              color:
                  selected ? AppColors.highwayOrange : AppColors.textSecondary,
              size: 24,
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 10,
                fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                color: selected
                    ? AppColors.highwayOrange
                    : AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
