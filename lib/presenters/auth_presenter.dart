import '../models/auth_model.dart';

class AuthPresenter {
  final AuthModel _authModel = AuthModel();

  Future<String?> login(String email, String password) {
    return _authModel.login(email, password);
  }

  Future<String?> signUp(String email, String password) {
    return _authModel.signUp(email, password);
  }

  Future<void> logout() {
    return _authModel.logout();
  }

  Stream authStateChanges() {
    return _authModel.authStateChanges();
  }

  String? get currentUserEmail {
    return _authModel.currentUser?.email;
  }
}