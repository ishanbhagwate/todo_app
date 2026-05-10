class AuthException implements Exception {
  final String message;
  const AuthException([this.message = 'Authentication failed']);

  @override
  String toString() => message;
}

abstract class AuthRepository {
  /// Throws [AuthException] if credentials are invalid.
  Future<void> login(String username, String password);
}
