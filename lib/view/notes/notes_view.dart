import 'package:flutter/material.dart';
import 'package:vandal_course/constants/routes.dart';
import 'package:vandal_course/services/auth/auth_service.dart';
import 'package:vandal_course/services/crud/notes_service.dart';
import "dart:developer" as developer show log;
import '../../enums/menu_action.dart';

class NotesView extends StatefulWidget {
  const NotesView({super.key});

  @override
  State<NotesView> createState() => _NotesViewState();
}

class _NotesViewState extends State<NotesView> {
  late final NotesService _notesService;
  String userEmail = AuthService.firebase().currentUser!.email!;

  @override
  void initState() {
    _notesService = NotesService();
    //If you open the database
    _notesService.open();
    super.initState();
  }

  @override
  void dispose() {
    //Then close your database
    _notesService.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).pushNamed(newNotesRoute);
        },
        child: const Icon(
          Icons.add,
        ),
      ),
      appBar: AppBar(
        title: const Text("Your Notes"),
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
                    await AuthService.firebase().logOut();
                    Navigator.of(context).pushNamedAndRemoveUntil(
                      loginRoute,
                      (_) => false,
                    );
                  }
              }
            },
          ),
        ],
      ),
      body: FutureBuilder(
        future: _notesService.getOrCreateUser(email: userEmail),
        builder: (context, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.done:
              return StreamBuilder(
                stream: _notesService.allNotes,
                builder: (context, snapshot) {
                  switch (snapshot.connectionState) {
                    // We need to use the waiting because stream will be ongoing unlike future.
                    case ConnectionState.waiting:
                      return const Text("Notes will appear here");
                    case ConnectionState.active:
                      return const Text("Finally notes coming");
                    default:
                      return const CircularProgressIndicator();
                  }
                },
              );
            default:
              return const CircularProgressIndicator();
          }
        },
      ),
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
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(true);
            },
            child: const Text("Logout"),
          )
        ],
      );
    },
    // So what whens when the future is completed.
  ).then((value) => value ?? false);
}
