import 'package:injectable/injectable.dart';

import '../repositories/auth_repository.dart';

@injectable
class LoginUseCase {
  final AuthRepository _repository;

  LoginUseCase(this._repository);

  Future<void> call(String username, String password) =>
      _repository.login(username, password);
}
