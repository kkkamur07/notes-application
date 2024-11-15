import "package:firebase_auth/firebase_auth.dart" show User;
import "package:flutter/material.dart";

//? How do we define a user.
@immutable
class AuthUser {
  final String id;
  final bool isEmailVerified;
  final String email;
  AuthUser({
    required this.id,
    required this.isEmailVerified,
    required this.email,
  });

  //? We kind of copied the firebase user to our own.
  factory AuthUser.fromFirebase(User user) => AuthUser(
        id: user.uid,
        isEmailVerified: user.emailVerified,
        email: user.email!,
      );
}
