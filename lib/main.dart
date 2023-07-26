import "package:firebase_auth/firebase_auth.dart";
import "package:firebase_core/firebase_core.dart";
import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:vandal_course/view/login_view.dart";
import "firebase_options.dart";

void main() {
  // Ensure the widgets are binded first.
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations(
      [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]).then(
    (_) {
      runApp(
        MaterialApp(
          title: "FirebaseLearn",
          home: VandalLearn(),
          theme: ThemeData(),
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
      child: Scaffold(
        //! This future builder holds the logic

        body: FutureBuilder(
          future: Firebase.initializeApp(
            options: DefaultFirebaseOptions.currentPlatform,
          ),
          builder: (context, snapshot) {
            switch (snapshot.connectionState) {
              case ConnectionState.done:
                final user = FirebaseAuth.instance.currentUser;
                //? If the user is email verified?
                final emailVerified = user?.emailVerified ?? false;
                if (emailVerified) {
                  print("Verified");
                } else {
                  print("Not-Verified");
                }
                return LoginView();
              default:
                return CircularProgressIndicator();
            }
          },
        ),
      ),
    );
  }
}
