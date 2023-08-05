import "package:flutter/material.dart";

import "../dialogs/show_generic_dialog.dart";

Future<bool> showLogoutDialogBox({
  required BuildContext context,
}) {
  const String errorTitle = "Log out";
  const String errorContent = "Are you sure you want to logout";
  return showGenericDialog<bool>(
    context: context,
    title: errorTitle,
    content: errorContent,
    optionsBuilder: () => {
      'Cancel': false,
      'Logout': true,
    },
  ).then(
    (value) => value ?? false,
  );
}
