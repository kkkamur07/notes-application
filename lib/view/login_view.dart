import 'dart:developer' as developer show log;
import 'package:vandal_course/constants/routes.dart';

import "../constants/log.dart" as log;

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../util/show_error_dialogs.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  TextEditingController? _email;

  TextEditingController? _password;

  @override
  void initState() {
    super.initState();
    _email = TextEditingController();
    _password = TextEditingController();
  }

  @override
  void dispose() {
    super.dispose();
    _email?.dispose();
    _password?.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          TextField(
            controller: _email,
            enableSuggestions: true,
            autocorrect: false,
            decoration: const InputDecoration(hintText: "Enter your Email"),
            keyboardType: TextInputType.emailAddress,
          ),
          TextField(
            controller: _password,
            obscureText: true,
            enableSuggestions: false,
            autocorrect: false,
            keyboardType: TextInputType.visiblePassword,
            decoration: const InputDecoration(hintText: "Input your password"),
          ),
          TextButton(
            onPressed: () async {
              // This needs to be a future builder.

              String email = _email?.text ?? "";
              String password = _password?.text ?? "";
              try {
                await FirebaseAuth.instance.signInWithEmailAndPassword(
                  email: email,
                  password: password,
                );
                final user = FirebaseAuth.instance.currentUser;
                final emailVerified = user?.emailVerified ?? false;
                if (emailVerified) {
                  Navigator.of(context).pushNamedAndRemoveUntil(
                    notesRoute,
                    (route) => false,
                  );
                } else {
                  Navigator.of(context).pushNamedAndRemoveUntil(
                    verifyEmailRoute,
                    (route) => false,
                  );
                }
                developer.log(log.userLogIn);
                //? Your Error handling have to be robust.
              } on FirebaseAuthException catch (e) {
                //? Add logging here.
                if (e.code == 'user-not-found') {
                  await showErrorDialog(
                    context,
                    "User Not Found",
                  );
                } else if (e.code == 'wrong-password') {
                  await showErrorDialog(
                    context,
                    "Wrong Passwordr",
                  );
                } else if (e.code == "invalid-email") {
                  await showErrorDialog(
                    context,
                    "Invalid Email",
                  );
                } else {
                  await showErrorDialog(
                    context,
                    "Error ${e.code}",
                  );
                }
                //? You can use catch to catch other errors.
              } catch (e) {
                await showErrorDialog(
                  context,
                  e.toString(),
                );
              }
            },
            child: const Text("Login"),
          ),
          //? The link between login view and register view.
          TextButton(
            child: const Text("Not registered Yet? Register Here"),
            onPressed: () {
              //? This will cause an error in because it doesn't have any scaffold.
              Navigator.of(context).pushNamedAndRemoveUntil(
                registerRoute,
                (route) => false,
              );
            },
          ),
        ],
      ),
    );
  }
}
