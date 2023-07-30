import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:vandal_course/constants/routes.dart";
import "package:vandal_course/services/auth/auth_service.dart";
import "package:vandal_course/view/login_view.dart";
import "package:vandal_course/view/notes_view.dart";
import "package:vandal_course/view/register_view.dart";
import './view/verify_email.dart';

void main() {
  // Ensure the widgets are binded first.
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations(
      [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]).then(
    (_) {
      runApp(
        MaterialApp(
          title: "NotesApplication",
          home: VandalLearn(),
          theme: ThemeData(),
          initialRoute: '/',
          routes: {
            verifyEmailRoute: (context) => VerifyEmailView(),
            registerRoute: (context) => RegisterView(),
            loginRoute: (context) => LoginView(),
            notesRoute: (context) => NotesView(),
          },
        ),
      );
    },
  );
}

class VandalLearn extends StatelessWidget {
  const VandalLearn({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: FutureBuilder(
        future: AuthService.firebase().initialize(),
        builder: (context, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.done:
              final user = AuthService.firebase().currentUser;
              if (user != null) {
                if (user.isEmailVerified) {
                  return NotesView();
                } else {
                  return VerifyEmailView();
                }
              } else {
                //? What to do when the user is not null?
                return LoginView();
              }
            default:
              return CircularProgressIndicator();
          }
        },
      ),
    );
  }
}
