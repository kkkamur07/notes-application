import '../auth/auth_user.dart';

//? Basically this class is about the things we can do with the provider.
abstract class AuthProvider {
  AuthUser? get currentUser;

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
