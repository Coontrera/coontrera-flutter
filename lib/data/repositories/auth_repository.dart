import '../models/app_user.dart';

abstract class AuthRepository {
  Future<AppUser> login(String email, String password);

  Future<AppUser> register({
    required String name,
    required String email,
    required String password,
    required String phone,
  });

  Future<void> logout();
  Future<void> resetPassword(String email);

  /// Restores a previously persisted session (survives app restarts).
  Future<AppUser?> restoreSession();

  Future<List<AppUser>> getAllClients();

  Future<AppUser?> getById(String id);
}
