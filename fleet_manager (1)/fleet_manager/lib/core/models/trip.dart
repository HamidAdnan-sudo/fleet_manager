class Trip {
  final String id;
  final String? truckId;
  final DateTime? startedAt;
  final DateTime? endedAt;
  final String? origin;
  final String? destination;
  final String? status;
  final String? createdBy;
  final DateTime? createdAt;

  Trip({required this.id, this.truckId, this.startedAt, this.endedAt, this.origin, this.destination, this.status, this.createdBy, this.createdAt});

  factory Trip.fromJson(Map<String, dynamic> json) => Trip(
        id: json['id'] as String,
        truckId: json['truck_id'] as String?,
        startedAt: json['started_at'] != null ? DateTime.parse(json['started_at'] as String) : null,
        endedAt: json['ended_at'] != null ? DateTime.parse(json['ended_at'] as String) : null,
        origin: json['origin'] as String?,
        destination: json['destination'] as String?,
        status: json['status'] as String?,
        createdBy: json['created_by'] as String?,
        createdAt: json['created_at'] != null ? DateTime.parse(json['created_at'] as String) : null,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'truck_id': truckId,
        'started_at': startedAt?.toIso8601String(),
        'ended_at': endedAt?.toIso8601String(),
        'origin': origin,
        'destination': destination,
        'status': status,
        'created_by': createdBy,
        'created_at': createdAt?.toIso8601String(),
      };
}
