class LocationModel {
  final String id;
  final String truckId;
  final double latitude;
  final double longitude;
  final DateTime? recordedAt;

  LocationModel({required this.id, required this.truckId, required this.latitude, required this.longitude, this.recordedAt});

  factory LocationModel.fromJson(Map<String, dynamic> json) => LocationModel(
        id: json['id'] as String,
        truckId: json['truck_id'] as String,
        latitude: (json['latitude'] as num).toDouble(),
        longitude: (json['longitude'] as num).toDouble(),
        recordedAt: json['recorded_at'] != null ? DateTime.parse(json['recorded_at'] as String) : null,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'truck_id': truckId,
        'latitude': latitude,
        'longitude': longitude,
        'recorded_at': recordedAt?.toIso8601String(),
      };
}
