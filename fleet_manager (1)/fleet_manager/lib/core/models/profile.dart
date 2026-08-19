class Profile {
  final String id;
  final String? fullName;
  final String? company;
  final DateTime? createdAt;

  Profile({required this.id, this.fullName, this.company, this.createdAt});

  factory Profile.fromJson(Map<String, dynamic> json) => Profile(
        id: json['id'] as String,
        fullName: json['full_name'] as String?,
        company: json['company'] as String?,
        createdAt: json['created_at'] != null ? DateTime.parse(json['created_at'] as String) : null,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'full_name': fullName,
        'company': company,
        'created_at': createdAt?.toIso8601String(),
      };
}
