import 'package:flutter/material.dart';
import 'package:vandal_course/util/dialogs/show_generic_dialog.dart';

Future<void> cannotShowEmptyNoteDialog(BuildContext context) {
  return showGenericDialog(
    context: context,
    title: "Sharing",
    content: "Cannot share an empty note",
    optionsBuilder: () => {
      'Ok': null,
    },
  );
}
