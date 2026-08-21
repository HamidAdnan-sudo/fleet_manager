import 'package:fleet_manager/core/models/profile.dart';
import 'package:fleet_manager/core/supabase_service.dart';

/// Loads and caches the signed-in user's profile row (name, company,
/// role) so screens don't each re-query it after login.
class ProfileService {
  ProfileService._();
  static Profile? current;

  static Future<Profile?> fetchCurrent() async {
    final user = SupabaseService.client.auth.currentUser;
    if (user == null) {
      current = null;
      return null;
    }
    final row = await SupabaseService.client
        .from('profiles')
        .select()
        .eq('id', user.id)
        .maybeSingle();

    if (row == null) {
      // Trigger hasn't created the row yet (or ran before this client
      // could see it) — fall back to what we know from the auth user so
      // the UI still has something sensible to show.
      current = Profile(
        id: user.id,
        email: user.email,
        fullName: user.userMetadata?['full_name'] as String?,
        company: user.userMetadata?['company'] as String?,
        role: user.userMetadata?['role'] as String? ?? 'driver',
      );
      return current;
    }

    current = Profile.fromJson(row);
    return current;
  }

  static void clear() => current = null;
}
