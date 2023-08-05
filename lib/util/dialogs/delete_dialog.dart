import "package:flutter/material.dart";

import "../dialogs/show_generic_dialog.dart";

Future<bool> showDeleteDialog({
  required BuildContext context,
}) {
  const String deleteTitle = "Delete";
  const String deleteContent = "Are you sure you want to delete";
  return showGenericDialog<bool>(
    context: context,
    title: deleteTitle,
    content: deleteContent,
    optionsBuilder: () => {
      'Cancel': false,
      'Delete': true,
    },
  ).then(
    (value) => value ?? false,
  );
}
