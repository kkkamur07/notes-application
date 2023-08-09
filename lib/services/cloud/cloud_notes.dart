import "package:cloud_firestore/cloud_firestore.dart";

import "../cloud/cloud_constants.dart" as col;

class CloudNote {
  final String documentId;
  final String ownerUserId;
  final String text;

  CloudNote({
    required this.documentId,
    required this.ownerUserId,
    required this.text,
  });

  // Creating the cloudNote from the snapshot.
  CloudNote.fromSnapshot(QueryDocumentSnapshot<Map<String, dynamic>> snapshot)
      : documentId = snapshot.id,
        ownerUserId = snapshot.data()[col.ownerUserIdFieldName],
        text = snapshot.data()[col.textField] as String;
}
