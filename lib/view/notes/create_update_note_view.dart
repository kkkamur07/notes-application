import 'package:flutter/material.dart';
import 'package:vandal_course/services/auth/auth_service.dart';
import 'package:vandal_course/services/crud/notes_service.dart';
import 'package:vandal_course/util/generics/get_arguments.dart';

class NewNotesView extends StatefulWidget {
  const NewNotesView({super.key});

  @override
  State<NewNotesView> createState() => _NewNotesViewState();
}

class _NewNotesViewState extends State<NewNotesView> {
  DatabaseNotes? _note;
  late final NotesService _notesService;
  late final TextEditingController _textNotes;

  @override
  void initState() {
    _notesService = NotesService();
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
    await _notesService.updateNotes(note: note, text: text);
  }

  // Adding listeners to the text Editing Controller.

  void _setupTextEditingController() {
    _textNotes.removeListener(_textEditingControllerUpdate);
    _textNotes.addListener(_textEditingControllerUpdate);
  }

  Future<DatabaseNotes> createOrGetExistingNote(BuildContext context) async {
    //So basically it sees if have the existing note.
    final widgetNote = context.getArgument<DatabaseNotes>();

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
    final userEmail = currentUser.email;
    final userOwner = await _notesService.getOrCreateUser(email: userEmail);
    final newNote = await _notesService.createNote(owner: userOwner);
    _note = newNote;
    return newNote;
  }

  void _deleteNoteIfTextIsEmpty() async {
    final notes = _note;
    if (_textNotes.text.isEmpty && notes != null) {
      await _notesService.deleteNote(id: notes.id);
    }
  }

  void _saveNoteIfTextIsNotEmpty() async {
    final note = _note;
    final text = _textNotes.text;
    if (note != null && text.isNotEmpty) {
      await _notesService.updateNotes(
        note: note,
        text: text,
      );
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
