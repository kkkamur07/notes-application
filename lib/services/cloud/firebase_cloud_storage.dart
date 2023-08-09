import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:vandal_course/services/cloud/cloud_notes.dart';
import 'package:vandal_course/services/cloud/cloud_storage_exceptions.dart';
import '../cloud/cloud_constants.dart' as col;

class FirebaseCloudStorage {
  final notes = FirebaseFirestore.instance.collection(col.notes);

  // D in CRUD
  Future<void> deleteNotes({required String documentID}) async {
    try {
      await notes.doc(documentID).delete();
    } catch (e) {
      throw CouldNotDeleteNotes();
    }
  }

  // U in CRUD
  Future<void> updateNotes(
      {required String documentID, required String text}) async {
    try {
      await notes.doc(documentID).update({col.textField: text});
    } catch (e) {
      throw CouldNotUpdateNotes();
    }
  }

  // Creating a Stream of the notes
  Stream<Iterable<CloudNote>> allNotes({required String ownerUserId}) =>
      notes.snapshots().map((value) => value.docs
          .map((doc) => CloudNote.fromSnapshot(doc))
          .where((notes) => notes.ownerUserId == ownerUserId));

  // R in CRUD
  Future<Iterable<CloudNote>> getNotes({required String ownerID}) async {
    try {
      Iterable<CloudNote> cloudNotes = await notes
          .where(col.ownerUserIdFieldName, isEqualTo: ownerID)
          .get()
          .then(
            (value) => value.docs.map(
              (notes) => CloudNote.fromSnapshot(notes),
            ),
          );
      return cloudNotes;
    } catch (e) {
      throw CouldNotGetNotes();
    }
  }

  //C in CRUD
  Future<CloudNote> createNewNotes(
      {required String ownerID, String text = ''}) async {
    try {
      final DocumentReference doc = await notes.add({
        col.ownerUserIdFieldName: ownerID,
        col.textField: text,
      });
      final fetchedNote = await doc.get();
      return CloudNote(
        documentId: fetchedNote.id,
        ownerUserId: ownerID,
        text: text,
      );
    } catch (e) {
      throw CouldNotCreateNotes();
    }
  }

  static final FirebaseCloudStorage _shared =
      FirebaseCloudStorage._sharedInstance();
  FirebaseCloudStorage._sharedInstance();
  factory FirebaseCloudStorage() => _shared;
}
