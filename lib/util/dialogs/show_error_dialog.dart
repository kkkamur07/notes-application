import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:vandal_course/util/dialogs/show_generic_dialog.dart';

Future<void> showErrorDialog(
  BuildContext context,
  String text,
) {
  const String title = "An Error occurred";
  return showGenericDialog<void>(
    context: context,
    title: title,
    content: text,
    optionsBuilder: () => {
      'Ok': null,
    },
  );
}
