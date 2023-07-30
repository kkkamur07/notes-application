import '../auth/auth_user.dart';

//? Basically the blueprint of what the provider should look like
abstract class AuthProvider {
  AuthUser? get currentUser;
  Future<void> initialize();

  Future<AuthUser?> logIn({
    required String Email,
    required String password,
  });

  Future<AuthUser> createUser({
    required String Email,
    required String password,
  });

  Future<void> logOut();
  Future<void> sendEmailVerification();
}
