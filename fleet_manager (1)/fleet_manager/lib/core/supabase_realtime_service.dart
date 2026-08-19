import 'dart:async';

import 'package:fleet_manager/core/models/location_model.dart';
import 'package:fleet_manager/core/models/trip.dart';
import 'package:fleet_manager/core/supabase_service.dart';

class SupabaseRealtimeService {
  /// Stream of location history rows for all trucks (updates in realtime).
  static Stream<List<LocationModel>> locationsStream() {
    final stream = SupabaseService.client
      .from('locations')
      .stream(primaryKey: ['id'])
      .order('recorded_at');

    return stream.map((rows) => rows.map((r) => LocationModel.fromJson(r)).toList());
  }

  /// Stream of trips table changes.
  static Stream<List<Trip>> tripsStream() {
    final stream = SupabaseService.client
      .from('trips')
      .stream(primaryKey: ['id'])
      .order('created_at');

    return stream.map((rows) => rows.map((r) => Trip.fromJson(r)).toList());
  }

  /// Insert a new location record
  static Future<void> insertLocation(LocationModel loc) async {
    await SupabaseService.client.from('locations').insert(loc.toJson());
  }
}
