import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/app_user.dart';
import '../models/user_role.dart';
import '../repositories/auth_repository.dart';
import '../repositories/repository_exceptions.dart';

class FirebaseAuthRepository implements AuthRepository {
  final _auth = FirebaseAuth.instance;
  final _profiles = FirebaseFirestore.instance.collection('profiles');

  AppUser _decode(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    return AppUser(
      id: doc.id,
      email: data['email'],
      name: data['name'],
      phone: data['phone'],
      role: UserRole.values.byName(data['role']),
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      passwordHash: '',
      passwordSalt: '',
    );
  }

  Future<AppUser> _profile(User user, {String? name, String? phone}) async {
    final ref = _profiles.doc(user.uid);
    return FirebaseFirestore.instance.runTransaction((tx) async {
      final doc = await tx.get(ref);
      if (doc.exists) return _decode(doc);
      if (name == null || phone == null) {
        throw const AuthException(
          'Complete o cadastro usando o mesmo e-mail e senha.',
        );
      }
      final profile = AppUser(
        id: user.uid,
        name: name,
        email: user.email!,
        phone: phone,
        role: UserRole.client,
        passwordHash: '',
        passwordSalt: '',
        createdAt: DateTime.now(),
      );
      tx.set(ref, {
        'email': profile.email,
        'name': profile.name,
        'phone': profile.phone,
        'role': 'client',
        'createdAt': FieldValue.serverTimestamp(),
      });
      return profile;
    });
  }

  Future<T> _handle<T>(Future<T> Function() action) async {
    try {
      return await action();
    } on FirebaseAuthException catch (e) {
      throw AuthException(switch (e.code) {
        'email-already-in-use' => 'Este e-mail já está cadastrado.',
        'weak-password' => 'Escolha uma senha mais forte.',
        'invalid-email' => 'Informe um e-mail válido.',
        'user-disabled' => 'Esta conta está desativada.',
        'invalid-credential' ||
        'wrong-password' ||
        'user-not-found' => 'E-mail ou senha incorretos.',
        'too-many-requests' => 'Muitas tentativas. Aguarde e tente novamente.',
        _ => 'Não foi possível autenticar (${e.code}).',
      });
    }
  }

  @override
  Future<AppUser> login(String email, String password) => _handle(() async {
    final result = await _auth.signInWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
    return _profile(result.user!);
  });

  @override
  Future<AppUser> register({
    required String name,
    required String email,
    required String password,
    required String phone,
  }) => _handle(() async {
    final address = email.trim();
    UserCredential result;
    try {
      result = await _auth.createUserWithEmailAndPassword(
        email: address,
        password: password,
      );
    } on FirebaseAuthException catch (error) {
      if (error.code != 'email-already-in-use') rethrow;
      // Recupera um cadastro interrompido entre a criação da conta e do perfil.
      result = await _auth.signInWithEmailAndPassword(
        email: address,
        password: password,
      );
      if ((await _profiles.doc(result.user!.uid).get()).exists) {
        await _auth.signOut();
        throw const AuthException(
          'Este e-mail já está cadastrado. Entre pela tela de login.',
        );
      }
    }
    return _profile(result.user!, name: name.trim(), phone: phone.trim());
  });

  @override
  Future<AppUser?> restoreSession() async {
    final user = await _auth.authStateChanges().first;
    if (user == null) return null;
    return _profile(user);
  }

  @override
  Future<void> resetPassword(String email) => _handle(() async {
    try {
      await _auth.sendPasswordResetEmail(email: email.trim());
    } on FirebaseAuthException catch (e) {
      if (e.code != 'user-not-found') rethrow;
    }
  });

  @override
  Future<void> logout() => _auth.signOut();

  @override
  Future<List<AppUser>> getAllClients() async {
    final result = await _profiles.where('role', isEqualTo: 'client').get();
    return result.docs.map(_decode).toList()
      ..sort((a, b) => a.name.compareTo(b.name));
  }

  @override
  Future<AppUser?> getById(String id) async {
    final doc = await _profiles.doc(id).get();
    return doc.exists ? _decode(doc) : null;
  }
}
