// import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:vandal_course/services/auth/auth_service.dart';
import 'package:vandal_course/services/cloud/cloud_notes.dart';
import 'package:vandal_course/services/cloud/firebase_cloud_storage.dart';
// import 'package:vandal_course/services/crud/notes_service.dart';
import 'package:vandal_course/util/generics/get_arguments.dart';

class NewNotesView extends StatefulWidget {
  const NewNotesView({super.key});

  @override
  State<NewNotesView> createState() => _NewNotesViewState();
}

class _NewNotesViewState extends State<NewNotesView> {
  CloudNote? _note;
  late final FirebaseCloudStorage _notesService;
  late final TextEditingController _textNotes;

  @override
  void initState() {
    _notesService = FirebaseCloudStorage();
    _textNotes = TextEditingController();
    super.initState();
  }

  //This takes care of our views disposal.
  @override
  void dispose() {
    _deleteNoteIfTextIsEmpty();
    _saveNoteIfTextIsNotEmpty();
    _textNotes.dispose();
    super.dispose();
  }

  // Constantly update the text controller
  void _textEditingControllerUpdate() async {
    final note = _note;
    if (note == null) {
      return;
    }
    final text = _textNotes.text;
    await _notesService.updateNotes(documentID: note.documentId, text: text);
  }

  // Adding listeners to the text Editing Controller.

  void _setupTextEditingController() {
    _textNotes.removeListener(_textEditingControllerUpdate);
    _textNotes.addListener(_textEditingControllerUpdate);
  }

  Future<CloudNote> createOrGetExistingNote(BuildContext context) async {
    //So basically it sees if have the existing note.
    final widgetNote = context.getArgument<CloudNote>();

    if (widgetNote != null) {
      _note = widgetNote;
      _textNotes.text = widgetNote.text;
      return widgetNote;
    }

    final existingNote = _note;
    if (existingNote != null) {
      return existingNote;
    }

    final currentUser = AuthService.firebase().currentUser!;
    // final userEmail = currentUser.email;
    // final userOwner = await _notesService.getOrCreateUser(email: userEmail);
    final userID = currentUser.id;
    final newNote = await _notesService.createNewNotes(ownerID: userID);
    _note = newNote;
    return newNote;
  }

  void _deleteNoteIfTextIsEmpty() async {
    final notes = _note;
    if (_textNotes.text.isEmpty && notes != null) {
      await _notesService.deleteNotes(documentID: notes.documentId);
    }
  }

  void _saveNoteIfTextIsNotEmpty() async {
    final note = _note;
    final text = _textNotes.text;
    if (note != null && text.isNotEmpty) {
      await _notesService.updateNotes(documentID: note.documentId, text: text);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Create New Notes"),
      ),
      body: FutureBuilder(
        future: createOrGetExistingNote(context),
        builder: (context, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.done:
              //Widgets core section shouldn't change much.
              _setupTextEditingController();
              return TextField(
                controller: _textNotes,
                // To make the text field multi-line.
                keyboardType: TextInputType.multiline,
                // Infinite length of the lines.
                maxLines: null,
                decoration: const InputDecoration(
                  hintText: "Start typing your notes",
                ),
              );
            default:
              return const CircularProgressIndicator();
          }
        },
      ),
    );
  }
}
