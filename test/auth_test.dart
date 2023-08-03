import "package:test/test.dart";
import "package:vandal_course/services/auth/auth_exceptions.dart";
import "package:vandal_course/services/auth/auth_provider.dart";
import "package:vandal_course/services/auth/auth_user.dart";

void main() {
  group('Mock Authentication', () {
    final provider = MockAuthProvider();
    test("Should Not initialized to begin with", () {
      expect(provider.isInitialized, false);
    });
    test("Cannot logout if not initialized", () {
      expect(
        provider.logOut(),
        throwsA(TypeMatcher<NotInitializedException>()),
      );
    });
    test("Should be able to initialized", () async {
      await provider.initialize();
      expect(provider.isInitialized, true);
    });

    test("User should be null", () {
      expect(provider.currentUser, null);
    });

    test(
      "should be able to initialize in < 2",
      () async {
        await provider.initialize();
        expect(provider.isInitialized, true);
      },
      timeout: const Timeout(
        Duration(seconds: 2),
      ),
    );

    test("Create user should delegate to login", () async {
      final badEmailUser = provider.createUser(
        Email: "foobar@bar.com",
        password: "12345678",
      );

      expect(
        badEmailUser,
        throwsA(TypeMatcher<UserNotFoundException>()),
      );

      final badPasswordUser =
          provider.createUser(Email: "any@email.com", password: "foobar");

      expect(badPasswordUser, throwsA(TypeMatcher<WrongPasswordException>()));

      final emailUser =
          await provider.createUser(Email: "foo", password: "bar");
      expect(provider.currentUser, emailUser);
      expect(emailUser.isEmailVerified, false);
    });

    test("Login user should be able to get verified", () async {
      provider.sendEmailVerification();
      final user = provider.currentUser;
      expect(user, isNotNull);
      expect(user!.isEmailVerified, true);
    });

    test("Should be able to logout and login", () async {
      await provider.logOut();
      await provider.logIn(Email: "food", password: "bar");
      final user = provider.currentUser;
      expect(user, isNotNull);
    });
  });
}

class NotInitializedException implements Exception {}

class MockAuthProvider implements AuthProvider {
  AuthUser? _user;
  var _isInitialized = false;
  bool get isInitialized => _isInitialized;

  @override
  Future<AuthUser> createUser(
      {required String Email, required String password}) async {
    if (!isInitialized) throw NotInitializedException();
    await Future.delayed(
      const Duration(seconds: 1),
    );
    return logIn(Email: Email, password: password);
  }

  @override
  AuthUser? get currentUser => _user;

  @override
  Future<void> initialize() async {
    await Future.delayed(Duration(seconds: 1));
    _isInitialized = true;
  }

  @override
  Future<AuthUser> logIn({required String Email, required String password}) {
    if (!isInitialized) throw NotInitializedException();
    // Creating some mock state
    if (Email == "foobar@bar.com") throw UserNotFoundException();
    if (password == "foobar") throw WrongPasswordException();
    AuthUser user = AuthUser(isEmailVerified: false, email: "foobar@bar.com");
    _user = user;
    //? If you want to return a future user value.
    return Future.value(user);
  }

  @override
  Future<void> logOut() async {
    if (!isInitialized) throw NotInitializedException();
    if (_user == null) throw UserNotFoundException();
    await Future.delayed(
      const Duration(seconds: 1),
    );

    //? To logout successfully we need to set the user to null
    _user = null;
  }

  @override
  Future<void> sendEmailVerification() async {
    if (!isInitialized) throw NotInitializedException();
    final user = _user;
    if (user == null) throw UserNotFoundException();
    //? So basically
    final newUser = AuthUser(isEmailVerified: true, email: "foobar@bar.com");
    _user = newUser;
  }
}
