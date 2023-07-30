import "package:firebase_auth/firebase_auth.dart" show User;
import "package:flutter/material.dart";

//? How do we define a user.
@immutable
class AuthUser {
  final bool isEmailVerified;
  AuthUser(this.isEmailVerified);

  //? We kind of copied the firebase user to our own.
  factory AuthUser.fromFirebase(User user) => AuthUser(user.emailVerified);
}
