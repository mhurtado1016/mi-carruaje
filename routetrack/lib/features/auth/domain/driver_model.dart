class DriverModel {
  final String id;
  final String name;
  final String email;
  final String zone;
  final String shift;
  final String status;
  final String? avatarUrl;
  final String token;

  const DriverModel({
    required this.id,
    required this.name,
    required this.email,
    required this.zone,
    required this.shift,
    required this.status,
    this.avatarUrl,
    required this.token,
  });

  factory DriverModel.fromJson(Map<String, dynamic> json) => DriverModel(
        id: json['id'] as String,
        name: json['name'] as String,
        email: json['email'] as String,
        zone: json['zone'] as String? ?? '',
        shift: json['shift'] as String? ?? 'day',
        status: json['status'] as String? ?? 'active',
        avatarUrl: json['avatar_url'] as String?,
        token: json['token'] as String,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'email': email,
        'zone': zone,
        'shift': shift,
        'status': status,
        'avatar_url': avatarUrl,
        'token': token,
      };

  String get initials {
    final parts = name.trim().split(' ');
    if (parts.length >= 2) return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    return name.isNotEmpty ? name[0].toUpperCase() : '?';
  }
}
