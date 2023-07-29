import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:vandal_course/constants/routes.dart';

class VerifyEmailView extends StatefulWidget {
  const VerifyEmailView({super.key});

  @override
  State<VerifyEmailView> createState() => _VerifyEmailViewState();
}

class _VerifyEmailViewState extends State<VerifyEmailView> {
  final user = FirebaseAuth.instance;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          const Text(
              "We've sent a verification email, please verify your email"),
          const Text(
              "If you haven't received the verification email, please click on the button below"),
          MaterialButton(
            onPressed: () async {
              //? To send the verification email
              await user.currentUser?.sendEmailVerification();
            },
            child: const Text("Send Email verification."),
          ),
          MaterialButton(
            onPressed: () async {
              await user.signOut();
              Navigator.of(context).pushNamedAndRemoveUntil(
                registerRoute,
                (route) => false,
              );
            },
            child: const Text("Restart"),
          )
        ],
      ),
    );
  }
}
