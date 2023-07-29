import 'dart:developer' as developer show log;
import 'package:vandal_course/constants/routes.dart';
import 'package:vandal_course/util/show_error_dialogs.dart';
import "../constants/log.dart" as log;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

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
                await FirebaseAuth.instance.createUserWithEmailAndPassword(
                  email: email,
                  password: password,
                );
                //? Prompting the user to verify the email
                final user = FirebaseAuth.instance.currentUser;
                //? Sending the verification email before routing to the screen.
                await user?.sendEmailVerification();
                Navigator.of(context).pushNamedAndRemoveUntil(
                    verifyEmailRoute, (route) => false);
                //? Logging the values
                developer.log(log.userSignedIn);
              } on FirebaseAuthException catch (e) {
                if (e.code == 'weak-password') {
                  await showErrorDialog(
                    context,
                    'The password provided is too weak.',
                  );
                } else if (e.code == 'email-already-in-use') {
                  await showErrorDialog(
                    context,
                    'Email is already in use',
                  );
                } else if (e.code == "invalid-email") {
                  await showErrorDialog(
                    context,
                    'Invalid Email ',
                  );
                } else {
                  await showErrorDialog(
                    context,
                    "Error : ${e.code}",
                  );
                }
                //? Catches anyOther exception that is not firebase exception.
              } catch (e) {
                await showErrorDialog(
                  context,
                  "Error : $e",
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
    );
  }
}
