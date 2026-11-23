import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';
import '../../../core/utils/password_hasher.dart';
import '../../local/hive_boxes.dart';
import '../../models/app_user.dart';
import '../../models/user_role.dart';
import '../auth_repository.dart';
import '../repository_exceptions.dart';
import 'mock_latency.dart';

class MockAuthRepository implements AuthRepository {
  @override
  Future<void> resetPassword(String email) async {
    throw const AuthException("O envio de e-mail está disponível após vincular o Firebase.");
  }
  MockAuthRepository({required this.usersBox, required this.metaBox});

  final Box<AppUser> usersBox;
  final Box metaBox;

  static const _uuid = Uuid();

  AppUser? _findByEmail(String email) {
    final normalized = email.trim().toLowerCase();
    for (final user in usersBox.values) {
      if (user.email.toLowerCase() == normalized) return user;
    }
    return null;
  }

  @override
  Future<AppUser> login(String email, String password) async {
    await simulateLatency();
    final user = _findByEmail(email);
    if (user == null) {
      throw const AuthException('E-mail ou senha inválidos.');
    }
    if (!PasswordHasher.verify(password, user.passwordSalt, user.passwordHash)) {
      throw const AuthException('E-mail ou senha inválidos.');
    }
    await metaBox.put(MetaKeys.currentUserId, user.id);
    return user;
  }

  @override
  Future<AppUser> register({
    required String name,
    required String email,
    required String password,
    required String phone,
  }) async {
    await simulateLatency();
    if (_findByEmail(email) != null) {
      throw const AuthException('Este e-mail já está cadastrado.');
    }
    final salt = PasswordHasher.generateSalt();
    final user = AppUser(
      id: _uuid.v4(),
      name: name.trim(),
      email: email.trim().toLowerCase(),
      phone: phone.trim(),
      passwordHash: PasswordHasher.hash(password, salt),
      passwordSalt: salt,
      role: UserRole.client,
      createdAt: DateTime.now(),
    );
    await usersBox.put(user.id, user);
    await metaBox.put(MetaKeys.currentUserId, user.id);
    return user;
  }

  @override
  Future<void> logout() async {
    await simulateLatency();
    await metaBox.delete(MetaKeys.currentUserId);
  }

  @override
  Future<AppUser?> restoreSession() async {
    await simulateLatency();
    final id = metaBox.get(MetaKeys.currentUserId) as String?;
    if (id == null) return null;
    return usersBox.get(id);
  }

  @override
  Future<List<AppUser>> getAllClients() async {
    await simulateLatency();
    final clients = usersBox.values.where((u) => u.role == UserRole.client).toList();
    clients.sort((a, b) => a.name.compareTo(b.name));
    return clients;
  }

  @override
  Future<AppUser?> getById(String id) async {
    await simulateLatency();
    return usersBox.get(id);
  }
}
