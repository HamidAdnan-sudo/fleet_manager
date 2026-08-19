class Truck {
  final String id;
  final String? plate;
  final String? model;
  final String? driverId;
  final int? capacity;
  final String? status;
  final DateTime? createdAt;

  Truck({required this.id, this.plate, this.model, this.driverId, this.capacity, this.status, this.createdAt});

  factory Truck.fromJson(Map<String, dynamic> json) => Truck(
        id: json['id'] as String,
        plate: json['plate'] as String?,
        model: json['model'] as String?,
        driverId: json['driver'] as String?,
        capacity: json['capacity'] is int ? json['capacity'] as int : (json['capacity'] != null ? int.tryParse(json['capacity'].toString()) : null),
        status: json['status'] as String?,
        createdAt: json['created_at'] != null ? DateTime.parse(json['created_at'] as String) : null,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'plate': plate,
        'model': model,
        'driver': driverId,
        'capacity': capacity,
        'status': status,
        'created_at': createdAt?.toIso8601String(),
      };
}
