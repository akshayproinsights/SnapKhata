// lib/features/auth/domain/entities/user.dart

/// Pure Dart user entity — no Flutter or Supabase imports.
class AppUser {
  final String id;
  final String email;
  final String? phone;
  final String? businessName;

  const AppUser({
    required this.id,
    required this.email,
    this.phone,
    this.businessName,
  });

  @override
  String toString() =>
      'AppUser(id: $id, email: $email, businessName: $businessName)';
}
