class StaffUser {
  final int id;
  final String name;
  final String email;
  final String role; // admin | clinician

  const StaffUser({required this.id, required this.name, required this.email, required this.role});

  factory StaffUser.fromJson(Map<String, dynamic> json) => StaffUser(
        id: json['id'] as int,
        name: json['name'] as String,
        email: json['email'] as String,
        role: json['role'] as String,
      );
}
