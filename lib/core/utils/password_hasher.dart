import 'dart:convert';
import 'dart:math';
import 'package:crypto/crypto.dart';

/// Lightweight salted-hash helper for the mocked auth layer. Not meant to
/// stand in for real backend auth (that will replace this repository
/// entirely) — it exists so mock passwords are never stored/compared as
/// plaintext even locally.
abstract final class PasswordHasher {
  static String generateSalt([int length = 16]) {
    final random = Random.secure();
    final bytes = List<int>.generate(length, (_) => random.nextInt(256));
    return base64UrlEncode(bytes);
  }

  static String hash(String password, String salt) {
    final bytes = utf8.encode('$salt:$password');
    return sha256.convert(bytes).toString();
  }

  static bool verify(String password, String salt, String expectedHash) {
    return hash(password, salt) == expectedHash;
  }
}
