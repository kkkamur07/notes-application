import 'dart:developer' as developer show log;
import 'package:vandal_course/constants/routes.dart';
import 'package:vandal_course/services/auth/auth_exceptions.dart';
import 'package:vandal_course/services/auth/auth_service.dart';
import "../constants/log.dart" as log;
import 'package:flutter/material.dart';

import '../util/dialogs/show_error_dialog.dart';

class RegisterView extends StatefulWidget {
  const RegisterView({super.key});

  @override
  State<RegisterView> createState() => _RegisterViewState();
}

class _RegisterViewState extends State<RegisterView> {
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
                  await AuthService.firebase().createUser(
                    Email: email,
                    password: password,
                  );
                  //? To send the verification Email
                  await AuthService.firebase().sendEmailVerification();

                  Navigator.of(context).pushNamedAndRemoveUntil(
                      verifyEmailRoute, (route) => false);

                  developer.log(log.userSignedIn);
                } on WeakPasswordException {
                  await showErrorDialog(
                    context,
                    'The password provided is too weak.',
                  );
                } on EmailAlreadyInUseException {
                  await showErrorDialog(
                    context,
                    'Email is already in use',
                  );
                } on InvalidEmailException {
                  await showErrorDialog(
                    context,
                    'Invalid Email',
                  );
                } on GenericAuthExceptions {
                  await showErrorDialog(
                    context,
                    "Authentication Error",
                  );
                }
              },
              child: const Text("Register"),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pushNamedAndRemoveUntil(
                  loginRoute,
                  (route) => false,
                );
              },
              child: const Text("Already Registered? Login here. "),
            ),
          ],
        ),
      ),
    );
  }
}
