import 'dart:developer' as developer show log;
import 'package:vandal_course/view/login_view.dart';

import "../constants/log.dart" as log;

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class RegisterView extends StatefulWidget {
  static String route = "/register/";
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
                final credential =
                    await FirebaseAuth.instance.createUserWithEmailAndPassword(
                  email: email,
                  password: password,
                );
                //? Logging the values
                developer.log(log.userSignedIn);
                developer.log(credential.toString());
              } on FirebaseAuthException catch (e) {
                if (e.code == 'weak-password') {
                  print('The password provided is too weak.');
                } else if (e.code == 'email-already-in-use') {
                  print('The account already exists for that email.');
                } else if (e.code == "invalid-email") {
                  print("Invalid-Email");
                }
              }
            },
            child: const Text("Register"),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pushNamedAndRemoveUntil(
                LoginView.route,
                (route) => false,
              );
            },
            child: const Text("Already Registered? Login here. "),
          ),
        ],
      ),
    );
    ;
  }
}
