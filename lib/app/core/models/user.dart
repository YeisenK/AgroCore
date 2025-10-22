import 'role.dart';

class User {
  final String id;
  final String email;
  final List<Role> roles;

  const User({required this.id, required this.email, required this.roles});

  factory User.fromJson(Map<String, dynamic> json) {
    final rolesJson = (json['roles'] as List?)?.cast<String>() ?? const [];
    final roles = rolesJson.map(roleFromString).whereType<Role>().toList();
    return User(
      id: json['id'].toString(),
      email: json['email'] ?? '',
      roles: roles,
    );
  }

  bool get isAgricultor => roles.contains(Role.agricultor);
  bool get isIngeniero => roles.contains(Role.ingeniero);
  bool get isAdmin => roles.contains(Role.admin);
}
