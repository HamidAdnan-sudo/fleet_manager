/// A fleet-staff account. [role] drives how the app greets and treats the
/// user: 'admin' (fleet manager/owner), 'dispatcher' (plans trips), or
/// 'driver' (drives trucks).
class Profile {
  final String id;
  final String? email;
  final String? fullName;
  final String? company;
  final String role;
  final DateTime? createdAt;

  Profile({
    required this.id,
    this.email,
    this.fullName,
    this.company,
    this.role = 'driver',
    this.createdAt,
  });

  factory Profile.fromJson(Map<String, dynamic> json) => Profile(
        id: json['id'] as String,
        email: json['email'] as String?,
        fullName: json['full_name'] as String?,
        company: json['company'] as String?,
        role: json['role'] as String? ?? 'driver',
        createdAt: json['created_at'] != null ? DateTime.parse(json['created_at'] as String) : null,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'email': email,
        'full_name': fullName,
        'company': company,
        'role': role,
        'created_at': createdAt?.toIso8601String(),
      };

  /// First name only, falling back to the email or a generic label —
  /// used for short greetings like "Welcome back, James".
  String get firstName {
    final name = fullName?.trim();
    if (name != null && name.isNotEmpty) return name.split(' ').first;
    if (email != null && email!.isNotEmpty) return email!.split('@').first;
    return 'there';
  }

  String get roleLabel {
    switch (role) {
      case 'admin':
        return 'Fleet Manager';
      case 'dispatcher':
        return 'Dispatcher';
      case 'driver':
        return 'Driver';
      default:
        return role;
    }
  }
}
