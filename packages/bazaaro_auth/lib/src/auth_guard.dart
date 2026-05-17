import 'package:bazaaro_core/bazaaro_core.dart';
import 'package:bazaaro_domain/bazaaro_domain.dart';

String? guardRoute({
  required UserProfile? profile,
  required List<UserRole> allowedRoles,
  String loginPath = '/login',
}) {
  if (profile == null) {
    return loginPath;
  }
  if (profile.status != UserStatus.active) {
    return '/blocked';
  }
  if (allowedRoles.isEmpty ||
      allowedRoles.contains(profile.role) ||
      profile.role == UserRole.superAdmin) {
    return null;
  }
  return '/unauthorized';
}
