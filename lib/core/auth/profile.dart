import 'role.dart';

class Profile {
  const Profile({
    required this.id,
    required this.role,
    this.fullName,
    this.storeId,
  });

  final String id;
  final AppRole role;
  final String? fullName;
  final String? storeId;

  factory Profile.fromMap(Map<String, dynamic> map) {
    return Profile(
      id: map['id'] as String,
      role: AppRole.fromDb(map['role'] as String),
      fullName: map['full_name'] as String?,
      storeId: map['store_id'] as String?,
    );
  }
}
