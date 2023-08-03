import 'package:flutter/material.dart';
import 'package:vandal_course/services/auth/auth_service.dart';
import 'package:vandal_course/services/crud/notes_service.dart';

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

  void _setupTextEditingController() async {
    _textNotes.removeListener(_textEditingControllerUpdate);
    _textNotes.addListener(_textEditingControllerUpdate);
  }

  Future<DatabaseNotes> createNewNote() async {
    final existingNote = _note;
    if (existingNote != null) return existingNote;

    final currentUser = AuthService.firebase().currentUser!;
    final userEmail = currentUser.email!;
    final userOwner = await _notesService.getOrCreateUser(email: userEmail);
    return await _notesService.createNote(owner: userOwner);
  }

  void _deleteNoteIfTextIsEmpty() {
    final notes = _note;
    if (_textNotes.text.isEmpty && notes != null) {
      _notesService.deleteNote(id: notes.id);
    }
  }

  void _saveNoteIfTextIsNotEmpty() {
    final note = _note;
    final text = _textNotes.text;
    if (note != null && text.isNotEmpty) {
      _notesService.updateNotes(
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
        future: createNewNote(),
        builder: (context, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.done:
              // This is how we can get the data from the snapshot.
              _note = snapshot.data;
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
