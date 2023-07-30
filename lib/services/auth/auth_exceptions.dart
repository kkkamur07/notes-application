//? Login Exceptions
class UserNotFoundException implements Exception {}

class WrongPasswordException implements Exception {}

//? Register Exceptions
class WeakPasswordException implements Exception {}

class EmailAlreadyInUseException implements Exception {}

class InvalidEmailException implements Exception {}

//? Generic exceptions

class GenericAuthExceptions implements Exception {}

class UserNotLoggedInAuthException implements Exception {}
