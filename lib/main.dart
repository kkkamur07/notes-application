import "package:firebase_auth/firebase_auth.dart";
import "package:firebase_core/firebase_core.dart";
import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:vandal_course/view/login_view.dart";
import "package:vandal_course/view/register_view.dart";
import "firebase_options.dart";
import './view/verify_email.dart';
import "dart:developer" as developer show log;

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
            VerifyEmailView.route: (context) => VerifyEmailView(),
            RegisterView.route: (context) => RegisterView(),
            LoginView.route: (context) => LoginView(),
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
        future: Firebase.initializeApp(
          options: DefaultFirebaseOptions.currentPlatform,
        ),
        builder: (context, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.done:
              final user = FirebaseAuth.instance.currentUser;
              //? If the user is email verified?
              final emailVerified = user?.emailVerified ?? false;
              if (user != null) {
                if (emailVerified) {
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

enum MenuAction { logout }

class NotesView extends StatefulWidget {
  const NotesView({super.key});

  @override
  State<NotesView> createState() => _NotesViewState();
}

class _NotesViewState extends State<NotesView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Main UI"),
        actions: [
          PopupMenuButton<MenuAction>(
            itemBuilder: (context) {
              return [
                const PopupMenuItem(
                  value: MenuAction.logout,
                  child: Text("Logout"),
                ),
              ];
            },
            onSelected: (value) async {
              developer.log(value.toString());
              switch (value) {
                case MenuAction.logout:
                  final shouldLogout = await showLogoutDialogBox(context);
                  if (shouldLogout) {
                    //? We have to wait for the async operation - and return back to the login screen.
                    await FirebaseAuth.instance.signOut();
                    Navigator.of(context).pushNamedAndRemoveUntil(
                      LoginView.route,
                      (_) => false,
                    );
                  }
              }
            },
          ),
        ],
      ),
      body: Text("Main UI"),
    );
  }
}

Future<bool> showLogoutDialogBox(BuildContext context) {
  //? Show dialog box return a boolean value
  return showDialog<bool>(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: const Text("SignOut"),
        content: const Text("Are you sure you want to sign out?"),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(false);
            },
            child: Text("Cancel"),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(true);
            },
            child: Text("Logout"),
          )
        ],
      );
    },
    // So what whens when the future is completed.
  ).then((value) => value ?? false);
}
