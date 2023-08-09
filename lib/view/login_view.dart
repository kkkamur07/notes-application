import 'dart:developer' as developer show log;
import 'package:vandal_course/constants/routes.dart';
import 'package:vandal_course/services/auth/auth_exceptions.dart';
import 'package:vandal_course/services/auth/auth_service.dart';

import "../constants/log.dart" as log;

import 'package:flutter/material.dart';

import '../util/dialogs/show_error_dialog.dart';

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
    return SafeArea(
      child: Scaffold(
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
              decoration:
                  const InputDecoration(hintText: "Input your password"),
            ),
            TextButton(
              onPressed: () async {
                // This needs to be a future builder.

                String email = _email?.text ?? "";
                String password = _password?.text ?? "";
                try {
                  await AuthService.firebase().logIn(
                    Email: email,
                    password: password,
                  );
                  final user = AuthService.firebase().currentUser;
                  if (user?.isEmailVerified ?? false) {
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
                } on UserNotFoundException {
                  await showErrorDialog(
                    context,
                    "User Not Found",
                  );
                } on WrongPasswordException {
                  await showErrorDialog(
                    context,
                    "Wrong Passwordr",
                  );
                } on InvalidEmailException {
                  await showErrorDialog(
                    context,
                    "Invalid Email",
                  );
                } on GenericAuthExceptions {
                  await showErrorDialog(context, "Authentication Error");
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
      ),
    );
  }
}
