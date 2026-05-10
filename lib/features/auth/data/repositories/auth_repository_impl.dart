import 'package:injectable/injectable.dart';

import '../../domain/repositories/auth_repository.dart';

@Injectable(as: AuthRepository)
class AuthRepositoryImpl implements AuthRepository {
  static const _validUsername = 'admin';
  static const _validPassword = 'password';

  @override
  Future<void> login(String username, String password) async {
    await Future.delayed(const Duration(milliseconds: 500));
    if (username != _validUsername || password != _validPassword) {
      throw const AuthException('Invalid username or password');
    }
  }
}
