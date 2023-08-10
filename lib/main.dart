import "package:bloc/bloc.dart";
import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:flutter_bloc/flutter_bloc.dart";
import "package:path/path.dart";
import "package:vandal_course/constants/routes.dart";
import "package:vandal_course/services/auth/auth_service.dart";
import "package:vandal_course/view/login_view.dart";
import 'package:vandal_course/view/notes/create_update_note_view.dart';
import 'package:vandal_course/view/notes/notes_view.dart';
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
          home: HomePage(),
          theme: ThemeData(),
          initialRoute: '/',
          routes: {
            verifyEmailRoute: (context) => const VerifyEmailView(),
            registerRoute: (context) => const RegisterView(),
            loginRoute: (context) => const LoginView(),
            notesRoute: (context) => const NotesView(),
            newNotesRoute: (context) => const NewNotesView(),
          },
        ),
      );
    },
  );
}

// class VandalLearn extends StatelessWidget {
//   const VandalLearn({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return SafeArea(
//       child: FutureBuilder(
//         future: AuthService.firebase().initialize(),
//         builder: (context, snapshot) {
//           switch (snapshot.connectionState) {
//             case ConnectionState.done:
//               final user = AuthService.firebase().currentUser;
//               if (user != null) {
//                 if (user.isEmailVerified) {
//                   return NotesView();
//                 } else {
//                   return VerifyEmailView();
//                 }
//               } else {
//                 //? What to do when the user is not null?
//                 return LoginView();
//               }
//             default:
//               return CircularProgressIndicator();
//           }
//         },
//       ),
//     );
//   }
// }

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late final TextEditingController _controller;

  @override
  void initState() {
    _controller = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    _controller = TextEditingController();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) {
        return CounterBloc();
      },
      child: Scaffold(
          appBar: AppBar(
            title: Text("Yo"),
          ),
          body: BlocConsumer<CounterBloc, CounterClass>(
            listener: (context, state) {
              _controller.clear();
            },
            builder: (context, state) {
              final invalidValue =
                  (state is CounterClassInvalid) ? state.invalidValue : "";
              return Column(
                children: [
                  Text("Current value is ${state.value}"),
                  //Visible based on some-conditions.
                  Visibility(
                    visible: state is! CounterClassValid,
                    child: Text("Invalid Input $invalidValue"),
                  ),
                  TextField(
                    controller: _controller,
                    decoration:
                        const InputDecoration(hintText: "Enter a number here"),
                    keyboardType: TextInputType.number,
                  ),
                  Row(
                    children: [
                      TextButton(
                        onPressed: () {
                          context
                              .read<CounterBloc>()
                              .add(IncrementEvent(_controller.text));
                        },
                        child: const Text("Incremement"),
                      ),
                      TextButton(
                        onPressed: () {
                          context.read<CounterBloc>().add(
                                DecrementEvent(_controller.text),
                              );
                        },
                        child: const Text("Decrement"),
                      ),
                    ],
                  ),
                ],
              );
            },
          )),
    );
  }
}

//What we expect from your bloc is simple integer.
@immutable
abstract class CounterClass {
  final int value;
  const CounterClass({required this.value});
}

// These are the states.
// We have to have state into - valid and invalid state.
class CounterClassValid extends CounterClass {
  const CounterClassValid(int value) : super(value: value);
}

class CounterClassInvalid extends CounterClass {
  // On this invalid value we will give out this class.
  final String invalidValue;
  const CounterClassInvalid({
    required this.invalidValue,
    required int previousValue,
  }) : super(value: previousValue);
}

// Define an event.
abstract class CounterEvent {
  final String value;
  const CounterEvent(this.value);
}

//These are the types of event.
class IncrementEvent extends CounterEvent {
  const IncrementEvent(String value) : super(value);
}

class DecrementEvent extends CounterEvent {
  const DecrementEvent(String value) : super(value);
}

// Defining bloc - it takes the event and state
class CounterBloc extends Bloc<CounterEvent, CounterClass> {
  // Defining our initial class.
  CounterBloc() : super(const CounterClassValid(0)) {
    on<IncrementEvent>(
      //Two things it gives your the event and the emitted value.
      (event, emit) {
        final integer = int.tryParse(event.value);
        if (integer == null) {
          // So emit a value and the state.
          emit(CounterClassInvalid(
            invalidValue: event.value,
            previousValue: state.value,
          ));
        } else {
          emit(
            CounterClassValid(state.value + integer),
          );
        }
      },
    );
    // What to do on decrement event
    on<DecrementEvent>(
      (event, emit) {
        final integer = int.tryParse(event.value);
        if (integer == null) {
          emit(
            CounterClassInvalid(
              invalidValue: event.value,
              // You have access to the current state.
              previousValue: state.value,
            ),
          );
        } else {
          //What to do when this scenario happens
          emit(
            CounterClassValid(state.value - integer),
          );
        }
      },
    );
  }
}
