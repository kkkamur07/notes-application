import "../auth/auth_provider.dart";
import "../auth/auth_user.dart";

//? It is just a pseudo layer.
class AuthService implements AuthProvider {
  final AuthProvider provider;

  const AuthService(this.provider);

  @override
  Future<AuthUser> createUser({
    required String Email,
    required String password,
  }) =>
      provider.createUser(
        Email: Email,
        password: password,
      );

  @override
  AuthUser? get currentUser => provider.currentUser;

  @override
  Future<AuthUser?> logIn({
    required String Email,
    required String password,
  }) =>
      provider.logIn(
        Email: Email,
        password: password,
      );

  @override
  Future<void> logOut() => provider.logOut();

  @override
  Future<void> sendEmailVerification() => provider.sendEmailVerification();
}
