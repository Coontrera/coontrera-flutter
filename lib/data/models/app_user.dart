import 'package:hive/hive.dart';
import 'user_role.dart';

part 'app_user.g.dart';

@HiveType(typeId: 1)
class AppUser extends HiveObject {
  AppUser({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.passwordHash,
    required this.passwordSalt,
    required this.role,
    required this.createdAt,
  });

  @HiveField(0)
  String id;

  @HiveField(1)
  String name;

  @HiveField(2)
  String email;

  @HiveField(3)
  String phone;

  @HiveField(4)
  String passwordHash;

  @HiveField(5)
  String passwordSalt;

  @HiveField(6)
  UserRole role;

  @HiveField(7)
  DateTime createdAt;

  AppUser copyWith({
    String? name,
    String? email,
    String? phone,
    String? passwordHash,
    String? passwordSalt,
  }) {
    return AppUser(
      id: id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      passwordHash: passwordHash ?? this.passwordHash,
      passwordSalt: passwordSalt ?? this.passwordSalt,
      role: role,
      createdAt: createdAt,
    );
  }
}
