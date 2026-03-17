import "package:core/core.dart";
import "package:flutter/foundation.dart";

import "../../data/models/driver.dart";
import "../../data/repositories/auth_repository.dart";

class LoginViewModel extends ChangeNotifier {
  final AuthRepository _repository;

  LoginViewModel(this._repository);

  late final login = Command1<Driver, ({String email, String password})>(
    (args) => _repository.login(args.email, args.password),
  );

  late final logout = Command0<Unit>(() => _repository.logout());
}
