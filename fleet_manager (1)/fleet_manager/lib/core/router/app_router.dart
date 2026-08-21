import 'package:go_router/go_router.dart';
import 'package:fleet_manager/core/supabase_service.dart';
import 'package:fleet_manager/features/auth/presentation/screens/splash_screen.dart';
import 'package:fleet_manager/features/auth/presentation/screens/login_screen.dart';
import 'package:fleet_manager/features/auth/presentation/screens/signup_screen.dart';
import 'package:fleet_manager/features/home/presentation/screens/main_screen.dart';
import 'package:fleet_manager/features/trucks/presentation/screens/truck_detail_screen.dart';
import 'package:fleet_manager/features/trips/presentation/screens/trip_detail_screen.dart';
import 'package:fleet_manager/features/profile/presentation/screens/settings_screen.dart';
import 'package:fleet_manager/features/profile/presentation/screens/about_screen.dart';

/// All route path constants — never use raw strings for navigation
abstract class AppRoutes {
  static const String splash      = '/';
  static const String login       = '/login';
  static const String signup      = '/signup';
  static const String main        = '/main';
  static const String truckDetail = '/truck-detail';
  static const String tripDetail  = '/trip-detail';
  static const String settings    = '/settings';
  static const String about       = '/about';
}

class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: AppRoutes.splash,
    redirect: (context, state) {
      final loggedIn = SupabaseService.client.auth.currentSession != null;
      final loc = state.matchedLocation;
      final isPublicRoute = loc == AppRoutes.splash || loc == AppRoutes.login || loc == AppRoutes.signup;

      if (!loggedIn && !isPublicRoute) return AppRoutes.login;
      if (loggedIn && (loc == AppRoutes.login || loc == AppRoutes.signup)) return AppRoutes.main;
      return null;
    },
    routes: [
      GoRoute(
        path: AppRoutes.splash,
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: AppRoutes.login,
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: AppRoutes.signup,
        builder: (context, state) => const SignupScreen(),
      ),
      GoRoute(
        path: AppRoutes.main,
        builder: (context, state) => const MainScreen(),
      ),
      GoRoute(
        path: AppRoutes.truckDetail,
        builder: (context, state) {
          final truck = state.extra as Map<String, dynamic>?;
          return TruckDetailScreen(truck: truck);
        },
      ),
      GoRoute(
        path: AppRoutes.tripDetail,
        builder: (context, state) {
          final trip = state.extra as Map<String, dynamic>?;
          return TripDetailScreen(trip: trip);
        },
      ),
      GoRoute(
        path: AppRoutes.settings,
        builder: (context, state) => const SettingsScreen(),
      ),
      GoRoute(
        path: AppRoutes.about,
        builder: (context, state) => const AboutScreen(),
      ),
    ],
  );
}
