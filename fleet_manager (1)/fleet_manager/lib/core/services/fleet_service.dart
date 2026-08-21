import 'package:fleet_manager/core/supabase_service.dart';

/// Query helpers shared by the home, trucks and trips screens. Rows come
/// back as raw maps (with embedded truck/driver data) so screens can
/// render them directly without an extra model-mapping layer.
class FleetService {
  FleetService._();

  static final _client = SupabaseService.client;

  /// All trucks, newest first, with the assigned driver's name embedded.
  static Future<List<Map<String, dynamic>>> fetchTrucks() async {
    final rows = await _client
        .from('trucks')
        .select('*, driver:profiles!trucks_driver_id_fkey(id, full_name)')
        .order('created_at', ascending: false);
    return List<Map<String, dynamic>>.from(rows as List);
  }

  /// Trips, newest first, with the truck's plate and driver name embedded.
  static Future<List<Map<String, dynamic>>> fetchTrips({int? limit}) async {
    var query = _client
        .from('trips')
        .select('*, trucks(plate, model, driver:profiles!trucks_driver_id_fkey(full_name))')
        .order('created_at', ascending: false);
    final rows = limit != null ? await query.limit(limit) : await query;
    return List<Map<String, dynamic>>.from(rows as List);
  }

  /// Profiles with role = driver, for assigning a truck to someone.
  static Future<List<Map<String, dynamic>>> fetchDrivers() async {
    final rows = await _client
        .from('profiles')
        .select('id, full_name, email')
        .eq('role', 'driver')
        .order('full_name');
    return List<Map<String, dynamic>>.from(rows as List);
  }

  static Future<void> upsertTruck(Map<String, dynamic> values) async {
    await _client.from('trucks').upsert(values);
  }

  static Future<void> upsertTrip(Map<String, dynamic> values) async {
    await _client.from('trips').upsert(values);
  }

  /// Flattens a raw `trucks` row (with embedded driver) into the plain
  /// string map the truck list/detail widgets render.
  static Map<String, dynamic> truckDisplayMap(Map<String, dynamic> row) {
    final driver = row['driver'] as Map<String, dynamic>?;
    return {
      'id': row['id'],
      'plate': row['plate'] as String? ?? '—',
      'model': row['model'] as String? ?? '—',
      'driver': driver?['full_name'] as String? ?? 'Unassigned',
      'driver_id': row['driver_id'],
      'capacity': row['capacity']?.toString() ?? '',
      'status': row['status'] as String? ?? 'idle',
    };
  }

  /// Flattens a raw `trips` row (with embedded truck + driver) into the
  /// map the trip list/detail widgets render. Includes both display
  /// strings (route, date) and raw editable fields (origin, destination,
  /// truck_id) so the same map can be used for viewing and editing.
  static Map<String, dynamic> tripDisplayMap(Map<String, dynamic> row) {
    final truck = row['trucks'] as Map<String, dynamic>?;
    final driver = truck?['driver'] as Map<String, dynamic>?;
    final origin = row['origin'] as String? ?? '';
    final destination = row['destination'] as String? ?? '';
    final createdAt = row['created_at'] as String?;
    return {
      'id': row['id'],
      'truck_id': row['truck_id'],
      'origin': origin,
      'destination': destination,
      'route': '${origin.isEmpty ? '—' : origin} → ${destination.isEmpty ? '—' : destination}',
      'truck': truck?['plate'] as String? ?? 'Unassigned',
      'driver': driver?['full_name'] as String? ?? 'Unassigned',
      'cargo': row['cargo'] as String? ?? '',
      'status': row['status'] as String? ?? 'pending',
      'date': createdAt != null ? formatDate(DateTime.parse(createdAt)) : '—',
    };
  }

  static const _months = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
  ];

  static String formatDate(DateTime dt) =>
      '${dt.day} ${_months[dt.month - 1]} ${dt.year}';
}
