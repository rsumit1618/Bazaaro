import 'package:bazaaro_core/bazaaro_core.dart';

class UserProfile {
  const UserProfile({
    required this.uid,
    required this.name,
    required this.email,
    required this.role,
    required this.permissions,
    required this.status,
    this.phone,
    this.photoUrl,
  });

  final String uid;
  final String name;
  final String email;
  final String? phone;
  final String? photoUrl;
  final UserRole role;
  final List<String> permissions;
  final UserStatus status;

  bool can(String permission) =>
      role == UserRole.superAdmin || permissions.contains(permission);
}
