import 'package:bazaaro_core/bazaaro_core.dart';
import 'package:bazaaro_domain/bazaaro_domain.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final firebaseAuthProvider = Provider<FirebaseAuth>(
  (ref) => FirebaseAuth.instance,
);
final authStateProvider = StreamProvider<User?>(
  (ref) => ref.watch(firebaseAuthProvider).authStateChanges(),
);

final demoProfileProvider = Provider<UserProfile?>((ref) {
  final user = ref.watch(authStateProvider).valueOrNull;
  if (user == null) return null;
  return UserProfile(
    uid: user.uid,
    name: user.displayName ?? 'Bazaaro User',
    email: user.email ?? '',
    role: UserRole.customer,
    permissions: const [],
    status: UserStatus.active,
    photoUrl: user.photoURL,
  );
});
